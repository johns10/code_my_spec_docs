# Phoenix.LiveView.Upload



## allow_upload(socket, name, opts)

Allows an upload.

## cancel_upload(socket, name, entry_ref)

Cancels an upload entry.

## consume_uploaded_entries(socket, name, func)

Consumes the uploaded entries or raises if entries are still in progress.

## consume_uploaded_entry(socket, entry, func)

Consumes an individual entry or raises if it is still in progress.

## disallow_upload(socket, name)

Disallows a previously allowed upload.

## drop_upload_entries(socket, conf, entry_refs)

Drops all entries from the upload.

## generate_preflight_response(socket, name, cid, refs)

Generates a preflight response by calling the `:external` function.

## get_upload_by_pid(socket, pid)

Returns the `%UploadConfig{}` from the socket for the `Phoenix.LiveView.UploadChannel` pid.

## get_upload_by_ref!(socket, config_ref)

Retrieves the `%UploadConfig{}` from the socket for the provided ref or raises.

## maybe_cancel_uploads(socket)

Cancels all uploads that exist.

Returns the new socket with the cancelled upload configs.

## put_entries(socket, conf, entries, cid)

Puts the entries into the `%UploadConfig{}`.

## put_upload_error(socket, conf_name, entry_ref, reason)

Populates the errors for a given entry.

## register_entry_upload(socket, conf, pid, entry_ref)

Registers a new entry upload for an `Phoenix.LiveView.UploadChannel` process.

## unregister_completed_entry_upload(socket, conf, entry_ref)

Unregisters a completed entry from an `Phoenix.LiveView.UploadChannel` process.

## update_progress(socket, config_ref, entry_ref, progress)

Updates the entry progress.

Progress is either an integer percently between 0 and 100, or a map
with an `"error"` key containing the information for a failed upload
while in progress on the client.

## update_upload_entry_meta(socket, upload_conf_name, entry, meta)

Updates the entry metadata.

## uploaded_entries(socket, name)

Returns the completed and in progress entries for the upload.