# ./seaseq_cli.py
"""
Sea-Seq Validation CLI
Dependencies (install as needed):
  pip install questionary rich PyPDF2 python-dotenv requests

Optional:
  pip install pdfminer.six  # if you prefer higher-fidelity PDF text extraction

Run:
  python seaseq_cli.py --input /path/to/issues.csv --api-url https://seaseq.internal/api --api-key $SEA_SEQ_KEY
"""

from __future__ import annotations

import argparse
import csv
import ipaddress
import json
import os
import re
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

# Soft deps
try:
    import questionary  # for CLI drop-downs
except Exception:
    questionary = None  # fallback to numeric prompt

try:
    from PyPDF2 import PdfReader
except Exception:
    PdfReader = None

try:
    import requests
except Exception:
    requests = None

from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich import box

console = Console()

IP_REGEX = re.compile(r"\b(?:(?:25[0-5]|2[0-4]\d|1?\d{1,2})\.){3}(?:25[0-5]|2[0-4]\d|1?\d{1,2})\b")
# Basic domain: lenient on TLD to catch gov lists; restricts invalid chars
DOMAIN_REGEX = re.compile(r"\b(?=.{1,253}\b)(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,63}\b")

###############################################################################
# Input loading (CSV / PDF)
###############################################################################

def read_csv_targets(path: str) -> Tuple[List[str], List[str]]:
    ips, domains = [], []
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = list(reader) if reader.fieldnames else []
        if not rows and not reader.fieldnames:
            # No headers: try simple CSV
            f.seek(0)
            simple_reader = csv.reader(f)
            for row in simple_reader:
                for cell in row:
                    _collect_targets_from_text(cell, ips, domains)
            return ips, domains

    with open(path, newline="", encoding="utf-8") as f:
        # Re-read generically to scan every cell
        reader_any = csv.reader(f)
        for row in reader_any:
            for cell in row:
                _collect_targets_from_text(cell, ips, domains)
    return ips, domains


def read_pdf_targets(path: str) -> Tuple[List[str], List[str]]:
    if PdfReader is None:
        raise RuntimeError("PyPDF2 not installed. Run: pip install PyPDF2")
    reader = PdfReader(path)
    ips, domains = [], []
    for page in reader.pages:
        try:
            text = page.extract_text() or ""
        except Exception:
            text = ""
        _collect_targets_from_text(text, ips, domains)
    return ips, domains


def _collect_targets_from_text(text: str, ips: List[str], domains: List[str]) -> None:
    for m in IP_REGEX.findall(text or ""):
        ips.append(m.strip())
    for m in DOMAIN_REGEX.findall(text or ""):
        domains.append(m.strip().lower())


def load_targets(path: str) -> Tuple[List[str], List[str]]:
    if not os.path.exists(path):
        raise FileNotFoundError(f"Input not found: {path}")
    ext = os.path.splitext(path)[1].lower()
    if ext == ".csv":
        ips, domains = read_csv_targets(path)
    elif ext == ".pdf":
        ips, domains = read_pdf_targets(path)
    else:
        raise ValueError("Unsupported input type. Use CSV or PDF.")
    return _dedupe_valid_ips(ips), _dedupe_domains(domains)


def _dedupe_valid_ips(ips: Iterable[str]) -> List[str]:
    seen = set()
    out = []
    for ip in ips:
        try:
            ipaddress.ip_address(ip)
        except ValueError:
            continue
        if ip not in seen:
            seen.add(ip)
            out.append(ip)
    return out


def _dedupe_domains(domains: Iterable[str]) -> List[str]:
    seen = set()
    out = []
    for d in domains:
        if d not in seen:
            seen.add(d)
            out.append(d)
    return out


###############################################################################
# Sea-Seq client (wire these methods to your Sea-Seq deployment)
###############################################################################

