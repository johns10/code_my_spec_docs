# Git



## add(repository, args \\ [])

Run `git add` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## add!(repository, args \\ [])

Same as `add/2` but raises an exception on error.

## add__interactive(repository, args \\ [])

Run `git add--interactive` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## add__interactive!(repository, args \\ [])

Same as `add__interactive/2` but raises an exception on error.

## am(repository, args \\ [])

Run `git am` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## am!(repository, args \\ [])

Same as `am/2` but raises an exception on error.

## annotate(repository, args \\ [])

Run `git annotate` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## annotate!(repository, args \\ [])

Same as `annotate/2` but raises an exception on error.

## archimport(repository, args \\ [])

Run `git archimport` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## archimport!(repository, args \\ [])

Same as `archimport/2` but raises an exception on error.

## archive(repository, args \\ [])

Run `git archive` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## archive!(repository, args \\ [])

Same as `archive/2` but raises an exception on error.

## bisect(repository, args \\ [])

Run `git bisect` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## bisect!(repository, args \\ [])

Same as `bisect/2` but raises an exception on error.

## bisect__helper(repository, args \\ [])

Run `git bisect--helper` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## bisect__helper!(repository, args \\ [])

Same as `bisect__helper/2` but raises an exception on error.

## blame(repository, args \\ [])

Run `git blame` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## blame!(repository, args \\ [])

Same as `blame/2` but raises an exception on error.

## branch(repository, args \\ [])

Run `git branch` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## branch!(repository, args \\ [])

Same as `branch/2` but raises an exception on error.

## bundle(repository, args \\ [])

Run `git bundle` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## bundle!(repository, args \\ [])

Same as `bundle/2` but raises an exception on error.

## cat_file(repository, args \\ [])

Run `git cat-file` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## cat_file!(repository, args \\ [])

Same as `cat_file/2` but raises an exception on error.

## check_attr(repository, args \\ [])

Run `git check-attr` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## check_attr!(repository, args \\ [])

Same as `check_attr/2` but raises an exception on error.

## check_ignore(repository, args \\ [])

Run `git check-ignore` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## check_ignore!(repository, args \\ [])

Same as `check_ignore/2` but raises an exception on error.

## check_mailmap(repository, args \\ [])

Run `git check-mailmap` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## check_mailmap!(repository, args \\ [])

Same as `check_mailmap/2` but raises an exception on error.

## check_ref_format(repository, args \\ [])

Run `git check-ref-format` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## check_ref_format!(repository, args \\ [])

Same as `check_ref_format/2` but raises an exception on error.

## checkout(repository, args \\ [])

Run `git checkout` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## checkout!(repository, args \\ [])

Same as `checkout/2` but raises an exception on error.

## checkout_index(repository, args \\ [])

Run `git checkout-index` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## checkout_index!(repository, args \\ [])

Same as `checkout_index/2` but raises an exception on error.

## cherry(repository, args \\ [])

Run `git cherry` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## cherry!(repository, args \\ [])

Same as `cherry/2` but raises an exception on error.

## cherry_pick(repository, args \\ [])

Run `git cherry-pick` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## cherry_pick!(repository, args \\ [])

Same as `cherry_pick/2` but raises an exception on error.

## citool(repository, args \\ [])

Run `git citool` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## citool!(repository, args \\ [])

Same as `citool/2` but raises an exception on error.

## clean(repository, args \\ [])

Run `git clean` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## clean!(repository, args \\ [])

Same as `clean/2` but raises an exception on error.

## clone(args)

Clones the repository. The first argument can be `url` or `[url, path]`.
Returns `{:ok, repository}` on success and `{:error, reason}` on failure.

## clone!(args)

Same as clone/1 but raise an exception on failure.

## column(repository, args \\ [])

Run `git column` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## column!(repository, args \\ [])

Same as `column/2` but raises an exception on error.

## commit(repository, args \\ [])

Run `git commit` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## commit!(repository, args \\ [])

Same as `commit/2` but raises an exception on error.

## commit_tree(repository, args \\ [])

Run `git commit-tree` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## commit_tree!(repository, args \\ [])

Same as `commit_tree/2` but raises an exception on error.

## config(repository, args \\ [])

Run `git config` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## config!(repository, args \\ [])

Same as `config/2` but raises an exception on error.

