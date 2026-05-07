# ExCliVcr.Recorder

GenServer that manages recording and playback of System.cmd and Port calls.

The Recorder maintains state about the current cassette and handles
the logic for deciding whether to record or replay commands and ports.

## active?()

Check if recording is currently active.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## execute(command, args, opts)

Execute a command through the recorder.

## start(opts)

Start recording/playback for a cassette.

## stop()

Stop recording and save the cassette.