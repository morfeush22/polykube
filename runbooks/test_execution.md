Testing commits 382e93e46cffa001393c6fd6edaf74990e503538..7a576bc3935a6b555e33346fd73ad77c925e9e4a (30 commits)
Repeat each polyrepo run 3 times (?).
Repeat each monorepo run 1 time.

Test 1-n worker nodes + 1 E2E test worker node.

1. Start server infrastructure (make start_server_infra)
1. Pause/unpause desired pipelines (monorepo/polyrepo) (make pause_all_pipelines)
1. Prune docker (docker image prune --all, docker volume prune, docker network prune)
1. Stop GoCD clients (make delete_gocd_clients)
1. Start GoCD clients (make run_gocd_clients/make run_gocd_clients_common) (check number of workers)
1. Save current timestamp (timestamp=`date +%s%3N`)
1. Checkout desired commit in Kubernetes repository
1. Refresh repositories/revert/empty commit
    1. Save changed files (easiest in monorepo) (git diff --name-only sha1 sha2)
    1. Save changed repositories names (check subset_repos_ops.md, ignore version files - need to check manually)
1. Unpause pipelines (i.e. make unpause_all_pipelines REGEXP_FILTER='polyrepo')
1. Save results (make calculate_pipelines_duration FROM_DATE_MS=$timestamp) rollback and repeat 1/n times from beginning

To revert:
CHANGED_REPOS_LIST - no new lines at beginning and end (https://stackoverflow.com/questions/7359527/removing-trailing-starting-newlines-with-sed-awk-tr-and-friends)
export WHAT="git revert HEAD --no-edit"
make execute_in_git_repos GIT_REPOS_FILE=<(tail -n +1 <<<"$CHANGED_REPOS_LIST") - x 2 (execute twice)
giterize

To empty commit:
CHANGED_REPOS_LIST - no new lines at beginning and end (https://stackoverflow.com/questions/7359527/removing-trailing-starting-newlines-with-sed-awk-tr-and-friends)
WHAT="echo '$(uuidgen)' > .trigger_build; git add -A; git commit -m 'new commit $(date -Iseconds)'"
WHAT="${WHAT}" make execute_in_git_repos GIT_REPOS_FILE=<(tail -n +1 <<<"$CHANGED_REPOS_LIST")
giterize

https://docs.google.com/document/d/1-OgO8XZ2gB6ascMxDIA9dLrqQp5SI2Cm8qD2iZtBNnQ/edit
https://docs.google.com/spreadsheets/d/1S5cRHrhdKVGhwXjBTjtIAvFRhE-Aoy2S1pRLjhAZk1o/edit#gid=0
