# Glossary

Terminology used in FIST and the events it serves.

## FIST-Specific Terms

| Term | Definition |
|------|------------|
| **FIST** | For Information and Scheduling of Teams. The volunteer management application. |
| **Voluntell** | To directly enroll a volunteer into a shift without them applying. A portmanteau of "volunteer" and "tell." Used by leads and NoInfo coordinators to fill urgent gaps. |
| **Rota** | A shift rotation — a named group of related shifts covering a date range. E.g., "Gate Day Shifts" containing morning, afternoon, and evening gate shifts for each day of the event. |
| **Duty** | A generic term for any volunteer commitment: shift, project, lead position, or task. |
| **Signup** | The association between a volunteer and a duty. Has a status (pending, confirmed, refused) and metadata (enrolled, notified, reviewed). |
| **NoInfo** | 1. A team within the Volunteers department that runs the on-site information and shift coordination hub. 2. A role in the system granting cross-team visibility for real-time shift filling. Named as a play on "info" — the place that has no information (but actually does). |

## Organizational Terms

| Term | Definition |
|------|------------|
| **NOrg** | FixMe Organization (formerly Nowhere Organization). The single top-level division encompassing all departments and teams. |
| **Division** | The highest level in the organizational hierarchy. Currently only NOrg exists. |
| **Department** | A group of related teams under shared leadership. Examples: SLAP, BDSM, Malfare. |
| **Team** | The operational unit where volunteers work. Each team has its own shifts, leads, and signup management. |
| **Lead** | A person managing a team. Leads can create shifts, review applications, and voluntell people for their team. |
| **MetaLead** | A person managing a department. Has lead-level access across all teams in their department. Short for "meta-level lead." |
| **Manager** | A system-wide administrator who can configure event settings, manage users, and oversee all teams. |

## Event Phase Terms

| Term | Definition |
|------|------------|
| **Build / Setup** | The multi-week period before the event when infrastructure is constructed. ~3 weeks before event start. |
| **Event Time** | The event itself, typically ~5-6 days. When most shift-based volunteering happens. |
| **Strike** | The period after the event when everything is dismantled and the site is returned to its natural state. ~1 week. |
| **Early Entry** | Permission to arrive on site before the event officially starts, granted to volunteers with setup shifts. |
| **Barrios Arrival** | The date when barrio (neighborhood/camp) organizers can begin arriving. |
| **FIST Open Date** | The date when general volunteer registration opens. Before this date, only leads and org members can access the system. |

## Department Abbreviations

| Abbreviation | Full Name | Scope |
|-------------|-----------|-------|
| **SLAP** | Sound, Lights, And Power | Infrastructure: generators, PA systems, lighting |
| **BDSM** | Build, Demolition, Site Management | Physical construction and teardown of the event |
| **GG&P** | Gate, Greeters & Perimeter | Entry control, welcoming, and site perimeter |
| **DVS** | Department of Volunteer Servicing | Keeping setup/strike crews supplied with food and water |
| **LNT** | Leave No Trace | Ensuring environmental responsibility |

## Team Names

| Team | Department | What They Do |
|------|-----------|--------------|
| **Grumpy Katz** | GG&P | Gate crew who check tickets and manage entry/exit |
| **Nomads** | Malfare | Roaming mediators and hazard-awareness volunteers |
| **La Cantina** | Volunteers | Kitchen team feeding all on-shift volunteers |
| **Shit Ninjas** | Production | Maintain the compost toilets |
| **Ice Ice Baby** | Production | Ice sales during the event |
| **Welfare Enough** | Malfare | 24-hour safe and sober space |
| **Kunsthaus** | Creativity | Art workshop and maker space |
| **Toolhaus** | BDSM | Tool management and heavy machinery |
| **Demarcation** | City Planning | Site layout, GPS mapping, and placement |

## Signup Policies

| Term | Definition |
|------|------------|
| **Public** | Any volunteer can sign up for the shift; immediately confirmed. |
| **Require Approval** | The volunteer's application goes to "pending" and must be approved by a lead. Used for sensitive or specialized roles. |

## Signup Statuses

| Status | Meaning |
|--------|---------|
| **Pending** | Volunteer has applied; waiting for lead review. |
| **Confirmed** | Volunteer is assigned to the duty. |
| **Refused** | Lead denied the application. |

## Shift Properties

| Term | Definition |
|------|------------|
| **Skills** | Tags indicating what abilities are useful for a shift (e.g., "fire safety experience", "languages", "licensed to drive in Spain"). |
| **Quirks** | Tags indicating characteristics of a shift (e.g., "sober shift", "work in the shade", "intense work"). Volunteers can also indicate quirk preferences on their profile. |
| **Priority** | How critical a shift is: essential, important, or normal. Affects display ordering and urgency indicators. |
| **Needed** | Minimum number of volunteers required for a duty. |
| **Spaces / Wanted** | Maximum number of volunteers that can sign up. |

## Burn Culture Terms

| Term | Definition |
|------|------------|
| **Burn / Burn Event** | A participatory event following Burning Man principles: radical self-reliance, communal effort, decommodification, leave no trace. |
| **Playa Name** | A chosen name used at burn events instead of one's legal name. Also called a "burn name" or "FoD name." |
| **Barrio** | A neighborhood or camp at the event. Groups of participants who camp together and often contribute a shared offering. |
| **Leave No Trace** | The principle that the event site must be returned to its original condition after strike. No litter, no marks, no evidence. |
| **Participant** | Everyone at a burn event is a participant, not an attendee or spectator. The event is created collectively. |
| **Nobody** | A participant at FixMe specifically. A play on the event name. |

## Technical Terms

| Term | Definition |
|------|------------|
| **Fistbump** | External API for ticket verification and magic link authentication. |
| **Quicket** | Third-party ticketing platform (legacy integration). |
| **Magic Link** | A URL containing a verification hash that allows passwordless login or registration. |
| **Cron** | Scheduled background jobs that handle automated email notifications and data maintenance. |
| **Email Cache** | A queue of rendered emails waiting to be sent, allowing for rate limiting and optional manual review. |
