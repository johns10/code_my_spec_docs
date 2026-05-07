# Jason.Fragment

Provides a way to inject an already-encoded JSON structure into a
to-be-encoded structure in optimized fashion.

This avoids a decoding/encoding round-trip for the subpart.

This feature can be used for caching parts of the JSON, or delegating
the generation of the JSON to a third-party system (e.g. Postgres).