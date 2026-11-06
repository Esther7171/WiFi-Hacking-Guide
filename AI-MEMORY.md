# AI Working Memory — WiFi-Hacking-Guide

_For the AI assistant (Claude). Read on fresh clone to restore context._

## What this repo is
A wireless penetration testing handbook (owner's lab notes, full workflow, and defensive guidance). Single source of truth is `README.md`; the MkDocs Material site is built from it at CI time. Owner: deathesther.

## State & plan
- Lives on both remotes: `origin` = GitLab (deathesther/wifi-hacking-guide), `github` = GitHub (Esther7171/WiFi-Hacking-Guide). Keep both in sync.
- Name kept as `wifi-hacking-guide` deliberately (discoverability). Do NOT rename to a "pentesting" slug unless the owner asks again in the current message.
- MkDocs Material site (`mkdocs.yml`, `.gitlab-ci.yml`) renders Mermaid via pymdownx.superfences custom_fences.
- `checklists/` holds eight printable per-area assessment checklists.
- Social preview card points at `github.com/Esther7171/WiFi-Hacking-Guide`.

## How to continue
Pull from GitLab or GitHub. Markdown guide plus MkDocs. No application build step; the CI job copies README.md to docs/index.md.

## Constraints
- Commits authored only as **deathesther**, never add any Claude co-author / attribution line.
- Never use em dashes anywhere. Use hyphens, colons, periods, or parentheses.
- Do NOT push to any remote automatically. Commit locally only; push to BOTH GitHub and GitLab only when the owner explicitly says to push in the current message.
- Content stays safety-first: lab-only framing for anything disruptive, no fabricated hardware/test results, no credential-harvesting or sustained-DoS recipes aimed at production.
