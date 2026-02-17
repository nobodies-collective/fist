# User Roles and Permissions

FIST has a layered permission model tied to the organizational hierarchy. Permissions cascade upward: a department lead inherits visibility over all teams in their department.

## Role Hierarchy

```
Admin
  └── Manager
        └── MetaLead (department level)
              └── Lead (team level)
                    └── NoInfo (special team with cross-team visibility)
                          └── Volunteer (base role)
```

## Volunteer

Every registered user is a volunteer. This is the base role.

**Can do:**
- Register an account (email/password or magic link)
- Fill out the volunteer form (profile, skills, dietary needs, emergency contact)
- Browse available shifts, projects, and lead positions
- Sign up for open shifts (immediately confirmed for public shifts)
- Apply for approval-required shifts and lead positions
- View their own dashboard with booked shifts and available openings
- Edit their profile and form data
- Set a profile picture
- Choose preferred language (English, French, Spanish)

**Dashboard shows:**
- Welcome message with profile picture
- List of responsibilities (lead roles, if any)
- "Your Shifts" table of confirmed and pending signups
- "Shifts Need Help" list of open shifts they can sign up for, filterable by type

## Lead

A lead manages a single team. Lead status is granted by signing up for (and being confirmed in) a lead position on a team.

**Has all volunteer permissions, plus:**
- View their team's lead dashboard (`/lead/team/:teamId`)
- See team staffing stats (shifts confirmed vs. needed, volunteer count, pending requests)
- Edit team settings (name, description, skills, quirks, policies)
- Create and manage shift rotas (groups of recurring shifts)
- Create and manage projects (multi-day commitments)
- Review and approve/deny pending signup requests
- "Voluntell" (enroll) specific users into shifts
- Search and browse the full volunteer list (with completed profiles)
- Filter volunteers by skill, quirk, or priority
- Export team rota data as CSV
- Request user contact information (with audit logging and reason required)

## MetaLead

A metalead manages a department (a group of teams). Metalead status comes from being confirmed as a lead at the department level.

**Has all lead permissions across their department, plus:**
- View the department dashboard (`/metalead/department/:deptId`)
- See aggregated stats: metalead/lead fill rates, shift coverage, volunteer count
- Edit department settings
- Create new teams within the department
- Review lead applications across all teams in the department
- View build and strike staffing reports for the department
- Export department rota and early entry data as CSV
- Manage early entry allocations for the department

## NoInfo

NoInfo is a special team within the Volunteers department. Members act as on-site shift coordinators during the event. NoInfo status is determined by being a lead of the "NoInfo" team (or being a manager).

**Has volunteer permissions, plus:**
- Access the NoInfo dashboard (`/noinfo`) showing unfilled shifts for event time and strike
- "Voluntell" volunteers into shifts in real time (enrolling them directly)
- View the NoInfo user list with aggregate statistics
- View any volunteer's full profile, form data, responsibilities, and booked shifts
- Access user statistics (registered users, profiles filled, ticket holders, duty coverage, online users)
- Filter shifts by event period or strike period
- See which shifts are urgent and need immediate coverage

## Manager

Managers have system-wide administrative access.

**Has all permissions above, plus:**
- Access the manager dashboard (`/manager`) with global staffing overview
- View and edit event settings (dates, periods, enrollment timing, cron configuration)
- View and manage the full user list with role information
- Promote/demote users to manager or admin roles
- Create and manage departments
- Manage email templates (enrollment, verification, notifications)
- Approve or manage cached emails before sending
- Export all rotas, cantina setup data, and early entry lists as CSV
- Send mass shift reminder emails to all volunteers with signups
- Import/export the full rota structure as JSON (for year-to-year migration)
- Trigger event migration to a new year (copies structure, adjusts dates, preserves leads)
- Ban users
- Change user passwords

## Admin

Admin is the highest privilege level.

**Has all manager permissions, plus:**
- Grant and revoke admin status for other users
- Full system access

## Permission Checks

The system enforces permissions through:
- **Route guards**: The `RequireAuth` component checks login, email verification, FIST open date, form completion, and role-specific access before rendering protected pages
- **Method mixins**: Server methods use auth mixins (`isManager`, `isLead`, `isSameUserOrManager`, `isNoInfo`, `isAnyLead`) to validate permissions before executing
- **Hierarchical roles**: The `alanning:roles` package manages role scopes. A lead role on a team ID also grants access to parent department views where applicable.
