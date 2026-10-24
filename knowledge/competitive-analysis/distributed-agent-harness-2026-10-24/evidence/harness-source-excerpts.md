# Existing harness source excerpts

Read-only `git show` snapshot at `6c66a6654b8386ce7fd445e4c8e1bf5f3d3e044c`. Line numbers refer to that commit. No credential values or environment configuration are included.

## lib/code_my_spec/agents.ex

```text
1888:   defp start_detached_agent(scope, role) do
1889:     if Application.get_env(:code_my_spec, :env) == :desktop do
1890:       with {:ok, {provider, model}, _source} <- resolve_model(scope, role),
1891:            {:ok, _credential} <- Credential.fetch(scope, provider) do
1892:         root = CodeMySpec.Paths.agents_root()
1893:         directory = Path.join([root, scope.active_project_id, Atom.to_string(role)])
1894: 
1895:         with :ok <- File.mkdir_p(directory) do
1896:           AgentsRepository.create_agent(scope, %{
1897:             role: role,
1898:             engine: :alloy,
1899:             provider: provider,
1900:             model: model,
1901:             execution_mode: :detached,
1902:             working_copy_id: nil,
1903:             working_copy: directory,
1904:             continuous: false,
1905:             tools: tools_for(scope, %{role: role, working_copy_id: nil}),
1906:             status: :starting
1907:           })
1908:         end
1909:       end
1910:     else
1911:       {:error, :no_execution_host}
1912:     end
1913:   end
1914: 
1915:   defp ensure_detached_running(scope, %Agent{execution_mode: :detached} = agent) do
1916:     scope = scope_for(scope, agent)
1917: 
1918:     cond do
1919:       Agent.off?(agent) or present?(scope, agent) ->
1920:         {:ok, agent}
1921: 
1922:       Application.get_env(:code_my_spec, :env) != :desktop ->
1923:         {:error, :no_execution_host}
1924: 
1925:       true ->
1926:         with {:ok, credential} <- Credential.fetch(scope, agent.provider),
1927:              {:ok, _} <- open_conversation(scope, agent),
1928:              hydrated =
1929:                LaunchRequest.hydrate(scope, %{
1930:                  agent
1931:                  | credential: credential,
1932:                    tools: tools_of(scope, agent)
1933:                }),
1934:              {:ok, report} <- Transport.start_agent(nil, hydrated, @start_timeout_ms),
1935:              {:ok, started} <- record_started(scope, agent, report) do
1936:           broadcast(scope, {:agent_started, started})
1937:           {:ok, started}
1938:         end
1939:     end
1940:   end
1941: 
1942:   defp ensure_detached_running(_scope, agent), do: {:ok, agent}
2352:   def move_main_agent(%Scope{} = scope, copy) do
2353:     case main_agent_anywhere(scope) do
2354:       nil ->
2355:         :none
2356: 
2357:       %Agent{working_copy_id: id} when id == :erlang.map_get(:id, copy) ->
2358:         with :ok <- move_main_copy_roster(scope, nil, copy), do: :none
2359: 
2360:       %Agent{} = agent ->
2361:         with {:ok, moved} <- relocate(scope, agent, copy),
2362:              :ok <- move_main_copy_roster(scope, agent.working_copy_id, copy) do
2363:           {:ok, moved}
2364:         end
2365:     end
2366:   end
2367: 
2368:   # Main can leave setup scratch when a real main copy is designated. Stop the
2369:   # old engine before changing its routing; its conversation stays with its id.
2370:   defp relocate(scope, %Agent{execution_mode: :detached} = agent, copy) do
2371:     with {:ok, credential} <- Credential.fetch(scope, agent.provider),
2372:          :ok <- halt_for_restart(agent),
2373:          {:ok, moved} <-
2374:            AgentsRepository.update_agent(scope, agent, %{
2375:              execution_mode: :working_copy,
2376:              working_copy_id: copy.id,
2377:              working_copy: copy.root,
2378:              status: :starting,
2379:              turn_started_at: nil,
2380:              os_pid: nil,
2381:              os_boot_id: nil
2382:            }),
2383:          :ok <- carry_on_if_mid_turn(scope, agent),
2384:          {:ok, started} <-
2385:            launch(
2386:              scope,
2387:              LaunchRequest.hydrate(scope_for(scope, moved), %{moved | credential: credential})
2388:            ) do
2389:       broadcast(scope, {:agent_started, started})
2390:       {:ok, started}
2391:     end
2392:   end
2393: 
2394:   defp relocate(scope, agent, copy) do
2395:     with {:ok, moved} <-
2396:            AgentsRepository.update_agent(scope, agent, %{
2397:              working_copy_id: copy.id,
2398:              working_copy: copy.root
2399:            }) do
2400:       broadcast(scope, {:agent_started, moved})
2401:       {:ok, moved}
2402:     end
2403:   end
2404: 
2405:   # Product lives where main lives, so it moves with it.
2406:   defp move_main_copy_roster(scope, from_id, copy) do
2407:     others = RoleProfile.roles_where_home(:main) -- [:main]
2408: 
2409:     scope
2410:     |> seat_holders()
2411:     |> Enum.filter(
2412:       &(&1.role in others and
2413:           (&1.execution_mode == :detached or
2414:              (&1.working_copy_id == from_id and &1.working_copy_id != copy.id)))
2415:     )
```

