import re
from typing import List
import os
import sys
import json
import shutil
import asyncio


async def run_command(*args):
    try:
        process = await asyncio.create_subprocess_exec(
            *args, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
        )
    except Exception as e:
        print(e)
        return None

    stdout, stderr = await process.communicate()
    if process.returncode != 0:
        print(f"Error running {' '.join(args)}: {stderr.decode().strip()}", file=sys.stderr)
    return stdout.decode().strip()


MESSAGE_LOG = ["chore: auto-update packages \n\n\n"]


def update_message():
    if MESSAGE_LOG:
        with open("./update-message.log", "a", encoding="utf-8") as f:
            f.writelines(MESSAGE_LOG)


async def update_pkg(pkgs):
    pkg, args = pkgs
    command = ["nix-update"]
    if args:
        command += args

    command.append(f"{pkg}")

    print(" ".join(command))
    result: str = await run_command(*command)
    match = re.search(r"(Update\s+\S+\s+->\s+\S+)", result)
    if match:
        MESSAGE_LOG.append(f"[{pkg}]: {match.group(1)} \n")


async def check_auto_update(package: str):
    nix_expression = "x: builtins.intersectAttrs { autoUpdate = null; updateScript = null; } x"
    command = ["nix", "eval", f".#{package}.passthru", "--json", "--apply", nix_expression]
    result = await run_command(*command)

    resutl_json = json.loads(result)
    if result:
        if resutl_json.get("autoUpdate") is True:
            return package, None

        if resutl_json.get("updateScript", None):
            scripts = resutl_json.get("updateScript")
            extraArgs = scripts[1:]
            return package, extraArgs


async def find_packages() -> List[str]:
    command = ["nix-env", "-f", "default.nix", "-qaP", "--json"]
    result = await run_command(*command)
    return list(json.loads(result).keys())


async def main():
    packages = await find_packages()

    tasks = [check_auto_update(pkgs) for pkgs in packages]
    results = await asyncio.gather(*tasks)

    update_pkgs_tasks = [update_pkg(pkg) for pkg in results if pkg is not None]
    await asyncio.gather(*update_pkgs_tasks)
    update_message()


if __name__ == "__main__":
    asyncio.run(main())
