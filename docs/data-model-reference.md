# Data Model Reference

This document defines the current data model needed for behavior parity.

## 1. Local Collections (Explicit Schemas)

### `users` (`Meteor.users`)

Schema source: `both/collections/users.js`

| Field | Type | Notes |
|------|------|-------|
| `_id` | String | User ID |
| `emails[]` | Object[] | `address`, `verified` |
| `createdAt` | Date | auto on insert |
| `services` | Object | auth provider payload (blackbox) |
| `roles[]` | Object[] | scoped roles data |
| `ticketId` | Number | optional ticket number |
| `fistbumpHash` | String | hash used at magic-link signup |
| `fistbumpHashUsed` | String | replay-protection marker |
| `rawTicketInfo` | Object | external API payload |
| `profile` | Profile schema | from MeteorProfile package + local extension |
| `profile.formFilled` | Boolean | local extension, default false |
| `status` | Object | user online status package data |
| `isBanned` | Boolean | login-block flag |
| `_impersonateToken` | String | reserved/optional; no active flow in this repo |

### `volunteerForm`

Schema source: `both/collections/users.js`

Extends package volunteer form schema and adds:

| Field | Type | Required | Allowed Values / Notes |
|------|------|----------|------------------------|
| `about` | String | No | free text |
| `experience` | String | No | free text |
| `gender` | String | No | `male`, `female`, `other` |
| `food` | String | No | `omnivore`, `vegetarian`, `vegan`, `fish` |
| `allergies[]` | String[] | No | `celiac`, `shellfish`, `nuts/peanuts`, `treenuts`, `soy`, `egg` |
| `intolerances[]` | String[] | No | `gluten`, `peppers`, `shellfish`, `nuts`, `egg`, `lactose`, `other` |
| `medical` | String | No | free text |
| `languages[]` | String[] | No | `english`, `french`, `spanish`, `german`, `italian`, `other` |
| `emergencyContact` | String | Yes | free text |
| `anything` | String | No | free text |

Package extension fields used in UI/calls include `userId`, `skills[]`, `quirks[]`.

### `settings` (`EventSettings`)

Schema source: `both/collections/settings.js`

| Field | Type | Required | Notes |
|------|------|----------|-------|
| `eventName` | String | Yes | currently read-only in UI form |
| `previousEventName` | String | Yes | prior event scope |
| `eventPeriod` | `{start: Date, end: Date}` | Yes | main event window |
| `buildPeriod` | `{start: Date, end: Date}` | Yes | setup window |
| `strikePeriod` | `{start: Date, end: Date}` | Yes | teardown window |
| `earlyEntryMax` | Number | Yes | max early-entry passes |
| `barriosArrivalDate` | Date | Yes | camp organizer arrival |
| `fistOpenDate` | Date | Yes | volunteer opening gate |
| `earlyEntryClose` | Date | Yes | close date for EE edits |
| `earlyEntryRequirementEnd` | Date | Yes | datetime after which EE pass not needed |
| `cronFrequency` | String | No | user-entered interval string |
| `emailManualCheck` | Boolean | Yes | queue approval requirement |

### Other local collections

| Collection | Purpose |
|-----------|---------|
| `tickets` | legacy Quicket support cache |
| `emailCache` | rendered outbound email queue |
| `emailLogs` | successful send audit |
| `emailFails` | exhausted retry failures |
| `signupGcBackup` | backup before orphan-signup deletion |
| `fistMigrations` | migration version tracking |

## 2. Core Operational Collections (Package-Provided, Required)

These collections are supplied by `meteor/goingnowhere:volunteers` but are heavily used here.

### Organization units

#### `division`

Observed fields:

- `_id`
- `name`
- `description`
- `policy`
- `parentId` (top marker often `TopEntity`)

#### `department`

Observed fields:

- `_id`
- `name`
- `description`
- `policy`
- `parentId` (division ID)

#### `team`

Observed fields:

- `_id`
- `name`
- `description`
- `parentId` (department ID)
- `policy`
- `email`
- `location`
- `skills[]`
- `quirks[]`

### Duties

#### `rotas`

Observed fields:

- `_id`
- `parentId` (team ID)
- `title`
- `description`
- `priority`
- `policy`
- `start`
- `end`

#### `shift`

Observed fields:

- `_id`
- `parentId` (team ID)
- `rotaId`
- `title`
- `start`
- `end`
- `min`
- `max`
- `priority`
- `policy`

#### `project`

Observed fields:

- `_id`
- `parentId` (team ID)
- `title`
- `description`
- `start`
- `end`
- `priority`
- `policy`
- `staffing[]` (daily min/max)

#### `lead`

Observed fields:

- `_id`
- `parentId` (team or department ID)
- `title`
- `description`
- `priority`
- `policy`

### `signups`

Observed fields:

- `_id`
- `userId`
- `parentId`
- `shiftId`
- `type` (`shift`, `project`, `lead`, `task`)
- `status` (`pending`, `confirmed`, `refused`, etc by package)
- `enrolled` (voluntold flag)
- `reviewed` (review processed flag)
- `notification` (email notification sent flag)
- `start`/`end` (project-specific signup window in some flows)
- `createdAt`

## 3. Relationships

1. Division -> Department -> Team via `parentId`.
2. Team -> Rota/Shift/Project/Lead via `parentId`.
3. Shift -> Rota via `rotaId`.
4. Signup -> Duty via `shiftId` plus `type`.
5. Signup -> User via `userId`.
6. Lead authority comes from confirmed lead signups + scoped role hierarchy.

## 4. Enumerations And Flags

### Duty policy

- `public`
- `requireApproval`

### Common signup states in this repo

- `pending`
- `confirmed`
- `refused`
- `bailed`
- `cancelled`

### Signup flags

- `enrolled=true` means direct assignment by lead/noinfo.
- `reviewed=true` means an approval decision has occurred.
- `notification=true` means notification pipeline already handled it.

## 5. Data Hygiene Rules

1. Signup GC removes signups pointing to deleted duties and stores backup.
2. Ticket jobs periodically validate/refresh `ticketId`.
3. Form completion is represented by `profile.formFilled`.
4. Email delivery is queue-based with retry/failure collections.

## 6. Migration/Import Effects

- `event.new.event` clones structure/forms and lead signups while clearing user ticket metadata.
- `rota.all.import` recreates structural collections and settings from JSON payload.

## 7. Rebuild Guidance

For cross-stack rebuilds:

1. Implement these collections with explicit schemas and constraints.
2. Preserve parent-child role inheritance logic.
3. Preserve signup-state side effects (notification flags, enrollment flags).
4. Keep event settings as first-class runtime config, not static constants.
