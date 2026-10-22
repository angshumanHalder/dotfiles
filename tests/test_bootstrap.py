#!/usr/bin/env python3
"""Offline smoke check: python3 tests/test_bootstrap.py (installs nothing)."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


with tempfile.TemporaryDirectory(prefix="dotfiles-bootstrap-test-") as temporary:
    root = Path(temporary)
    repo, home, tools = (root / name for name in ("repo", "home", "tools"))
    for directory in (repo, home, tools):
        directory.mkdir()
    shutil.copyfile(Path(__file__).resolve().parents[1] / "bootstrap.sh", repo / "bootstrap.sh")
    for file in ("nvim/init.lua", "kitty/kitty.conf", "gh/hosts.yml"):
        destination = repo / file
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text("fixture\n")
    subprocess.run(["git", "init", "-q", str(repo)], check=True)
    subprocess.run(["git", "-C", str(repo), "add", "nvim", "kitty", "gh"], check=True)
    subprocess.run(["bash", "-n", str(repo / "bootstrap.sh")], check=True)
    stub = tools / "stub"
    stub.write_text("""#!/usr/bin/env python3
import os, pathlib, sys
root = pathlib.Path(os.environ['BOOTSTRAP_TEST_ROOT'])
name, args = pathlib.Path(sys.argv[0]).name, sys.argv[1:]
with (root / 'commands').open('a') as log:
    log.write(name + ' ' + ' '.join(args) + '\\n')
if name == 'uname':
    print('Darwin' if args == ['-s'] else 'arm64')
elif name == 'brew' and args == ['--prefix', 'rustup']:
    print(root / 'rustup')
elif name == 'brew' and args[:1] == ['bundle']:
    (root / 'Brewfile').write_text(sys.stdin.read())
elif name == 'stow' and '--simulate' in args and (root / 'fail-stow').exists():
    sys.exit(1)
""")
    stub.chmod(0o755)
    for name in ("uname", "xcode-select", "brew", "rustup", "stow"):
        (tools / name).symlink_to(stub)
    environment = dict(os.environ, HOME=str(home), PATH=f"{tools}:{os.environ['PATH']}",
                       BOOTSTRAP_TEST_ROOT=str(root))
    environment.pop("XDG_CONFIG_HOME", None)
    command = ["bash", str(repo / "bootstrap.sh")]
    for _ in range(2):
        subprocess.run(command, env=environment, check=True, stdout=subprocess.DEVNULL)
    staged = home / ".local/share/dotfiles-stow/config/.config"
    assert (staged / "nvim/init.lua").resolve() == (repo / "nvim/init.lua").resolve()
    assert (staged / "kitty/kitty.conf").resolve() == (repo / "kitty/kitty.conf").resolve()
    assert not (staged / "gh").exists(), "Never stow credentials"
    assert (home / ".zprofile").read_text().count("shellenv") == 1
    assert (home / ".zshrc").read_text().count("starship init") == 1
    brewfile = (root / "Brewfile").read_text()
    for package in ("rustup", "go", "python", "node", "typescript", "lua", "ghostty", "kitty"):
        assert f'"{package}"' in brewfile
    assert "--component rust-analyzer" in (root / "commands").read_text()
    # A Stow conflict must stop before activation or service startup.
    (root / "commands").write_text("")
    (root / "fail-stow").touch()
    existing = home / ".config/nvim/init.lua"
    existing.parent.mkdir(parents=True)
    existing.write_text("keep my config\n")
    result = subprocess.run(command, env=environment, stdout=subprocess.DEVNULL)
    assert result.returncode != 0
    assert existing.read_text() == "keep my config\n"
    commands = (root / "commands").read_text().splitlines()
    assert not any(line.startswith("stow ") and "--simulate" not in line for line in commands)
    assert not any("services start" in line for line in commands)
print("bootstrap smoke check: OK (mocked installers; no system changes)")
