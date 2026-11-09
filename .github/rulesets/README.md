# Repository rulesets

These files are this repository's GitHub rulesets, as they are live. GitHub
doesn't read them. After a pull request that changes one of them merges, a
repository admin applies it with `gh` from the repository root.

| File | Enforces |
| --- | --- |
| `signed-commits.json` | A verified signature on every commit of `main`. No bypass actors. |
| `main.json` | `main`: pull requests with two approvals and resolved review threads, merge commits only; no deletion or force push. Organization admins can bypass it. |

Every commit on `main` needs a verified signature. Commits on a pull
request's branch don't need one while it is open. Before it merges, a
maintainer rewrites the branch as one commit, signs that commit with their
own key and pushes it, and then merges it with a merge commit, which GitHub
signs. So `main` gains one commit a person signed, and one merge commit.

That push dismisses earlier approvals. Two people approve again, or an
organization admin merges the pull request through the `main` ruleset's
bypass.

The repository's settings allow merge commits only (Settings → General → Pull
Requests). GitHub's squash merge would make the commit itself and sign it
with GitHub's key, so no person's signature would reach `main`. Its rebase
merge makes commits with no signature, which the rule refuses.

## Apply a change

Define `repo` and `apply` first. This block changes nothing on GitHub:

```bash
repo=repos/Qbit-Org/qbit-white-paper
apply() {
  local name id
  name=$(jq -er .name "$1") || return
  id=$(gh api "$repo/rulesets?includes_parents=false&per_page=100" --jq ".[] | select(.name == \"$name\") | .id") || return
  if [ -n "$id" ]; then
    gh api -X PUT "$repo/rulesets/$id" --input "$1" --jq '"updated \(.name) (\(.id))"'
  else
    gh api -X POST "$repo/rulesets" --input "$1" --jq '"created \(.name) (\(.id))"'
  fi
}
```

Then run `apply` once for each file that changed, here `main.json`. It
updates the ruleset of that name, or creates it when GitHub has none:

```bash
apply .github/rulesets/main.json
```

A ruleset is found by its name. To rename one, rename it on GitHub first,
then apply the file.

The merge-method setting isn't a ruleset. To set a repository up from these
files, apply `signed-commits.json` before anything else, then the other
files, then the setting, so there is never a moment when an unsigned commit
could be merged. The chain stops at the first step that fails. Fix that
step and run the chain again: applying a file twice is harmless.

```bash
apply .github/rulesets/signed-commits.json &&
  apply .github/rulesets/main.json &&
  gh api -X PATCH "$repo" -F allow_merge_commit=true -F allow_squash_merge=false -F allow_rebase_merge=false
```

## Check that GitHub matches

```bash
repo=repos/Qbit-Org/qbit-white-paper
list="$repo/rulesets?includes_parents=false&per_page=100"
norm='{name, target, enforcement, conditions, rules: (.rules | sort_by(.type)), bypass_actors: (.bypass_actors | sort_by(.actor_type, .actor_id))}'
for f in .github/rulesets/*.json; do
  name=$(jq -r .name "$f")
  id=$(gh api "$list" --jq ".[] | select(.name == \"$name\") | .id")
  if [ -z "$id" ]; then
    echo "$name: not on GitHub"
  elif diff <(jq -S "$norm" "$f") <(gh api "$repo/rulesets/$id" | jq -S "$norm"); then
    echo "$name: matches"
  else
    echo "$name: differs (lines with < are the file's, > are GitHub's)"
  fi
done
gh api "$list" --jq '.[].name' | while read -r name; do
  [ -f ".github/rulesets/$name.json" ] || echo "$name: on GitHub, but has no file"
done
gh api "$repo" --jq '{allow_merge_commit, allow_squash_merge, allow_rebase_merge}'
```

Every line should say `matches`, and the settings should show merge commits
only. `includes_parents=false` leaves out organization rulesets, which these
files don't hold.
