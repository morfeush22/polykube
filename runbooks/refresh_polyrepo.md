make pause_all_pipelines

WHAT="rm -r ./*"
make execute_in_all_git_repos

make migrate_all_to_polyrepo
make polyrepo_construct_edge_file
make construct_polyrepo_gocd_yaml_files

WHAT="(git update-index --refresh && test -z "'"$(git status --porcelain)"'") || (git add -A && git commit -m 'new commit $(date -Iseconds)')"
WHAT="${WHAT}" make execute_in_all_git_repos

make giterize_all_polyrepos_git_repos

make unpause_all_pipelines
