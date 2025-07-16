# Invitation Notifier Design

## Overview
The Invitation Notifier provides a simple, focused interface for sending invitation-related emails. Following the same pattern as `UserNotifier`, it handles email composition and delivery for the invitation lifecycle.

## Core Structure

### Simple Module Design
Single module with focused responsibility for invitation emails. Uses Swoosh for email composition and the application's main Mailer for delivery. Follows the same pattern as `UserNotifier` with private `deliver/3` helper.

### Email Functions
- **deliver_invitation_email(invitation, url)**: Sends invitation to join account
- **deliver_invitation_reminder(invitation, url)**: Sends reminder for pending invitation
- **deliver_invitation_cancelled(invitation)**: Notifies when invitation is cancelled
- **deliver_welcome_email(user, account)**: Welcomes new member after acceptance

## Implementation Pattern

```elixir
defmodule CodeMySpec.Invitations.InvitationNotifier do
  import Swoosh.Email
  
  alias CodeMySpec.Mailer
  alias CodeMySpec.Invitations.Invitation
  
  # Delivers the email using the application mailer
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"CodeMySpec", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)
    
    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end
end
```

## Email Templates

### Invitation Email
Simple text template with invitation link, account context, and inviting user information. Includes clear call-to-action and expiration notice.

### Reminder Email
Follow-up message emphasizing time-sensitive nature of invitation. Includes updated link and account context.

### Cancellation Notice
Professional notification when invitation is cancelled by admin. Brief and respectful messaging.

### Welcome Email
Confirmation after successful invitation acceptance. Includes next steps and account information.

## Key Features

### Text-Only Templates
Simple text-based email templates that are easy to maintain and have excellent deliverability. No HTML complexity or rendering issues.

### Inline Email Bodies
Email content defined inline using heredoc syntax, making it easy to read and modify. No external template files to manage.

### Consistent Patterns
Uses the same deliver helper pattern as UserNotifier for consistency across the application. Same error handling and return values.

### Minimal Dependencies
Only depends on Swoosh and the application Mailer. No additional email libraries or complex template engines.

This design provides a straightforward, maintainable email system that handles the core invitation communication needs without unnecessary complexity.