## count_objects(repository, args \\ [])

Run `git count-objects` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## count_objects!(repository, args \\ [])

Same as `count_objects/2` but raises an exception on error.

## credential(repository, args \\ [])

Run `git credential` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## credential!(repository, args \\ [])

Same as `credential/2` but raises an exception on error.

## credential_cache(repository, args \\ [])

Run `git credential-cache` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## credential_cache!(repository, args \\ [])

Same as `credential_cache/2` but raises an exception on error.

## credential_cache__daemon(repository, args \\ [])

Run `git credential-cache--daemon` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## credential_cache__daemon!(repository, args \\ [])

Same as `credential_cache__daemon/2` but raises an exception on error.

## credential_gnome_keyring(repository, args \\ [])

Run `git credential-gnome-keyring` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## credential_gnome_keyring!(repository, args \\ [])

Same as `credential_gnome_keyring/2` but raises an exception on error.

## credential_store(repository, args \\ [])

Run `git credential-store` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## credential_store!(repository, args \\ [])

Same as `credential_store/2` but raises an exception on error.

## cvsexportcommit(repository, args \\ [])

Run `git cvsexportcommit` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## cvsexportcommit!(repository, args \\ [])

Same as `cvsexportcommit/2` but raises an exception on error.

## cvsimport(repository, args \\ [])

Run `git cvsimport` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## cvsimport!(repository, args \\ [])

Same as `cvsimport/2` but raises an exception on error.

## cvsserver(repository, args \\ [])

Run `git cvsserver` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## cvsserver!(repository, args \\ [])

Same as `cvsserver/2` but raises an exception on error.

## daemon(repository, args \\ [])

Run `git daemon` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## daemon!(repository, args \\ [])

Same as `daemon/2` but raises an exception on error.

## describe(repository, args \\ [])

Run `git describe` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## describe!(repository, args \\ [])

Same as `describe/2` but raises an exception on error.

## diff(repository, args \\ [])

Run `git diff` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## diff!(repository, args \\ [])

Same as `diff/2` but raises an exception on error.

## diff_files(repository, args \\ [])

Run `git diff-files` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## diff_files!(repository, args \\ [])

Same as `diff_files/2` but raises an exception on error.

## diff_index(repository, args \\ [])

Run `git diff-index` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## diff_index!(repository, args \\ [])

Same as `diff_index/2` but raises an exception on error.

## diff_tree(repository, args \\ [])

Run `git diff-tree` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## diff_tree!(repository, args \\ [])

Same as `diff_tree/2` but raises an exception on error.

## difftool(repository, args \\ [])

Run `git difftool` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## difftool!(repository, args \\ [])

Same as `difftool/2` but raises an exception on error.

## difftool__helper(repository, args \\ [])

Run `git difftool--helper` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## difftool__helper!(repository, args \\ [])

Same as `difftool__helper/2` but raises an exception on error.

## execute_command(repo, command, args, callback)

Execute the git command in the given repository.

## fast_export(repository, args \\ [])

Run `git fast-export` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## fast_export!(repository, args \\ [])

Same as `fast_export/2` but raises an exception on error.

## fast_import(repository, args \\ [])

Run `git fast-import` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## fast_import!(repository, args \\ [])

Same as `fast_import/2` but raises an exception on error.

## fetch(repository, args \\ [])

Run `git fetch` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## fetch!(repository, args \\ [])

Same as `fetch/2` but raises an exception on error.

## fetch_pack(repository, args \\ [])

Run `git fetch-pack` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## fetch_pack!(repository, args \\ [])

Same as `fetch_pack/2` but raises an exception on error.

## filter_branch(repository, args \\ [])

Run `git filter-branch` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## filter_branch!(repository, args \\ [])

Same as `filter_branch/2` but raises an exception on error.

## fmt_merge_msg(repository, args \\ [])

Run `git fmt-merge-msg` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## fmt_merge_msg!(repository, args \\ [])

Same as `fmt_merge_msg/2` but raises an exception on error.

## for_each_ref(repository, args \\ [])

Run `git for-each-ref` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## for_each_ref!(repository, args \\ [])

Same as `for_each_ref/2` but raises an exception on error.

## format_patch(repository, args \\ [])

Run `git format-patch` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## format_patch!(repository, args \\ [])

Same as `format_patch/2` but raises an exception on error.

