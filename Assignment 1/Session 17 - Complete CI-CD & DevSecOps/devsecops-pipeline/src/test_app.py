# pyrefly: ignore [missing-import]
import pytest
from app import app, validate_username

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_check(client):
    response = client.get('/health')
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data['status'] == 'HEALTHY'
    assert json_data['author'] == 'Sambhav D Bohra'

def test_validate_username_valid():
    assert validate_username("sambhav_bohra") is True
    assert validate_username("devops-user-01") is True

def test_validate_username_invalid_chars():
    # SQL injection attempt
    assert validate_username("admin' OR '1'='1") is False
    # Command injection attempt
    assert validate_username("user; rm -rf /") is False
    # Too short
    assert validate_username("ab") is False

def test_validate_user_endpoint_success(client):
    response = client.post('/api/users/validate', json={"username": "validUser123"})
    assert response.status_code == 200
    assert response.get_json()['status'] == 'valid'

def test_validate_user_endpoint_bad_input(client):
    response = client.post('/api/users/validate', json={"username": "<script>alert(1)</script>"})
    assert response.status_code == 422
