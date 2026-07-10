# CodeMySpec.Mail

Email-on-your-domain for an account: per-project mailboxes (each assigned to a user or shared, with a catch-all for unmatched addresses) over the project's verified domain. Inbound arrives via the provider's email.received webhook (routed by To-address to a mailbox); outbound sends with the mailbox address as From. We persist message metadata + text/html body for durable per-correspondent threads (the provider only retains ~30 days); attachments are linked within the provider window, not stored (v1). Provider (Resend) sits behind an adapter. Not coupled to Conversations/chat.

## Type

context
