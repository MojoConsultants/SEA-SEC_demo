**Big idea:** This tool looks at a website like a careful guard.  
It takes notes about what it sees, learns what “normal” looks like, and points out things that seem risky.

## The three helpers (services)

1. **Data Service — The Note Taker**
   - Visits a website page by page.
   - Writes down simple facts: page address, links it finds, forms (places you can type), and basic safety signs (like if the page uses HTTPS).
   - Saves these notes as **events** (little records).

2. **Learning Service — The Student**
   - Reads many events to learn normal patterns.
   - Uses a simple math model to spot **weird** events (outliers).
   - The more it sees, the smarter it gets.

3. **Reporting Service — The Storyteller**
   - Takes the events and the model’s “weirdness” scores.
   - Makes clear reports with traffic‑light colors (green/yellow/red).
   - You can read the report in a web page (HTML) or open it in a spreadsheet (CSV).

## Changing the website
You can point the tool at any public website.  
Just call **/set_site** with the new address or set `TARGET_SITE_URL` before you run it.

## A simple trip
1. **/ingest/run** — The Note Taker crawls the site and saves events.
2. **/learn/train** — The Student learns from those events.
3. **/report/generate** — The Storyteller makes reports you can read.

That’s it! Three steps: **collect, learn, report**.

## How to run SEA-SEC Demo Program
#source .venv/bin/activate
#pip install -r requirements.txt
#export TARGET_SITE_URL="https://mlbam-park.b12sites.com/"
#uvicorn app:app --reload --port 8000
---

# 🚀 Sea-Seq CLI — Quick Start Guide

The **Sea-Seq Validation CLI** helps you validate and upload issue reports to the Sea-Seq API.

---

## 📦 Requirements

* macOS / Linux / Windows (with Python 3.8+)
* Python 3
* `pip3` for installing dependencies

---

## 🔧 Installation

1. **Clone this repo** or download the release ZIP.

   ```bash
   git clone https://github.com/YOUR_ORG/SEA-SEQ_demo.git
   cd SEA-SEQ_demo
   ```

2. **Install dependencies**

   ```bash
   pip3 install -r requirements.txt
   ```

3. **Make the CLI executable (macOS/Linux only)**

   ```bash
   chmod +x seaseq_cli.py
   ```

---

## 🚀 Usage

### Option 1: Run directly with Python

```bash
python3 seaseq_cli.py --input ./reports/issues.csv --api-url https://seaseq.internal/api --api-key YOUR_API_KEY
```

### Option 2: Run as an executable

```bash
./seaseq_cli.py --input ./reports/issues.csv --api-url https://seaseq.internal/api --api-key YOUR_API_KEY
```

---

## 📌 Arguments

| Option      | Description                            | Required |
| ----------- | -------------------------------------- | -------- |
| `--input`   | Path to input file (.csv, .json, .pdf) | ✅        |
| `--api-url` | Sea-Seq API endpoint URL               | ✅        |
| `--api-key` | API key for authentication             | ✅        |
| `--export`  | Optional: Export parsed issues to JSON | ❌        |

---

## 🖥️ Interactive Mode

If you run the CLI with no arguments, it will prompt you step-by-step:

```bash
./seaseq_cli.py
```

---

## 📂 Additional Documentation

This repository includes several **detailed user guides** in the [`Userguides/`](Userguides) folder:

* **Quick Start** — how to get up and running
* **Usage** — advanced options and file formats
* **Examples** — demo files (`.csv`, `.json`, `.pdf`) you can try immediately
* **Runbook** — operational best practices

👉 Check the **Userguides folder** if you want more in-depth walkthroughs, examples, or troubleshooting help.

---

## ✅ Example

```bash
./seaseq_cli.py \
  --input ./demo/issues.json \
  --api-url https://seaseq.internal/api \
  --api-key abc123XYZ \
  --export parsed.json
######CLI vs API vs Runne#####```

👉 You need to choose which mode you want as default.

Option A — Default = Runner

If you want Docker to auto-generate a report when launched:

CMD ["python", "runner.py"]

Option B — Default = API (likely safer)

If you want the API as the default (current state), but sometimes run runner:

docker run --rm myimage python runner.py
---
## ✅ Test Reports rendering 

