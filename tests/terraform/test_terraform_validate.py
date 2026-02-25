import shutil
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
TERRAFORM_DIRS = [
    REPO_ROOT / "terraform" / "bootstrap",
    REPO_ROOT / "terraform" / "envs" / "dev",
    REPO_ROOT / "terraform" / "envs" / "qa",
    REPO_ROOT / "terraform" / "envs" / "prod",
]


def _terraform_available() -> bool:
    return shutil.which("terraform") is not None


def _run(command: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=cwd, text=True, capture_output=True, check=False)


@pytest.mark.skipif(not _terraform_available(), reason="terraform is not installed")
def test_terraform_fmt_check() -> None:
    result = _run(["terraform", "fmt", "-check", "-recursive"], REPO_ROOT)
    assert result.returncode == 0, result.stderr + result.stdout


@pytest.mark.skipif(not _terraform_available(), reason="terraform is not installed")
@pytest.mark.parametrize("tf_dir", TERRAFORM_DIRS)
def test_terraform_validate(tf_dir: Path) -> None:
    init_result = _run(["terraform", "init", "-backend=false", "-input=false"], tf_dir)
    assert init_result.returncode == 0, init_result.stderr + init_result.stdout

    validate_result = _run(["terraform", "validate"], tf_dir)
    assert validate_result.returncode == 0, validate_result.stderr + validate_result.stdout
