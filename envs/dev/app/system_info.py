import platform
import socket
import time

import psutil


def get_ipv4_address() -> str:
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        try:
            sock.connect(("8.8.8.8", 80))
            return sock.getsockname()[0]
        except OSError:
            return socket.gethostbyname(socket.gethostname())


def get_ipv6_address() -> str:
    with socket.socket(socket.AF_INET6, socket.SOCK_DGRAM) as sock:
        try:
            sock.connect(("2001:4860:4860::8888", 80))
            return sock.getsockname()[0]
        except OSError:
            return "IPv6 unavailable"


def get_architecture() -> str:
    return platform.machine()


def get_uptime_seconds() -> int:
    return int(time.time() - psutil.boot_time())


def get_hostname() -> str:
    return socket.gethostname()