execute the following 

python3 test_render.py
🔹 How to use all three modes
🔹 Usage examples
#####################################
API (default)

docker run -d -p 8000:8000 sea-seq:latest


Run CLI via runner_cli.py

docker run --rm --entrypoint python sea-seq:latest runner_cli.py scan --target demo.com


Run Report generator directly

docker run --rm --entrypoint python sea-seq:latest runner_report.py

# SEA-SEQ — Shift-Left Endpoint Assurance & Security

**SEA-SEQ** is a fast, language-agnostic **API testing and security validation runner**.
It combines **OpenAPI contract validation**, **functional tests**, **coverage tracking**, and **lightweight security checks** into one CI-ready tool.

---

## Why SEA-SEQ?

* 🔧 **Language-agnostic**: Write suites in YAML — no SDK lock-in.
* 📜 **Contract validation**: Enforce responses against OpenAPI (status, headers, body schemas).
* 📈 **Coverage reports**: Track which paths and methods in your OpenAPI spec are tested.
* ⚡ **Parallel execution**: Run scenarios concurrently; stop early with **fail-fast**.
* 🪝 **Hooks**: Plug in Go, Python, or shell scripts for token injection, scrubbing, or pentest scans.
* 🛡️ **Security checks**: Extend test steps with pentest configs (headers, ports, TLS).
* 📦 **CI-ready**: Emit JUnit, JSON, HTML, and coverage artifacts for Jenkins, CircleCI, GitHub Actions.

---

## Quickstart

### 1. Build the CLI

```bash
go build -o seaseq ./cmd/sea-qa
```

> Requires Go 1.21+ (tested with 1.22).

### 2. Define environment variables

Example: `tests/examples/jsonplaceholder/env.json`

```json
{
  "BASE_URL": "https://jsonplaceholder.typicode.com"
}
```

### 3. Write a suite

Example: `tests/examples/jsonplaceholder/suite.yaml`

```yaml
name: JSONPlaceholder — SEA-SEQ Demo
openapi: tests/examples/jsonplaceholder/openapi.json

scenarios:
  - name: List posts
    steps:
      - request:
          method: GET
          url: ${BASE_URL}/posts?userId=1
          headers: { Accept: application/json }
        expect:
          - type: status
            value: 200
          - type: contract
            value: true
```

### 4. Run

```bash
./seaseq \
  --spec tests/examples/jsonplaceholder/suite.yaml \
  --env  tests/examples/jsonplaceholder/env.json \
  --openapi tests/examples/jsonplaceholder/openapi.json \
  --out reports -v --parallel 4
```

Artifacts:

* `reports/report.html`
* `reports/results.json`
* `reports/junit.xml`
* `reports/coverage.json`

---

## Security Extensions

SEA-SEQ supports embedding lightweight pentests into your test runs.

### Example Pentest Config (`pentest.yaml`)

```yaml
targets:
  - 127.0.0.1
  - example.com
ports: [22, 80, 443]
http_checks:
  missing_headers:
    - Strict-Transport-Security
    - Content-Security-Policy
    - X-Frame-Options
```

### Example Suite with Security Hook

```yaml
name: Demo Suite with SecTest
openapi: ./openapi.yaml

scenarios:
  - name: Health check + pentest
    steps:
      - hooks:
          - when: before
            process: ["python3", "security/pentest_runner.py", "--config", "configs/pentest.yaml", "--out", "reports/sec-findings.json"]
        request:
          method: GET
          url: ${BASE_URL}/health
          headers: { Accept: application/json }
        expect:
          - { type: status, value: 200 }
          - { type: contract, value: true }
```

---

## Suite Format

* **Variables**: `${KEY}` from `--env` JSON files.
* **Timeouts**: Use `timeout_ms` (snake\_case).
* **Tag filtering**: `--include-tags smoke` / `--exclude-tags flaky`.

---

## CI/CD Examples

### GitHub Actions

`.github/workflows/seaseq.yml`

