import pytest
from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json()["status"] == "ok"


def test_home(client):
    response = client.get("/")
    assert response.status_code == 200
    assert b"Hello" in response.data


def test_error(client):
    response = client.get("/error")
    assert response.status_code == 500


def test_metrics(client):
    response = client.get("/metrics")
    assert response.status_code == 200
    assert b"app_requests_total" in response.data
