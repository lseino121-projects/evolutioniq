from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_healthz():
    resp = client.get("/healthz")
    assert resp.status_code == 200
    assert resp.json() == {"ok": True}

def test_root():
    resp = client.get("/")
    assert resp.status_code == 200
    assert "Top .001% DevOps Prep" in resp.json()["message"]
