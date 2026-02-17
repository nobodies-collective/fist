# Organizational Structure

FIST models a hierarchical organization with three levels: Division, Department, and Team.

## Hierarchy

```
Division (NOrg)
├── Department: SLAP
│   ├── Team: Power
│   ├── Team: Sound
│   └── Team: Lights
├── Department: Volunteers
│   ├── Team: NoInfo
│   ├── Team: DVS (Dept of Volunteer Servicing)
│   └── Team: La Cantina
├── Department: BDSM
│   ├── Team: Build Crew
│   ├── Team: Strike Crew
│   ├── Team: Toolhaus
│   ├── Team: LNT (Leave No Trace)
│   └── Team: Designated Driver
├── Department: Participants Wellness
│   └── Team: Site Lead & Site Mgmt Crew
├── Department: Production
│   ├── Team: Event Production Office
│   ├── Team: Ice Ice Baby!
│   └── Team: Shit Ninjas
├── Department: City Planning
│   └── Team: Demarcation Team
├── Department: Creativity
│   ├── Team: Kunsthaus
│   ├── Team: Art Tours
│   ├── Team: Art Cars
│   ├── Team: Innovation
│   └── Team: Ohana House
├── Department: GG&P (Gate, Greeters & Perimeter)
│   ├── Team: Grumpy Katz Gate Krew
│   ├── Team: Perimeter Crew
│   └── Team: Greeters
└── Department: Malfare
    ├── Team: Fire Arena
    ├── Team: Interpreters
    ├── Team: Nomads
    ├── Team: Malfare Office
    └── Team: Welfare Enough
```

## Division

The top-level organizational container. In practice, there is one division called **NOrg** (short for Nowhere Organization). Divisions exist in the data model for flexibility but are not heavily used in the UI.

## Department

A department groups related teams under a shared leadership structure. Each department has:

- **Name and description**
- **Policy**: Controls visibility (typically `public`)
- **MetaLead position**: Each department has at least one metalead (department-level lead)
- **Parent**: Always belongs to a division

**Department examples and what they oversee:**

| Department | Scope |
|------------|-------|
| SLAP | Sound, Lights, And Power infrastructure |
| Volunteers | Volunteer coordination, food service, on-site info |
| BDSM | Build, Demolition, Site Management — physical construction and teardown |
| Production | Event logistics, supplies, sanitation |
| Malfare | Welfare, safety, emergency response, mediation |
| GG&P | Gate operations, greeting, perimeter security |
| Creativity | Art support, innovation, accessible spaces |
| City Planning | Site layout and demarcation |
| Participants Wellness | Site safety and maintenance during event |

## Team

A team is the operational unit where volunteers actually work. Each team has:

- **Name and description**: Shown to volunteers when browsing shifts
- **Parent department**: Determines which metalead oversees it
- **Skills**: Tags indicating what skills are useful (e.g., "fire safety experience", "languages", "licensed to drive in Spain")
- **Quirks**: Tags indicating shift characteristics (e.g., "sober shift", "work in the shade", "intense work")
- **Location**: Optional (e.g., "cantina" for food service)
- **Policy**: Access control for shifts under this team
- **Email**: Contact address for the team
- **Lead positions**: Each team has at least one lead role

## Team Characteristics

Teams vary significantly in their operational model:

**Setup/Strike teams** (Build Crew, Strike Crew, DVS, Toolhaus, LNT):
- Work full days with a siesta break
- Not shift-based during their primary period
- Use "projects" rather than "shifts" for scheduling

**Event-time shift teams** (NoInfo, Gate Krew, Nomads, Ice, etc.):
- Work in defined shift rotations (typically 4-6 hours)
- Use "rotas" to define recurring shift patterns

**Hybrid teams** (Power, LNT, La Cantina):
- Full days during setup/strike, shift-based during event time

**Small/specialized teams** (Art Cars, Innovation, Fire Arena):
- Small rosters, event-time only, shorter shifts

## How Structure Affects Permissions

The hierarchy creates a cascading permission model:

1. A **team lead** can manage shifts, approve signups, and voluntell users for their team
2. A **metalead** has lead-level access across all teams in their department
3. A **manager** has access to everything across the entire organization

Role inheritance uses Meteor's `alanning:roles` package with scoped roles. When a department or team is created, a corresponding role is created and added to the parent's role hierarchy.

## Creating and Modifying Structure

- **Managers** can create new departments (from the manager dashboard)
- **Metaleads** can create new teams within their department
- **Leads** can edit their own team's settings (name, description, skills, quirks)
- The full structure can be exported as JSON and re-imported for the next year's event (see [Event Lifecycle](event-lifecycle.md))
