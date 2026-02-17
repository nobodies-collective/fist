# Event Lifecycle

FIST manages the full annual cycle of an event: from opening volunteer registration months in advance, through the three on-site phases, to yearly rollover.

## Annual Timeline

```
January          FIST opens (fistOpenDate)
                 Leads/managers set up teams, rotas, shifts
                 ↓
Months before    Volunteers register, fill profiles, browse & sign up
                 Leads review applications, fill teams
                 ↓
~3 weeks before  BUILD/SETUP period begins
                 Early entry volunteers arrive
                 ↓
Event week       EVENT period (~5-6 days, typically early-mid July)
                 ↓
After event      STRIKE period (~1 week)
                 Teardown and leave-no-trace
                 ↓
After strike     Managers migrate FIST to the next year's event
```

## Three On-Site Phases

### Build / Setup Period

- **Duration**: Approximately 3 weeks before the event
- **Work style**: Full days with siesta; not shift-based
- **Managed via**: Projects (multi-day commitments)
- **Key teams**: Build Crew, DVS (volunteer servicing), Toolhaus, Demarcation, Power, LNT
- **Cantina**: La Cantina feeds setup crews; the system tracks daily dietary headcounts during the build period.

Volunteers who sign up for setup shifts may qualify for **early entry** — arriving on site before the event officially starts. The early entry system tracks:
- Maximum early entry passes available (`earlyEntryMax`)
- Barrios arrival date (when neighborhood/camp organizers arrive)
- Early entry close date (after which only leads can modify early entry shifts)
- Early entry requirement end time (after which early entry passes are no longer needed)

### Event Period

- **Duration**: Approximately 5-6 days (Tuesday to Sunday, typically second week of July)
- **Work style**: Shift-based rotations, typically 4-8 hours
- **Managed via**: Shifts organized into rotas
- **All teams active**: Gate, NoInfo, Nomads, Ice, Production, Malfare, etc.
- **On-site coordination**: NoInfo team uses FIST to fill last-minute gaps

### Strike Period

- **Duration**: Approximately 1 week after the event
- **Work style**: Full days with siesta
- **Managed via**: Projects
- **Key teams**: Strike Crew, LNT, Toolhaus, Power
- **NoInfo support**: NoInfo dashboard has a dedicated "strike shifts" view

## Key Event Settings

Managers configure these dates and parameters in Event Settings (`/manager/eventSettings`):

| Setting | Purpose |
|---------|---------|
| `eventName` | Identifier for this year's event (e.g., "fixme2026") |
| `previousEventName` | Last year's event (for data migration reference) |
| `eventPeriod` | Start and end dates of the event itself |
| `buildPeriod` | Start and end dates of setup/build |
| `strikePeriod` | Start and end dates of teardown/strike |
| `fistOpenDate` | When the system opens for general volunteer registration |
| `earlyEntryMax` | Maximum number of early entry passes |
| `earlyEntryClose` | Deadline after which only leads can modify early entry shifts |
| `earlyEntryRequirementEnd` | After this datetime, early entry passes are no longer needed |
| `barriosArrivalDate` | When barrio/camp organizers can arrive |
| `cronFrequency` | How often automated notification emails are sent (e.g., "every 15 mins") |
| `emailManualCheck` | If true, emails are queued for manager review before sending |

## Pre-Event: FIST Open Date

The `fistOpenDate` gates access for general volunteers:

- **Before the date**: Only org members (emails ending in the event's domain) and existing leads can access the system. The homepage shows a countdown timer.
- **After the date**: All registered volunteers can access the dashboard and sign up for shifts.

This allows leads and managers to set up the organizational structure, create rotas, and define shifts before the general volunteer population can see them.

## During the Event: Real-Time Coordination

Once the event is underway:

- **Volunteers** check their dashboards for upcoming shifts
- **Leads** monitor their team's staffing and handle last-minute changes
- **NoInfo coordinators** use their dashboard to identify unfilled shifts and voluntell available volunteers
- **Managers** monitor global staffing levels and can send mass reminders

The system tracks online status of users, helping NoInfo and leads find available people.

## Cron Jobs and Automation

Several automated jobs run during the event lifecycle:

| Job | Schedule | Purpose |
|-----|----------|---------|
| Enrollment notifications | Configurable (e.g., every 15 min) | Email volunteers who've been voluntold |
| Review notifications | Configurable | Email volunteers whose applications were approved/denied |
| Email cache send | Every 5 minutes | Send queued emails (unless manual check is enabled) |
| Signups GC | Every 3 days at 3am | Clean up orphaned signups (duty was deleted) |
| Missing ticket check | Daily at 4am | Re-check users without tickets against ticket API |
| All ticket check | Weekly on Mondays | Re-validate all ticket IDs |

Ticket-related cron jobs automatically stop after the event end date.

## Year-to-Year Migration

At the end of each event cycle, managers migrate FIST to the next year. There are two approaches:

### Option 1: New Event Migration (In-App)

Available via "Prepare FIST for a new event" on the manager dashboard:

1. Enter the new event name (e.g., "fixme2026") and new event dates
2. The system copies from the current event:
   - All volunteer form data
   - Organizational structure (departments, teams)
   - Rotas with dates shifted by the year difference
   - Shifts and projects with dates shifted
   - Lead positions
   - Confirmed lead signups (preserving the lead roster)
3. The system updates:
   - Event settings with new dates
   - Previous event name reference
3. The system resets:
   - All ticket IDs (volunteers must re-enter for the new year)
   - All non-lead signups

### Option 2: JSON Export/Import

For more control, managers can:

1. **Export** the full rota as JSON (teams, rotas, shifts, projects, leads, settings)
2. **Edit** the JSON manually (add/remove teams, adjust shift structures)
3. **Import** the modified JSON into a fresh or existing event

This allows structural changes between years (new teams, reorganized departments) while preserving the basic schedule template.

## What Persists Across Years

| Data | Persists? | Notes |
|------|-----------|-------|
| User accounts | Yes | Same login works year to year |
| Volunteer form data | Yes | Copied to new event collections |
| Org structure | Yes | Copied and can be modified |
| Lead assignments | Yes | Confirmed leads are preserved |
| Shift signups | No | Reset for new year |
| Ticket IDs | No | Must re-enter each year |
| Manager/admin roles | Manual | Must be re-granted for the new event scope |
