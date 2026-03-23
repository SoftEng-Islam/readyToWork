# Contributing

## Local Setup

```bash
cp .env.example .env
pnpm install
pnpm check:setup
pnpm dev
```

## Workflow Expectations

- Keep changes focused and explain the user-facing impact in the pull request.
- Run `pnpm check` before you open a pull request.
- Update `.env.example`, `README.md`, or `Overview.md` when configuration or setup steps change.
- Do not commit local secrets, build artifacts, or dependency folders.

## Pull Requests

- Link the issue or problem statement that motivated the change.
- Include screenshots or recordings for visible UI changes.
- Call out any new environment variables, database changes, or breaking behavior.
- Prefer follow-up pull requests over mixing unrelated refactors into the same branch.
