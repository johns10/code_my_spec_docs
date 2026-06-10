# ExCliVcr.Cassette

Handles reading and writing cassette files.

Cassettes are JSON files that store recorded command and port executions.

## Format

Cassettes use a structured format:

    {
      "commands": [...],
      "ports": [...]
    }

## path_for/1

Get the full path for a cassette name.

## load/1

Load recordings from a cassette file.

Returns a map with :commands and :ports keys.

## save/2

Save recordings to a cassette file.