# Local GitHub Pages Build

```sh
bin/pages install
bin/pages build
bin/pages serve
```

Open http://localhost:4000 after starting the server.

## Woodpecker CI

The [workflow](.woodpecker.yaml) runs on pushes to `main` and `development` and on manual runs after this
repository is enabled in Woodpecker. It selects a native Mac or Linux ARM64/Pi worker with the
tools below. Both use the **local backend**, not a Docker image: `image: bash` selects the
shell. Portable jobs take any matching available worker; strict Mac-first priority is not
configured.

[`.ci/check.sh`](.ci/check.sh) contains the project-specific build/test commands. Run the same
checks locally from the repository root with `bash .ci/check.sh`. Prerequisites: Python 3.11+, Ruby 3.x and Bundler. The existing bin/pages helper builds Jekyll
with the GitHub Pages gem set; on macOS it prefers Homebrew ruby@3.3 when installed. Put Ruby
3.x on PATH on Linux. Bundler resolves dependencies as in the existing local build; Gemfile.lock
remains ignored by this repository. This validates the site build and does not deploy GitHub
Pages.

Configure the server's GitHub integration and a reachable webhook endpoint once. The agents
connect outbound; no SSH access to the Mac is needed. Install the native `plugin-git` clone
helper and put all required tools on the worker's PATH. Use one workflow at a time per worker
because browser suites and simulators share local resources. Run only trusted code under a
dedicated worker account; the local backend is not a sandbox. Configure a finite repository
pipeline timeout.

Add a repository-scoped fine-grained **user PAT** as the Woodpecker secret
`github_comment_token`, with Contents: write permission for this repository (required to update
comments). It is injected only into the comment step. That step creates a pass/fail comment on
`CI_COMMIT_SHA`, with the pipeline link and a bounded failure excerpt; repeating the report for
the same pipeline/workflow updates its own comment. A reporting failure fails the step instead
of silently claiming that a comment was sent. Woodpecker's built-in commit statuses remain
separate from these comments.

Console output is retained by Woodpecker according to the server's retention policy. Files in
`.ci-output/` (including any raw Xcode log/result bundle) are temporary workspace output, not
automatically uploaded artifacts. Configure artifact storage before relying on those files after
worker cleanup. A Tailnet-only log link requires Tailnet access; the comment excerpt is stored
on GitHub and visible to repository readers. Known token values are masked, but logs must not
contain private data.

Test the reporter without network access: `python3 -B .ci/test_report.py`. No CI server, secret,
webhook or worker is provisioned merely by adding these files. Existing GitHub Actions workflows
are unchanged.