class SeaSeqClient:
    """
    Minimal client stub. Replace URLs and payloads to match Sea-Seq API.
    """

    def __init__(self, api_url: Optional[str] = None, api_key: Optional[str] = None, timeout: int = 15):
        self.api_url = api_url or os.getenv("SEA_SEQ_API_URL", "").rstrip("/")
        self.api_key = api_key or os.getenv("SEA_SEQ_API_KEY", "")
        self.timeout = timeout
        self._lock = threading.Lock()

    def _session(self):
        if requests is None:
            raise RuntimeError("requests not installed. Run: pip install requests")
        s = requests.Session()
        if self.api_key:
            s.headers["Authorization"] = f"Bearer {self.api_key}"
        s.headers["User-Agent"] = "SeaSeqCLI/1.0"
        return s

    def list_targets(self) -> List[str]:
        # Replace with real endpoint
        if not self.api_url:
            return []
        url = f"{self.api_url}/targets"
        try:
            with self._session() as s:
                r = s.get(url, timeout=self.timeout)
                r.raise_for_status()
                data = r.json()
        except Exception:
            return []
        # Expecting list of IPs
        targets = [t for t in data if isinstance(t, str)]
        return _dedupe_valid_ips(targets)

    def list_websites(self, ip: str) -> List[str]:
        # Replace with real endpoint
        if not self.api_url:
            return []
        url = f"{self.api_url}/targets/{ip}/websites"
        try:
            with self._session() as s:
                r = s.get(url, timeout=self.timeout)
                r.raise_for_status()
                data = r.json()
        except Exception:
            return []
        # Expecting domains/hosts
        sites = [d for d in data if isinstance(d, str)]
        return _dedupe_domains(sites)

    def run_test(self, test_name: str, target: "ValidationTarget") -> Tuple[bool, str]:
        # Replace with real Sea-Seq “test execution” endpoint if it exists.
        # Fallback: local test registry to simulate behavior.
        func = TEST_REGISTRY.get(test_name)
        if not func:
            return False, f"Unknown test: {test_name}"
        return func(target)


###############################################################################
# Validation targets & test registry
###############################################################################

@dataclass(frozen=True)
class ValidationTarget:
    ip: str
    website: Optional[str] = None  # host/sni/url as needed


# Tests must be of type: Callable[[ValidationTarget], Tuple[bool, str]]
TEST_REGISTRY: Dict[str, Callable[[ValidationTarget], Tuple[bool, str]]] = {}


def register_test(name: str):
    def deco(func: Callable[[ValidationTarget], Tuple[bool, str]]):
        TEST_REGISTRY[name] = func
        return func
    return deco


# --- Example tests (replace/extend to mirror Sea-Seq's actual suite) ---

@register_test("dns_resolves")
def test_dns_resolves(target: ValidationTarget) -> Tuple[bool, str]:
    import socket
    host = target.website or target.ip
    try:
        socket.getaddrinfo(host, 80)
        return True, f"Resolved {host}"
    except Exception as e:
        return False, f"DNS failed for {host}: {e}"

@register_test("http_reachable")
def test_http_reachable(target: ValidationTarget) -> Tuple[bool, str]:
    if requests is None:
        return False, "requests not installed"
    url = f"http://{target.website or target.ip}"
    try:
        r = requests.get(url, timeout=6)
        ok = 200 <= r.status_code < 400
        return ok, f"HTTP {r.status_code} for {url}"
    except Exception as e:
        return False, f"HTTP error for {url}: {e}"

@register_test("tls_validity")
def test_tls_validity(target: ValidationTarget) -> Tuple[bool, str]:
    import ssl, socket
    host = target.website or target.ip
    ctx = ssl.create_default_context()
    try:
        with socket.create_connection((host, 443), timeout=6) as sock:
            with ctx.wrap_socket(sock, server_hostname=host if not _is_ip(host) else None) as ssock:
                cert = ssock.getpeercert()
                subject = dict(x[0] for x in cert.get("subject", []))
                cn = subject.get("commonName", "<none>")
                return True, f"TLS ok; CN={cn}"
    except Exception as e:
        return False, f"TLS error: {e}"

@register_test("port_scan_top")
def test_port_scan_top(target: ValidationTarget) -> Tuple[bool, str]:
    import socket
    host = target.website or target.ip
    open_ports = []
    for port in (22, 80, 443, 3389, 445):
        try:
            with socket.create_connection((host, port), timeout=0.5):
                open_ports.append(port)
        except Exception:
            pass
    return (True, f"Open: {open_ports}") if open_ports else (True, "No common ports open")

@register_test("seaseq_policy")
def test_seaseq_policy(target: ValidationTarget) -> Tuple[bool, str]:
    # Placeholder for Sea-Seq policy suite integration.
    return True, "Policy checks placeholder (wire to Sea-Seq)"


def _is_ip(s: str) -> bool:
    try:
        ipaddress.ip_address(s)
        return True
    except Exception:
        return False


###############################################################################
# Selector UI (drop-downs)
###############################################################################

def select_from_list(title: str, choices: Sequence[str]) -> Optional[str]:
    if not choices:
        return None
    if questionary:
        return questionary.select(title, choices=list(choices)).ask()
    # Fallback numeric
    console.print(Panel.fit(title, style="bold - seaseq_cli.py:303"))
    for i, c in enumerate(choices, 1):
        console.print(f"[{i}] {c} - seaseq_cli.py:305")
    while True:
        sel = input("Choose #: ").strip()
        if sel.isdigit() and 1 <= int(sel) <= len(choices):
            return choices[int(sel) - 1]
        console.print("[red]Invalid selection[/red] - seaseq_cli.py:310")


