# Resend.Emails

Send emails via Resend.

## send/2

Sends an email given a map of parameters.

Parameter options:

  * `:to` - Recipient email address (required)
  * `:from` - Sender email address (required)
  * `:cc` - Additional email addresses to copy, may be a single address or a list of addresses
  * `:bcc` - Additional email addresses to blind-copy, may be a single address or a list of addresses
  * `:reply_to` - Specify the email that recipients will reply to
  * `:subject` - Subject line of the email
  * `:headers` - Map of headers to add to the email with corresponding string values
  * `:html` - The HTML-formatted body of the email
  * `:text` - The text-formatted body of the email
  * `:attachments` - List of attachments to include in the email

You must include one or both of the `:html` and `:text` options.

## get/2

Gets an email given an ID.