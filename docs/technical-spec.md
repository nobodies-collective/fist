# Technical Specification

This document provides technical details for recreating the FIST application in a new technology stack. It covers the data model, core algorithms, API logic, and architectural patterns.

## Data Model

FIST uses a document-oriented model. Relationships are primarily managed through `parentId` and `shiftId` references.

### 1. Users & Volunteers
Extends standard Meteor/Passport user models.

| Collection | Key Fields | Description |
|------------|------------|-------------|
| `users` | `_id`, `emails[]`, `profile.firstName`, `profile.lastName`, `profile.nickname`, `profile.language`, `profile.picture`, `profile.formFilled` (bool), `ticketId` (int), `roles[]`, `isBanned` (bool), `status.online` (bool) | Core user accounts. Profile data is duplicated here for fast access. |
| `volunteerForm` | `userId`, `about` (text), `experience` (text), `skills[]`, `quirks[]`, `gender`, `food`, `allergies[]`, `intolerances[]`, `medical` (text), `languages[]`, `emergencyContact`, `anything` | Full volunteer profile data. |

### 2. Organizational Units
A three-level hierarchy: Division -> Department -> Team.

| Field | Type | Description |
|-------|------|-------------|
| `_id` | String | Unique identifier. |
| `parentId` | String | Reference to parent unit (Division or Department). |
| `name` | String | Display name. |
| `description` | Text | Description of the unit. |
| `skills[]` | String | Useful skills for this unit (Team level only). |
| `quirks[]` | String | Characteristics of shifts in this unit. |
| `location` | String | Optional physical location. |
| `policy` | Enum | `public` or `private`. |
| `email` | String | Contact email for the team. |

### 3. Duties & Scheduling
Four types of duties: `shift`, `project`, `lead`, `task`.

#### Shifts & Rotas
Shifts are grouped into Rotas for bulk management.
- **Rota**: `_id`, `parentId` (teamId), `title`, `description`, `priority`, `policy`, `start` (date), `end` (date).
- **Shift**: `_id`, `rotaId`, `parentId` (teamId), `title`, `start` (datetime), `end` (datetime), `min` (int), `max` (int), `priority`, `policy`.

#### Projects
Multi-day commitments.
- `_id`, `parentId` (teamId), `title`, `description`, `start` (date), `end` (date), `priority`, `policy`.
- `staffing[]`: Array of objects `{ min: int, max: int }` mapping to each day of the project duration.

#### Lead Positions
- `_id`, `parentId` (team or deptId), `title`, `description`, `responsibilities`, `qualifications`, `policy` (usually `requireApproval`).

### 4. Signups
Associations between users and duties.

| Field | Type | Description |
|-------|------|-------------|
| `userId` | String | Reference to user. |
| `shiftId` | String | Reference to shift, project, or lead position. |
| `parentId` | String | Reference to team or department. |
| `type` | Enum | `shift`, `project`, `lead`, `task`. |
| `status` | Enum | `confirmed`, `pending`, `refused`, `bailed`, `cancelled`. |
| `enrolled` | Bool | True if assigned by an admin ("voluntold"). |
| `reviewed` | Bool | True if a lead has acted on the request. |
| `notification` | Bool | True if notification email has been sent. |
| `start`, `end` | Date | (Project only) Specific dates the volunteer is committed to. |

---

## Core Algorithms

### 1. Urgency Scoring (NoInfo Dashboard)
Used to prioritize which shifts need the most attention.

**Score Calculation:**
```
preferenceScore = count(user.skills ∩ duty.skills) + count(user.quirks ∩ duty.quirks)
priorityMultiplier = { normal: 1, important: 3, essential: 6 }
minRemaining = max(0, duty.min - confirmedSignups)
maxRemaining = max(0, duty.max - confirmedSignups)

# For Rota/Shifts:
score = (maxRemaining * shiftHours * (1 + preferenceScore)) + 
        (minRemaining * priorityMultiplier * shiftHours * (1 + preferenceScore))

# For Projects:
score = (maxRemaining * (1 + preferenceScore)) + 
        (minRemaining * priorityMultiplier * (1 + preferenceScore))
```
*Note: The score is typically calculated per user if preferences are known, otherwise `preferenceScore` defaults to 1.*

### 2. Yearly Migration (Rollover)
Copies structure and leads while shifting dates.

1.  **Calculate Offset**: `dayDifference = newEventStart - oldEventStart`.
2.  **Duplicate Units**: Copy all Departments and Teams, creating new IDs but preserving hierarchy.
3.  **Duplicate Duties**: Copy Rotas, Shifts, Projects, and Lead Positions.
4.  **Shift Dates**: All `start` and `end` dates are updated: `newDate = oldDate + dayDifference`.
5.  **Preserve Leads**: Copy `signups` where `type: 'lead'` and `status: 'confirmed'`.
6.  **Reset Tickets**: Clear `ticketId` and `rawTicketInfo` for all users.
7.  **Clear Signups**: Do NOT copy non-lead signups.

### 3. Early Entry (EE) Calculation
Determines if a volunteer qualifies for early site access.

- **Trigger**: Any confirmed signup with a `start` date before the `eventPeriod.start`.
- **EE Date**: `min(signup.start) - 1 day`.
- **Logic**: Aggregates all pre-event shifts for a user to find their earliest arrival date.

---

## API & Server Logic

### Authentication Mixins
Permission checks must be enforced at the API layer:
- **`isLead(unitId)`**: User has a confirmed 'lead' signup for `unitId`.
- **`isMetaLead(deptId)`**: User has a confirmed 'lead' signup for `deptId` (grants access to all teams in `deptId`).
- **`isNoInfo()`**: User is a lead of the "NoInfo" team or a Manager.
- **`isManager()`**: User has the global 'manager' or 'admin' role.

### Cron Jobs
- **Enrollment Notifications**: `SELECT * FROM signups WHERE enrolled=true AND notification=false`. Trigger `voluntell` email.
- **Review Notifications**: `SELECT * FROM signups WHERE reviewed=true AND notification=false`. Trigger `reviewed` email.
- **Ticket Cleanup**: Re-verify `ticketId` against Fistbump API. If invalid/missing, unset the field.

### Email System
All emails are queued in an `emailCache` table before sending to allow for:
1.  **Rate Limiting**: One email every 2 seconds.
2.  **Manual Approval**: Gating by `emailManualCheck` setting.
3.  **Audit Trail**: Moving to `emailLogs` on success or `emailFails` after 5 retries.

---

## External Integrations

### Fistbump API
- **Verification**: `GET /verify?key=[key]&v=[hash]`
  - Returns: `{ Email: string, TicketId: string }`
- **Lookup**: `GET /huntthenooner?key=[key]&nooner=[email_or_ticket]`
  - Returns: Array of ticket objects.

## Architectural Notes
- **Real-time Updates**: The `signups` and `status.online` fields are highly volatile during the event. Implementations should use WebSockets or high-frequency polling for the NoInfo and Lead dashboards.
- **Date Handling**: All dates must be stored in UTC but displayed in the event's local timezone (Spain/Madrid) to avoid shift-offset errors.
