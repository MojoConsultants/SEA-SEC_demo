Got it ✅ — here’s the updated **README.md** with a note about the **Userguides folder** so contributors and users know where to find additional documentation.

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
```

---
