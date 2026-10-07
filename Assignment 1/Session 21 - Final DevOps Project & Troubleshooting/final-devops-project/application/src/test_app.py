import pytest
from app import app, ORDERS_DB

@pytest.fixture
def client():
    app.config['TESTING'] = True
    ORDERS_DB.clear()
    with app.test_client() as client:
        yield client

def test_health_check(client):
    res = client.get('/health')
    assert res.status_code == 200
    data = res.get_json()
    assert data['status'] == 'HEALTHY'
    assert data['author'] == 'Sambhav D Bohra'

def test_ready_check(client):
    res = client.get('/ready')
    assert res.status_code == 200
    assert res.get_json()['status'] == 'READY'

def test_create_order_success(client):
    payload = {"item": "Kubernetes Production Guide", "amount": 49.99}
    res = client.post('/api/v1/orders', json=payload)
    assert res.status_code == 201
    data = res.get_json()
    assert data['item'] == "Kubernetes Production Guide"
    assert data['amount'] == 49.99
    assert data['status'] == 'PROCESSED'

def test_create_order_invalid_amount(client):
    payload = {"item": "Free Item", "amount": -10}
    res = client.post('/api/v1/orders', json=payload)
    assert res.status_code == 422

def test_create_order_missing_fields(client):
    res = client.post('/api/v1/orders', json={})
    assert res.status_code == 400

def test_metrics_endpoint(client):
    res = client.get('/metrics')
    assert res.status_code == 200
    assert b"http_requests_total" in res.data
