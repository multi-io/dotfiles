# initial split

hack/initial-split.sh


# subsequent splits:

git checkout -b new-pub-master

git rebase -i --onto pub-master last-pub-merge
... change all commits to "e" ...

on each prompt, run hack/rebase-i-edit.sh blindly until "Successfully rebased and updated refs/heads/master."

git branch -f pub-master new-pub-master

git checkout master
git merge pub-master --no-edit --allow-unrelated-histories
git tag -f last-pub-merge
git branch -D new-pub-master
