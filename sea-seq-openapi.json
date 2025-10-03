{
  "openapi": "3.0.0",
  "info": {
    "title": "SEA-SEQ Security API",
    "version": "1.0.0",
    "description": "API for running security scans and generating reports using SEA-SEQ."
  },
  "paths": {
    "/scan": {
      "post": {
        "summary": "Run a security scan",
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "properties": {
                  "target": {
                    "type": "string"
                  },
                  "options": {
                    "type": "array",
                    "items": {
                      "type": "string"
                    }
                  }
                },
                "required": [
                  "target"
                ]
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Scan started successfully",
            "content": {
              "application/json": {
                "example": {
                  "status": "success",
                  "scan_id": "abc123",
                  "message": "Scan started"
                }
              }
            }
          }
        }
      }
    },
    "/report/{scan_id}": {
      "get": {
        "summary": "Get report by scan ID",
        "parameters": [
          {
            "name": "scan_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Report retrieved",
            "content": {
              "application/json": {
                "example": {
                  "scan_id": "abc123",
                  "vulnerabilities": [],
                  "summary": {}
                }
              }
            }
          }
        }
      }
    },
    "/health": {
      "get": {
        "summary": "Health check",
        "responses": {
          "200": {
            "description": "API is healthy",
            "content": {
              "application/json": {
                "example": {
                  "status": "ok"
                }
              }
            }
          }
        }
      }
    }
  }
}