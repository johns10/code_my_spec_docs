# Swoosh.Adapters.AmazonSES

An adapter that sends email using the Amazon Simple Email Service (SES) Query API.
This adapter does not depend on `ExAws`; if you are already using it, you may
prefer `Swoosh.Adapters.ExAwsAmazonSES`.

This email adapter makes use of the Amazon SES SendRawEmail action and generates
a SMTP style message containing the information to be emailed. This allows for
greater and more customizable email message and ensures the capability to add
attachments. As a result, however, the `:gen_smtp` dependency is required in order
to correctly generate the SMTP message that will be sent.

Ensure you have the dependency added in your mix.exs file:

    def deps do
      [
        {:swoosh, "~> 1.0"},
        {:gen_smtp, "~> 1.0"}
      ]
    end

**Note**: If Swoosh was compiled prior to `:gen_smtp` being installed, it may be necessary to
force a recompilation of the library. This can be accomplished using `mix deps.compile swoosh --force`.

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

See also:

[Amazon SES Query Api Docs](http://docs.aws.amazon.com/ses/latest/APIReference/Welcome.html)

[Amazon SES SendRawEmail Documentation](http://docs.aws.amazon.com/ses/latest/APIReference/API_SendRawEmail.html)

## Configuration options

### Required

Note that these are handled automatically if using `Swoosh.Adapters.ExAwsAmazonSES`.

* `:region` - the AWS region
* `:access_key` - the IAM access key
* `:secret` - the IAM secret

### Optional

The following [request parameters](https://docs.aws.amazon.com/ses/latest/APIReference/API_SendRawEmail.html#API_SendRawEmail_RequestParameters) can be set in the configuration:

* `:ses_source` - mapped to `Source` parameter in the API request
* `:ses_source_arn` - mapped to `SourceArn` parameter in the API request
* `:ses_from_arn` - mapped to `FromArn` parameter in the API request
* `:ses_return_path_arn` - mapped to `ReturnPathArn` parameter in the API request

See details on how to use the parameters from [the SES API documentation](https://docs.aws.amazon.com/ses/latest/APIReference/API_SendRawEmail.html#API_SendRawEmail_RequestParameters).

## Examples

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.AmazonSES,
      region: "region-endpoint",
      access_key: "aws-access-key",
      secret: "aws-secret-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with tags and configuration set

    import Swoosh.Email

    new()
    |> from("guybrush.threepwood@pirates.grog")
    |> to("elaine.marley@triisland.gov")
    |> subject("Mighty Pirate Newsletter")
    |> text_body("Hello")
    |> put_provider_option(:tags, [%{name: "name1", value: "test1"}])
    |> put_provider_option(:configuration_set_name, "configuration_set_name1")

## Provider Options

  * `:tags` (list[map]) - a list of key/value pairs of a tag
  * `:configuration_set_name` (string) - the name of the configuration set
  * `:security_token` (string) - temporary security token obtained through
    AWS Security Token Service (AWS STS)

## IAM role

In case you use IAM role for authenticating AWS requests, you can fetch
temporary `:access_key` and `:secret_key` from that role, but you also need to
include additional `X-Amz-Security-Token` header to that request.

You can do that by adding `:security_token` to `:provider_options`.

If you don't have a static `:access_key` and `:secret_key` for your
application, you can use the `Swoosh.Adapters.ExAwsAmazonSES` adapter to fetch credentials
on-demand as specified in your application's `:ex_aws` configuration.