# ExCliVcr.Cassette

Handles reading and writing cassette files.

Cassettes are JSON files that store recorded command and port executions.

## Format

Cassettes use a structured format:

    {
      "commands": [...],
      "ports": [...]
    }

## load(path)

Load recordings from a cassette file.

Returns a map with :commands and :ports keys.

## path_for(name)

Get the full path for a cassette name.

## save(path, recordings)

Save recordings to a cassette file.