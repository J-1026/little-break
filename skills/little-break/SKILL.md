---
name: little-break
description: 每当用户交给你一个需要动手的任务（搜索、调研、写代码、写文档、生成文件、多步操作），开始之前先用这个技能：在内置浏览器里悄悄备好一个随机小游戏，并在对话里放一张「要不要玩一会」卡片，然后继续任务。用户说「打一把」「换一个游戏」「30分钟内别问」「今天别问」时也用。
---

# Little Break · 干活间隙玩一会

大量用 AI 干活时，人一直在做判断，大脑很累。这个技能让用户在等你干活的时候，可以随手玩一会小游戏。
玩不玩由用户自己决定：你不要等他，不要劝他，也不要在回复里解释这些步骤。

启动页：https://j-1026.github.io/little-break/
启动页每次从游戏列表里随机抽一个游戏，同时记住用户的「别问」设置。它在页面里提供 `window.LB`：

- `LB.status()` → `{ snoozed, until, game, games }`
- `LB.snooze(30)`：30 分钟内不再询问
- `LB.snoozeToday()`：今天不再询问
- `LB.clearSnooze()`：恢复询问
- `LB.next()`：随机换一个游戏

## 什么时候用

- 用户交给你一个需要动手的任务：开始之前，按「任务开始时」做一次。同一个任务只做一次。
- 用户说「打一把」「来一局」「玩一会」：按「用户要玩时」做。
- 用户说「换一个游戏」：按「换游戏」做。
- 用户说「30分钟内别问」「今天别问」「又可以问了」之类的话（包括点卡片按钮发来的消息）：按「别问设置」做。
- 纯闲聊、打招呼、一两句就能回答的问题：不用。

## 任务开始时

几秒钟的事，做完立刻继续任务。

1. **没有内置浏览器工具**（工具名里没有 `Claude_Browser`）：在回复最开头写一行「任务在跑，要不要玩一会？https://j-1026.github.io/little-break/」，然后直接去做任务，后面几步都跳过。

2. **备好游戏。** 用 `tabs_context` 看有没有已经开着启动页（https://j-1026.github.io）的标签页。没有的话，用 `preview_start` 在新标签页打开 https://j-1026.github.io/little-break/，不要切到前台。

3. **看用户是不是设置了「别问」。** 在这个标签页上用 `javascript_tool` 执行 `LB.status()`。如果页面还没加载好，等 1 秒再试一次；还是不行，就当作没有设置「别问」。
   - 如果 `snoozed` 是 true：**不放卡片，什么都不说**，直接去做任务。
   - 否则记下 `game`，也就是这次抽到的游戏名。

4. **放卡片。** 用内联可视化工具（例如 `show_widget`；如果它要求先调用一次说明工具，比如 `read_me`，就静默调用，不要提）把下面的 HTML 原样画出来，title 用 `little_break_card`，并把里面的 `{{GAME}}` 换成上一步拿到的游戏名。没有可视化工具的话，就在回复开头写一行：「任务在跑，要不要玩一会？这次是 {{GAME}}，按 ⌘⇧B 开玩（Windows 是 Ctrl+Shift+B）。」

5. **继续做用户交给你的任务。**

卡片 HTML：

```html
<h2 class="sr-only">A card offering a quick game while Claude works.</h2>
<div style="background: var(--surface-2); border: 0.5px solid var(--border); border-radius: 12px; padding: 14px 16px;">
  <div style="display: flex; align-items: center; gap: 14px;">
    <div style="flex: none; width: 40px; height: 40px; border-radius: var(--radius); background: var(--bg-accent); display: flex; align-items: center; justify-content: center;"><i class="ti ti-device-gamepad-2" style="font-size: 20px; color: var(--text-accent);" aria-hidden="true"></i></div>
    <div style="flex: 1; min-width: 0;">
      <p id="lb-t" style="margin: 0; font-weight: 500; font-size: 15px;">任务在跑，要不要玩一会？</p>
      <p id="lb-s" style="margin: 0; font-size: 13px; color: var(--text-secondary);">这次是{{GAME}}，已在旁边备好，按 <span style="font-family: var(--font-mono); font-size: 12px; padding: 1px 6px; border: 0.5px solid var(--border-strong); border-radius: 4px;">⌘ ⇧ B</span> 开玩</p>
    </div>
  </div>
  <div id="lb-a" style="display: flex; gap: 8px; justify-content: flex-end; margin-top: 10px;">
    <button id="lb-no">不用了</button>
    <button id="lb-30">30 分钟内别问</button>
    <button id="lb-day">今天别问</button>
  </div>
</div>
<script>
function lbDone(t, s) {
  document.getElementById('lb-a').style.display = 'none';
  document.getElementById('lb-t').textContent = t;
  document.getElementById('lb-s').textContent = s;
}
document.getElementById('lb-no').onclick = function () { lbDone('好，那就专心等结果', '想玩的时候随时按 ⌘⇧B'); };
document.getElementById('lb-30').onclick = function () { lbDone('好，30 分钟内不再问你', '想玩的时候随时按 ⌘⇧B'); sendPrompt('Little Break：30分钟内别问'); };
document.getElementById('lb-day').onclick = function () { lbDone('好，今天不再问你', '想玩的时候随时按 ⌘⇧B'); sendPrompt('Little Break：今天别问'); };
</script>
```

## 用户要玩时

找到启动页标签页（没有就用 `preview_start` 打开 https://j-1026.github.io/little-break/），用 `tabs_select` 切到它，再看 `tabs_context` 里面板是不是隐藏的。如果是隐藏的，告诉用户按 ⌘⇧B（Windows 是 Ctrl+Shift+B）调出来。回复一句话就够了。

## 换游戏

在启动页标签页上执行 `LB.next()`，告诉用户这次换成了哪个游戏。一句话就够了。

## 别问设置

在启动页标签页上执行对应的方法（没有这个标签页就先用 `preview_start` 打开），然后用一句话确认：

- 「30分钟内别问」或其他时长 → `LB.snooze(分钟数)`
- 「今天别问」 → `LB.snoozeToday()`
- 「又可以问了」「恢复」 → `LB.clearSnooze()`

如果这条消息是在你干活的中途点按钮发来的，确认完就继续之前的任务。
