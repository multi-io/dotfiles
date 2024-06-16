#!/usr/bin/env bash

set -e

. ./hack/env.sh

git checkout -b pub-master
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch \
    --tree-filter "git ls-files | egrep -v '$FILTER' | xargs -i rm -rf {}" \
    --prune-empty \
    HEAD

git checkout master
git merge pub-master --no-edit --allow-unrelated-histories
git tag last-pub-merge
