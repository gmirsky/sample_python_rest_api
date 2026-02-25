import platform
import socket
import time

import psutil


# Resolve a routable IPv4 address for this host.
def get_ipv4_address() -> str:
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        try:
            sock.connect(("8.8.8.8", 80))
            return sock.getsockname()[0]
        except OSError:
            return socket.gethostbyname(socket.gethostname())


# Resolve a routable IPv6 address for this host.
def get_ipv6_address() -> str:
    with socket.socket(socket.AF_INET6, socket.SOCK_DGRAM) as sock:
        try:
            sock.connect(("2001:4860:4860::8888", 80))
            return sock.getsockname()[0]
        except OSError:
            return "IPv6 unavailable"


# Return host CPU architecture string.
def get_architecture() -> str:
    return platform.machine()


# Return host uptime in whole seconds.
def get_uptime_seconds() -> int:
    return int(time.time() - psutil.boot_time())


# Return host name.
def get_hostname() -> str:
    return socket.gethostname()
