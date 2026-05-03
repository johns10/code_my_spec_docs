# Spec-driven development: finally useful, still not executable

_Part 4 of the [BDD Attention Thesis](/blog/bdd-attention-thesis). Previous: [Part 3: Write It Down](/blog/bdd-attention-write-it-down)._

---

The todo-list failure taught me something specific: the model and I had completely different definitions of "done." I meant "the feature works under all the conditions a user might encounter." The model meant "I wrote code matching the task description." Those two things are not the same, and a task list will never reconcile them.

I didn't stop at acceptance criteria. I ended up writing spec files — one per module — that described three things at once: what the module should do, how it should do it, and what the tests should verify. All in the same document, all in one place.

## What a spec file actually looked like

A bare-minimum example, for a user registration context:

```markdown
# Accounts.create_user/2

Creates a new user account with the provided attributes.

@spec create_user(Scope.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}

**Process:**
1. Validate email uniqueness against existing users
2. Hash password before storing
3. Create user record via UsersRepository.create_user/1
4. Broadcast {:created, user} event on success
5. Return result tuple

**Test Assertions:**
- creates user with valid attributes
- returns changeset error when email already exists
- hashes password before persisting (raw password not stored)
- broadcasts created event on success
- returns error for missing required fields
```

That's a different artifact than "Implement user registration." The function signature tells the model exactly what it's building. The process gives it the implementation steps. The test assertions tell it exactly what done looks like — specific conditions, not a general description.

The model couldn't check off "implement user registration" at 40% complete anymore, because "complete" was now defined as: all five test assertions pass, not "I wrote something that resembles the task."

## Why this worked so much better

Three things changed.

First, the model had a concrete definition of done for every function. Not "implement auth" but "five specific assertions pass." It could compare its output against the spec line by line.

Second, the implementation guidance was co-located with the verification criteria. The model didn't have to hold "how to build this" in one part of context and "how to verify this" in another part. Same document. Same read. Same attention budget at the front of the session.

Third, the scope was explicit. Every function in the spec file had exactly the assertions it needed — no more, no less. The model wasn't guessing what edge cases to cover. I had listed them.

For the first time, when the model said it was done, I mostly agreed. The spec gave us the same definition of done.

This is the shape Amazon's Kiro, Tessl, and GitHub's Spec Kit have all converged on, for the same reason: a spec the model and the human can both read produces less drift than a chat both of them have to remember.

## The problem that remained

The spec worked. The model wrote the tests. My harness ran the tests. The tests passed.

The feature was still broken.

Unit tests test functions. They run in isolation with controlled inputs. "Returns changeset error when email already exists" — the model wrote that test, it hit the function directly, and it returned the right tuple. Test green.

But a user opening a browser, filling out the registration form, submitting with a duplicate email, and looking at what the page shows them — that's a different verification entirely. The function returned the right value. The LiveView didn't render the error in the right place. The form cleared instead of preserving the email field. The error appeared for half a second and then disappeared. The test had no idea any of this was happening.

Passing unit tests tell you the functions do what the spec says. They tell you nothing about whether the application works.

I'd built a system that gave me high confidence in my function implementations and zero additional confidence in my features. The spec was right. The tests were right. The app was wrong.

What I needed wasn't better unit tests. I needed something that verified the feature the way a user would encounter it — by actually using it. A spec that drove a real browser, made real clicks, observed real results.

It turns out that format already exists.

## Coming next

Given/When/Then was invented in 2006. It wasn't designed for AI agents. It was designed because human developers, testers, and product managers couldn't agree on what "done" meant either — and someone figured out that if you wrote behaviors in a tight enough format, the spec could be executed directly. No translation step. The spec is the test.

Applied to AI coding, it solves the same problem for the same reason.

**Continue to [Part 5: Naive BDD](/blog/bdd-attention-naive-bdd).**