## fsck(repository, args \\ [])

Run `git fsck` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## fsck!(repository, args \\ [])

Same as `fsck/2` but raises an exception on error.

## fsck_objects(repository, args \\ [])

Run `git fsck-objects` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## fsck_objects!(repository, args \\ [])

Same as `fsck_objects/2` but raises an exception on error.

## gc(repository, args \\ [])

Run `git gc` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## gc!(repository, args \\ [])

Same as `gc/2` but raises an exception on error.

## get_tar_commit_id(repository, args \\ [])

Run `git get-tar-commit-id` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## get_tar_commit_id!(repository, args \\ [])

Same as `get_tar_commit_id/2` but raises an exception on error.

## grep(repository, args \\ [])

Run `git grep` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## grep!(repository, args \\ [])

Same as `grep/2` but raises an exception on error.

## gui(repository, args \\ [])

Run `git gui` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## gui!(repository, args \\ [])

Same as `gui/2` but raises an exception on error.

## gui__askpass(repository, args \\ [])

Run `git gui--askpass` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## gui__askpass!(repository, args \\ [])

Same as `gui__askpass/2` but raises an exception on error.

## hash_object(repository, args \\ [])

Run `git hash-object` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## hash_object!(repository, args \\ [])

Same as `hash_object/2` but raises an exception on error.

## help(repository, args \\ [])

Run `git help` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## help!(repository, args \\ [])

Same as `help/2` but raises an exception on error.

## http_backend(repository, args \\ [])

Run `git http-backend` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## http_backend!(repository, args \\ [])

Same as `http_backend/2` but raises an exception on error.

## http_fetch(repository, args \\ [])

Run `git http-fetch` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## http_fetch!(repository, args \\ [])

Same as `http_fetch/2` but raises an exception on error.

## http_push(repository, args \\ [])

Run `git http-push` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## http_push!(repository, args \\ [])

Same as `http_push/2` but raises an exception on error.

## imap_send(repository, args \\ [])

Run `git imap-send` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## imap_send!(repository, args \\ [])

Same as `imap_send/2` but raises an exception on error.

## index_pack(repository, args \\ [])

Run `git index-pack` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## index_pack!(repository, args \\ [])

Same as `index_pack/2` but raises an exception on error.

## init!(args \\ [])

Run `git init` in the given directory
Returns `{:ok, repository}` on success and `{:error, reason}` on failure.

## init_db(repository, args \\ [])

Run `git init-db` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## init_db!(repository, args \\ [])

Same as `init_db/2` but raises an exception on error.

## instaweb(repository, args \\ [])

Run `git instaweb` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## instaweb!(repository, args \\ [])

Same as `instaweb/2` but raises an exception on error.

## interpret_trailers(repository, args \\ [])

Run `git interpret-trailers` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## interpret_trailers!(repository, args \\ [])

Same as `interpret_trailers/2` but raises an exception on error.

## log(repository, args \\ [])

Run `git log` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## log!(repository, args \\ [])

Same as `log/2` but raises an exception on error.

## ls_files(repository, args \\ [])

Run `git ls-files` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## ls_files!(repository, args \\ [])

Same as `ls_files/2` but raises an exception on error.

## ls_remote(repository, args \\ [])

Run `git ls-remote` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## ls_remote!(repository, args \\ [])

Same as `ls_remote/2` but raises an exception on error.

## ls_tree(repository, args \\ [])

Run `git ls-tree` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## ls_tree!(repository, args \\ [])

Same as `ls_tree/2` but raises an exception on error.

## mailinfo(repository, args \\ [])

Run `git mailinfo` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## mailinfo!(repository, args \\ [])

Same as `mailinfo/2` but raises an exception on error.

## mailsplit(repository, args \\ [])

Run `git mailsplit` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## mailsplit!(repository, args \\ [])

Same as `mailsplit/2` but raises an exception on error.

## merge(repository, args \\ [])

Run `git merge` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge!(repository, args \\ [])

Same as `merge/2` but raises an exception on error.

## merge_base(repository, args \\ [])

Run `git merge-base` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge_base!(repository, args \\ [])

Same as `merge_base/2` but raises an exception on error.

## merge_file(repository, args \\ [])

Run `git merge-file` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge_file!(repository, args \\ [])

