#!/usr/bin/env python3
"""
runner_report.py – Generate SEA-SEQ reports via Python code
Runs inside Docker or manually if invoked.
"""

import os
import sys
import logging
import traceback
from datetime import datetime

# Import your service (adjust path if different)
from app.services.data_service import set_target_site
from app.services.report_service import generate_report  # assuming exists

def main():
    log_file = "/var/log/sea-seq/runner_report.log"
    logging.basicConfig(
        filename=log_file,
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
    )
    logger = logging.getLogger("runner_report")

    output_dir = "/app/reports"
    os.makedirs(output_dir, exist_ok=True)

    try:
        logger.info("Starting report generation…")

        now = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        outpath = os.path.join(output_dir, f"report_{now}.html")

        # Example: set a target site from env
        target = os.getenv("TARGET_SITE", "https://example.com")
        set_target_site(target)
        logger.info(f"Target site set: {target}")

        # Call into your real reporting logic
        generate_report(output_path=outpath)

        logger.info(f"✅ Report generated: {outpath}")
        print(f"Report generated: {outpath} - runner_report.py:44")

    except Exception as e:
        logger.error("❌ Report generation failed: %s", e)
        logger.debug(traceback.format_exc())
        print(f"[ERROR] Report generation failed: {e} - runner_report.py:49", file=sys.stderr)
        sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()
