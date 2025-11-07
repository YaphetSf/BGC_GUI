from __future__ import annotations

import plistlib
from pathlib import Path


def get_repo_root() -> Path:
    return Path(__file__).resolve().parent


def get_workflow_path(repo_root: Path) -> Path:
    return repo_root / "Basecam.app" / "Contents" / "document.wflow"


def build_command(repo_root: Path) -> str:
    return "\n".join(
        [
            f'cd "{repo_root}"',
            "./run_mac.sh \"$@\"",
        ]
    )


def update_workflow_command(workflow_path: Path, command: str) -> bool:
    if not workflow_path.exists():
        raise FileNotFoundError(f"Automator workflow not found: {workflow_path}")

    with workflow_path.open("rb") as handle:
        workflow_data = plistlib.load(handle)

    try:
        action_parameters = (
            workflow_data["actions"][0]["action"]["ActionParameters"]
        )
    except (KeyError, IndexError) as exc:
        raise KeyError(
            "Unexpected Automator workflow structure; unable to locate COMMAND_STRING"
        ) from exc

    current_command = action_parameters.get("COMMAND_STRING", "")
    if current_command == command:
        return False

    action_parameters["COMMAND_STRING"] = command

    with workflow_path.open("wb") as handle:
        plistlib.dump(workflow_data, handle, fmt=plistlib.FMT_XML)

    return True


def main() -> None:
    repo_root = get_repo_root()
    workflow_path = get_workflow_path(repo_root)
    target_command = build_command(repo_root)

    try:
        updated = update_workflow_command(workflow_path, target_command)
    except (FileNotFoundError, KeyError) as error:
        print(f"Error: {error}")
        return

    if updated:
        print(f"Updated Automator workflow at {workflow_path} with repo path {repo_root}.")
    else:
        print("Automator workflow already up to date.")


if __name__ == "__main__":
    main()
