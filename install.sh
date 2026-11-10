#!/usr/bin/env bash
# Little Break installer for Codex and Claude Code (macOS / Linux)
#   curl -fsSL https://j-1026.github.io/little-break/install.sh | bash
set -e

BASE="${LB_BASE:-https://j-1026.github.io/little-break}"
LB_HOME="$HOME/.little-break"
SCRIPT="$LB_HOME/little-break.sh"
HOOK_CMD="bash \"$SCRIPT\" hook"

say() { printf '%s\n' "$*"; }
fetch() { curl -fsSL "$1" -o "$2"; }

say "Little Break · 安装中…"
mkdir -p "$LB_HOME"
fetch "$BASE/scripts/little-break.sh" "$SCRIPT"
chmod +x "$SCRIPT"
fetch "$BASE/skills/little-break/SKILL.md" "$LB_HOME/SKILL.md"

add_hook() {  # $1 = json file
  local file="$1"
  if ! command -v python3 >/dev/null 2>&1; then
    say "  ⚠️  没找到 python3，没法自动写入 $file"
    say "     请手动在 UserPromptSubmit 里加一条 command hook：$HOOK_CMD"
    return 1
  fi
  python3 - "$file" "$HOOK_CMD" <<'PY'
import json, os, sys
path, cmd = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f) or {}
    except Exception:
        print("  ⚠️  " + path + " 不是合法的 JSON，跳过，没有改动它")
        sys.exit(1)
hooks = data.setdefault("hooks", {})
groups = hooks.setdefault("UserPromptSubmit", [])
for g in groups:
    for h in g.get("hooks", []):
        if "little-break.sh" in h.get("command", ""):
            print("  ✓ hook 已存在：" + path)
            sys.exit(0)
groups.append({"hooks": [{"type": "command", "command": cmd, "timeout": 10}]})
if os.path.exists(path):
    os.replace(path, path + ".bak-little-break")
with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print("  ✓ 已写入 hook：" + path)
PY
}

installed=0

# ---- Codex ----
if [ -d "$HOME/.codex" ] || command -v codex >/dev/null 2>&1; then
  say "→ Codex"
  mkdir -p "$HOME/.codex/skills/little-break"
  cp "$LB_HOME/SKILL.md" "$HOME/.codex/skills/little-break/SKILL.md"
  say "  ✓ 技能：~/.codex/skills/little-break"
  add_hook "$HOME/.codex/hooks.json" || true
  if grep -Eq '^[[:space:]]*(codex_)?hooks[[:space:]]*=[[:space:]]*false' "$HOME/.codex/config.toml" 2>/dev/null; then
    say "  ⚠️  你的 ~/.codex/config.toml 里关掉了 hooks（hooks = false），需要改回 true 才会弹出"
  fi
  installed=1
fi

# ---- Claude Code ----
if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
  say "→ Claude Code"
  mkdir -p "$HOME/.claude/skills/little-break"
  cp "$LB_HOME/SKILL.md" "$HOME/.claude/skills/little-break/SKILL.md"
  say "  ✓ 技能：~/.claude/skills/little-break"
  add_hook "$HOME/.claude/settings.json" || true
  installed=1
fi

if [ "$installed" = "0" ]; then
  say "没找到 Codex 或 Claude Code。脚本已放在 $SCRIPT，装好它们之后再运行一次这条命令即可。"
  exit 0
fi

say ""
say "装好了。重启 Codex / Claude Code 后，交给它一个任务，就会弹出「要不要玩一会？」"
say "Codex 第一次启动时如果提示有新 hook 需要确认，输入 /hooks 信任它。"
say "随时可以对它说：打一把 / 30分钟内别问 / 今天别问 / 又可以问了"
