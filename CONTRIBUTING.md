# Contributing

Contributions are welcome. All contributed code will be covered by the Apache License v2 of this project.

## Linting

eth-docker CI uses [pre-commit](https://pre-commit.com/) to lint all code within the repo. Add it to your local
copy with `pip install pre-commit` and `pre-commit install`.

This repo uses a squash-and-merge workflow to avoid extra merge commits. You can create a git alias with
`git config --global alias.push-clean '!git fetch upstream main && git rebase upstream/main && git push -f'`
and then `git push-clean` to your fork before opening a PR.
