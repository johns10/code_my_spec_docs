# Swoosh.Adapters.ExAwsAmazonSES

An adapter that wraps `Swoosh.Adapters.AmazonSES` to use credentials from `ExAws`.

You may prefer this adapter to `Swoosh.Adapters.AmazonSES` if you have already
configured ExAws for your project and are using instance role credentials.

This allows you to use automatically managed, short-lived credentials, rather than provisioning
a static access key / secret key pair.

See also:

[IAM Roles for EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)
[IAM roles for ECS tasks](https://docs.aws.amazon.com/AmazonECS/latest/userguide/task-iam-roles.html)

> ### Dependencies {: .info}
>
> In addition to the `:gen_smtp` dependency that the `AmazonSES` adapter
> requires, this adapter also depends on `:ex_aws`.
>
> Ensure you have the dependencies added in your mix.exs file:
>
>     def deps do
>       [
>         {:swoosh, "~> 1.0"},
>         {:gen_smtp, "~> 1.0"},
>         {:ex_aws, "~> 2.1"},
>         # Dependency of `:ex_aws`
>         {:sweet_xml, "~> 0.6"}
>       ]
>     end

## Example

    # config/config.exs
    config :ex_aws,
      access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
      secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
      region: "us-east-1"

    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.ExAwsAmazonSES

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

See also:

[Getting started with ExAws](https://hexdocs.pm/ex_aws/readme.html#getting-started)