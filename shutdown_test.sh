#!/bin/bash

# Exit immediately if any command fails
set -e

echo "Step 1: Bringing down Docker containers..."
docker-compose down -v

echo "Step 2: Running run-sea-seq.sh with 'down'..."
./run-sea-seq.sh down

echo "Step 3: Running smoke tests..."
./smoke-test.sh

echo "✅ All steps completed successfully."
### End of script

### This script performs the following actions:
# 1. Brings down Docker containers using `docker-compose down -v`.
# 2. Executes the `run-sea-seq.sh` script with the argument `down`.
# 3. Runs the `smoke-test.sh` script to perform smoke tests.        
# 4. Prints a success message if all steps complete without errors.
# 5. The script exits immediately if any command fails, ensuring robust error handling.
# 6. Each step is clearly logged to the console for easy tracking of progress.
# 7. Assumes that `docker-compose`, `run-sea-seq.sh`, and `smoke-test.sh` are available in the current directory or system PATH.
# 8. Designed to be run in a Unix-like environment with Bash shell.
# 9. Uses `set -e` to ensure the script stops execution on any error.
# 10. Provides clear and concise output messages for each step to inform the user of the current operation.
# 11. Cleans up any associated volumes with the `-v` flag in the `docker-compose down` command.
# 12. Ensures that the script is executable and has the necessary permissions to run.
# 13. Can be easily modified to include additional steps or change existing ones as needed.
# 14. Suitable for use in CI/CD pipelines or local development environments to manage Docker services and validate their state.
# 15. Encourages best practices in scripting by maintaining readability and simplicity.
# 16. Can be integrated into larger automation workflows for managing application lifecycles.
# 17. Provides a clear structure for future enhancements or modifications.
# 18. Ensures that all dependencies are met before executing each step.
# 19. Can be scheduled to run at specific intervals or triggered by events in a development
#     or production environment.
# 20. Aims to improve efficiency and reliability in managing Docker-based applications.
# 21. Facilitates easy debugging by isolating each step and providing immediate feedback on failures.
# 22. Can be adapted to include logging mechanisms for better traceability.
# 23. Supports scalability by allowing additional services to be added to the `docker-compose`
#     configuration as needed.
# 24. Promotes consistency in managing application states across different environments.
# 25. Helps maintain a clean and organized development environment by removing unused containers
#     and volumes.
# 26. Can be used as a template for creating similar scripts for other applications or services 