import os
import functions_framework
import requests
from google.cloud import secretmanager

# Initialize the Secret Manager client
secret_client = secretmanager.SecretManagerServiceClient()

def get_secret(secret_name):
    name = f"projects/{os.environ['GOOGLE_CLOUD_PROJECT']}/secrets/{secret_name}/versions/latest"
    response = secret_client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")

@functions_framework.http
def handle_callback(request):
    print("Function was triggered")

    # Verify the request method
    if request.method != 'POST':
        return 'Only POST requests are accepted', 405

    # Get the API token from Secret Manager
    api_token = get_secret(os.environ.get('SECRET_NAME', 'api-token'))

    # TODO: Replace with the actual URL you want to send the POST request to
    target_url = "https://example.com/api/endpoint"

    # TODO: Replace with the actual content you want to send
    content = {
        "key": "value"
    }

    # Set up the headers with the API token
    headers = {
        "Content-Type": "application/json",
        "token": api_token
    }

    try:
        # Send the POST request
        response = requests.post(target_url, json=content, headers=headers)
        response.raise_for_status()
        return f"Request sent successfully. Status code: {response.status_code}", 200
    except requests.RequestException as e:
        print(f"Error sending request: {str(e)}")
        return f"Error sending request: {str(e)}", 500
