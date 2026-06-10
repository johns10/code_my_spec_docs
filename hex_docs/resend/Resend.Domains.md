# Resend.Domains

Manage domains in Resend.

## create/2

Creates a new domain.

Parameter options:

  * `:name` - The domain name (required)
  * `:region` - Region to deliver emails from, on of: `["us-east-1", "eu-west-1", "sa-east-1"]`

## get/2

Gets a domain given an ID.

## verify/2

Begins the verification process for a domain.

## list/1

Lists all domains.

## remove/2

Removes a domain. Caution: This can't be undone!