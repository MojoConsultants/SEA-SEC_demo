from fastapi import FastAPI
import os
import logging
import json
import sys

# Import the router and service
from app.routes import router as api_router
from app.services.data_service import set_target_site

# -------------------------------------------------
# JSON Logging for Docker
# -------------------------------------------------
class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "level": record.levelname,
            "time": self.formatTime(record, self.datefmt),
            "message": record.getMessage(),
            "logger": record.name,
        }
        return json.dumps(log_record)

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())

logger = logging.getLogger("sea-sec")
logger.setLevel(logging.INFO)
logger.handlers = [handler]
logger.propagate = False

# -------------------------------------------------
# App Factory
# -------------------------------------------------
def create_app() -> FastAPI:
    reports_dir = "data/reports/latest"
    os.makedirs(reports_dir, exist_ok=True)

    app = FastAPI(
        title="SEA-SEC API",
        description="Security analysis and reporting pipeline",
        version="1.0.0"
    )

    app.include_router(api_router, prefix="/api")

    # Startup event hook
    @app.on_event("startup")
    async def startup_event():
        logger.info("SEA-SEC API starting up...")
        logger.info(f"Reports directory ensured at: {os.path.abspath(reports_dir)}")
        logger.info("Swagger docs available at: /docs")
        logger.info("ReDoc docs available at: /redoc")

        # Auto-set target site if provided in env
        default_site = os.getenv("TARGET_SITE")
        if default_site:
            set_target_site(default_site)
            logger.info(f"🌐 Target site set from env: {default_site}")
        else:
            logger.info("ℹ️ No TARGET_SITE env var provided — call /api/set_site manually.")

    # Shutdown event hook
    @app.on_event("shutdown")
    async def shutdown_event():
        logger.info("SEA-SEC API shutting down... Goodbye!")

    return app

# -------------------------------------------------
# Entry Point
# -------------------------------------------------
app = create_app()

# Run with:
command: uvicorn main:api --host 0.0.0.0 --port 8000

# or for development with auto-reload:
# uvicorn main:app --host   