###############################################################################
# Runner
###############################################################################

@dataclass
class TestResult:
    name: str
    ok: bool
    message: str
    duration_s: float


def run_tests(client: SeaSeqClient, target: ValidationTarget, tests: Sequence[str]) -> List[TestResult]:
    results: List[TestResult] = []
    start = time.time()
    futures = {}
    with ThreadPoolExecutor(max_workers=min(8, len(tests) or 1)) as ex:
        for tname in tests:
            futures[ex.submit(_run_one, client, tname, target)] = tname
        for fut in as_completed(futures):
            name, ok, msg, dur = fut.result()
            results.append(TestResult(name=name, ok=ok, message=msg, duration_s=dur))
    results.sort(key=lambda r: r.name)
    total = time.time() - start
    console.print(Panel(f"Completed {len(results)} tests in {total:.2f}s - seaseq_cli.py:337", style="dim"))
    return results


def _run_one(client: SeaSeqClient, test_name: str, target: ValidationTarget) -> Tuple[str, bool, str, float]:
    t0 = time.time()
    ok, msg = client.run_test(test_name, target)
    return test_name, ok, msg, time.time() - t0


def print_report(results: List[TestResult]) -> None:
    table = Table(title="Sea-Seq Validation Report", box=box.SIMPLE_HEAVY)
    table.add_column("Test", style="bold")
    table.add_column("Status")
    table.add_column("Message")
    table.add_column("Time (s)", justify="right")
    for r in results:
        status = "[green]PASS[/green]" if r.ok else "[red]FAIL[/red]"
        table.add_row(r.name, status, r.message, f"{r.duration_s:.2f}")
    console.print(table)


def save_json(path: str, ip: str, website: Optional[str], results: List[TestResult]) -> None:
    payload = {
        "ip": ip,
        "website": website,
        "results": [
            {"test": r.name, "ok": r.ok, "message": r.message, "duration_s": r.duration_s}
            for r in results
        ],
    }
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)


###############################################################################
# CLI
###############################################################################

def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Sea-Seq Security Validation CLI")
    p.add_argument("--input", "-i", required=True, help="CSV or PDF with gov issues (IPs/domains inside)")
    p.add_argument("--api-url", help="Sea-Seq API base URL")
    p.add_argument("--api-key", help="Sea-Seq API key (or env SEA_SEQ_API_KEY)")
    p.add_argument("--json", help="Write JSON report to this path")
    p.add_argument("--tests", nargs="*", default=[], help="Subset of tests to run (default: all)")
    return p.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)

    try:
        file_ips, file_domains = load_targets(args.input)
    except Exception as e:
        console.print(f"[red]Input error:[/red] {e} - seaseq_cli.py:392")
        return 2

    client = SeaSeqClient(api_url=args.api_url, api_key=args.api_key)
    seaseq_ips = client.list_targets()
    merged_ips = _dedupe_valid_ips([*file_ips, *seaseq_ips])

    if not merged_ips and not file_domains:
        console.print("[yellow]No targets found in file or SeaSeq.[/yellow] - seaseq_cli.py:400")
        return 1

    chosen_ip = select_from_list("Select an IP target", merged_ips) if merged_ips else None
    if not chosen_ip:
        console.print("[yellow]No IP selected; attempting domainonly workflow.[/yellow] - seaseq_cli.py:405")

    candidate_sites: List[str] = []
    if chosen_ip:
        candidate_sites.extend(client.list_websites(chosen_ip))
    candidate_sites.extend(file_domains)
    candidate_sites = _dedupe_domains(candidate_sites)

    chosen_site = select_from_list("Select a website/host (optional)", ["<none>"] + candidate_sites) if candidate_sites else "<none>"
    if chosen_site == "<none>":
        chosen_site = None

    if not chosen_ip and not chosen_site:
        console.print("[red]You must select at least an IP or a website.[/red] - seaseq_cli.py:418")
        return 1

    target = ValidationTarget(ip=chosen_ip or "0.0.0.0", website=chosen_site)
    available_tests = sorted(TEST_REGISTRY.keys())
    selected_tests = args.tests or available_tests

    console.print(Panel.fit(
        f"Target IP: {target.ip}\nWebsite: {target.website or '-'}\nTests: {', '.join(selected_tests)}",
        title="Run Summary",
        style="bold",
    ))

    results = run_tests(client, target, selected_tests)
    print_report(results)

    if args.json:
        try:
            save_json(args.json, target.ip, target.website, results)
            console.print(f"[green]Saved JSON report:[/green] {args.json} - seaseq_cli.py:437")
        except Exception as e:
            console.print(f"[red]Failed to write JSON:[/red] {e} - seaseq_cli.py:439")
            return 3

    return 0