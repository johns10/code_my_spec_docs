# ElixirMake.Artefact



## archive_path(config, target, nif_version)

Returns the full path to the precompiled archive.

## available_target_urls(config, precompiler)

Returns all available {{target, nif_version}, url} pairs available.

## cache_dir()

Returns user cache directory.

## checksum(basename, contents)

Computes the checksum and artefact for the given contents.

## checksum_algo()

Returns the checksum algorithm

## compress(archive_path, paths)

Compresses the given files and computes its checksum and artefact.

## current_target_url(config, precompiler, current_nif_version)

Returns the url for the current target.

## verify_and_decompress(archive_path, app_priv)

Verifies and decompresses the given `archive_path` at `app_priv`.

## write_checksum_for_target!(artefact)

Writes checksum for the target to disk.

## write_checksums!(checksums)

Writes checksums to disk.