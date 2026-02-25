import re

from fastapi.testclient import TestClient

from app.main import app

https_client = TestClient(app, base_url="https://testserver")
http_client = TestClient(app, base_url="http://testserver")


def test_health_endpoint() -> None:
    response = https_client.get("/health")
    assert response.status_code == 200
    assert response.text == "OK"


def test_ipv4_endpoint() -> None:
    response = https_client.get("/ipv4")
    assert response.status_code == 200
    assert re.match(r"^\d{1,3}(\.\d{1,3}){3}$", response.text)


def test_ipv6_endpoint() -> None:
    response = https_client.get("/ipv6")
    assert response.status_code == 200
    assert response.text


def test_arch_endpoint() -> None:
    response = https_client.get("/arch")
    assert response.status_code == 200
    assert response.text


def test_uptime_endpoint() -> None:
    response = https_client.get("/uptime")
    assert response.status_code == 200
    assert response.text.isdigit()


def test_hostname_endpoint() -> None:
    response = https_client.get("/hostname")
    assert response.status_code == 200
    assert response.text


def test_http_redirects_to_https() -> None:
    response = http_client.get("/health", follow_redirects=False)
    assert response.status_code in (301, 307, 308)
    assert response.headers["location"].startswith("https://")
