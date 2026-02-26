from ntpath import dirname
import re
from typing import List, Tuple, Optional
import os
import sys
import json
import shutil
import asyncio
from pathlib import Path


async def run_command(*args) -> str:
    try:
        process = await asyncio.create_subprocess_exec(
            *args, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
        )
    except Exception as e:
        return ""

    stdout, stderr = await process.communicate()
    if process.returncode != 0:
        print(f"Error running {' '.join(args)}: {stderr.decode().strip()}", file=sys.stderr)
    return stdout.decode().strip()


MESSAGE_LOG = ["chore: auto-update packages \n\n\n"]


def update_message() -> None:
    if MESSAGE_LOG and len(MESSAGE_LOG) > 1:
        with open("./update-message.log", "a", encoding="utf-8") as f:
            f.writelines(MESSAGE_LOG)


async def get_pkg_path_simple(package: str) -> str | None:
    nix_expression = f"""
        (builtins.unsafeGetAttrPos "pname" (import ./default.nix {{}}).{package}).file
    """
    command = ["nix", "eval", "--expr", nix_expression, "--impure"]
    nix_file = await run_command(*command)
    path = Path(json.loads(nix_file))
    update = dirname(path) + "/update.sh"
    if os.path.exists(update):
        return update


async def update_pkg(pkgs: Tuple[str, List[str]]):
    pkg, args = pkgs

    update_path = await get_pkg_path_simple(pkg)

    if not args:
        command = ["nix-update"]
    else:
        if update_path is None:
            command = ["nix-update"]
        else:
            command = [update_path]
        command = command + args[1:]

    command.append(f"{pkg}")

    print(" ".join(command))
    result: str = await run_command(*command)
    match = re.search(r"(Update\s+\S+\s+->\s+\S+)", result)
    if match:
        MESSAGE_LOG.append(f"[{pkg}]: {match.group(1)} \n")


async def check_auto_update(package: str) -> Optional[Tuple[str, Optional[List[str]]]]:
    nix_expression = "x: builtins.intersectAttrs { autoUpdate = null; updateScript = null; } x"
    command = ["nix", "eval", f".#{package}.passthru", "--json", "--apply", nix_expression]
    result = await run_command(*command)

    resutl_json = json.loads(result)
    if result:
        if resutl_json.get("autoUpdate") is True:
            return package, None

        if resutl_json.get("updateScript", None):
            scripts = resutl_json.get("updateScript")
            if isinstance(scripts, str):
                scripts = [scripts]
            return package, scripts


async def find_packages() -> List[str]:
    command = ["nix-env", "-f", "default.nix", "-qaP", "--json"]
    result = await run_command(*command)
    return list(json.loads(result).keys())


async def main() -> None:
    packages = await find_packages()

    tasks = [check_auto_update(pkgs) for pkgs in packages]
    results = await asyncio.gather(*tasks)

    update_pkgs_tasks = [update_pkg(pkg) for pkg in results if pkg is not None]
    await asyncio.gather(*update_pkgs_tasks)
    update_message()


if __name__ == "__main__":
    asyncio.run(main())