```yaml
name: SEA-SEQ

on:
  push:
    branches: [ main, master ]
  pull_request:

jobs:
  run:
    runs-on: ubuntu-latest
    env:
      SPEC: tests/examples/jsonplaceholder/suite.yaml
      OPENAPI: tests/examples/jsonplaceholder/openapi.json
      ENVFILE: tests/examples/jsonplaceholder/env.json
      OUTDIR: reports
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - uses: actions/cache@v4
        with:
          path: |
            ~/go/pkg/mod
            ~/.cache/go-build
          key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
          restore-keys: |
            ${{ runner.os }}-go-
      - run: go build -o seaseq ./cmd/sea-qa
      - run: |
          ./seaseq \
            --spec "$SPEC" \
            --openapi "$OPENAPI" \
            --env "$ENVFILE" \
            --out "$OUTDIR" \
            --parallel 4 -v
      - if: always()
        uses: actions/upload-artifact@v4
        with:
          name: seaseq-reports
          path: reports/
```

---

### Jenkins

`Jenkinsfile`

```groovy
pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
  }

  environment {
    GO111MODULE = 'on'
    GOCACHE     = "${WORKSPACE}@tmp/go-build"
    GOMODCACHE  = "${WORKSPACE}@tmp/go-mod"
    SPEC        = 'tests/examples/jsonplaceholder/suite.yaml'
    OPENAPI     = 'tests/examples/jsonplaceholder/openapi.json'
    ENVFILE     = 'tests/examples/jsonplaceholder/env.json'
    OUTDIR      = 'reports'
  }

  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Build CLI') {
      steps {
        sh 'go mod download'
        sh 'go build -o seaseq ./cmd/sea-qa'
      }
    }

    stage('Run SEA-SEQ') {
      steps {
        sh '''
          ./seaseq \
            --spec "${SPEC}" \
            --openapi "${OPENAPI}" \
            --env "${ENVFILE}" \
            --out "${OUTDIR}" \
            --parallel 4 -v
        '''
      }
    }
  }

  post {
    always {
      junit allowEmptyResults: true, testResults: 'reports/junit.xml'
      archiveArtifacts artifacts: 'reports/**', fingerprint: true
      // publishHTML plugin can display report.html:
      // publishHTML(target: [reportDir: 'reports', reportFiles: 'report.html', reportName: 'SEA-SEQ Report', keepAll: true])
    }
  }
}
```

---

### CircleCI

`.circleci/config.yml`

```yaml
version: 2.1

jobs:
  seaseq:
    docker:
      - image: cimg/go:1.22
    environment:
      SPEC: tests/examples/jsonplaceholder/suite.yaml
      OPENAPI: tests/examples/jsonplaceholder/openapi.json
      ENVFILE: tests/examples/jsonplaceholder/env.json
      OUTDIR: reports
    steps:
      - checkout
      - restore_cache:
          keys:
            - go-mod-{{ checksum "go.sum" }}
            - go-mod-
      - run: go mod download
      - save_cache:
          key: go-mod-{{ checksum "go.sum" }}
          paths: [~/go/pkg/mod]
      - run: go build -o seaseq ./cmd/sea-qa
      - run: |
          ./seaseq \
            --spec "$SPEC" \
            --openapi "$OPENAPI" \
            --env "$ENVFILE" \
            --out "$OUTDIR" \
            --parallel 4 -v
      - store_test_results: { path: reports }
      - store_artifacts: { path: reports, destination: reports }

workflows:
  seaseq:
    jobs: [seaseq]
```

---
# Site Metadata Crawler

This project includes a Python crawler that collects metadata (title, description, keywords, robots) from all pages of a given website, along with the hosting IP address. Results are saved into a CSV file for analysis or Six Sigma STTS tracking.

---


# Site Metadata Crawler

[![codecov](https://codecov.io/gh/MojoConsultants/sea-sec/branch/main/graph/badge.svg)](https://codecov.io/gh/MojoConsultants/sea-sec)


## 🚀 Setup Instructions

### 1. Clone the Repository
```bash
gh repo clone MojoConsultants/sea-sec
cd sea-sec

## Contributing

PRs welcome! Before submitting:

1. Run `go fmt ./... && go test ./...`.
2. Add/update fixtures under `tests/examples/*`.
3. Update this README if your change affects behavior.

---

## License

**Apache License 2.0** — see [`LICENSE`](LICENSE).

---


