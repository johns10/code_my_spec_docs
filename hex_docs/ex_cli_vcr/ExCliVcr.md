# ExCliVcr

Record and replay System.cmd and Port calls for testing.

ExCliVcr intercepts calls to `System.cmd/3` and either records them to a
cassette file or replays previously recorded responses.

## Usage

In your test:

    use ExCliVcr

    test "runs a command" do
      use_cmd_cassette "my_command" do
        # System.cmd is automatically mocked
        {output, 0} = System.cmd("echo", ["hello"])
        assert output == "hello\n"
      end
    end

## Port Recording

For Port operations, you must use the ExCliVcr wrapper functions because
`Port.open/2` compiles to a BIF that cannot be mocked at runtime:

    test "uses a port" do
      use_cmd_cassette "my_port" do
        # Must use ExCliVcr.port_open instead of Port.open
        port = ExCliVcr.port_open({:spawn, "cat"}, [:binary, :exit_status])

        # Use ExCliVcr wrappers for port operations
        ExCliVcr.port_command(port, "hello\n")
        receive do
          {^port, {:data, data}} -> assert data == "hello\n"
        end

        ExCliVcr.port_close(port)
      end
    end

## Configuration

Configure ExCliVcr in your `config/test.exs`:

    config :ex_cli_vcr,
      cassette_dir: "test/fixtures/cassettes",
      record_mode: :once

## Record Modes

- `:once` - Record if cassette doesn't exist, replay if it does (default)
- `:new` - Always record, overwriting existing cassettes
- `:none` - Never record, only replay (raises if cassette missing)
- `:all` - Record all calls even if cassette exists

## cassette_dir()

Get the configured cassette directory.

## cmd(command, args, opts \\ [])

Execute a command, recording or replaying as appropriate.

This is a drop-in replacement for `System.cmd/3` that integrates with
ExCliVcr's recording and playback system.

When called inside a `use_cassette` block, it will either:
- Record the command output if no recording exists
- Replay a previously recorded response

When called outside a `use_cassette` block, it passes through to `System.cmd/3`.

## Examples

    use_cmd_cassette "my_test" do
      {output, exit_code} = ExCliVcr.cmd("echo", ["hello"], [])
    end

## default_record_mode()

Get the default record mode.

## execute_cmd(command, args, opts \\ [])

Execute a command, recording or replaying as appropriate.

Alias for `cmd/3`.

## port_close(port)

Close a port.

Use this instead of Port.close/1 when working with recorded ports.

## port_command(port, data, opts \\ [])

Send a command to a port.

Use this instead of Port.command/2 when working with recorded ports.

## port_open(open_args, opts)

Open a port, recording or replaying as appropriate.

Use this instead of `Port.open/2` within a `use_cmd_cassette` block.
`Port.open/2` cannot be automatically mocked because it compiles to a BIF.

When called inside a `use_cmd_cassette` block, it will either:
- Record the port messages if no recording exists
- Replay previously recorded messages

When called outside a `use_cmd_cassette` block, it passes through to `Port.open/2`.

## Examples

    use_cmd_cassette "my_test" do
      port = ExCliVcr.port_open({:spawn, "echo hello"}, [:binary, :exit_status])
      receive do
        {^port, {:data, data}} -> data
      end
    end

## use_cmd_cassette(name, opts \\ [], list)

Execute a block of code with command recording/playback enabled.

## Options

- `:record` - Override the record mode for this cassette
- `:match_requests_on` - List of fields to match on (default: `[:command, :args]`)

## Examples

    use_cmd_cassette "list_files" do
      ExCliVcr.cmd("ls", ["-la"])
    end

    use_cmd_cassette "list_files", record: :new do
      ExCliVcr.cmd("ls", ["-la"])
    end