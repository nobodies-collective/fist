# Integrations

FIST integrates with external systems for authentication, ticket verification, and email delivery.

## Fistbump

Fistbump is an external verification service that links the event's ticketing system to FIST. It provides two key functions:

### Magic Link Authentication

Fistbump enables passwordless account creation and login:

1. The event's communication system sends ticket holders a magic link containing a verification hash
2. The link points to FIST: `/work?fornothing=HASH` (an optional `&path=destination` can be appended to redirect after login)
3. FIST calls the Fistbump API to verify the hash
4. The API returns the ticket holder's email and ticket ID

**For existing users**: The system generates a login token and logs them in automatically.

**For new users**: The email is pre-filled and the ticket ID is pre-linked. The user only needs to set a password and agree to terms.

This reduces friction for onboarding ticket holders who might not have created a FIST account yet.

### Ticket Verification

When a volunteer enters a ticket ID (format: QTK12345678) on their profile form, FIST verifies it against the Fistbump API:

- **Valid ticket**: Ticket ID and raw ticket info are stored on the user record
- **Invalid ticket**: The volunteer is informed but can continue without a ticket
- **API error**: Treated gracefully; the rest of the form is still saved

The system also runs automated ticket checks:
- **Daily**: Checks users without tickets to see if they've since purchased one
- **Weekly**: Re-validates all ticket IDs to catch transfers or cancellations

### Configuration

Fistbump integration is configured via `server/env.json`:
- `noonerHuntApi`: Base URL for the Fistbump API
- `noonerHuntKey`: API key for authentication

If these values are not configured, the system continues to operate without ticket verification.

## Quicket

Quicket is a ticketing platform. FIST has a **legacy** integration for syncing guest lists.

**Current status**: The Quicket integration code exists but is no longer actively used. The Fistbump integration has largely replaced it.

**What it did:**
- Pulled the full guest list from the Quicket API
- Matched guests to FIST users by email address
- Stored ticket information (barcode, name, email, raw guest data)
- Detected ticket transfers and email changes

**Configuration** (if ever re-enabled):
- `quicketEventId`: The Quicket event identifier
- `quicketApiKey`: API key
- `quicketUserToken`: User authentication token

## Email System

FIST has a sophisticated email system for volunteer communications.

### Architecture

```
Template Engine (EmailForms)
        │
        ▼
   Email Cache ──→ Manual Review (if emailManualCheck enabled)
        │
        ▼
   Send Queue ──→ SMTP Server
        │
        ▼
   Email Logs / Email Fails
```

### Email Templates

Templates are managed through the EmailForms package and can be edited by managers at `/manager/emailForms`. Each template has:
- **Name**: Identifier (e.g., "voluntell", "reviewed")
- **From address**: Sender email
- **Subject line**: Can include template variables
- **Body**: Uses Spacebars-style variable interpolation

**Available context variables in templates:**

| Context | Variables |
|---------|-----------|
| User | First name, last name, email |
| Shifts | List of shifts with title, team, start/end, status, enrollment info |
| Projects | List of projects with title, team, dates, status |
| Leads | List of lead positions with title, team, status |
| UserTeams | List of teams the user has signups for, with team email |
| Site | URL and site name |

### Email Types

| Template | Trigger | Content |
|----------|---------|---------|
| `enrollAccount` | Admin enrolls a new user | Invitation link to create account |
| `verifyEmail` | User registers | Link to verify email address |
| `voluntell` | Lead/NoInfo enrolls a volunteer | Notification of new assignments |
| `reviewed` | Lead approves/denies an application | Decision notification |
| `shiftReminder` | Manual trigger by manager | Reminder of all booked shifts |

### Email Flow

1. **Generation**: When a notification event occurs, the system renders the template with the user's current data
2. **Caching**: The rendered email is stored in the `EmailCache` collection
3. **Review** (optional): If `emailManualCheck` is enabled, emails wait for manager approval
4. **Sending**: Emails are sent through SMTP, rate-limited to one every 2 seconds
5. **Logging**: Successful sends are logged in `EmailLogs`
6. **Retry**: Failed sends are retried up to 5 times
7. **Failure tracking**: Permanently failed emails are stored in `EmailFails`

### Automatic Notifications

When cron is enabled, two notification jobs run at the configured frequency:

1. **Enrollment notifications**: Finds volunteers with new `enrolled` signups that haven't been notified yet. Sends the `voluntell` template.
2. **Review notifications**: Finds volunteers with newly reviewed (approved/denied) applications. Sends the `reviewed` template.

After sending, the system marks the signups as `notification: true` to prevent duplicate emails.

### Manual Email Controls

Managers can:
- **View queued emails** at `/manager/emailApproval`
- **Send individual emails** from the queue
- **Delete emails** that shouldn't be sent
- **Regenerate emails** (re-render with current data, replacing the cached version)
- **Send mass reminders** to all volunteers with signups (from the manager dashboard)

### SMTP Configuration

Email delivery requires an SMTP server configured via Meteor's standard `MAIL_URL` environment variable. The system sets:
- Default "from" address: `FIST <fist@[event-domain]>`
- Site name: `FIST [EventName] [EventYear]`

## Configuration File

External integration credentials are stored in `server/env.json` (not committed to the repository). Copy from `server/env.example` to create:

```json
{
  "noonerHuntApi": "https://api.example.com",
  "noonerHuntKey": "your-api-key",
  "quicketEventId": "12345",
  "quicketApiKey": "your-quicket-key",
  "quicketUserToken": "your-quicket-token"
}
```

All integrations are designed to fail gracefully. If credentials are missing or APIs are unavailable, the core FIST functionality continues to work — volunteers can still register, browse shifts, and sign up.
