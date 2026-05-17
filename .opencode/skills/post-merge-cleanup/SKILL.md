---
name: post-merge-cleanup
description: Use after a pull request has been merged in edwinhern/dotfiles to verify local main is fast-forwarded, the PR is merged, closing issues are closed, project items are Done, latest main CI passed, and git status is clean. Use when the user says a PR merged, asks to clean up after merge, or asks to verify post-merge state.
---

# Post-Merge Cleanup

Use this skill only in `edwinhern/dotfiles` after a PR has already been merged.

## Required Input

Use a PR number from the user, such as `#28` or `28`.

If the user does not give a PR number, infer it only when `gh pr view --json number` clearly resolves the current branch to one PR. If it cannot be inferred, ask one short question for the PR number.

## Scope

- Verify post-merge state with fresh commands.
- Switch local checkout to `main` and fast-forward it.
- Confirm the merged PR closed its linked issue or issues.
- Confirm the linked issue project items are `Done` in the `dotfiles` project.
- Confirm the latest `main` CI for the merge commit passed.
- Confirm the final git status is clean.

Do not choose the next issue. Do not merge PRs, close issues, delete branches, or delete worktrees.

## Workflow

1. Verify repository identity:
   Run `gh repo view --json nameWithOwner -q .nameWithOwner`.
   Continue only if it returns `edwinhern/dotfiles`.

2. Check for local changes:
   Run `git status --short --branch`.
   If there are modified, staged, or untracked files, stop and report them before switching branches.

3. Sync `main`:
   Run `git switch main`.
   Run `git pull --ff-only`.

4. Verify the PR:
   Run `gh pr view <PR> --repo edwinhern/dotfiles --json number,title,state,mergedAt,mergeCommit,closingIssuesReferences,url`.
   Require `state` to be `MERGED` and `mergeCommit.oid` to be present.
   If `closingIssuesReferences` is empty, report that the PR did not link a closing issue and stop.

5. Verify each closing issue:
   For each issue number in `closingIssuesReferences`, run `gh issue view <ISSUE> --repo edwinhern/dotfiles --json number,title,state,closedAt,url`.
   Require `state` to be `CLOSED`.

6. Verify project status:
   Run `gh project view 6 --owner edwinhern --format json`.
   Require `title` to be `dotfiles`.
   For each closing issue, run `gh project item-list 6 --owner edwinhern --format json --query "#<ISSUE>" --limit 20`.
   Find the item whose `content.number` matches the issue number.
   If no matching project item is found, report it and stop.
   Require the matching item `status` to be `Done`.

7. Verify CI for the merge commit:
   Run `gh run list --repo edwinhern/dotfiles --branch main --commit <MERGE_SHA> --workflow CI --json databaseId,displayTitle,workflowName,status,conclusion,headSha,url --limit 1`.
   Require one `CI` workflow run for `<MERGE_SHA>` and require it to have `status` `completed` and `conclusion` `success`.

8. Verify final local state:
   Run `git status --short --branch`.
   Require the output to show `main` tracking `origin/main` with no file changes.

## Report

Return a concise checklist with evidence:

- `main` sync result and current branch line
- PR number, merged state, merged time, and merge SHA
- Each closing issue number and closed state
- Project title
- Each project item status
- CI workflow conclusion and URL
- Final git status

If any check fails, report the failed check, include the command evidence, and stop without claiming cleanup is complete.
