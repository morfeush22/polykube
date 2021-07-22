make pause_all_pipelines

make execute_in_all_git_repos EXECUTE_IN_ALL_GIT_REPOS_DEST_ROOT_DIR="${HOME}/Projects/masters/monorepo" WHAT="rm -r ./*"

make migrate_all_to_monorepo
make create_monorepo_gocd_yamls_subdir

make execute_in_all_git_repos EXECUTE_IN_ALL_GIT_REPOS_DEST_ROOT_DIR="${HOME}/Projects/masters/monorepo" WHAT="(git update-index --refresh && git diff-index --quiet HEAD --) || (git add -A && git commit -m 'new commit $(date -Iseconds)')"

make giterize_all_monorepos_git_repos

make unpause_all_pipelines
