# Swoosh.Adapters.Local.Storage.Memory

In-memory storage driver used by the
[Swoosh.Adapters.Local](Swoosh.Adapters.Local.html) module.

The emails in this mailbox are stored in memory and won't persist once your
application is stopped.

## all()

List all the emails in the mailbox.

## Examples

    iex> email = new |> from("tony.stark@example.com")
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, [...]}
    iex> Memory.push(email)
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
    iex> Memory.all()
    [%Swoosh.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}]

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## delete_all()

Delete all the emails currently in the mailbox.

## Examples

    iex> email = new |> from("tony.stark@example.com")
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, [...]}
    iex> Memory.push(email)
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
    iex> Memory.delete_all()
    :ok
    iex> Memory.all()
    []

## get(id)

Get a specific email from the mailbox.

## Examples

    iex> email = new |> from("tony.stark@example.com")
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, [...]}
    iex> Memory.push(email)
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
    iex> Memory.get("A1B2C3")
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}

## pop()

Pop the last email from the mailbox.

## Examples

    iex> email = new |> from("tony.stark@example.com")
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, [...]}
    iex> Memory.push(email)
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
    iex> Memory.all() |> Enum.count()
    1
    iex> Memory.pop()
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
    iex> Memory.all() |> Enum.count()
    0

## push(email)

Push a new email into the mailbox.

In order to make it easy to fetch a single email, a `Message-ID` header is
added to the email before being stored.

## Examples

    iex> email = new |> from("tony.stark@example.com")
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, [...]}
    iex> Memory.push(email)
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}

## start(args \\ [])

Starts the server

## stop()

Stops the server