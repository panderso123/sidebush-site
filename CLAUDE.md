# CLAUDE.md

High-density working rules. Keep this terse — every token here is spent on every turn.

## Output & scope
- Don't overexplain. Answer the question asked; skip preamble and recap.
- Don't overengineer. Build what was requested, not a generalized framework.
- Don't add unrequested improvements, refactors, or files. Propose them in one line instead of doing them.
- Match the surrounding code's style, naming, and comment density. Don't add narration comments.

## Efficiency
- Speed matters. Prefer the fewest tool calls that get the job done.
- When changing most of a file, use one Write, not many sequential Edits.
- Batch independent tool calls into a single turn so they run in parallel.
- Don't re-fetch or re-run expensive steps (browser automation, large reads) when you already have the result.

## Parallelization & sub-agents
- Fan out independent steps to parallel sub-agents, then fan in to one synthesizer. Don't run independent work serially.
- Keep each sub-agent's context small and self-contained ("zone of good") — short, clean contexts beat one long context.
- For stochastic / open-ended tasks (brainstorm, find-N, research), run multiple agents on the same query and union the unique results — divergence surfaces answers a single run misses.
- Pipeline: for sequential work, hand off between specialist agents (A → B → C) so each stays in its "zone of good" rather than one agent accumulating all context.
- Decompose: split a task into independent branches, run them concurrently, and reserve a final cheap step to integrate.
- Only fan out when steps are genuinely independent. If step B needs step A's output, keep them sequential.

## Auto-research loop
- When a goal has a measurable metric + a change method + a standard assessment, run an iterative loop: hypothesis → change → assess → keep wins, discard losses.
- Maintain a running research log of every attempt and its outcome so past failures and successes aren't re-tried.
- Make one small, isolated change per iteration so each effect is attributable. Repeat until the metric stops improving.

## Automation, cheapest tier first
- Prefer HTTP/API requests: fastest and cheapest at volume, but more setup and more fragile.
- Fall back to browser automation (Chrome DevTools MCP) for general, JS-heavy, or stealth tasks — a good middle ground.
- Reserve computer automation (mouse/keyboard control) for when nothing else works: always works, but slow and token-heavy.
- Prototype with browser automation, capture the underlying network requests, then graft down to plain HTTP for volume.

## Don't over-rely on one model/harness
- Keep a fallback model/harness available so an outage or quality dip doesn't zero out productivity. Don't let one model become a monoculture.

## Docs-first for unfamiliar platforms
- Before using a non-trivial platform/API you don't have solid context on, read its docs first. Search `"API documentation" + <platform name>`.
- If the docs won't load for JS/rendering reasons, open a Chrome DevTools MCP instance so the content can be read.
- Always go through the official API docs when they exist. Tokens spent reading docs save far more tokens than guessing at calls that don't work — docs-first avoids ~99% of integration errors.

## Self-consistency
- Before acting on these rules, check that none directly contradict each other. If two conflict, flag it rather than silently picking one.
