Testing commits 382e93e46cffa001393c6fd6edaf74990e503538..7a576bc3935a6b555e33346fd73ad77c925e9e4a (30 commits)
Repeat each polyrepo run 3 times (?).
Repeat each monorepo run 1 time.

Test 1-3 worker nodes + 1 E2E test worker node.

1. Start server infrastructure (make start_server_infra)
1. Pause/unpause desired pipelines (monorepo/polyrepo)
1. Prune docker (docker image prune --all, docker volume prune, docker network prune)
1. Stop GoCD clients (make delete_gocd_clients)
1. Start GoCD clients(make run_gocd_clients)
1. Save current timestamp (timestamp=`date +%s%3N`)
1. Checkout desired commit in Kubernetes repository
1. Refresh repositories
    1. Save changed files (easiest in monorepo)
    1. Save changed repositories names (check subset_repos_ops.md)
1. Save results (make calculate_pipelines_duration FROM_DATE_MS=$timestamp) rollback and repeat 1/3 times from beginning

To revert:
CHANGED_REPOS_LIST - no new lines at beginning and end (https://stackoverflow.com/questions/7359527/removing-trailing-starting-newlines-with-sed-awk-tr-and-friends)
WHAT="git revert HEAD --no-edit" make execute_in_git_repos GIT_REPOS_FILE=<(tail -n +1 <<<"$CHANGED_REPOS_LIST") - x 2
giterize

https://docs.google.com/document/d/1-OgO8XZ2gB6ascMxDIA9dLrqQp5SI2Cm8qD2iZtBNnQ/edit
