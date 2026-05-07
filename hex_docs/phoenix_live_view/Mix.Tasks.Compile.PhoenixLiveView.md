# Mix.Tasks.Compile.PhoenixLiveView

A LiveView compiler for HEEx macro components.

Right now, only `Phoenix.LiveView.ColocatedHook` and `Phoenix.LiveView.ColocatedJS`
are handled.

You must add it to your `mix.exs` as:

    compilers: [:phoenix_live_view] ++ Mix.compilers()