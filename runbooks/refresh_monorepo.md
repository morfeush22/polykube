make pause_all_pipelines

WHAT="rm -r ./*"
WHAT="${WHAT}" make execute_in_all_git_repos EXECUTE_IN_ALL_GIT_REPOS_DEST_ROOT_DIR="${HOME}/Projects/masters/monorepo"

make migrate_all_to_monorepo
make create_monorepo_gocd_yamls_subdir

WHAT="(git update-index --refresh && test -z "'"$(git status --porcelain)"'") || (git add -A && git commit -m 'new commit $(date -Iseconds)')"
WHAT="${WHAT}" make execute_in_all_git_repos EXECUTE_IN_ALL_GIT_REPOS_DEST_ROOT_DIR="${HOME}/Projects/masters/monorepo"

make giterize_all_monorepos_git_repos

make unpause_all_pipelines
