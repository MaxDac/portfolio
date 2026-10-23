# Portfolio

Personal portfolio of **Massimiliano D'Acunzo**, a Software Engineer at Microsoft. It covers my career, skills and open-source projects ([FPInk](https://github.com/MaxDac/fpink), [MarkNotes](https://github.com/MaxDac/MarkNotes), [Repentance](https://github.com/MaxDac/Repentance) and [Privee](https://github.com/MaxDac/Privee)).

Built with **Elixir 1.20**, **Phoenix 1.8** and **Phoenix LiveView 1.2**, styled with Tailwind CSS v4 and daisyUI, and deployed on **Fly.io**.

## Features

- A single page with About, Projects, Experience, Skills and Contact sections, plus a detail page for each project (`/projects/:slug`).
- A theme selector with System, Light, Dark, Gruvbox, Nord, Solarized and Dracula. The choice is saved in `localStorage` and applied before the first paint, so the page never flashes the wrong theme.
- No database. All content lives in [`lib/portfolio/content.ex`](lib/portfolio/content.ex).
- A `/health` endpoint for Fly.io health checks.

## Development

Requirements: Elixir 1.20 and Erlang/OTP 29 (see `.tool-versions`).

```bash
mix setup         # fetch deps and install the Tailwind/esbuild binaries
mix phx.server    # http://localhost:4000
mix precommit     # compile with warnings as errors, format and test
```

### Editing content

Profile, highlights, projects, experience, skills, education and the list of themes are all defined in `Portfolio.Content`. Edit that module and the pages update automatically.

To add a theme, add a `@plugin "daisyui/packages/bundle/daisyui-theme"` block to `assets/css/app.css` and register its name in two places:

- `Portfolio.Content.themes/0`
- the `THEMES` list in the inline script in `lib/portfolio_web/components/layouts/root.html.heex`

## Deploying to Fly.io

Production runs at **https://maxdac-portfolio.fly.dev**. Every push to `main`
automatically deploys after both the `test` and `assets` jobs in
`.github/workflows/ci.yml` succeed. Pull requests never deploy. Deployments are
serialized, and superseded main revisions are skipped before deployment.

The pipeline builds the existing `Dockerfile` on the GitHub-hosted runner and
uses `flyctl deploy --local-only --ha=false`, avoiding Fly remote builders and
spare Machines. Images are labeled `git-<commit-sha>` for traceability. Fly health
checks and public smoke checks for `/health`, `/`, and `/projects/fpink` must pass.

### Hosting configuration

`fly.toml` matches the low-resource MarkNotes deployment: one shared CPU, 256 MB
RAM, Amsterdam (`ams`), HTTPS, automatic start/stop, and zero minimum running
Machines. There is no database or persistent volume. Shared IPv4 and public IPv6
provide ingress without a paid dedicated IPv4 address.

**Low cost does not mean guaranteed free.** Fly bills for resource usage unless
account-specific allowances apply, including compute while running, root
filesystem storage while stopped, and outbound traffic. Idle stop reduces
compute usage but introduces cold starts; a single Machine can also mean brief
interruptions during releases. See [Fly pricing](https://fly.io/docs/about/pricing/).

### One-time provisioning

The production app and repository secret are provisioned once using authenticated
local `fly` and `gh` CLIs. Do not repeat app/IP creation for an existing deployment,
and never reuse another app's Phoenix secret or token.

```bash
set -o pipefail
fly apps create maxdac-portfolio --org personal --yes
fly ips allocate-v4 --shared --app maxdac-portfolio --yes
fly ips allocate-v6 --app maxdac-portfolio
printf 'SECRET_KEY_BASE=%s\n' "$(openssl rand -base64 64 | tr -d '\n')" |
  fly secrets import --stage --app maxdac-portfolio
fly tokens create deploy --app maxdac-portfolio --expiry 2160h --name github-actions |
  gh secret set FLY_API_TOKEN --repo MaxDac/portfolio
```

`SECRET_KEY_BASE` stays in Fly secrets; only the app-scoped deploy token is stored
as the GitHub Actions repository secret `FLY_API_TOKEN`. Do not print secrets,
commit them, or run these commands with shell tracing enabled. The first release
is created by pushing the deployment changes to `main`, not by a local deploy.

### Token renewal

The deploy token expires after 90 days (`2160h`). Before expiry, rerun only the
`fly tokens create deploy ... | gh secret set FLY_API_TOKEN ...` command above.
After confirming a successful deployment with the new token, revoke the old token
using Fly's token management tools. An expired or missing token fails deployment;
it does not silently skip a release.

### Recovery

Inspect the failing GitHub Actions job and `fly status --app maxdac-portfolio`,
`fly checks list --app maxdac-portfolio`, or `fly logs --app maxdac-portfolio`.
A deployment or smoke-check failure stays failed; there is no automatic recovery
that hides it.

To restore a known-good release, select its image from
`fly releases --app maxdac-portfolio --image`, then deploy that exact image:

```bash
fly deploy --app maxdac-portfolio --config fly.toml --ha=false \
  --image registry.fly.io/maxdac-portfolio:<known-good-image-tag> --yes
curl --fail --show-error https://maxdac-portfolio.fly.dev/health
```

Coordinate manual recovery with any in-flight Actions deployment so it is not
immediately overwritten. Revert the offending commit through the normal review
process and push/merge the revert to `main` to make subsequent automated
deployments use the corrected code. This app has no database migrations to undo.

## License

The code is released under the MIT License (see [LICENSE](LICENSE)). The personal content (texts about me and my projects) is © Massimiliano D'Acunzo.