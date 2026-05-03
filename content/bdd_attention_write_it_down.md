# Write it down: the first workflow that actually worked, and where it still broke

_Part 3 of the [BDD Attention Thesis](/blog/bdd-attention-thesis). Previous: [Part 2: Prompt and Pray](/blog/bdd-attention-prompt-and-pray)._

---

The first thing I tried was the simplest version of an external artifact: get the instructions out of the chat and into files the model would re-read at the start of every session.

This worked better. Meaningfully better. And it still wasn't enough.

## What the actual system looked like

It wasn't one file. It was three.

**Development guidelines.** All the rules that had to hold across every session. Architecture decisions. Constraints. Testing conventions. Don't use Ecto changesets in this layer. Follow Phoenix context boundaries. No mocked database. Anything I'd said in a chat and watched the model forget by turn 20 went in here.

**Todo list.** A markdown file with checkboxes, generated from the implementation plan. What needs to be built, in dependency order. The model would check items off as it worked and add notes on blockers.

**Memory file.** An empty `memory.md` to start. The model would update it after each task — what's done, what's in progress, anything it needed to carry into the next session.

And one more piece: the same prompt, repeated at the start of every chat.

```
Continue working on the project in @project_folder. Follow the development
guidelines in @development_guidelines, and remember everything in @memory.
```

The guidelines came in at position zero. Full attention. Nothing buried them yet. Then: short chat. One task. Write tests, implement, run tests, fix failures, update todos, update memory, commit, stop. Close the chat. Open a new one. Send the same prompt.

I ran that loop for months. It was the most effective workflow I'd used to that point.

## Why the short chat matters

The "close the chat and start a new one" step isn't just hygiene. It's the mechanism that makes the rest of it work.

Every instruction you give a model redistributes attention away from everything that came before it (covered in [Part 2](/blog/bdd-attention-prompt-and-pray)). A chat that runs for 40 turns is a chat where your guidelines from turn 1 are competing with 39 turns of code diffs, error messages, and follow-up instructions for the same finite attention budget.

Closing the chat resets that budget. Reopening with the guidelines file loaded fresh means those rules are loudest again. The model isn't fighting 40 turns of noise to find the architectural constraints. It reads them first, at full attention, every time.

This is the same reason CLAUDE.md works in Claude Code. If you want a rule to hold, don't keep it in the chat. Put it somewhere that gets re-read fresh.

## The first failure mode

After a few months I started noticing a pattern: the model would check a task off, I'd assume it was done, and I'd find out later it wasn't.

"Implement the user authentication flow." Checked. I looked at what it had built. Login worked. Registration didn't handle duplicate emails. Password reset was a stub. Session expiration wasn't implemented. From my perspective the task was 40% complete. From the model's perspective it was done because it had written code that matched the phrase "implement the user authentication flow."

The todo list described tasks — directions to travel, not destinations you could verify. "Implement X" is a direction. "A user who submits the registration form with a duplicate email sees an error message" is a behavior. You can either observe it or you can't. There's no judgment involved.

I had been writing tasks. I hadn't been writing behaviors. The model and I were using the same word — "done" — to mean completely different things.

## The second failure mode

The subtler problem was memory.md.

I wanted the model to update the memory file as it worked. That meant the model was writing to memory.md. The model writing to memory.md was the same model that had just finished a task and wanted to report progress. Those two facts combined badly.

The model would update the memory to reflect its own interpretation of what had happened. Steps that weren't quite done would be recorded as complete. Context that contradicted the guidelines would drift in. By session five on a long feature, the `memory.md` I was loading at session start wasn't the state I thought the project was in. It was a version that had been edited iteratively by a model that was motivated to show forward progress.

The thing I was relying on to keep the model honest was being written by the model I needed to hold honest.

## What it solved, what it missed

Looking back, this three-file workflow solved one problem cleanly and missed a different problem entirely.

The problem it solved was attention drift on architectural constraints. The development guidelines were now at the front of context at session start, not buried in a chat from three days ago. The "forgot we don't use changesets" failures almost disappeared. Short chats kept the context budget from compounding into noise. That was real, and it was a big improvement over prompt-and-pray.

The problem it didn't solve was verification. "Done" in a task list is a judgment call, and the model and I were making different judgments from the same imprecise description. I needed to describe what done looked like in terms precise enough that neither of us had to judge it — something you could check, not just estimate.

That's a different kind of artifact.

## Coming next

I stopped writing tasks and started writing specs — one per module, with function signatures, step-by-step process, and test assertions co-located in the same document. That was closer to what I needed. Then the unit tests passed and the features were still broken.

**Continue to [Part 4: Spec files](/blog/bdd-attention-spec-files).**
