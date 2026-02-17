# Technical Specification

This specification is intended for rebuilding the application in another stack.

It is based on current implementation in this repository and resolves earlier drift between docs and code.

## Scope And Authority

Primary technical sources:

- Routing/auth gates: `client/router.jsx`, `client/components/RequireAuth.jsx`
- Local server APIs: `server/methods.js`, `both/methods.js`, `server/email.js`
- Automation: `server/cron.js`, `server/ticketCron.js`
- Local schemas: `both/collections/users.js`, `both/collections/settings.js`
- Config identity: `both/config.js`, `both/init.js`
- Default organization data: `imports/fixtures/units-fixtures.js`

For full field/method details, see:

- [Data Model Reference](data-model-reference.md)
- [Server Methods and Jobs](server-methods-and-jobs.md)

## Runtime Architecture

1. Browser UI (React + Meteor DDP calls)
2. Meteor method/publication server
3. MongoDB collections
4. External integrations:
   - Fistbump API
   - SMTP email transport

A large portion of domain logic is provided by `meteor/goingnowhere:volunteers` package. This repo adds event-specific behavior, security wrappers, docs, fixtures, and integrations.

## Identity And Branding Constants

Current code constants:

- Organization display name: `FixMe` (`both/config.js`)
- Event scope: `fixme2026` (`both/init.js`)
- Previous scope: `nowhere2025` (`both/init.js`)

Rebuilds must make these values configurable, not hardcoded.

## Data Model (Summary)

Local collections directly defined here:

1. `users`
2. `volunteerForm`
3. `settings`
4. `tickets` (legacy support)
5. `emailCache`, `emailLogs`, `emailFails`
6. `signupGcBackup`
7. `fistMigrations`

Core operational collections supplied by package but required for parity:

- `division`, `department`, `team`
- `rotas`, `shift`, `project`, `lead`
- `signups`

## Authentication And Authorization Contract

### Authentication

- Email/password account flow with verification emails.
- Magic-link flow through Fistbump (`accounts.fistbump.check`).
- Magic-link replay prevention via `fistbumpHashUsed`.

### Route access gates

Protected pages enforce:

1. logged in
2. verified email
3. open-date gate (`fistOpenDate`) with bypass for org-domain or lead
4. role-specific guard (`isManager`, `isLead`, `isALead`)
5. completed form (`profile.formFilled`) except `/profile`

### Role model

- Team and department roles are scoped and hierarchical.
- Role inheritance is implemented via `alanning:roles` parent relationships.

## Core Workflows

### Volunteer profile update

Method: `volunteerBio.update`

- Validates/saves profile + volunteer form.
- Optionally validates ticket ID with Fistbump lookup.
- Marks `profile.formFilled=true`.
- Returns `{ hasTicket, wasError }`.

### User search and management

Methods:

- `users.paged` (lead scope)
- `users.paged.manager` (manager scope)

Security:

- Search fields are allowlisted and regex-escaped to reduce NoSQL injection risk.

### CSV exports

Implemented methods:

- `team.rota`, `dept.rota`, `all.rota`
- `ee.csv`
- `cantina.setup`

Important behavior details:

- Rota exports include confirmed shift/project signups.
- Early Entry export groups signups by user/email and computes `eeDate = first_start - 1 day`.
- Cantina export is build-period scoped and combines project coverage + shift-derived daily unique counts.

### Urgency scoring (NoInfo/open-duty ranking)

Implemented in package aggregations (`packages/meteor-volunteers/both/methods/aggregations.js`).

Priority mapping:

- `normal` -> `1`
- `important` -> `3`
- `essential` -> `6`

Preference score:

- intersection count of user skills with duty/team skills
- plus intersection count of user quirks with duty/team quirks

Project score:

- `volDays = sum(confirmed_signup_days)`
- `minRemaining = max(0, minStaffing - volDays)`
- `maxRemaining = max(0, maxStaffing - volDays)`
- `score = maxRemaining*(1+preferenceScore) + minRemaining*priorityScore*(1+preferenceScore)`

Rota score:

- per-shift remaining counts are aggregated across shift instances
- `shiftHours = max(1, firstShiftDurationHours)`
- `score = maxRemaining*shiftHours*(1+preferenceScore) + minRemaining*priorityScore*shiftHours*(1+preferenceScore)`

List endpoints sort by `score` descending.

### Migration paths

### `event.new.event`

- Clones volunteer forms, org units, duties, confirmed lead signups.
- Shifts dates by event-start day delta.
- Updates settings event names and periods.
- Clears ticket metadata from users.

Constraint:

- Destination scope is current hardcoded `Volunteers.eventName`. Developer intervention is required between annual cycles unless this is redesigned.

### `rota.all.export` / `rota.all.import`

- Name-based JSON structure transport for depts/teams/rotas/shifts/projects/leads/settings.
- Import removes and recreates structure collections and settings.

### Signup lifecycle invariants

Core rules (package signup methods):

1. Prevent overlapping double-bookings across shift/project commitments.
2. Enforce capacity before insert (including project day windows).
3. Enforce project signup dates inside parent project bounds.
4. Enforce shift-change cutoff rules:
   - before duty start for normal duties
   - before `earlyEntryClose` for early-entry duties
5. Non-owner signup creation is only valid for lead/noinfo voluntell operations.

## Email And Notification Pipeline

1. Render template with user + duty context.
2. Insert into `emailCache`.
3. Optional manual manager approval.
4. Sender drains queue every 2s/item.
5. Success -> `emailLogs`; repeated failure -> `emailFails`.

Automated notification jobs select signups based on `enrolled/reviewed/notification/status` flags.

## Background Jobs

Configured through `SyncedCron` and event settings observer.

Jobs include:

- Enrollment notifications
- Review notifications
- Email cache sender
- Signup GC with backup
- Ticket queue fill and processing

Ticket jobs run only under production/test-ticket mode and stop after event end.

## Integrations API Contract

### Fistbump

- Verify hash: `/verify?key=...&v=...`
- Ticket lookup: `/huntthenooner?key=...&nooner=...`

Expected behavior:

- Network/API failures should not destroy main volunteer form workflow.
- Invalid hash returns a user-facing login link error.

### SMTP

- Standard outbound email transport.
- From/site defaults built from org config and event scope.

## Timezone And Locale

Current implementation defaults to `Europe/Paris` for app timezone behavior.

Rebuild requirement:

- Preserve single authoritative event timezone and use it consistently for all date filtering, export windows, and display.

## Known Package Boundary

The following high-value capabilities are called from package code and must be reimplemented in a full cross-stack rebuild:

- Duty signup insertion/review/removal logic
- Team/department stats aggregations
- Open-shift urgency ranking for NoInfo
- Build/strike staffing report generation
- Department/team browse views

Because these live outside this repository, treat them as required behavior inferred from current UI and method usage contracts.

## Acceptance Criteria For Parity

1. All documented routes enforce equivalent auth gates.
2. All listed methods exist with equivalent inputs, authorization, and side effects.
3. Cron jobs produce equivalent notification and cleanup outcomes.
4. CSV exports match current fields and filtering rules.
5. Migration paths preserve lead continuity and reset ticket state.
6. Magic-link flow enforces replay protection and rate limits.
