CLEANUP after force-push to main
================================

What happened
------------
The repository `origin/main` was rewritten with a clean history (force-pushed) to remove build artifacts and start fresh.

If you previously had a local clone or branches based on the old `main`, your local history will diverge from the remote. Use the steps below to recover.

Recommended recovery options
----------------------------

1) If you don't have local changes to keep (fast, recommended):

```bash
git fetch origin
git checkout -B main origin/main
git pull --ff-only
```

2) If you have local commits you want to keep:

Create a backup branch, then rebase or cherry-pick onto the new main.

```bash
# create a backup
git branch backup-before-main
# fetch the new main
git fetch origin
# rebase your backup branch onto the new main
git checkout backup-before-main
git rebase origin/main
# resolve conflicts if any, then push to a new branch
git push origin backup-before-main:refs/heads/backup-before-main
```

3) If you prefer to re-clone (cleanest):

```bash
cd ..
git clone https://github.com/molofson/NowPlayingApp.git
```

Notes
-----
- After recovery, confirm `git log --oneline --graph --decorate --all` shows the new main as expected.
- If you maintain long-lived branches that were based on the old history, you may need to rebase them onto the new `origin/main`.

Questions or problems
---------------------
If you run into issues, open an issue or contact the repository owner with details about your local state and any errors from the commands above.
