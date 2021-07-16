make pause_all_pipelines

make execute_in_all_git_repos WHAT="rm -r ./*"

make migrate_all_to_polyrepo
make polyrepo_construct_edge_file
make construct_polyrepo_gocd_yaml_files
make giterize_all_polyrepos_git_repos

make execute_in_all_git_repos WHAT="git add -A"
make execute_in_all_git_repos WHAT="git commit -m 'new commit''"

make giterize_all_polyrepos_git_repos

make unpause_all_pipelines
