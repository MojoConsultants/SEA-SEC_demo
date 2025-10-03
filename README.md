# Sea-Seq README

This repository contains Sea-Seq, a penetration testing tool designed to accept a test location, resolve it to IP addresses, run tests via a runner, and serve results through a reporting service. It supports execution via command line, Docker, and API.

---

## Table of Contents

- [Overview](#overview)
- [Motivation & Goals](#motivation--goals)
- [Project Architecture](#project-architecture)
  - [Core Components](#core-components)
  - [Execution Modes](#execution-modes)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Usage](#usage)
- [Tutorial & Diagram](#tutorial--diagram)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

Sea-Seq is designed to:
- Accept a test location and map it to target IPs
- Use a runner to execute penetration tests on those IPs
- Generate and serve results via a reporting service
- Provide multiple execution pathways: CLI, Docker, and API

---

## Motivation & Goals

- Provide a flexible penetration testing workflow that can be invoked from different interfaces.
- Ensure consistent behavior across CLI, Docker, and API usage.
- Facilitate traceability of test locations to IP targets and results.

---

## Project Architecture

### Core Components

- **`run-sea-seq`**: Entry point script that orchestrates the end-to-end flow across interfaces.
- **`runner.py`**: Executes penetration tests against selected IPs (invokes internal scanners/tools).
- **`reporting_service.py`**: Maps test locations to IPs and handles result delivery (generation, storage, and serving).

### Execution Modes

- **CLI**: Direct command-line invocation for local or CI environments.
- **Docker**: Containerized execution with Docker-related hooks and configuration.
- **API**: Programmatic access via an API layer for integration with other systems.

---

## Getting Started

### Prerequisites

- Python (and/or Go as used by the project) depending on the implementation
- Docker (for Docker-based execution)
- Access to required network resources for penetration testing

### Installation

1. Clone the repository.
2. Install dependencies as defined in the project (e.g., `pip install -r requirements.txt` or equivalent).
3. If using Docker, ensure Docker is running and pull/build the necessary images as described in the Docker setup.

### Usage

- CLI: `./run-sea-seq <options>`
- Docker: `docker-compose up` or `docker run <sea-seq-image> <options>`
- API: Start the API service and make requests to the endpoints provided in the API documentation

> NOTE: Specific commands, options, and environment variables are described in the tutorial and accompanying diagrams below.

---

## Tutorial & Diagram

- A diagram illustrating the end-to-end flow (from location input to IP resolution, to testing, to results) is provided in the tutorial folder of the codebase.
- The diagram visually explains:
  - How a test location is mapped to IPs
  - How `run-sea-seq` coordinates the workflow
  - How `runner.py` interfaces with scanners/tools
  - How `reporting_service.py` delivers and serves results
- Where to find it:
  - Path: `tutorial/Sea-Seq_End-to-End_Flow_Diagram.png` (or within the `tutorial` directory as applicable)
  - The README references this diagram and briefly describes its elements

---

## Contributing

- Please follow the contribution guidelines in `CONTRIBUTING.md` (if provided).
- Report issues and submit pull requests with clear descriptions and steps to reproduce.

---

## License

- This project is not icensed. Its pending Copyright. 