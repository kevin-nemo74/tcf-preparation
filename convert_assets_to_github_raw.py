import json
import os
from urllib.parse import quote, urlparse, unquote

# -----------------------------
# CONFIG
# -----------------------------
INPUT_CE = "assets/data/ce_tests.json"
INPUT_CO = "assets/data/co_tests.json"

# Old base(s) you want to replace (you can add more if you used multiple)
OLD_BASES = [
    "https://raw.githubusercontent.com/kevin-nemo74/tcf-preparation/main/",
    "https://raw.githubusercontent.com/kevin-nemo74/TCF_Canada_Preparation/main/",
]

NEW_BASE = "https://raw.githubusercontent.com/kevin-nemo74/assets/main/"

OVERWRITE = True  # False -> writes *_rewritten.json


# -----------------------------
# HELPERS
# -----------------------------
def normalize_path(p: str) -> str:
    """
    Normalize a repo-relative path:
      assets/images/ce/ce_01/1.webp
    URL-encode safely (keep slashes).
    """
    p = p.strip().replace("\\", "/")
    if p.startswith("/"):
        p = p[1:]
    return quote(p, safe="/-_.~")


def extract_repo_relative(url: str) -> str:
    """
    Extract the repo-relative path after the GitHub raw base.
    Example:
      https://raw.githubusercontent.com/user/repo/branch/assets/audio/...
    -> assets/audio/...
    If URL doesn't match expected format, return original URL unchanged.
    """
    try:
        parsed = urlparse(url)
        # raw.githubusercontent.com/<user>/<repo>/<branch>/<path...>
        parts = parsed.path.split("/")
        # parts[0] = '' then user, repo, branch, then rest...
        if len(parts) < 5:
            return url
        rel_parts = parts[4:]  # after /user/repo/branch/
        rel_path = "/".join(rel_parts)
        return unquote(rel_path)
    except Exception:
        return url


def rewrite_url(url: str) -> str:
    """
    If url starts with any OLD_BASE, replace base with NEW_BASE.
    Else if it's already a raw.githubusercontent.com URL, extract relative path and rebuild with NEW_BASE.
    Else return unchanged.
    """
    if not url or not isinstance(url, str):
        return url

    for old in OLD_BASES:
        if url.startswith(old):
            rel = url[len(old):]
            rel = unquote(rel)
            return NEW_BASE + normalize_path(rel)

    # If it's already a GitHub raw URL but with unknown base, rebuild anyway
    if "raw.githubusercontent.com" in url:
        rel = extract_repo_relative(url)
        # If extract failed (returned original URL), don't touch it
        if rel == url:
            return url
        return NEW_BASE + normalize_path(rel)

    return url


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_json(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def rewrite_ce(data):
    changed = 0
    for test in data:
        for q in test.get("questions", []):
            if "imageUrl" in q and q["imageUrl"]:
                new_url = rewrite_url(q["imageUrl"])
                if new_url != q["imageUrl"]:
                    q["imageUrl"] = new_url
                    changed += 1
    return data, changed


def rewrite_co(data):
    changed = 0
    for test in data:
        for q in test.get("questions", []):
            if "audioUrl" in q and q["audioUrl"]:
                new_url = rewrite_url(q["audioUrl"])
                if new_url != q["audioUrl"]:
                    q["audioUrl"] = new_url
                    changed += 1

            if "imageUrl" in q and q["imageUrl"]:
                new_url = rewrite_url(q["imageUrl"])
                if new_url != q["imageUrl"]:
                    q["imageUrl"] = new_url
                    changed += 1
    return data, changed


def main():
    if not os.path.exists(INPUT_CE):
        raise FileNotFoundError(f"Missing: {INPUT_CE}")
    if not os.path.exists(INPUT_CO):
        raise FileNotFoundError(f"Missing: {INPUT_CO}")

    ce = load_json(INPUT_CE)
    co = load_json(INPUT_CO)

    ce, ce_changed = rewrite_ce(ce)
    co, co_changed = rewrite_co(co)

    if OVERWRITE:
        out_ce = INPUT_CE
        out_co = INPUT_CO
    else:
        out_ce = INPUT_CE.replace(".json", "_rewritten.json")
        out_co = INPUT_CO.replace(".json", "_rewritten.json")

    save_json(out_ce, ce)
    save_json(out_co, co)

    print("✅ Done rewriting URLs")
    print(f"CE updated URLs: {ce_changed}")
    print(f"CO updated URLs: {co_changed}")
    print("Output CE:", out_ce)
    print("Output CO:", out_co)
    print("NEW_BASE:", NEW_BASE)


if __name__ == "__main__":
    main()