import re
from typing import List, Tuple, Optional
import os
import sys
import json
import subprocess
from pathlib import Path


def run_command(*args) -> str:
    """运行命令并返回 stdout 字符串"""
    try:
        # 使用 check=False 捕获 returncode，不抛出异常
        result = subprocess.run(args, capture_output=True, text=True, encoding="utf-8")
        if result.returncode != 0:
            print(f"Error running {' '.join(args)}: {result.stderr.strip()}", file=sys.stderr)
            return ""
        return result.stdout.strip()
    except Exception as e:
        print(f"Exception executing {' '.join(args)}: {e}", file=sys.stderr)
        return ""


MESSAGE_LOG = ["chore: auto-update packages \n\n\n"]


def update_message() -> None:
    if len(MESSAGE_LOG) > 1:
        with open("./update-message.log", "a", encoding="utf-8") as f:
            f.writelines(MESSAGE_LOG)


def get_pkg_path_simple(package: str) -> str | None:
    """通过 nix eval 获取包的路径并检查是否有本地 update.sh"""
    nix_expression = f'(builtins.unsafeGetAttrPos "pname" (import ./default.nix {{}}).{package}).file'
    command = ["nix", "eval", "--expr", nix_expression, "--impure", "--json"]

    nix_file_json = run_command(*command)
    if not nix_file_json:
        return None

    try:
        nix_file = json.loads(nix_file_json)
        path = Path(nix_file)
        update_sh = path.parent / "update.sh"
        if update_sh.exists():
            return str(update_sh)
    except json.JSONDecodeError:
        return None
    return None


def update_pkg(pkg_info: Tuple[str, Optional[List[str]]]):
    """执行包更新逻辑"""
    pkg, scripts = pkg_info
    update_path = get_pkg_path_simple(pkg)

    # 构造命令
    if not scripts:
        command = ["nix-update"]
    else:
        # 如果有本地 update.sh 则优先使用
        if update_path is None:
            command = ["nix-update"]
        else:
            command = [update_path]

        # 处理脚本参数（如果有的话）
        if len(scripts) > 1:
            command = command + scripts[1:]

    command.append(pkg)

    print(f"-> Updating {pkg}: {' '.join(command)}")
    result = run_command(*command)

    # 解析更新日志
    match = re.search(r"(Update\s+\S+\s+->\s+\S+)", result)
    if match:
        MESSAGE_LOG.append(f"[{pkg}]: {match.group(1)} \n")


def check_auto_update(package: str) -> Optional[Tuple[str, Optional[List[str]]]]:
    """评估包的 passthru 属性以确定是否需要更新"""
    nix_expression = "x: builtins.intersectAttrs { autoUpdate = null; updateScript = null; } x"
    command = ["nix", "eval", f".#{package}.passthru", "--json", "--impure", "--apply", nix_expression]

    result_raw = run_command(*command)
    if not result_raw:
        return None

    try:
        res_json = json.loads(result_raw)
        # 检查 autoUpdate 字段
        if res_json.get("autoUpdate") is True:
            return (package, None)

        # 检查 updateScript 字段
        scripts = res_json.get("updateScript")
        if scripts:
            if isinstance(scripts, str):
                scripts = [scripts]
            return (package, scripts)
    except json.JSONDecodeError:
        return None
    return None


def find_packages() -> List[str]:
    """获取所有包列表"""
    print("Scanning packages...")
    command = ["nix-env", "-f", "default.nix", "-qaP", "--json"]
    result = run_command(*command)
    if not result:
        return []
    return list(json.loads(result).keys())


def main() -> None:
    packages = find_packages()
    print(f"Found {len(packages)} packages.")

    # 顺序处理每个包
    for pkg_name in packages:
        # 1. 检查是否开启了自动更新
        update_info = check_auto_update(pkg_name)

        # 2. 如果符合条件，立即执行更新
        if update_info:
            update_pkg(update_info)

    update_message()
    print("All tasks finished.")


if __name__ == "__main__":
    main()
