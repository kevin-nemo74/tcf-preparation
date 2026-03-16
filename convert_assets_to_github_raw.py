import json
import os
from urllib.parse import quote

# -----------------------------
# CONFIG
# -----------------------------
REPO_RAW_BASE = "https://raw.githubusercontent.com/kevin-nemo74/tcf-preparation/main/"
INPUT_CE = "assets/data/ce_tests.json"
INPUT_CO = "assets/data/co_tests.json"

# If True, overwrite original JSON files.
# If False, write to *_remote.json files.
OVERWRITE = True


# -----------------------------
# HELPERS
# -----------------------------
def normalize_asset_path(p: str) -> str:
    """
    Convert an asset path like:
      assets/images/ce/ce_01/q1.webp
    to a repo-relative path:
      assets/images/ce/ce_01/q1.webp

    Then URL-encode it safely for raw.githubusercontent.
    """
    p = p.strip().replace("\\", "/")
    if p.startswith("/"):
        p = p[1:]
    # Keep it as repo path; your repo has /assets/... so leave it
    # URL encode each segment but keep slashes
    return quote(p, safe="/-_.~")


def to_raw_url(asset_path: str) -> str:
    rel = normalize_asset_path(asset_path)
    return REPO_RAW_BASE + rel


def convert_ce_tests(data):
    """
    Convert CE questions:
      imagePath -> imageUrl
    """
    for test in data:
        for q in test.get("questions", []):
            if "imagePath" in q and q["imagePath"]:
                q["imageUrl"] = to_raw_url(q["imagePath"])
                del q["imagePath"]
    return data


def convert_co_tests(data):
    """
    Convert CO questions:
      audioPath -> audioUrl
      imagePath -> imageUrl (optional)
    """
    for test in data:
        for q in test.get("questions", []):
            if "audioPath" in q and q["audioPath"]:
                q["audioUrl"] = to_raw_url(q["audioPath"])
                del q["audioPath"]

            if "imagePath" in q and q["imagePath"]:
                q["imageUrl"] = to_raw_url(q["imagePath"])
                del q["imagePath"]
            else:
                # If imagePath missing or empty, ensure no imageUrl
                q.pop("imageUrl", None)

    return data


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_json(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def main():
    if not os.path.exists(INPUT_CE):
        raise FileNotFoundError(f"Missing: {INPUT_CE}")
    if not os.path.exists(INPUT_CO):
        raise FileNotFoundError(f"Missing: {INPUT_CO}")

    ce = load_json(INPUT_CE)
    co = load_json(INPUT_CO)

    ce = convert_ce_tests(ce)
    co = convert_co_tests(co)

    if OVERWRITE:
        out_ce = INPUT_CE
        out_co = INPUT_CO
    else:
        out_ce = INPUT_CE.replace(".json", "_remote.json")
        out_co = INPUT_CO.replace(".json", "_remote.json")

    save_json(out_ce, ce)
    save_json(out_co, co)

    print("✅ Done!")
    print("CE output:", out_ce)
    print("CO output:", out_co)
    print("Base URL:", REPO_RAW_BASE)


if __name__ == "__main__":
    main()