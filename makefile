# SEA-SEQ Makefile - run both functional tests and pentest step together

IMAGE_NAME=seaseq_runner
REPORTS_DIR=$(PWD)/reports

# Default target
all: help

help:
	@echo "SEA-SEQ Make Targets:"
	@echo "  make build     - Build Docker image"
	@echo "  make compose   - Spin up API/DB/Web stack (docker-compose)"
	@echo "  make down      - Stop docker-compose services"
	@echo "  make reports   - Run default test suite + pentest and generate reports"
	@echo "  make reports SUITE=... ENV=... OPENAPI=... - Run custom suite"

build:
	docker build -t $(IMAGE_NAME) .

compose:
	docker-compose up --build -d && docker-compose logs -f

down:
	docker-compose down -v

reports: build
	mkdir -p $(REPORTS_DIR)
	docker run --rm -it \
		-e TARGET_SITE_URL="$(TARGET_SITE_URL)" \
		-v $(REPORTS_DIR):/app/reports \
		-v $(PWD):/app \
		$(IMAGE_NAME) \
		/bin/bash -lc "\
			set -e; \
			echo '[step] running seaseq CLI'; \
			./seaseq \
				--spec $(or $(SUITE),tests/examples/jsonplaceholder/suite.yaml) \
				--env $(or $(ENV),tests/examples/jsonplaceholder/env.json) \
				--openapi $(or $(OPENAPI),tests/examples/jsonplaceholder/openapi.json) \
				--out reports -v --parallel 4; \
			echo '[step] seaseq finished'; \
			if [ -f security/pentest_runner.py ]; then \
				echo '[step] running security/pentest_runner.py with pentest.yaml'; \
				python3 security/pentest_runner.py --config pentest.yaml --out reports/sec-findings.json || echo 'pentest runner exited non-zero'; \
			else \
				echo '[notice] security/pentest_runner.py not found — skipping pentest runner' > reports/sec-findings-not-run.txt; \
			fi; \
			echo '[done] test + pentest steps completed'"

.PHONY: all help build compose down reports_DIR)"	

	@echo "Reports generated in $(REPORTS_DIR)"	
	@echo "To view the HTML report, open $(REPORTS_DIR)/report.html in your browser."
	@echo "To view the JUnit XML report, check $(REPORTS_DIR)/junit.xml."
	@echo "To view the JSON report, check $(REPORTS_DIR)/report.json."		
	@echo "To view the CSV report, check $(REPORTS_DIR)/report.csv."
	@echo "To view the Markdown report, check $(REPORTS_DIR)/report.md."
	@echo "To view the PDF report, check $(REPORTS_DIR)/report.pdf."
	@echo "To view the Allure report, run 'allure serve $(REPORTS