# Phoenix.LiveView.Helpers



## sigil_L(arg, list)

Provides `~L` sigil with HTML safe Live EEx syntax inside source files.

    iex> ~L"""
    ...> Hello <%= "world" %>
    ...> """
    {:safe, ["Hello ", "world", "\n"]}