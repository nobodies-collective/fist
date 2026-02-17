# Volunteer Journey

This document traces the complete experience of a volunteer from first visit to shift day.

## 1. Discovery

A volunteer arrives at the FIST homepage. Before the system opens (controlled by `fistOpenDate`), they see:
- A countdown to when registration for on-site roles opens
- A link to volunteer remotely before the event ("I can't wait, I want to volunteer now!")
- An "About" section explaining what the event is

After `fistOpenDate`, the homepage changes to show:
- "For Information and Scheduling of Teams" tagline
- A "Register now" button (or "Get to it" if already logged in)

## 2. Registration

Two paths to create an account:

### Standard Registration
1. Click "Register" on the homepage
2. Enter email address and password (minimum 6 characters)
3. Agree to terms and conditions
4. Account is created; redirect to email verification

### Magic Link (Fistbump)
1. Receive a magic link URL (e.g., from the event's ticketing/communication system)
2. Click the link, which contains a verification hash (`/work?fornothing=HASH`)
3. FIST verifies the hash against the Fistbump API
4. If the email matches an existing account: auto-login via token
5. If new user: pre-fill email (from ticket data), set a password, agree to terms
6. Account is created with ticket ID already linked; email is pre-verified

## 3. Email Verification

- After standard registration, the volunteer must verify their email
- A verification email is sent automatically
- The volunteer clicks the link in the email to verify
- Users arriving via magic link skip this step (their email is verified by the Fistbump system)
- Unverified users are redirected to a "check your email" page on any protected route

## 4. Volunteer Form

Before accessing the dashboard, every volunteer must complete their profile form. The system redirects to `/profile` automatically if the form hasn't been filled.

**Information collected:**

| Field | Required | Notes |
|-------|----------|-------|
| Ticket ID | No | Format: QTK12345678. Validated against ticket API |
| Playa Name / Nickname | No | Display name used throughout the system |
| First Name | Yes | |
| Last Name | No | |
| Language | No | English, French, or Spanish (sets UI language) |
| Profile Picture | No | Upload for recognition |
| How can you help? | No | Free text about background and abilities |
| Burn event experience | No | Previous volunteering experience |
| Skills | No | Multi-select from team-defined skill tags |
| Shift quirks | No | What they look for in a shift (e.g., "work in the shade", "sober shift") |
| Gender | No | Used only for shifts where gender balance is desirable |
| Languages spoken | No | Checkboxes: English, French, Spanish, German, Italian, Other |
| Food preference | No | Omnivore, Vegetarian, Vegan, Pescetarian |
| Grave allergies | No | Celiac, Shellfish, Nuts/Peanuts, Tree nuts, Soy, Egg |
| Food intolerances | No | Gluten, Peppers, Shellfish, Nuts, Egg, Lactose, Other |
| Medical conditions | No | Confidential, used only in emergencies |
| Emergency contact | Yes | Name, number, languages, relationship |
| Anything else | No | Free text |

After saving, the volunteer is redirected to their dashboard (or to wherever they were trying to go).

## 5. Browsing Available Shifts

The volunteer dashboard (`/dashboard`) has two main panels:

### Your Shifts (left panel, if any exist)
A table of all confirmed and pending signups showing shift details and status.

### Shifts Need Help (right panel)
A filterable list of open shifts across all teams. Volunteers can filter by:
- **Shift type**: All, event-time shifts, setup/strike projects, lead positions
- The list shows shifts that still have open spots

Volunteers can also browse by organizational structure:
- `/department/:deptId` shows all teams in a department
- `/department/:deptId/team/:teamId` shows a specific team's shifts

## 6. Signing Up

The signup experience depends on the shift's **policy**:

### Public Shifts
- Click "Sign up" on any open shift
- Immediately confirmed
- Appears in "Your Shifts" on the dashboard

### Approval-Required Shifts
- Click "Apply" on the shift
- Status set to "pending"
- The team lead sees the application in their pending requests queue
- Lead approves or denies
- Volunteer is notified via email of the decision

### Lead Positions
- All lead positions require approval
- The volunteer applies; metaleads or managers review
- Upon confirmation, the volunteer gains lead permissions for that team

## 7. Being "Voluntold"

Leads and NoInfo coordinators can directly enroll volunteers into shifts. This is called "voluntelling" in the system.

- The volunteer receives an enrollment notification email
- The signup appears on their dashboard as confirmed
- This is commonly used during the event when NoInfo needs to fill urgent gaps

## 8. Notifications

Volunteers receive emails at several points:

| Trigger | Template | Content |
|---------|----------|---------|
| After being voluntold | `voluntell` | Lists newly enrolled shifts/projects/leads |
| After lead reviews signup | `reviewed` | Approval or denial of pending applications |
| Before event (if enabled) | `shiftReminder` | Reminder of all confirmed shifts |
| Account enrollment | `enrollAccount` | Invitation link to join FIST |
| Email verification | `verifyEmail` | Link to verify email address |

Notification frequency is controlled by the cron settings (configurable by managers). Emails can also be manually reviewed before sending if `emailManualCheck` is enabled.

## 9. During the Event

On-site, volunteers:
- Check their dashboard for upcoming shifts
- May be approached by NoInfo coordinators to fill urgent openings
- Can continue signing up for shifts via the web app
- See "Urgent Shifts Today" and "Urgent Shifts this Week" indicators

## 10. Access Gates

The system enforces several gates along the journey:

```
Visit homepage
  └── Must be logged in → redirect to /login
        └── Must have verified email → redirect to /verify-email
              └── Must be after fistOpenDate (unless org member or lead) → redirect to /
                    └── Must have filled volunteer form → redirect to /profile
                          └── Dashboard and shift browsing available
```

Organization members (email ending in the configured domain) and existing leads bypass the `fistOpenDate` gate, allowing them to set up the system before it opens to the general volunteer population.
