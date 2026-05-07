# Gettext.Extractor



## disable()

Disables extraction.

## enable()

Enables message extraction.

## extract(caller, backend, domain, msgctxt, id, extracted_comments)

Extracts a message by temporarily storing it in an agent.

Note that this function doesn't perform any operation on the filesystem.

## extracting?()

Tells whether messages are being extracted.

## pot_files(app, gettext_config)

Returns a list of POT files based on the results of the extraction.

Returns a list of paths and their contents to be written to disk. Existing POT
files are either purged from obsolete messages (in case no extracted
message ends up in that file) or merged with the extracted messages;
new POT files are returned for extracted messages that belong to a POT
file that doesn't exist yet.

This is a stateful operation. Once pot_files are generated, their information
is permanently removed from the extractor.