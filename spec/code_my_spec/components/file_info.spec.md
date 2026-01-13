# CodeMySpec.Components.Sync.FileInfo

Struct representing a file's metadata for sync comparison.

**type**: struct

## Fields

- `:path` - Path to the file (relative to base_dir)
- `:mtime` - Last modification time from filesystem, converted to UTC DateTime

## Functions

### from_path/1

Creates a FileInfo struct from a file path by reading its modification time from the filesystem.

```elixir
@spec from_path(String.t()) :: t()
```

**Process**:
1. Call `File.stat!/1` to get file metadata
2. Extract `mtime` from the stat struct (Erlang datetime tuple)
3. Convert to `DateTime.t()` in UTC
4. Return FileInfo struct with path and mtime

**Test Assertions**:
- returns FileInfo struct with correct path
- mtime is a UTC DateTime
- raises on non-existent file

### collect_files/2

Collects all files matching a glob pattern as FileInfo structs.

```elixir
@spec collect_files(base_dir :: String.t(), glob :: String.t()) :: [t()]
```

**Process**:
1. Use `Path.wildcard/1` to find matching files
2. Map each path to a FileInfo struct via `from_path/1`

**Test Assertions**:
- returns list of FileInfo structs
- each struct has correct path and mtime
- returns empty list when no files match

## Dependencies

- File (Elixir standard library)
- DateTime (Elixir standard library)
