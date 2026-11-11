from pathlib import Path

Import("env")


def git_commit(project_dir: str) -> str:
    git_dir = Path(project_dir) / ".git"
    try:
        head = (git_dir / "HEAD").read_text(encoding="utf-8").strip()
        if not head.startswith("ref: "):
            return head[:12]
        ref = head[5:]
        loose_ref = git_dir / ref
        if loose_ref.is_file():
            return loose_ref.read_text(encoding="utf-8").strip()[:12]
        packed_refs = git_dir / "packed-refs"
        for line in packed_refs.read_text(encoding="utf-8").splitlines():
            if line and not line.startswith(("#", "^")):
                commit, name = line.split(" ", 1)
                if name == ref:
                    return commit[:12]
    except (OSError, ValueError):
        pass
    return "unknown"


commit = git_commit(env.subst("$PROJECT_DIR"))
env.Append(CPPDEFINES=[("DOWNHILL_GIT_COMMIT", f'\\"{commit}\\"')])
