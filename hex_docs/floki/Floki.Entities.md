# Floki.Entities



## decode(charref)

Decode charrefs and numeric charrefs.

This is useful if you want to decode any charref. The tokenizer will
use a different algorithm, so this may not be necessary.

## encode(string)

Encode HTML entities in a string.

Currently only encodes the main HTML entities:

* single quote - ' - is replaced by "&#39;".
* double quote - " - is replaced by "&quot;".
* ampersand - & - is replaced by "&amp;".
* less-than sign - < - is replaced by "&lt;".
* greater-than sign - > - is replaced by "&gt;".

All other symbols are going to remain the same.

Optimized IO data implementation from Plug.HTML