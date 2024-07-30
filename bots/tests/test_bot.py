import pytest
import requests
from unittest.mock import Mock, patch
from bot import handle_callback

@pytest.fixture
def mock_request():
    mock = Mock()
    mock.method = 'POST'
    return mock

@pytest.fixture
def mock_env(monkeypatch):
    monkeypatch.setenv('GOOGLE_CLOUD_PROJECT', 'test-project')
    monkeypatch.setenv('SECRET_NAME', 'test-secret')

def test_handle_callback_method_not_allowed(mock_request):
    mock_request.method = 'GET'
    response, status_code = handle_callback(mock_request)
    assert status_code == 405
    assert response == 'Only POST requests are accepted'

@patch('bot.get_secret')
@patch('bot.requests.post')
def test_handle_callback_success(mock_post, mock_get_secret, mock_request, mock_env):
    mock_get_secret.return_value = 'test-token'
    mock_response = Mock()
    mock_response.status_code = 200
    mock_post.return_value = mock_response

    response, status_code = handle_callback(mock_request)

    assert status_code == 200
    assert 'Request sent successfully' in response
    mock_post.assert_called_once_with(
        'https://example.com/api/endpoint',
        json={'key': 'value'},
        headers={'Content-Type': 'application/json', 'token': 'test-token'}
    )

@patch('bot.get_secret')
@patch('bot.requests.post')
def test_handle_callback_request_exception(mock_post, mock_get_secret, mock_request, mock_env):
    mock_get_secret.return_value = 'test-token'
    mock_post.side_effect = requests.RequestException('Test error')

    response, status_code = handle_callback(mock_request)

    assert status_code == 500
    assert 'Error sending request' in response