Same as `merge_file/2` but raises an exception on error.

## merge_index(repository, args \\ [])

Run `git merge-index` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge_index!(repository, args \\ [])

Same as `merge_index/2` but raises an exception on error.

## merge_octopus(repository, args \\ [])

Run `git merge-octopus` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge_octopus!(repository, args \\ [])

Same as `merge_octopus/2` but raises an exception on error.

## merge_one_file(repository, args \\ [])

Run `git merge-one-file` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge_one_file!(repository, args \\ [])

Same as `merge_one_file/2` but raises an exception on error.

## merge_ours(repository, args \\ [])

Run `git merge-ours` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge_ours!(repository, args \\ [])

Same as `merge_ours/2` but raises an exception on error.

## merge_recursive(repository, args \\ [])

Run `git merge-recursive` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge_recursive!(repository, args \\ [])

Same as `merge_recursive/2` but raises an exception on error.

## merge_resolve(repository, args \\ [])

Run `git merge-resolve` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge_resolve!(repository, args \\ [])

Same as `merge_resolve/2` but raises an exception on error.

## merge_subtree(repository, args \\ [])

Run `git merge-subtree` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge_subtree!(repository, args \\ [])

Same as `merge_subtree/2` but raises an exception on error.

## merge_tree(repository, args \\ [])

Run `git merge-tree` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## merge_tree!(repository, args \\ [])

Same as `merge_tree/2` but raises an exception on error.

## mergetool(repository, args \\ [])

Run `git mergetool` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## mergetool!(repository, args \\ [])

Same as `mergetool/2` but raises an exception on error.

## mktag(repository, args \\ [])

Run `git mktag` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## mktag!(repository, args \\ [])

Same as `mktag/2` but raises an exception on error.

## mktree(repository, args \\ [])

Run `git mktree` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## mktree!(repository, args \\ [])

Same as `mktree/2` but raises an exception on error.

## mv(repository, args \\ [])

Run `git mv` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## mv!(repository, args \\ [])

Same as `mv/2` but raises an exception on error.

## name_rev(repository, args \\ [])

Run `git name-rev` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## name_rev!(repository, args \\ [])

Same as `name_rev/2` but raises an exception on error.

## new(path \\ ".")

Return a Git.Repository struct with the specified or defaulted path.
For use with an existing repo (when Git.init and Git.clone would not be appropriate).

## notes(repository, args \\ [])

Run `git notes` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## notes!(repository, args \\ [])

Same as `notes/2` but raises an exception on error.

## p4(repository, args \\ [])

Run `git p4` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## p4!(repository, args \\ [])

Same as `p4/2` but raises an exception on error.

## pack_objects(repository, args \\ [])

Run `git pack-objects` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## pack_objects!(repository, args \\ [])

Same as `pack_objects/2` but raises an exception on error.

## pack_redundant(repository, args \\ [])

Run `git pack-redundant` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## pack_redundant!(repository, args \\ [])

Same as `pack_redundant/2` but raises an exception on error.

## pack_refs(repository, args \\ [])

Run `git pack-refs` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## pack_refs!(repository, args \\ [])

Same as `pack_refs/2` but raises an exception on error.

## patch_id(repository, args \\ [])

Run `git patch-id` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## patch_id!(repository, args \\ [])

Same as `patch_id/2` but raises an exception on error.

## prune(repository, args \\ [])

Run `git prune` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## prune!(repository, args \\ [])

Same as `prune/2` but raises an exception on error.

## prune_packed(repository, args \\ [])

Run `git prune-packed` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## prune_packed!(repository, args \\ [])

Same as `prune_packed/2` but raises an exception on error.

## pull(repository, args \\ [])

Run `git pull` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## pull!(repository, args \\ [])

Same as `pull/2` but raises an exception on error.

## push(repository, args \\ [])

Run `git push` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## push!(repository, args \\ [])

Same as `push/2` but raises an exception on error.

## quiltimport(repository, args \\ [])

Run `git quiltimport` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## quiltimport!(repository, args \\ [])

Same as `quiltimport/2` but raises an exception on error.

## read_tree(repository, args \\ [])

Run `git read-tree` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## read_tree!(repository, args \\ [])

Same as `read_tree/2` but raises an exception on error.

## rebase(repository, args \\ [])

Run `git rebase` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## rebase!(repository, args \\ [])