## lib/code_my_spec/agents/agent.ex

```text
90:   @primary_key {:id, :binary_id, autogenerate: true}
91:   @foreign_key_type :binary_id
92:   schema "agents" do
93:     field :engine, Ecto.Enum, values: @engines, default: :alloy
94:     field(:execution_mode, Ecto.Enum, values: [:working_copy, :detached], default: :working_copy)
95:     # A terminal Claude Code session's own session id (story 1122): how a
96:     # resumed session finds its agent again, and how its tool calls name it.
97:     field :engine_session_id, :string
98:     # The file that session writes what it says and spends to, as its SessionStart
99:     # hook named it: where a re-attached harness reads it from.
100:     field :transcript_path, :string
101:     # When a terminal session last ran a Bash command able to move HEAD (rebase,
102:     # pull, checkout, ...). `Validation` reads it to tell inherited history from
103:     # this turn's work when no edits were recorded.
104:     field :git_rewrite_at, :utc_datetime_usec
105:     # The tool the agent is running now, as one line, or nil. Set by a tool call
106:     # starting and cleared by it ending or the turn ending.
107:     field :current_tool, :string
108:     field :turn_tool_count, :integer
366:       :account_id
367:     ])
368:     |> validate_required([
369:       :engine,
370:       :provider,
371:       :working_copy,
372:       :role,
373:       :project_id,
374:       :account_id
375:     ])
376:     |> maybe_require_working_copy_id(agent)
377:     |> foreign_key_constraint(:working_copy_id)
378:     |> References.check()
379:     |> foreign_key_constraint(:story_id)
380:     |> validate_story_holder()
381:     |> foreign_key_constraint(:epic_id)
382:     |> foreign_key_constraint(:issue_id)
383:     |> validate_config_dir_outside_working_copy()
384:     |> assoc_constraint(:project)
385:     |> unique_constraint([:project_id, :engine_session_id])
386:     |> unique_constraint(:project_id, name: :agents_one_detached_product_per_project)
387:   end
388: 
389:   # Required on creation only: the FK nilifies on checkout delete, and a row
390:   # left that way must still be writable (a stop, say).
391:   defp maybe_require_working_copy_id(changeset, %__MODULE__{id: nil}) do
392:     case {get_field(changeset, :execution_mode), get_field(changeset, :role)} do
393:       {:detached, role} when role in [:product, :main] ->
394:         if get_field(changeset, :working_copy_id),
395:           do: add_error(changeset, :working_copy_id, "must be empty for a detached agent"),
396:           else: changeset
397: 
398:       {:detached, _} ->
399:         add_error(changeset, :execution_mode, "is only available for product and main")
400: 
401:       _ ->
402:         validate_required(changeset, [:working_copy_id])
403:     end
404:   end
405: 
406:   defp maybe_require_working_copy_id(changeset, %__MODULE__{}), do: changeset
407: 
408:   # Only a story-scope role (coding, QA) holds a story. Main never does: it
409:   # guards against the team's work rather than doing it. Product holds an epic.
410:   defp validate_story_holder(changeset) do
```

## lib/code_my_spec/agents/transport/harness.ex

```text
77:   def start_agent(working_copy_id, %Agent{} = agent, timeout) do
78:     case holder(working_copy_id) do
79:       {:ok, pid} -> call(pid, {:start_agent, agent}, timeout, :start_timed_out)
80:       :none -> unreachable(working_copy_id, agent, "start")
81:     end
82:   end
83: 
84:   @impl true
85:   def dispatch_message(working_copy_id, %Agent{} = agent, ref, message, timeout) do
86:     case holder(working_copy_id) do
87:       {:ok, pid} ->
119:   def call_machine_tool(working_copy_id, tool, arguments, timeout) do
120:     case holder(working_copy_id) do
121:       {:ok, pid} ->
122:         call(
123:           pid,
124:           # The budget travels with the call. Every hop between here and Chrome
125:           # used to supply its own thirty seconds, so a caller who asked for a
126:           # minute got half of one from whichever hop was strictest — and no
127:           # part of the answer said which. The machine gets told what it has.
128:           {:call_machine_tool, %{"tool" => tool, "arguments" => arguments, "timeout" => timeout}},
129:           timeout,
130:           :machine_tool_timed_out
131:         )
132: 
133:       # Different from a tool that ran and failed, and it gets a different
134:       # sentence: the browser is on a machine that is not connected, which the
135:       # agent cannot fix by calling something else.
136:       :none ->
182:   defp holder(working_copy_id) do
183:     case HarnessRegistry.executor_holder(working_copy_id) do
184:       {:ok, pid, _instance} -> {:ok, pid}
185:       :error -> :none
186:     end
187:   end
188: 
189:   # Calling the holder when *we are* the holder is a deadlock, and the BEAM
190:   # turns it into an exit that kills the channel — taking every agent on that
191:   # copy with it, because the harness then rejoins and
192:   # `Agents.account_for_interrupted_turns/2` tells each one its turn was
```

