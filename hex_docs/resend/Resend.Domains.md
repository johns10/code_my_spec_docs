# Resend.Domains

Manage domains in Resend.

## create(client \\ Resend.client(), opts)

Creates a new domain.

Parameter options:

  * `:name` - The domain name (required)
  * `:region` - Region to deliver emails from, on of: `["us-east-1", "eu-west-1", "sa-east-1"]`

## get(client \\ Resend.client(), domain_id)

Gets a domain given an ID.

## list(client \\ Resend.client())

Lists all domains.

## remove(client \\ Resend.client(), domain_id)

Removes a domain. Caution: This can't be undone!

## verify(client \\ Resend.client(), domain_id)

Begins the verification process for a domain.