Same as `rebase/2` but raises an exception on error.

## receive_pack(repository, args \\ [])

Run `git receive-pack` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## receive_pack!(repository, args \\ [])

Same as `receive_pack/2` but raises an exception on error.

## reflog(repository, args \\ [])

Run `git reflog` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## reflog!(repository, args \\ [])

Same as `reflog/2` but raises an exception on error.

## relink(repository, args \\ [])

Run `git relink` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## relink!(repository, args \\ [])

Same as `relink/2` but raises an exception on error.

## remote(repository, args \\ [])

Run `git remote` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## remote!(repository, args \\ [])

Same as `remote/2` but raises an exception on error.

## remote_ext(repository, args \\ [])

Run `git remote-ext` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## remote_ext!(repository, args \\ [])

Same as `remote_ext/2` but raises an exception on error.

## remote_fd(repository, args \\ [])

Run `git remote-fd` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## remote_fd!(repository, args \\ [])

Same as `remote_fd/2` but raises an exception on error.

## remote_ftp(repository, args \\ [])

Run `git remote-ftp` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## remote_ftp!(repository, args \\ [])

Same as `remote_ftp/2` but raises an exception on error.

## remote_ftps(repository, args \\ [])

Run `git remote-ftps` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## remote_ftps!(repository, args \\ [])

Same as `remote_ftps/2` but raises an exception on error.

## remote_http(repository, args \\ [])

Run `git remote-http` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## remote_http!(repository, args \\ [])

Same as `remote_http/2` but raises an exception on error.

## remote_https(repository, args \\ [])

Run `git remote-https` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## remote_https!(repository, args \\ [])

Same as `remote_https/2` but raises an exception on error.

## remote_testsvn(repository, args \\ [])

Run `git remote-testsvn` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## remote_testsvn!(repository, args \\ [])

Same as `remote_testsvn/2` but raises an exception on error.

## repack(repository, args \\ [])

Run `git repack` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## repack!(repository, args \\ [])

Same as `repack/2` but raises an exception on error.

## replace(repository, args \\ [])

Run `git replace` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## replace!(repository, args \\ [])

Same as `replace/2` but raises an exception on error.

## request_pull(repository, args \\ [])

Run `git request-pull` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## request_pull!(repository, args \\ [])

Same as `request_pull/2` but raises an exception on error.

## rerere(repository, args \\ [])

Run `git rerere` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## rerere!(repository, args \\ [])

Same as `rerere/2` but raises an exception on error.

## reset(repository, args \\ [])

Run `git reset` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## reset!(repository, args \\ [])

Same as `reset/2` but raises an exception on error.

## rev_list(repository, args \\ [])

Run `git rev-list` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## rev_list!(repository, args \\ [])

Same as `rev_list/2` but raises an exception on error.

## rev_parse(repository, args \\ [])

Run `git rev-parse` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## rev_parse!(repository, args \\ [])

Same as `rev_parse/2` but raises an exception on error.

## revert(repository, args \\ [])

Run `git revert` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## revert!(repository, args \\ [])

Same as `revert/2` but raises an exception on error.

## rm(repository, args \\ [])

Run `git rm` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## rm!(repository, args \\ [])

Same as `rm/2` but raises an exception on error.

## send_email(repository, args \\ [])

Run `git send-email` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## send_email!(repository, args \\ [])

Same as `send_email/2` but raises an exception on error.

## send_pack(repository, args \\ [])

Run `git send-pack` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## send_pack!(repository, args \\ [])

Same as `send_pack/2` but raises an exception on error.

## sh_i18n__envsubst(repository, args \\ [])

Run `git sh-i18n--envsubst` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## sh_i18n__envsubst!(repository, args \\ [])

Same as `sh_i18n__envsubst/2` but raises an exception on error.

## shell(repository, args \\ [])

Run `git shell` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## shell!(repository, args \\ [])

Same as `shell/2` but raises an exception on error.

## shortlog(repository, args \\ [])

Run `git shortlog` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## shortlog!(repository, args \\ [])

Same as `shortlog/2` but raises an exception on error.

## show(repository, args \\ [])

Run `git show` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## show!(repository, args \\ [])

Same as `show/2` but raises an exception on error.

## show_branch(repository, args \\ [])

