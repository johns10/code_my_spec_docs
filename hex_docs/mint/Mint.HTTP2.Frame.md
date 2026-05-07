# Mint.HTTP2.Frame



## decode_next(bin, max_frame_size \\ 16384)

Decodes the next frame of the given binary.

Returns `{:ok, frame, rest}` if successful, `{:error, reason}` if not.

## encode(frame)

Encodes the given `frame`.