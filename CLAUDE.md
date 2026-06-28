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
- Decompose: split a task into independent branches, run them concurrently, and reserve a final cheap step to integrate.
- Only fan out when steps are genuinely independent. If step B needs step A's output, keep them sequential.

## Docs-first for unfamiliar platforms
- Before using a non-trivial platform/API you don't have solid context on, read its docs first. Search `"API documentation" + <platform name>`.
- If the docs won't load for JS/rendering reasons, open a Chrome DevTools MCP instance so the content can be read.
- Always go through the official API docs when they exist. Tokens spent reading docs save far more tokens than guessing at calls that don't work — docs-first avoids ~99% of integration errors.

## Self-consistency
- Before acting on these rules, check that none directly contradict each other. If two conflict, flag it rather than silently picking one.
