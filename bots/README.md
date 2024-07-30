# Callback Function Project

This project sets up a Google Cloud Function that handles callback requests and sends POST requests to a specified endpoint.

## Prerequisites

- Google Cloud account and project
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and configured
- [Terraform](https://www.terraform.io/downloads.html) installed
- [Poetry](https://python-poetry.org/docs/#installation) installed
- Python 3.10 or later

## Setup and Deployment

1. Clone this repository:
   ```
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Install project dependencies:
   ```
   poetry install
   ```

3. Run tests:
   ```
   poetry run pytest
   ```

4. Create a `function-source.zip` file:
   ```
   zip -r function-source.zip main.py pyproject.toml poetry.lock
   ```

5. Initialize Terraform:
   ```
   terraform init
   ```

6. Create a `terraform.tfvars` file with your specific values:
   ```
   project_id = "your-google-cloud-project-id"
   bucket_name = "your-unique-bucket-name"
   ```

7. Apply the Terraform configuration:
   ```
   terraform apply
   ```

8. After successful application, Terraform will output the URL of your deployed Cloud Function.

## Updating the Function

1. Make changes to the `main.py` file as needed.
2. Run tests to ensure everything is working:
   ```
   poetry run pytest
   ```
3. Update the `function-source.zip` file:
   ```
   zip -r function-source.zip main.py pyproject.toml poetry.lock
   ```
4. Apply the Terraform configuration again:
   ```
   terraform apply
   ```

## Cleaning Up

To remove all created resources:

```
terraform destroy
```

## Project Structure

- `main.py`: Contains the Cloud Function code
- `pyproject.toml`: Poetry configuration and dependencies
- `main.tf`: Terraform configuration for infrastructure
- `tests/test_main.py`: Unit tests for the Cloud Function

## Notes

- Remember to manually set the value of the API token secret after creation. You can do this through the Google Cloud Console or using the `gcloud` CLI.
- The `target_url` and `content` in `main.py` should be replaced with your actual values before deployment.
- Ensure that the Secret Manager API is enabled in your Google Cloud project.