Run `git show-branch` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## show_branch!(repository, args \\ [])

Same as `show_branch/2` but raises an exception on error.

## show_index(repository, args \\ [])

Run `git show-index` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## show_index!(repository, args \\ [])

Same as `show_index/2` but raises an exception on error.

## show_ref(repository, args \\ [])

Run `git show-ref` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## show_ref!(repository, args \\ [])

Same as `show_ref/2` but raises an exception on error.

## stage(repository, args \\ [])

Run `git stage` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## stage!(repository, args \\ [])

Same as `stage/2` but raises an exception on error.

## stash(repository, args \\ [])

Run `git stash` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## stash!(repository, args \\ [])

Same as `stash/2` but raises an exception on error.

## status(repository, args \\ [])

Run `git status` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## status!(repository, args \\ [])

Same as `status/2` but raises an exception on error.

## stripspace(repository, args \\ [])

Run `git stripspace` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## stripspace!(repository, args \\ [])

Same as `stripspace/2` but raises an exception on error.

## submodule(repository, args \\ [])

Run `git submodule` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## submodule!(repository, args \\ [])

Same as `submodule/2` but raises an exception on error.

## subtree(repository, args \\ [])

Run `git subtree` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## subtree!(repository, args \\ [])

Same as `subtree/2` but raises an exception on error.

## svn(repository, args \\ [])

Run `git svn` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## svn!(repository, args \\ [])

Same as `svn/2` but raises an exception on error.

## symbolic_ref(repository, args \\ [])

Run `git symbolic-ref` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## symbolic_ref!(repository, args \\ [])

Same as `symbolic_ref/2` but raises an exception on error.

## tag(repository, args \\ [])

Run `git tag` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## tag!(repository, args \\ [])

Same as `tag/2` but raises an exception on error.

## unpack_file(repository, args \\ [])

Run `git unpack-file` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## unpack_file!(repository, args \\ [])

Same as `unpack_file/2` but raises an exception on error.

## unpack_objects(repository, args \\ [])

Run `git unpack-objects` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## unpack_objects!(repository, args \\ [])

Same as `unpack_objects/2` but raises an exception on error.

## update_index(repository, args \\ [])

Run `git update-index` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## update_index!(repository, args \\ [])

Same as `update_index/2` but raises an exception on error.

## update_ref(repository, args \\ [])

Run `git update-ref` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## update_ref!(repository, args \\ [])

Same as `update_ref/2` but raises an exception on error.

## update_server_info(repository, args \\ [])

Run `git update-server-info` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## update_server_info!(repository, args \\ [])

Same as `update_server_info/2` but raises an exception on error.

## upload_archive(repository, args \\ [])

Run `git upload-archive` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## upload_archive!(repository, args \\ [])

Same as `upload_archive/2` but raises an exception on error.

## upload_pack(repository, args \\ [])

Run `git upload-pack` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## upload_pack!(repository, args \\ [])

Same as `upload_pack/2` but raises an exception on error.

## var(repository, args \\ [])

Run `git var` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## var!(repository, args \\ [])

Same as `var/2` but raises an exception on error.

## verify_commit(repository, args \\ [])

Run `git verify-commit` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## verify_commit!(repository, args \\ [])

Same as `verify_commit/2` but raises an exception on error.

## verify_pack(repository, args \\ [])

Run `git verify-pack` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## verify_pack!(repository, args \\ [])

Same as `verify_pack/2` but raises an exception on error.

## verify_tag(repository, args \\ [])

Run `git verify-tag` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## verify_tag!(repository, args \\ [])

Same as `verify_tag/2` but raises an exception on error.

## web__browse(repository, args \\ [])

Run `git web--browse` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## web__browse!(repository, args \\ [])

Same as `web__browse/2` but raises an exception on error.

## whatchanged(repository, args \\ [])

Run `git whatchanged` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## whatchanged!(repository, args \\ [])

Same as `whatchanged/2` but raises an exception on error.

## worktree(repository, args \\ [])

Run `git worktree` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## worktree!(repository, args \\ [])

Same as `worktree/2` but raises an exception on error.

## write_tree(repository, args \\ [])

Run `git write-tree` in the given repository
Returns `{:ok, output}` on success and `{:error, reason}` on failure.

## write_tree!(repository, args \\ [])

Same as `write_tree/2` but raises an exception on error.