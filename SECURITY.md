# 🔒 Security Policy

Ghostforge is a shell configuration that you run on your own machine. Every file
here either executes as you (`install.sh`), runs on every shell start
(`configs/.zshrc`), or runs on every prompt render (`configs/starship.toml`).
That makes a bug in this repo a bug with your shell's privileges, so security
reports are genuinely welcome.

---

## 📬 Reporting a Vulnerability

**Report privately, through GitHub:**

### → [Open a private security advisory](https://github.com/KevinArce/ghostforge/security/advisories/new)

That link uses GitHub's private vulnerability reporting, which is enabled on
this repo. The report is visible only to the maintainer until a fix ships, and
you get a thread to discuss it in.

> [!WARNING]
> **Please don't open a public issue or pull request for a security problem.**
> A public report tells everyone running this config how to exploit them before
> there's a fix. Use the private advisory link above instead.

### What to include

The more of this you have, the faster it gets fixed — but a partial report is
much better than no report:

| | |
|---|---|
| **Which file** | e.g. `install.sh`, `configs/.zshrc`, `configs/starship.toml` |
| **What happens** | The impact — arbitrary command execution, a file clobbered outside the repo, a leaked secret, a hijacked `PATH` |
| **How to trigger it** | Repro steps, or the input that sets it off (a crafted directory or branch name, a hostile repo you `cd` into, an environment variable) |
| **Your setup** | macOS version, chip (Apple Silicon / Intel), and `zsh --version` |

### What to expect

This is a personal project maintained in spare time, not a funded product, so
these are honest targets rather than an SLA:

| Stage | Target |
|-------|--------|
| First acknowledgement | Within **7 days** |
| Initial assessment | Within **14 days** |
| Fix for a confirmed high-impact issue | As quickly as is practical, pushed to `main` |

If two weeks pass with no reply, please bump the advisory thread — it means the
notification got lost, not that the report was dismissed.

There is no bug bounty, paid or otherwise. Credit in the advisory and the commit
is yours if you'd like it; tell me if you'd rather stay anonymous.

---

## 🎯 Scope

### In scope

The things this repo actually controls:

- **`install.sh`** — it runs with your privileges, writes outside the repo
  (`~/.zshrc`, `~/.config/ghostty/`, `~/.config/starship.toml`), edits your
  **global** git config (`core.pager`, `interactive.diffFilter`), and uses
  `duti` to make Ghostty the default handler for `.sh`, `.command`, `.zsh` and
  `.bash` files. Unsafe overwrites, a missing backup, a path that isn't quoted,
  or a privilege or file-association change beyond what the README documents are
  all in scope.
- **`configs/.zshrc`** — sourced on every interactive shell. Command injection,
  `PATH` ordering that lets a local directory shadow a real binary, or an `eval`
  of something an attacker can influence.
- **`configs/starship.toml`** — the `[custom.git_clean]`, `[custom.pnpm]`,
  `[custom.yarn]` and `[custom.npm]` blocks run shell commands **every time the
  prompt draws**. Anything that lets repository-controlled data (a branch name,
  a path, a `package.json` field) reach one of those commands as code is exactly
  the kind of bug worth reporting.
- **`configs/ghostty_config`** and **`configs/ghostty-themes/`** — settings that
  weaken terminal safety, such as unguarded clipboard or paste handling.
- **`tests/test_prompt.sh`** and **`docs/`** — including documentation that
  tells you to run something unsafe.

### Out of scope

Ghostforge installs third-party tools but does not ship them. Vulnerabilities in
the tools themselves belong upstream, where they can actually be fixed:

- **Homebrew** and any formula or cask it installs
- **Ghostty**, **Starship**, **zoxide**, **fzf**, `zsh-autosuggestions`,
  `zsh-syntax-highlighting`
- **bat**, **eza**, **fd**, **ripgrep**, **dust**, **btop**, **yazi**,
  **lazygit**, **git-delta**, **tmux**, **duti**
- **zsh**, **git**, and macOS itself

Also out of scope: anything that requires an attacker to already have code
execution or local access as your user, since at that point they can edit your
`.zshrc` directly and this config changes nothing.

If you're unsure which side of the line a finding falls on, report it anyway —
misrouted reports are easy to redirect, and I'd rather see it.

---

## 📌 Supported Versions

Ghostforge has no tagged releases. It's a rolling config, so only the current
state of `main` is supported.

| Version | Supported |
|---------|-----------|
| Latest commit on `main` | ✅ |
| Any older commit | ❌ — pull `main` and re-run `./install.sh` |

Fixes land on `main`. There are no backports, so updating means pulling and
re-running the installer, which is idempotent and backs up your `.zshrc` first.

---

## 🤝 Disclosure

Coordinated disclosure, kept simple:

1. You report privately using the advisory link above.
2. We confirm the issue and agree on the impact.
3. A fix lands on `main`.
4. The advisory is published with credit to you, and the README notes it if
   users need to take action themselves.

Please hold off on publishing until the fix is on `main`. If you need to
disclose on a fixed date regardless, say so in your first message and we'll work
to that deadline instead.

---

## 🛡️ A Note on Trusting This Repo

Ghostforge replaces your shell config and runs an installer, which is a real
amount of trust to hand a repo you found on the internet. So, plainly:

- **Read `install.sh` before you run it.** It's 166 lines of commented bash. It
  never calls `sudo`, and it downloads nothing itself — every install goes
  through `brew`. The one `curl` you'll spot is inside a quoted `echo` on line
  44: it prints Homebrew's own install command as a hint when Homebrew is
  missing, and the script then exits rather than running it.
- **Your old `.zshrc` is backed up**, not discarded — look for
  `~/.zshrc.backup.<timestamp>`.
- **Note that the installer changes two things beyond the terminal:** your
  global git pager becomes `delta`, and shell scripts start opening in Ghostty.
  Both are documented in the README, and both are reversible.

Verifying this yourself is the right instinct, and finding that the code doesn't
match this description is itself worth a report.
