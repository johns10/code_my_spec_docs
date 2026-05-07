# Resend.Swoosh.Adapter

Adapter module to configure Swoosh to send emails via Resend.

Using this adapter, we can configure a new Phoenix application to send mail
via Resend by default. If the project generated authentication with `phx.gen.auth`,
then all auth communication will work with Resend out of the box.

To configure your Mailer, specify the adapter and a Resend API key:

```ex
config :my_app, MyApp.Mailer,
  adapter: Resend.Swoosh.Adapter,
  api_key: "re_1234567"
```

If you're configuring your app for production, configure your adapter in `prod.exs`, and
your API key from the environment in `runtime.exs`:

```ex
# prod.exs
config :my_app, MyApp.Mailer, adapter: Resend.Swoosh.Adapter
```

```ex
# runtime.exs
config :my_app, MyApp.Mailer, api_key: "re_1234567"
```

And just like that, you should be all set to send emails with Resend!