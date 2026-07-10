# CodeMySpec.Mail.Email

A persisted email in a mailbox: belongs to a mailbox, carries direction (inbound/outbound), from/to, subject, text/html body, provider id, and threading headers (message_id, in_reply_to, references). Persisted on the inbound webhook and on send so history outlives the provider's ~30-day window. Threaded per correspondent (the other party's address). Attachments are referenced by provider URL within the window, not stored (v1).

## Type

schema
