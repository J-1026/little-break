# Little Break

**干活间隙，玩一会。** · *A little game while Claude works.*

[中文](#中文) · [English](#english)

---

## 中文

### 为什么做这个

大量用 AI 干活的时候，人要不停地做判断：这版对不对、够不够好、下一步怎么走。判断越多，大脑负荷越大，而且越往后只会越来越大。

Little Break 是一个 Claude 技能。你给 Claude 布置一个任务，它开始干活的时候，会在对话里问你一句：**要不要玩一会？** 想玩就按一下，游戏已经在旁边备好了；不想玩就接着等结果。Claude 不会停下来等你。

### 它做什么

- **每个任务开始时问一次**：只在真正需要动手的任务前出现，闲聊不会打扰你。
- **游戏是随机的**：每次从游戏列表里随机抽一个。现在列表里只有「守城小国王」，以后会换成或加入更多自己做的小游戏。
- **不打扰机制**：卡片上可以选「30 分钟内别问」或「今天别问」。这个设置会被记住，换一个对话也有效。
- **玩的地方就在 Claude 里**：游戏在 Claude 桌面版的内置浏览器里打开，按 ⌘⇧B（Windows 是 Ctrl+Shift+B）就能调出来。

### 安装

**Claude 桌面版 / 网页版**

在 Claude 对话里粘贴这一句，Claude 会弹出「保存技能」卡片，点保存即可：

```
帮我安装这个技能：https://github.com/J-1026/little-break
```

没有弹卡片的话，下载 [little-break-skill.zip](https://github.com/J-1026/little-break/releases/latest/download/little-break-skill.zip)，在 Customize › Skills 里点「+」→「Create skill」→「Upload a skill」上传。

> 卡片和「备好游戏」需要 Claude 桌面版的内置浏览器。在网页版或手机上，Claude 会改成在回复开头放一行游戏链接。

**Codex / Claude Code（macOS、Linux）**

在终端里粘贴这一行：

```
curl -fsSL https://j-1026.github.io/little-break/install.sh | bash
```

它会装好技能，并加一个 hook：你每次发任务，电脑上会弹出一个小窗口问「要不要玩一会？」，按钮是「来一局 / 30 分钟内别问 / 今天别问」。不靠模型判断，每次都会问（同一段时间内最多 5 分钟问一次，太短的消息比如「好的」不会问）。装完重启 Codex / Claude Code；Codex 如果提示有新 hook，输入 `/hooks` 信任它。

Claude Code 也可以用插件方式装：
```
/plugin marketplace add J-1026/little-break
/plugin install little-break@little-break
```

### 可以对 Claude / Codex 说的话

| 说 | 效果 |
| --- | --- |
| 打一把 | 马上打开游戏 |
| 换一个游戏 | 随机换一个 |
| 30分钟内别问 | 30 分钟内不再出现 |
| 今天别问 | 今天不再出现 |
| 又可以问了 | 恢复询问 |

### 换成你自己的游戏

游戏列表在 [`games.json`](games.json)：

```json
[
  { "name": "守城小国王", "url": "https://little-king-git-war-mode-sheji.vercel.app/" }
]
```

想用自己的游戏：Fork 这个仓库，改 `games.json`，在仓库设置里开启 GitHub Pages（从 `main` 分支的根目录部署），再把 `skills/little-break/SKILL.md` 里的启动页地址改成你自己的 Pages 地址，重新打包上传即可。游戏需要是能在网页里打开、并且允许被嵌入（iframe）的页面。

### 文件结构

```
index.html                    启动页：随机抽游戏、记住「别问」设置（GitHub Pages 托管）
games.json                    游戏列表
skills/little-break/SKILL.md  技能本体
scripts/little-break.sh       Codex / Claude Code 用的弹窗脚本
install.sh                    一行命令安装
hooks/hooks.json              Claude Code 插件的 hook
.claude-plugin/               Claude Code 插件配置
```

---

## English

### Why

Working with AI all day means making judgment calls nonstop: is this right, is it good enough, what's next. That load keeps growing.

Little Break is a Claude skill. When you hand Claude a task and it starts working, it asks you in the chat: **want to play for a bit?** The game is already loaded on the side. Play, or skip it. Claude keeps working either way.

### What it does

- **Asks once per task**: only before real work, never during small talk.
- **Random game**: picks one from the game list each time. Today the list has one game (守城小国王 · Little King); more of my own games will rotate in.
- **Don't-disturb options**: the card offers "not for 30 minutes" and "not today". The setting is remembered across conversations.
- **Plays inside Claude**: the game opens in the Claude desktop app's built-in browser. Press ⌘⇧B (Ctrl+Shift+B on Windows) to bring it up.

### Install

**Claude desktop / web**

Paste this into a Claude chat. Claude shows a "save skill" card; click save:

```
Install this skill for me: https://github.com/J-1026/little-break
```

If no card appears, download [little-break-skill.zip](https://github.com/J-1026/little-break/releases/latest/download/little-break-skill.zip) and upload it under Customize › Skills → "+" → "Create skill" → "Upload a skill".

> The card and preloading need the built-in browser of the Claude desktop app. On the web or mobile, Claude falls back to a one-line game link.

**Codex / Claude Code (macOS, Linux)**

Paste this into your terminal:

```
curl -fsSL https://j-1026.github.io/little-break/install.sh | bash
```

It installs the skill plus a hook: every time you send a task, a small window pops up asking "want to play for a bit?" with "Play / Not for 30 min / Not today". It doesn't rely on the model, so it asks every time (at most once every 5 minutes; very short messages like "ok" are skipped). Restart Codex / Claude Code afterwards; if Codex says there's a new hook to review, run `/hooks` and trust it.

Claude Code can also install it as a plugin:
```
/plugin marketplace add J-1026/little-break
/plugin install little-break@little-break
```

### Things you can say

| Say | Does |
| --- | --- |
| 打一把 / play | Opens the game now |
| 换一个游戏 / another game | Picks another random game |
| 30分钟内别问 / not for 30 min | Pauses for 30 minutes |
| 今天别问 / not today | Pauses until tomorrow |
| 又可以问了 / resume | Turns it back on |

### Use your own games

Edit [`games.json`](games.json) in a fork, enable GitHub Pages (deploy from the root of `main`), point the launcher URL in `skills/little-break/SKILL.md` at your Pages site, then re-zip and upload. Games must be web pages that allow being embedded in an iframe.
