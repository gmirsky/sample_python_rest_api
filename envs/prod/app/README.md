# envs/prod/app Python Documentation

## Overview

This package contains the FastAPI application for the production environment.

Modules:
- `app.main`: FastAPI app factory and HTTP endpoints.
- `app.system_info`: host/system helper functions used by endpoints.

## Module: `app.main`

### `create_app(enable_https_redirect: bool | None = None) -> FastAPI`
Creates and returns a configured FastAPI application instance.

Behavior:
- If `enable_https_redirect` is `None`, redirect behavior is read from `ENABLE_HTTPS_REDIRECT`.
- Truthy environment values: `1`, `true`, `yes`, `on` (case-insensitive).
- When enabled, `HTTPSRedirectMiddleware` is applied.

### `app`
ASGI application instance created by calling `create_app()`.

### API Endpoints
- `GET /health` → returns `OK`
- `GET /ipv4` → returns best-effort host IPv4 address
- `GET /ipv6` → returns best-effort host IPv6 address or fallback text
- `GET /arch` → returns machine architecture
- `GET /uptime` → returns uptime in seconds
- `GET /hostname` → returns host name

## Module: `app.system_info`

### `get_ipv4_address() -> str`
Returns a best-effort routable IPv4 address.

### `get_ipv6_address() -> str`
Returns a best-effort routable IPv6 address, or `IPv6 unavailable`.

### `get_architecture() -> str`
Returns CPU architecture (`platform.machine()`).

### `get_uptime_seconds() -> int`
Returns host uptime in whole seconds based on boot time.

### `get_hostname() -> str`
Returns host name.

## Run Locally (prod package)

```bash
PYTHONPATH=envs/prod uvicorn app.main:app --host 0.0.0.0 --port 8443
```

## Import Example

```python
from app.main import app, create_app
from app.system_info import get_hostname
```
