# GitHub workflow setup (BlackRaven-V2)

## 1. Authenticate `gh` (one time on this machine)

```bash
export PATH="$HOME/.local/bin:$PATH"
gh auth login
```

Choose: **GitHub.com** → **HTTPS** → **Login with a web browser** (or paste a PAT with `repo` scope).

Verify:

```bash
gh auth status
```

## 2. Create the remote repo (no "Fork" banner)

```bash
export PATH="$HOME/.local/bin:$PATH"
cd ~/BlackRaven-V2
gh repo create BlackRavenNetwork/BlackRaven-V2 \
  --private \
  --description "BlackRaven (BLKR) v2 — community chain based on BlackRaven" \
  --source=. \
  --remote=origin \
  --push
```

Use `--public` instead of `--private` if you want a public repo.

If the repo already exists on GitHub:

```bash
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/BlackRavenNetwork/BlackRaven-V2.git
git push -u origin v2/blackraven-transition
```

## 3. Day-to-day workflow

```bash
git checkout v2/blackraven-transition
./contrib/rebrand-to-blackraven.sh   # after review
git add -A && git commit -m "Describe change"
git push origin v2/blackraven-transition
gh pr create --base main --head v2/blackraven-transition --title "..." --body "..."
```

## 4. Optional: keep BlackRaven upstream for merges

`upstream-neoxa` remote points at BlackRavenChain/BlackRaven for occasional reference (do not push there).
