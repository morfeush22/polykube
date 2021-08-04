WHAT="(git update-index --refresh >/dev/null && test -z "'"$(git status --porcelain)"'") || pwd"
WHAT="${WHAT}" make execute_in_all_git_repos 2>/dev/null

WHAT="(git update-index --refresh >/dev/null && test -z "'"$(git status --porcelain)"'") || (pwd; git status)"
WHAT="${WHAT}" make execute_in_all_git_repos 2>/dev/null

WHAT="(git update-index --refresh >/dev/null && test -z "'"$(git status --porcelain)"'") || pwd"
CHANGED_REPOS_LIST="$(WHAT="${WHAT}" make execute_in_all_git_repos 2>/dev/null)"

WHAT=ls
./execute-in-git-repos.sh <(tail -n +2 <<<"$CHANGED_REPOS_LIST") 2>/dev/null

make execute_in_git_repos GIT_REPOS_FILE=<(tail -n +2 <<<"$CHANGED_REPOS_LIST")
