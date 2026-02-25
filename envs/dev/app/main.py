import os

from fastapi import FastAPI
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from fastapi.responses import PlainTextResponse

from app.system_info import (
    get_architecture,
    get_hostname,
    get_ipv4_address,
    get_ipv6_address,
    get_uptime_seconds,
)


# Parse common truthy string values from env configuration.
def _is_truthy(value: str | None) -> bool:
    if value is None:
        return False
    return value.strip().lower() in {"1", "true", "yes", "on"}


# Build the FastAPI app and optionally enable HTTPS redirect middleware.
def create_app(enable_https_redirect: bool | None = None) -> FastAPI:
    app = FastAPI(title="Sample Python REST API", version="1.0.0")

    if enable_https_redirect is None:
        enable_https_redirect = _is_truthy(os.getenv("ENABLE_HTTPS_REDIRECT"))

    if enable_https_redirect:
        app.add_middleware(HTTPSRedirectMiddleware)

    # Simple liveness endpoint.
    @app.get("/health", response_class=PlainTextResponse)
    def health() -> str:
        return "OK"

    # Return best-effort host IPv4 address.
    @app.get("/ipv4", response_class=PlainTextResponse)
    def ipv4() -> str:
        return get_ipv4_address()

    # Return best-effort host IPv6 address.
    @app.get("/ipv6", response_class=PlainTextResponse)
    def ipv6() -> str:
        return get_ipv6_address()

    # Return machine architecture.
    @app.get("/arch", response_class=PlainTextResponse)
    def arch() -> str:
        return get_architecture()

    # Return host uptime in seconds.
    @app.get("/uptime", response_class=PlainTextResponse)
    def uptime() -> str:
        return str(get_uptime_seconds())

    # Return host name.
    @app.get("/hostname", response_class=PlainTextResponse)
    def hostname() -> str:
        return get_hostname()

    return app


# ASGI application instance.
app = create_app()