## lib/cms_harness/agents/engine/impl.ex

```text
80:   def start(opts) do
81:     with {:ok, agent_id} <- require_opt(opts, :agent_id),
82:          {:ok, working_copy} <- require_opt(opts, :working_copy),
83:          :ok <- working_copy_exists(working_copy),
84:          # Validation only, with no MCP session: this runs in the caller's
85:          # process, which may be the channel. Sessions open in `init/1`.
86:          {:ok, _alloy_opts} <- alloy_options(opts, nil) do
87:       # Under its own `Keeper`, which restarts it on a crash and gives up on a
88:       # crash loop. Each engine `init/1` reports an up to `Liveness`; the Keeper
89:       # is watched here once, so its giving up is a single final down.
90:       case start_keeper(working_copy, opts) do
91:         {:ok, keeper} ->
92:           Logger.info("[CmsHarness] agent #{agent_id} running in #{working_copy}")
93:           :ok = Liveness.watch_keeper(agent_id, keeper, working_copy)
94:           started(agent_id)
95: 
96:         {:error, {:already_started, _keeper}} ->
97:           started(agent_id)
98: 
99:         {:error, reason} ->
100:           Logger.warning(describe_start_failure(agent_id, working_copy, reason))
101:           {:error, reason}
102:       end
103:     end
104:   end
105: 
106:   # Under its copy's agents supervisor (`Copy.Supervisor`), so the copy going
107:   # takes its agents with it.
108:   defp start_keeper(working_copy, opts) do
109:     with {:ok, _copy} <- Copy.ensure(working_copy) do
110:       DynamicSupervisor.start_child(Copy.agents(working_copy), {Keeper, opts})
111:     end
112:   end
113: 
```

## lib/code_my_spec/agents/mailbox.ex

```text
349:   def consume(scope, agent_id, ref, generation) when is_binary(generation) do
350:     transition(scope, agent_id, ref, fn
351:       %{state: :claimed} = entry ->
352:         agent = Repo.get!(Agent, agent_id)
353:         if agent.mailbox_generation != generation, do: Repo.rollback(:stale_engine)
354: 
355:         case may_consume(agent) do
356:           :ok ->
357:             entry =
358:               change_entry(entry, %{
359:                 state: :consumed,
360:                 generation: generation,
361:                 consumed_at: DateTime.utc_now(),
362:                 diagnostic: nil
363:               })
364: 
365:             {:ok, _} =
366:               Conversations.set_delivery(Repo.get!(Message, entry.message_id), :delivered,
367:                 broadcast: false
368:               )
369: 
370:             CompletionHandoffs.delivered(entry.message_id, agent)
371:             entry
372: 
373:           {:error, reason} ->
374:             Repo.rollback(reason)
375:         end
376: 
377:       _ ->
378:         Repo.rollback(:not_claimed)
379:     end)
380:   end
381: 
382:   defp may_consume(agent) do
383:     with :ok <- Transport.deliverable(agent) do
384:       if Presence.present?(agent.project_id, agent.id), do: :ok, else: {:error, :not_running}
385:     end
```

## lib/code_my_spec_web/channels/harness_project_channel.ex

```text
818:     {from, pending} = Map.pop(pending_machine_tool(socket), ref)
819:     if from, do: GenServer.reply(from, decode_machine_tool_result(msg))
820:     {:reply, :ok, assign(socket, :pending_machine_tool, pending)}
821:   end
822: 
823:   # The harness's answer to a filesystem request; see `handle_call/3`. An
824:   # unknown ref (caller gave up) is dropped rather than crashing the channel.
825:   def handle_in("fs_result", %{"ref" => ref} = msg, socket) do
826:     {from, pending} = Map.pop(socket.assigns[:pending_fs] || %{}, ref)
827:     if from, do: GenServer.reply(from, decode_fs_result(msg))
828:     {:noreply, assign(socket, :pending_fs, pending)}
957:   def handle_call({:call_machine_tool, request}, from, socket) do
958:     ref = Integer.to_string(System.unique_integer([:positive]))
959: 
960:     push(socket, "tool_call", Map.put(request, "ref", ref))
961: 
962:     {:noreply,
963:      assign(socket, :pending_machine_tool, Map.put(pending_machine_tool(socket), ref, from))}
```

## lib/cms_harness/project/channel_client.ex

```text
2631:   defp fail_pending(socket, reason) do
2632:     Enum.each(socket.assigns.pending, fn {_ref, {from, timer}} ->
2633:       Process.cancel_timer(timer)
2634:       GenServer.reply(from, {:error, reason})
2635:     end)
2636: 
2637:     assign(socket, :pending, %{})
2638:   end
```
