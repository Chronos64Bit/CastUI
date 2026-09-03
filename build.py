"""
CastUI Bundler
The Ventryx Company
Compiles modular src/ files into dist/CastUI.lua and main.lua
"""

import os
import re
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).parent
SRC_DIR = ROOT_DIR / "src"
DIST_DIR = ROOT_DIR / "dist"
DIST_FILE = DIST_DIR / "CastUI.lua"
MAIN_FILE = ROOT_DIR / "main.lua"

def normalize_module_name(file_path: Path) -> str:
    rel = file_path.relative_to(SRC_DIR)
    parts = list(rel.parts)
    # Remove extension
    parts[-1] = re.sub(r'\.luau?$', '', parts[-1])
    return ".".join(parts)

def resolve_require(match, current_module: str) -> str:
    req_body = match.group(1).strip()
    
    # If already a string quote require("...")
    str_match = re.match(r'["\']([^"\']+)["\']', req_body)
    if str_match:
        return f'require("{str_match.group(1)}")'
    
    tokens = req_body.split('.')
    if tokens[0] != "script":
        return match.group(0) # Not a script-relative require
    
    # script represents the current file
    curr_parts = current_module.split('.')
    
    idx = 1
    # Count how many .Parent tokens
    parent_count = 0
    while idx < len(tokens) and tokens[idx] == "Parent":
        parent_count += 1
        idx += 1
    
    # If there are Parent tokens, each Parent removes one level:
    # 1 Parent removes the file itself (giving its directory)
    # 2 Parents removes the directory (giving parent directory), etc.
    if parent_count > 0:
        base_parts = curr_parts[:-parent_count] if parent_count <= len(curr_parts) else []
    else:
        # No Parent tokens (e.g. script.Services from Init)
        # Sibling of current file in root
        base_parts = curr_parts[:-1]
    
    remaining = tokens[idx:]
    final_parts = base_parts + remaining
    resolved = ".".join(final_parts)
    return f'require("{resolved}")'

def transform_source(content: str, mod_name: str) -> str:
    # Pattern to match require(script...)
    pattern = re.compile(r'require\s*\(\s*(script[^)]+)\s*\)')
    transformed = pattern.sub(lambda m: resolve_require(m, mod_name), content)
    return transformed

def build():
    print("=" * 60)
    print("  CastUI  High-Performance Bundler")
    print("  The Ventryx Company")
    print("=" * 60)

    if not SRC_DIR.exists():
        print(f"Error: {SRC_DIR} does not exist.")
        sys.exit(1)

    DIST_DIR.mkdir(parents=True, exist_ok=True)

    modules = {}
    
    for root, _, files in os.walk(SRC_DIR):
        for file in files:
            if file.endswith((".luau", ".lua")):
                full_path = Path(root) / file
                mod_name = normalize_module_name(full_path)
                with open(full_path, "r", encoding="utf-8") as f:
                    content = f.read()
                transformed = transform_source(content, mod_name)
                modules[mod_name] = transformed
                print(f" [+] Bundled module: {mod_name}")

    if "Init" not in modules:
        print("Error: src/Init.luau not found!")
        sys.exit(1)

    bundle_lines = [
        "--[[\n"
        "\tCastUI\n"
        "\tModern Glass UI Library for Roblox Luau\n"
        "\tDeveloped by The Ventryx Company\n"
        "\n"
        "\tHigh Performance • Modern Acrylic Aesthetics • Zero Telemetry\n"
        "--]]\n",
        "return (function()\n",
        "\tlocal _modules = {}\n",
        "\tlocal _cache = {}\n\n",
        "\tlocal function require(modName: string)\n",
        "\t\tif _cache[modName] then\n",
        "\t\t\treturn _cache[modName]\n",
        "\t\tend\n",
        "\t\tlocal fn = _modules[modName]\n",
        "\t\tif not fn then\n",
        "\t\t\terror(\"[CastUI] Module not found: \" .. tostring(modName))\n",
        "\t\tend\n",
        "\t\tlocal result = fn(require)\n",
        "\t\t_cache[modName] = result\n",
        "\t\treturn result\n",
        "\tend\n\n"
    ]

    for mod_name, code in modules.items():
        bundle_lines.append(f'\t-- Module: {mod_name}\n')
        bundle_lines.append(f'\t_modules["{mod_name}"] = function(require)\n')
        for line in code.splitlines():
            bundle_lines.append(f"\t\t{line}\n")
        bundle_lines.append("\tend\n\n")

    bundle_lines.append('\treturn require("Init")\n')
    bundle_lines.append("end)()")

    bundled_code = "".join(bundle_lines)

    with open(DIST_FILE, "w", encoding="utf-8") as f:
        f.write(bundled_code)
    print(f"\n[OK] Generated: {DIST_FILE} ({len(bundled_code):,} bytes)")

    with open(MAIN_FILE, "w", encoding="utf-8") as f:
        f.write(bundled_code)
    print(f"[OK] Updated: {MAIN_FILE} ({len(bundled_code):,} bytes)")
    print("=" * 60)

if __name__ == "__main__":
    build()
