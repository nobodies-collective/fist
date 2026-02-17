# Lead Guide

This guide covers the day-to-day operations for team leads, department metaleads, and NoInfo coordinators.

## Team Lead

### Accessing Your Dashboard

Navigate to `/lead/team/:teamId` (or click your team name under "Responsibilities" on the volunteer dashboard).

### Dashboard Layout

**Sidebar:**
- Team name (with link to public view)
- List of current leads
- Stats: shifts confirmed/needed, volunteer count, pending requests
- Action buttons: Team Settings, Add Shift Rota, Add Project, Rota Export

**Main area (splits into two panels if there are pending requests):**
- **Pending requests** (right panel): Applications waiting for your review
- **Duty summary** (left/full panel): Tabbed view of all your team's shifts and projects

### Setting Up Your Team

1. **Edit team settings**: Click the wrench icon to update your team's name, description, skills, quirks, and policies
2. **Create rotas**: Click "Add Shift Rota" to create a time range for a group of shifts. Within each rota, individual shifts are created
3. **Create projects**: Click "Add Project" for multi-day commitments (typically setup/strike work)

### Managing Shifts

Each rota tab shows its shifts with:
- Date and time
- Signup slots: how many are filled vs. needed
- Individual volunteer signups with status

### Reviewing Applications

When a volunteer applies for a shift or lead position that requires approval:

1. The application appears in the "Pending Requests" panel
2. Review the volunteer's profile and skills
3. **Approve**: Confirms the signup; volunteer is notified
4. **Deny**: Refuses the application; volunteer is notified

### Enrolling Volunteers ("Voluntelling")

To directly assign a volunteer to a shift:

1. From the shift detail, open the enrollment interface
2. Search for volunteers by name, email, or skill
3. Click "Voluntell" (labeled as "Enroll" in some views)
4. The volunteer is immediately confirmed and will receive a notification email

**When to voluntell:**
- Filling urgent gaps during the event
- Assigning known volunteers who've agreed verbally
- Pre-assigning experienced volunteers to critical shifts

### Searching for Volunteers

The volunteer search (available to all leads) supports:
- **Name or email**: Free text search
- **By skill**: Filter volunteers who have specific skills
- **By quirk**: Filter by preferred shift characteristics
- **By priority**: Filter by urgency of unfilled positions
- **Include incomplete profiles**: Toggle to see users who haven't finished their form

### Exporting Data

Click "Rota Export" to download a CSV of all confirmed signups for your team, including:
- Shift name, start/end times
- Volunteer name, email, ticket number, full name

### Requesting Contact Info

To get a volunteer's email address:
1. Use the contact request feature
2. Provide a reason (minimum 10 characters)
3. The request is logged for audit purposes
4. The volunteer's primary email is returned

## Department MetaLead

### Accessing Your Dashboard

Navigate to `/metalead/department/:deptId` (or click your department name under "Responsibilities").

### Dashboard Layout

**Sidebar:**
- Department name (with link to public view)
- Department leads
- Stats: teams count, metalead/lead/shift fill rates, volunteer count, pending requests
- Action buttons: Settings, Add Team, Early Entry management, Rota Export, Early Entry Export

**Main area:**
- **Staffing Report**: Build and Strike coverage chart for all teams in the department
- **Lead Requests**: Pending applications for lead positions (if any)
- **Team List**: All teams with their leads, shift coverage, and quick access to team dashboards

### Department-Level Actions

As a metalead, you can:

1. **Create teams**: Add new teams to your department
2. **Edit department settings**: Update name, description, etc.
3. **Review lead applications**: Approve or deny lead candidates across all your teams
4. **View team dashboards**: Click through to any team's lead dashboard
5. **Manage early entry**: Allocate early entry passes for your department
6. **Export data**: Department-wide rota CSV and early entry CSV

### Monitoring Staffing

The Build and Strike staffing report shows daily coverage across your department's teams. Use this to identify:
- Teams that are understaffed for setup
- Days with particularly low coverage
- Whether lead positions are filled

## NoInfo Coordinator

NoInfo is a special team within the Volunteers department. Its members serve as on-site shift coordinators, matching available volunteers to unfilled shifts in real time.

### Accessing NoInfo

Navigate to `/noinfo` for event-time shifts or `/noinfo/strike` for strike shifts.

### NoInfo Dashboard

**Sidebar:**
- "NoInfo" header
- Toggle between event shifts and strike shifts

**Main area:**
- List of shifts and projects that need volunteers, sorted by urgency
- Each duty shows: team name, shift details, open slots
- "Voluntell" button on each shift to enroll a volunteer

### NoInfo Workflow (During Event)

1. **Check the dashboard** regularly to see which shifts need coverage
2. **Identify urgent shifts**: Shifts starting soon with unfilled spots
3. **Find volunteers**: Either from people visiting the NoInfo tent or by searching the user list
4. **Voluntell**: Enroll the volunteer into the shift directly
5. **The volunteer receives a notification** and the shift appears on their dashboard

### NoInfo User List (`/noinfo/userList`)

A comprehensive view of all registered volunteers with:

**Statistics panel:**
- Total registered users
- Users with completed profiles and pictures
- Ticket holders
- Users with duties, leads, event-time roles
- Users with 3+ event-time duties
- Currently online users

**User list:**
- Searchable by name, email, ticket number
- Click any user to view their full profile:
  - Profile picture
  - Contact information
  - Volunteer form data (skills, dietary info, etc.)
  - Current responsibilities (lead roles)
  - All booked shifts

### Tips for NoInfo Coordinators

- **Sort by urgency**: The dashboard prioritizes shifts that are starting soon and have low coverage
- **Check skills**: Before voluntelling someone into a specialized shift (e.g., fire safety, driving), verify they have the required skills
- **Event vs. Strike**: Use the toggle to switch between event-time and strike views. Strike coordination is critical as fewer volunteers remain after the event
- **Use the user list**: When someone walks up to the NoInfo tent wanting to help, search for them and browse available shifts together

## Common Workflows

### Before the Event

1. **Leads**: Set up team descriptions, create rotas and shifts, define skill/quirk requirements
2. **Metaleads**: Review department structure, ensure lead positions are filled, create any new teams needed
3. **All**: Monitor the staffing report as volunteers sign up; identify gaps early

### During the Event

1. **Leads**: Monitor pending requests, approve/deny quickly. Watch for shifts that need coverage.
2. **Metaleads**: Keep an eye on cross-team staffing. Help leads who are struggling to fill shifts.
3. **NoInfo**: The primary real-time coordination role. Match walk-up volunteers to urgent shifts.

### After the Event (Strike)

1. **Leads** of strike teams: Manage project signups for teardown
2. **NoInfo**: Switch to strike view, help coordinate remaining volunteers
3. **Managers**: Eventually trigger year rollover (see [Event Lifecycle](event-lifecycle.md))
