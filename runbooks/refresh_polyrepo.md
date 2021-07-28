make pause_all_pipelines

make execute_in_all_git_repos WHAT="rm -r ./*"

make migrate_all_to_polyrepo
make polyrepo_construct_edge_file
make construct_polyrepo_gocd_yaml_files

make execute_in_all_git_repos WHAT="(git update-index --refresh && test -z \"\$(git status --porcelain)\") || (git add -A && git commit -m 'new commit $(date -Iseconds)')"

make giterize_all_polyrepos_git_repos

make unpause_all_pipelines
