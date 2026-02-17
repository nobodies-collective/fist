# Lead Guide

Operational guide for team leads, department metaleads, and NoInfo coordinators.

## Team Lead

### Route

- `/lead/team/:teamId`

### Sidebar Actions

- Team settings edit.
- Add shift rota.
- Add project.
- Team rota CSV export (`team.rota`).

### Core Workflows

1. Build duty structure (rotas/projects).
2. Review pending requests (approve/deny).
3. Voluntell users directly into duties.
4. Track staffing and pending counts.

### Volunteer Search (Current UI)

Lead search currently supports:

- Name/email text search.
- Ticket number search.
- Include incomplete profiles toggle.

Note: skill/quirk/priority filters are not present in the current React search UI.

### Contact Request

Leads can request a volunteer email via `users.requestContact`.

- Requires a reason string.
- Minimum length: 10 characters.
- Access request is audit-logged server-side.

## Department MetaLead

### Route

- `/metalead/department/:deptId`

### Sidebar Actions

- Department settings edit.
- Add team.
- Early Entry tools.
- Department rota CSV (`dept.rota`).
- Early Entry CSV (`ee.csv`).

### Main Workflows

1. Review lead applications across department scope.
2. Monitor build/strike staffing report.
3. Manage team roster and structural changes.

Additional dept-level operations exposed in current UI include team move and delete actions.

## NoInfo Coordinator

### Routes

- `/noinfo` (event period)
- `/noinfo/strike` (strike period)
- `/noinfo/userList` (user search and profile modal)

### Core Workflow

1. Review open duties sorted by urgency.
2. Identify near-term gaps.
3. Select volunteer from NoInfo user list or direct interaction.
4. Voluntell user into shift/project.

### User List Tools

- Aggregated user stats (`users.stats`).
- Search users and open full profile panel (user info, volunteer form, responsibilities, booked duties).

### Permission Caveat

Router currently guards NoInfo pages with `isALead`, not strict `isNoInfo`. Some NoInfo server methods still require NoInfo authorization.

## Recommended Cadence

### Pre-event

1. Leads finalize rotas/projects and staffing targets.
2. Metaleads verify team structure and lead coverage.
3. Both monitor pending applications and staffing deficits.

### During event

1. Leads process requests quickly and adjust assignments.
2. Metaleads watch department-level risk.
3. NoInfo fills urgent real-time gaps.

### Strike

1. Strike teams keep project coverage current.
2. NoInfo switches to strike duty board.
3. Managers prepare rollover after operations close.
