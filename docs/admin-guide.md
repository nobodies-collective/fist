# Admin Guide

This guide covers the capabilities available to managers and admins.

## Accessing Manager Features

Navigate to `/manager` (or click "Manager" in the header navigation). The manager dashboard is only visible to users with the manager or admin role.

## Manager Dashboard

The main dashboard (`/manager`) shows:

### Sidebar
- **Global staffing stats**: Leads (occupied/total), MetaLeads (occupied/total), Shifts (booked/total)
- **Action buttons**:
  - Event Settings
  - New Department
  - Cantina Setup Export (CSV)
  - Rota Export (CSV of all rotas)
  - Early Entry management
  - Early Entry Export (CSV)
- **Danger Zone**:
  - Send Reminders to everyone (mass email)
  - Prepare FIST for a new event (migration wizard)

### Main Area
- **Staffing Report: Setup and Strike** — a visual report showing volunteer coverage across the build and strike periods for all departments

## Event Settings

Navigate to `/manager/eventSettings` to configure:

- **Event dates**: Event period, build period, strike period
- **FIST open date**: When general volunteers can access the system
- **Early entry settings**: Max passes, close date, requirement end time
- **Barrios arrival date**: When camp organizers can arrive
- **Cron frequency**: How often automated emails are sent (e.g., "every 15 mins"). Leave empty to disable.
- **Email manual check**: Toggle whether emails require manager approval before sending

Changes take effect immediately. Cron jobs automatically restart with new frequency settings.

## User Management

### User List (`/manager/userList`)

A searchable, paginated list of all users with:
- Name, nickname, email
- Online status and last login
- Ticket ID
- Account creation date
- Current roles (manager, admin, lead)
- Banned status

**Search options:**
- By name or email
- By ticket number
- Include users with incomplete profiles (toggle)

**Actions per user:**
- View full profile
- Change password
- Make/remove Manager role
- Make/remove Admin role
- Ban/unban user

### Email Approval (`/manager/emailApproval`)

When `emailManualCheck` is enabled, all outgoing emails are queued for review. Managers can:
- View pending emails
- Approve and send individual emails
- Delete emails that shouldn't be sent
- Regenerate an email (re-render the template with current data)

### Email Templates (`/manager/emailForms`)

Manage the templates used for notification emails:
- **enrollAccount**: Invitation email for new users
- **verifyEmail**: Email verification link
- **voluntell**: Notification when a user is enrolled by a lead
- **reviewed**: Notification when a signup is approved or denied
- **shiftReminder**: Pre-event reminder of booked shifts

Templates use Spacebars-style syntax with context variables for user data, shift details, and team information.

## Department Management

From the manager dashboard sidebar, click "New Department" to create a department. Each department:
- Belongs to the NOrg division
- Automatically gets a metalead position created
- Appears in the organizational hierarchy for leads and volunteers

Departments can be edited from their dashboard pages.

## Data Exports

### Rota Exports (CSV)

| Export | Button | Content |
|--------|--------|---------|
| All Rotas | "Rota Export" on manager dashboard | Every confirmed signup: shift, dates, volunteer name, email, ticket, full name |
| Cantina Setup | "Cantina Set-up Export" | Daily headcounts during build period by dietary preference (omnivore, vegetarian, vegan, fish) and allergy/intolerance counts |
| Early Entry | "Early Entry" | Volunteers with pre-event shifts: arrival date, shift progression, team assignments |

### Rota JSON Export/Import

For year-to-year migration or bulk editing of the shift structure.

**Export** (`/manager` > accessed via methods):
- Exports the full organizational structure as JSON
- Includes: settings, departments, teams, rotas, shifts, projects, lead positions
- References use names (not IDs) for portability

**Import** (`/manager` > Rota Import):
- Upload a JSON file with the full structure
- System recreates all departments, teams, rotas, shifts, projects, and leads
- Dates are shifted relative to the event period difference
- Replaces existing structure (destructive operation)

## Mass Communications

### Send Reminders to Everyone
Sends the `shiftReminder` email template to every user who has at least one confirmed or pending signup. Emails are rate-limited (one every 2 seconds) and go through the email cache system.

**Warning**: This sends to everyone, even if they already received a reminder. Use sparingly.

### Automatic Notifications
When cron is enabled, the system automatically sends:
- **Enrollment notifications**: To users who were voluntold, sent in batches at the configured cron frequency
- **Review notifications**: To users whose applications were approved or denied

## New Event Migration

The "Prepare FIST for a new event" button opens a migration wizard:

1. Enter the new event name and event dates
2. The system:
   - Copies volunteer forms, departments, teams, rotas, shifts, projects, and lead positions
   - Shifts all dates by the year difference
   - Preserves confirmed lead signups (carrying over the lead roster)
   - Resets all volunteer ticket IDs
   - Clears non-lead signups
3. After migration, review event settings to confirm dates are correct

**Important**: Manager and admin roles must be re-granted manually for the new event scope. The first admin role needs to be set directly in the database or preserved from before the migration.

## Monitoring

### Staffing Reports
The manager dashboard shows a Build and Strike staffing report. Department dashboards show the same for their scope. These reports help identify teams that are under-staffed for setup and teardown.

### User Statistics
Available via the NoInfo user list, showing:
- Total registered users
- Users with completed profiles
- Users with profile pictures
- Ticket holders
- Users with any duties
- Users who are leads
- Users with event-time duties
- Users with 3+ event-time duties
- Currently online users

## Troubleshooting

### Orphaned Signups
A garbage collection cron job runs every 3 days at 3am to clean up signups that reference deleted duties. Orphaned signups are backed up to `signupGcBackup` before removal.

### Email Failures
Failed emails (after 5 retries) are stored in the `emailFails` collection with error details. The system stops attempting sends after 10 successive failures to avoid overloading a broken SMTP server.

### Ticket Verification
The system runs daily checks for users missing tickets and weekly full re-validation. Results are processed gradually (every 20 seconds) to avoid API rate limits. These jobs stop after the event end date.
