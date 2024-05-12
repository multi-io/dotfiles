#!/usr/bin/env bash

. "$(dirname "$0")/env.sh"

if [[ ! -d ".git/rebase-merge" ]]; then
    echo "no rebase in progress, aborting" >&2
    exit 1
fi

if [[ -f .git/MERGE_MSG ]]; then
    # no commit was produced because of a conflict

    # find the commit that we are currently rebasing
    picking="$(tail -1 .git/rebase-merge/done | awk '{print $2}')"

    # we're assuming that the files in $picking that didn't match the filter are causing the conflict -- probably a "deleted by us" conflict
    # find those files, remove them from the commit
    git show --name-only --pretty="" "$picking" | grep -E -v "$FILTER" | xargs -I{} git rm -f {}

    # remove conflict lines from commit message
    sed -i '/^#.*/d' .git/MERGE_MSG

    git commit --no-edit

else
    # a commit was produced, see if we need to amend it

    if [[ -z "$(git show --name-only --pretty="" HEAD | grep -E "$FILTER")" ]]; then
        ## HEAD commit contains no changes to files matching the filter. => remove the commit entirely
        git reset --hard HEAD^;
    else
        # remove files from HEAD that don't match the filter
        git show --name-only --pretty="" HEAD | grep -E -v "$FILTER" | xargs -I{} git rm -f {}

        git commit --amend --no-edit
    fi
fi

git rebase --continue
