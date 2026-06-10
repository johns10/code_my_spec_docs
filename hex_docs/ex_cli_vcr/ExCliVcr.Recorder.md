# ExCliVcr.Recorder

GenServer that manages recording and playback of System.cmd and Port calls.

The Recorder maintains state about the current cassette and handles
the logic for deciding whether to record or replay commands and ports.

## start/1

Start recording/playback for a cassette.

## stop/0

Stop recording and save the cassette.

## execute/3

Execute a command through the recorder.

## active?/0

Check if recording is currently active.