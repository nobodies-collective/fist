# Server Methods and Jobs

This is the authoritative method/job contract for this repository.

## 1. Local Method Catalog

## Core methods (`server/methods.js`)

| Method | Auth | Input | Output / Side Effects |
|-------|------|-------|------------------------|
| `sendVerificationEmail` | logged-in user context | none | triggers Accounts verification email for caller |
| `eventSettings` | none | none | returns current settings doc |
| `Accounts.enrollUserCustom` | manager | enroll payload | currently throws `501` (not implemented) |
| `Accounts.adminChangeUserPassword` | same user or manager | `{userId,password,password_again}` | updates password when both fields match |
| `users.stats` | NoInfo/manager (`isNoInfoMixin`) | none | aggregate stats for user list sidebar |
| `users.paged` | any lead | `{search,page,perPage,includeIncomplete}` | paged users without manager extras |
| `users.paged.manager` | manager | same as above | paged users with role extras |
| `volunteerBio.update` | same user or manager | profile + volunteer form payload | updates `users.profile`, upserts `volunteerForm`, ticket lookup |
| `team.rota` | lead for target | `{parentId}` | team CSV rows |
| `dept.rota` | lead for target | `{parentId}` | flattened team CSV rows with team name |
| `all.rota` | manager | none | global CSV rows |
| `ee.csv` | lead | `{parentId}` optional | early-entry export rows grouped per user |
| `event.new.event` | manager | settings subset (`eventName`,`eventPeriod`) | yearly migration clone/shift flow |
| `rota.all.export` | manager | `{eventName}` | JSON structure export |
| `rota.all.import` | manager | `{rotaJson}` | destructive structural import |
| `cantina.setup` | manager | none | build-period daily dietary report |
| `shifts.empty` | NoInfo/manager | `Date` | up to 10 open future shifts |
| `users.requestContact` | any lead | `{userId,reason}` | returns target email + display name; audit logs request |
| `accounts.fistbump.check` | none | `{hash}` | existing-user token login payload or new-user bootstrap payload |

## Settings methods (`both/methods.js`)

| Method | Auth | Purpose |
|-------|------|---------|
| `settings.fetch` | none | fetch current settings |
| `settings.insert` | manager | insert settings doc |
| `settings.update` | manager | update settings doc (modifier validation) |

## Email/notification methods (`server/email.js`)

| Method | Auth | Purpose |
|-------|------|---------|
| `emailCache.get` | manager | list cached emails |
| `emailCache.send` | manager | send selected cached email |
| `emailCache.delete` | manager | delete cached email |
| `emailCache.reGenerate` | manager | regenerate from template and replace queue item |
| `email.sendShiftReminder` | manager | send reminder to one user |
| `email.sendMassShiftReminder` | manager | send reminders to all users with pending/confirmed signups |
| `email.sendReviewNotifications` | manager | send review summary to one user |

Additional method wrappers in `server/accounts.js` apply custom mixins to MeteorProfile methods (send enroll, email add/remove/primary, verification).

## Package method surface (`packages/meteor-volunteers`)

These are called directly from UI and are required for full parity:

| Method Pattern | Purpose |
|----------------|---------|
| `{event}.Volunteers.signups.insert` | create/upsert signup; applies approval/voluntell logic |
| `{event}.Volunteers.signups.update` | update signup (project timing and lead/admin flows) |
| `{event}.Volunteers.signups.remove` | remove signup (lead-controlled) |
| `{event}.Volunteers.signups.confirm` | set signup confirmed, mark reviewed |
| `{event}.Volunteers.signups.refuse` | set signup refused, mark reviewed |
| `{event}.Volunteers.signups.bail` | user/lead bail flow (`status='bailed'`) |
| `{event}.Volunteers.rotas.insert/update/remove` | rota CRUD + shift materialization |
| `{event}.Volunteers.team.insert/update/remove` | team CRUD + role hierarchy updates |
| `{event}.Volunteers.department.insert/update/remove` | department CRUD + cascading deletes |
| `shifts.open.list` | open-duty urgency list (project + rota) |
| `shifts.byPref.list` | open-duty list weighted by user prefs and period type |
| `project.staffing.report` | build/strike staffing report data |
| `duties.earlyEntry.list` | early-entry candidate aggregation |
| `user.role.add` / `user.role.remove` | scoped manager/admin role management |
| `prev-event.team.list` / `prev-event.team-volunteers.list` | previous-event read helpers |

### Package signup invariants

`{event}.Volunteers.signups.insert` enforces:

1. Shift-change window rules (`areShiftChangesOpen`).
2. `adminOnly` duty protection for non-leads.
3. User ownership unless lead/noinfo voluntell.
4. Double-booking detection by overlapping date ranges.
5. Capacity checks (including project daily wanted/needed checks).
6. Project signup dates constrained inside project start/end.
7. Status defaulting:
   - `public` or voluntell -> `confirmed`
   - otherwise -> `pending`

## 2. Method Security Rules

### Route-level authorization is insufficient

All privileged behavior is enforced server-side with mixins:

- Package mixins: `Volunteers.services.auth.mixins`
- Local mixins: `isNoInfoMixin`, `isSameUserOrNoInfoMixin`

### Search hardening

`users.paged*` sanitizes incoming search filters by:

- field allowlist
- regex escaping
- dropping unknown operators

This is a deliberate NoSQL injection mitigation.

## 3. Background Jobs (`server/cron.js` + `server/ticketCron.js`)

Jobs are activated/deactivated by observing `settings` changes.

### Activation condition

- `cronFrequency` set -> jobs registered and cron started.
- `cronFrequency` empty -> cron stopped.

### Jobs

| Job Name | Schedule Source | Action |
|---------|------------------|--------|
| `EnrollmentNotifications` | `every {cronFrequency}` | send enrollment emails for `enrolled=true`, `notification=false`, `status='confirmed'` |
| `ReviewNotifications` | `every {cronFrequency}` | send review emails for reviewed non-enrolled signups |
| `EmailCache` | every 5 minutes | drain email queue when manual check is off |
| `signupsGC` | at 03:00 every 3 days | remove signups whose referenced duty no longer exists, backup first |
| `MissingTicketCheck` | at 04:00 every day | queue checks for users missing tickets |
| `AllTicketCheck` | at 04:00 every monday | queue checks for all form-complete users |
| `ProcessTicketCheck` | every 20 seconds | process one queued ticket check item |

Ticket jobs run only when:

- production mode, or
- `devConfig.testTicketApi` enabled,

and only before event end date.

### Ticket queue logic

`queueTicketChecks(false)` selects users with:

- `profile.formFilled=true`
- missing/low `ticketId`

`queueTicketChecks(true)` selects all form-complete users.

Queue processor:

- updates changed ticket IDs
- unsets invalid tickets
- keeps data unchanged on API error

## 4. Rate Limiting (`server/rateLimiter.js`)

| Rule | Limit |
|------|-------|
| `accounts.fistbump.check` | 10 calls / hour |
| `accounts.fistbump.login` | 5 calls / second |
| methods starting with `Accounts.` | 3 calls / minute |

## 5. Migration Operations

### Schema/data migrations (`server/migrations.js`)

- migration versions tracked in `fistMigrations`.
- includes historical role carry-forward scripts.

### Annual data migration (`event.new.event`)

- separate from schema migrations.
- clones event content between scoped collection names.

## 6. Operational Warnings

1. `Accounts.enrollUserCustom` is present but intentionally unimplemented.
2. JSON import/export methods exist but are not fully wired into active manager routes.
3. NoInfo routes currently use broad `isALead` gate on client; rely on server auth for sensitive methods.
