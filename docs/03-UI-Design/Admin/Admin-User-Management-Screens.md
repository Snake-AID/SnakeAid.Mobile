# ADMIN USER MANAGEMENT SCREENS - SNAKEAID PLATFORM

## Document Information
- **Module:** Admin Web Application
- **Feature Category:** User & Permission Management
- **Total Screens:** 5 screens
- **Related Features:** FE-01 to FE-04 (User management, permissions, account status, activity history)
- **Platform:** Web Application (Desktop)
- **Color Scheme:** Blue Primary `#007BFF`, Dark Navy `#1E3A8A`

---

## Flow Context

### User Management Purpose

**Primary Goals:**
- Manage all user accounts across 4 roles: Patient, Rescuer, Expert, Admin
- Assign and modify role-based permissions
- Monitor user activity and behavior
- Handle account status (activate, lock, delete)
- Create new accounts for rescuers, experts, and admins
- View comprehensive user statistics and history

**User Roles:**
1. **Patient:** End users seeking snakebite help (self-registration via app)
2. **Rescuer:** Snake rescue teams (admin-created or verified)
3. **Expert:** Snake specialists for consultations (admin-created or verified)
4. **Admin:** System administrators (super admin, content admin, support admin)

**Key Features (Reference: Major-Features-Summary.md):**
- FE-01: Create accounts for patients, experts, and rescue teams
- FE-02: Assign access permissions by role
- FE-03: Manage account status (activate, lock, delete)
- FE-04: View user activity history

---

## Design System

### Color Palette
```
Primary Blue:       #007BFF
Dark Navy:          #1E3A8A
Success Green:      #28A745  (Active accounts)
Warning Amber:      #FFC107  (Pending verification)
Danger Red:         #DC3545  (Locked accounts)
Info Cyan:          #17A2B8
Light Gray:         #F8F9FA
Medium Gray:        #6C757D
White:              #FFFFFF
```

### Role Colors
```
Patient:    Green #228B22
Rescuer:    Orange #FF8A00
Expert:     Purple #6B46C1
Admin:      Blue #007BFF
```

---

## Screen Designs

### Screen 1: User List (Main Table View)

**Screen Purpose:**  
Comprehensive table displaying all users with advanced filtering, search, and bulk actions.

**Navigation:**
- Entry: Click "User Management" from sidebar
- Exit: Click user row → Screen 2 (User Detail), Back to Dashboard

**Key Components:**

1. **Page Header:**
   - Title: "User Management"
   - Total count: "1,234 users"
   - Action buttons: "+ Create User" (blue), "Import CSV", "Export"

2. **Filter Bar:**
   - Search: "Search by name, email, phone..."
   - Role dropdown: "All Roles" | Patient | Rescuer | Expert | Admin
   - Status dropdown: "All Status" | Active | Pending | Locked | Deleted
   - Date range: "Joined: Last 30 days"
   - Location filter: "All Locations"
   - Clear filters button

3. **User Table:**
   - Columns: [Checkbox] | Avatar | Name | Email | Phone | Role | Status | Joined Date | Last Active | Actions
   - Sortable columns (click header)
   - 20 rows per page with pagination
   - Row hover effect (light blue background)

4. **Table Rows (Examples):**

   **Row 1:**
   - ☐ Checkbox
   - Avatar: Photo
   - Name: "Nguyễn Văn A"
   - Email: "nguyenvana@email.com"
   - Phone: "090 123 4567"
   - Role: "Patient" (green badge)
   - Status: "Active" (green dot)
   - Joined: "10/11/2025"
   - Last Active: "2 hours ago"
   - Actions: [👁️ View] [✏️ Edit] [•••]

   **Row 2:**
   - ☐ Checkbox
   - Avatar: Photo
   - Name: "Đội Cứu Hộ SG"
   - Email: "doicuuho@email.com"
   - Phone: "091 234 5678"
   - Role: "Rescuer" (orange badge)
   - Status: "Active" (green dot)
   - Joined: "05/10/2025"
   - Last Active: "10 min ago"
   - Actions: [👁️] [✏️] [•••]

   **Row 3:**
   - ☐ Checkbox
   - Avatar: Photo
   - Name: "Dr. Chuyên Gia"
   - Email: "expert@email.com"
   - Phone: "092 345 6789"
   - Role: "Expert" (purple badge)
   - Status: "Pending" (amber dot)
   - Joined: "11/12/2025"
   - Last Active: "Never"
   - Actions: [👁️] [✏️] [•••]

5. **Bulk Actions (when rows selected):**
   - Top banner: "3 users selected"
   - Actions: "Activate", "Lock", "Delete", "Export Selected"
   - Cancel selection button

6. **Pagination:**
   - Bottom: "Showing 1-20 of 1,234"
   - Page numbers: ‹ 1 2 3 ... 62 ›
   - Rows per page: 10 | 20 | 50 | 100

**Stitch Prompt (English):**

```
User management table screen for admin portal.

PAGE HEADER (white background):
- Left: "User Management" (28pt bold) + "1,234 users" (14pt gray)
- Right: Three buttons:
  * "+ Create User" (blue #007BFF, filled, 44px height)
  * "Import CSV" (outlined blue)
  * "Export" (outlined blue)

FILTER BAR (light gray background, padding 16px):
- Search input (300px): "Search by name, email, phone..." + magnifying glass icon
- "Role:" dropdown (150px) showing "All Roles"
- "Status:" dropdown (150px) showing "All Status"
- "Joined:" date range picker (200px) showing "Last 30 days"
- "Location:" dropdown (150px) showing "All Locations"
- "Clear Filters" link (blue text)

USER TABLE (white card, rounded, shadow):
- HEADER ROW (light gray background):
  * Checkbox (select all)
  * "Avatar"
  * "Name" ↕️ (sortable)
  * "Email"
  * "Phone"
  * "Role" ↕️
  * "Status" ↕️
  * "Joined Date" ↕️
  * "Last Active" ↕️
  * "Actions"

DATA ROWS (3 examples):

ROW 1:
- ☐ Checkbox (unchecked)
- Avatar: 40px circle photo
- "Nguyễn Văn A" (16pt bold)
- "nguyenvana@email.com" (14pt gray)
- "090 123 4567"
- "Patient" (green badge #228B22)
- Green dot + "Active"
- "10/11/2025"
- "2 hours ago"
- Icon buttons: 👁️ View | ✏️ Edit | ••• More

ROW 2:
- ☐ Checkbox
- Avatar: 40px circle
- "Đội Cứu Hộ SG"
- "doicuuho@email.com"
- "091 234 5678"
- "Rescuer" (orange badge #FF8A00)
- Green dot + "Active"
- "05/10/2025"
- "10 min ago"
- Icons: 👁️ | ✏️ | •••

ROW 3:
- ☐ Checkbox
- Avatar: 40px circle
- "Dr. Chuyên Gia"
- "expert@email.com"
- "092 345 6789"
- "Expert" (purple badge #6B46C1)
- Amber dot + "Pending"
- "11/12/2025"
- "Never"
- Icons: 👁️ | ✏️ | •••

BULK ACTIONS BAR (appears when checkboxes selected, blue background):
- "3 users selected" (white text)
- Buttons: "Activate" | "Lock" | "Delete" | "Export Selected"
- "Cancel" link (white)

PAGINATION (bottom, centered):
- "Showing 1-20 of 1,234" (left)
- Page controls: ‹ 1 [2] 3 ... 62 › (center)
- "Rows per page: 20" dropdown (right)

DESIGN: Professional data table, clear role badges, status indicators, sortable columns, bulk actions, responsive pagination.
```

---

### Screen 2: User Detail View (Profile Overview)

**Screen Purpose:**  
Comprehensive view of individual user with all details, statistics, and quick actions.

**Navigation:**
- Entry: Click "View" from Screen 1 table row
- Exit: Back to User List, Edit button → Screen 3

**Key Components:**

1. **Breadcrumb:**
   - "User Management > User Detail > Nguyễn Văn A"

2. **User Header Card:**
   - Large avatar (120px)
   - Name: "Nguyễn Văn A" (32pt bold)
   - Role badge: "Patient" (green, large)
   - Status: "Active" (green dot + text)
   - Member since: "10/11/2025"
   - Action buttons: "Edit Profile", "Lock Account", "View Activity Log"

3. **Quick Stats (4 Cards):**

   **For Patient:**
   - "Incidents Reported: 3"
   - "Rescues Requested: 2"
   - "Consultations: 5"
   - "Total Spent: 2.5M VNĐ"

   **For Rescuer:**
   - "Rescues Completed: 47"
   - "Success Rate: 95%"
   - "Avg Response: 12 min"
   - "Total Earned: 15.2M VNĐ"

   **For Expert:**
   - "Consultations: 156"
   - "Rating: 4.8/5 ⭐"
   - "AI Verifications: 89"
   - "Total Earned: 24.5M VNĐ"

4. **Contact Information Tab:**
   - Email: "nguyenvana@email.com" (verified ✓)
   - Phone: "090 123 4567" (verified ✓)
   - Address: "123 Nguyễn Huệ, Q.1, TP.HCM"
   - Emergency Contact: "095 555 5555"

5. **Account Details Tab:**
   - User ID: "#USER-2025-001234"
   - Created: "10/11/2025 14:30"
   - Last Login: "12/12/2025 09:15"
   - IP Address: "113.161.xxx.xxx"
   - Device: "iPhone 14 Pro - iOS 17.2"
   - Login Method: "Phone + OTP"

6. **Activity Summary (Last 30 Days):**
   - Line chart showing daily activity
   - Metrics: Logins, Actions, Transactions

7. **Recent Activities (List - Last 10):**
   - "Reported snakebite case #INC-047" - 2 hours ago
   - "Completed payment 675K VNĐ" - 3 hours ago
   - "Logged in from Mobile App" - 5 hours ago
   - "Updated profile photo" - 1 day ago
   - "Requested rescue service" - 2 days ago

8. **Permissions & Roles (For non-patients):**
   - Current Role: "Rescuer"
   - Permissions: List of enabled features
   - Special Access: None

9. **Notes & Flags:**
   - Admin notes (internal): Text area for admin comments
   - Flags: "Verified Rescuer" ✓, "Background Check Complete" ✓

10. **Danger Zone:**
    - Red bordered box
    - "Lock Account" button (amber)
    - "Delete Account" button (red)
    - Warning text

**Stitch Prompt (English):**

```
User detail profile screen for admin view.

BREADCRUMB (top):
- "User Management > User Detail > Nguyễn Văn A" (14pt gray, links blue)

USER HEADER CARD (white, rounded, shadow, padding 24px):
- Avatar: 120px circle photo (left)
- Right side:
  * "Nguyễn Văn A" (32pt bold dark)
  * "Patient" badge (green #228B22, 18pt, rounded)
  * Green dot + "Active" (16pt)
  * "Member since 10/11/2025" (14pt gray)
- Far right:
  * "Edit Profile" button (blue filled)
  * "Lock Account" button (amber outlined)
  * "View Activity Log" link (blue)

QUICK STATS GRID (4 cards, equal width):

CARD 1 (Patient stats):
- Icon: Emergency symbol
- "Incidents Reported" (14pt gray)
- "3" (36pt bold blue)

CARD 2:
- Icon: Ambulance
- "Rescues Requested"
- "2" (36pt bold)

CARD 3:
- Icon: Video
- "Consultations"
- "5" (36pt bold)

CARD 4:
- Icon: Money
- "Total Spent"
- "2.5M VNĐ" (36pt bold green)

TABS (horizontal):
- "Contact Information" (ACTIVE, blue underline)
- "Account Details"
- "Activity Summary"
- "Permissions & Roles"
- "Notes & Flags"

CONTACT INFO TAB CONTENT (white card):
- Row: "Email" label | "nguyenvana@email.com" | Green checkmark "Verified"
- Row: "Phone" label | "090 123 4567" | Green checkmark "Verified"
- Row: "Address" label | "123 Nguyễn Huệ, Q.1, TP.HCM"
- Row: "Emergency Contact" label | "095 555 5555"

ACCOUNT DETAILS (gray background, key-value pairs):
- "User ID: #USER-2025-001234"
- "Created: 10/11/2025 14:30"
- "Last Login: 12/12/2025 09:15"
- "IP Address: 113.161.xxx.xxx"
- "Device: iPhone 14 Pro - iOS 17.2"
- "Login Method: Phone + OTP"

ACTIVITY SUMMARY:
- Line chart (300px height) showing activity over 30 days
- X-axis: dates
- Y-axis: action count
- Three lines: Logins (blue), Actions (green), Transactions (purple)

RECENT ACTIVITIES LIST (scrollable, max 10 items):
- Item 1: Dot icon | "Reported snakebite case #INC-047" | "2 hours ago"
- Item 2: Dot icon | "Completed payment 675K VNĐ" | "3 hours ago"
- Item 3: Dot icon | "Logged in from Mobile App" | "5 hours ago"
- "View All Activities →" link (bottom)

DANGER ZONE (red border, light red background):
- "⚠️ Danger Zone" header (red text, bold)
- "Lock Account" button (amber, 44px)
- "Delete Account" button (red, 44px)
- "These actions cannot be undone" (12pt gray)

DESIGN: Comprehensive profile view, clear stats visualization, tabbed navigation, activity tracking, admin controls.
```

---

### Screen 3: Create/Edit User Form

**Screen Purpose:**  
Form for creating new users (Rescuer, Expert, Admin) or editing existing user information.

**Navigation:**
- Entry: Click "+ Create User" from Screen 1, or "Edit" from Screen 2
- Exit: Cancel → Screen 1, Save → Screen 2 (user detail)

**Key Components:**

1. **Form Header:**
   - Title: "Create New User" or "Edit User: Nguyễn Văn A"
   - Step indicator: "Step 1 of 3: Basic Information"

2. **Basic Information Section:**
   - Full Name* (required)
   - Email* (with validation)
   - Phone Number* (with format mask)
   - Avatar Upload (drag & drop or browse)
   - Date of Birth
   - Gender (Male/Female/Other)

3. **Role Selection* (Required):**
   - Radio buttons: Patient | Rescuer | Expert | Admin
   - Description for each role shown when selected

4. **Role-Specific Fields:**

   **If Rescuer selected:**
   - Team Name*
   - License Number
   - Service Area (multiple provinces)
   - Years of Experience
   - Equipment List (checkboxes)
   - Background Check Upload

   **If Expert selected:**
   - Professional Title (Dr., Prof., etc.)
   - Specialization* (dropdown)
   - License/Certificate Number*
   - Institution/University
   - Years of Experience*
   - Consultation Fee (VNĐ)
   - Availability Schedule

   **If Admin selected:**
   - Admin Level* (Super Admin | Content Admin | Support Admin)
   - Department
   - Access Level (Full | Limited)

5. **Contact & Location:**
   - Address Line 1*
   - Address Line 2
   - City/Province* (dropdown)
   - District (dropdown)
   - Emergency Contact Name
   - Emergency Contact Phone

6. **Account Settings:**
   - Initial Password (auto-generated, can edit)
   - Require Password Change on First Login (checkbox, default ON)
   - Account Status: Active | Pending | Locked
   - Send Welcome Email (checkbox)

7. **Permissions (for Rescuer/Expert/Admin):**
   - Checkbox list of module access
   - Custom permission toggles

8. **Notes:**
   - Admin Notes (internal only)
   - Public Notes (visible to user)

9. **Action Buttons:**
   - "Cancel" (gray, outlined)
   - "Save as Draft" (blue, outlined)
   - "Create User" or "Save Changes" (blue, filled)

**Stitch Prompt (English):**

```
Create/edit user form for admin portal.

FORM HEADER:
- "Create New User" (28pt bold) or "Edit User: [Name]"
- Step indicator: "Step 1 of 3: Basic Information" (14pt gray)

FORM LAYOUT (white card, two-column where appropriate):

BASIC INFO SECTION:
- "Basic Information" header (20pt bold) + required asterisk note

LEFT COLUMN:
- "Full Name *" label + text input (full width)
- "Email *" label + email input + validation icon
- "Phone Number *" label + input with format "(090) 123-4567"

RIGHT COLUMN:
- "Avatar Upload" label
- Drag & drop box (200x200px, dashed border, gray)
  "Drop image here or Browse" + upload icon
  "Max 5MB, JPG/PNG"
- "Date of Birth" date picker
- "Gender" radio buttons: ○ Male  ○ Female  ○ Other

ROLE SELECTION SECTION:
- "Select Role *" header (20pt bold)
- Four large radio cards (horizontal):

  CARD 1: ○ Patient
  - Icon: Person (green)
  - "End user seeking help"
  
  CARD 2: ○ Rescuer (SELECTED example)
  - Icon: Ambulance (orange)
  - "Snake rescue team"
  - Checkmark showing selected
  
  CARD 3: ○ Expert
  - Icon: Doctor (purple)
  - "Snake specialist"
  
  CARD 4: ○ Admin
  - Icon: Shield (blue)
  - "System administrator"

ROLE-SPECIFIC FIELDS (appears when Rescuer selected):
- "Rescuer Information" header (18pt bold)
- "Team Name *" input
- "License Number" input
- "Service Area *" multi-select chips:
  "Hồ Chí Minh ×" "Đồng Nai ×" "+ Add Province"
- "Years of Experience" number input
- "Equipment" checkboxes:
  ☑ Snake hook
  ☑ Protective gloves
  ☑ Snake bag
  ☐ First aid kit
- "Background Check" file upload button

CONTACT & LOCATION:
- "Contact & Location" header
- "Address Line 1 *" input (full width)
- "Address Line 2" input (full width)
- Two columns:
  * "City/Province *" dropdown
  * "District" dropdown
- Two columns:
  * "Emergency Contact Name" input
  * "Emergency Contact Phone" input

ACCOUNT SETTINGS:
- "Account Settings" header
- "Initial Password" input + "Generate" button + eye icon
- ☑ "Require password change on first login" checkbox (checked)
- "Account Status" radio buttons:
  ● Active  ○ Pending  ○ Locked
- ☑ "Send welcome email" checkbox

PERMISSIONS (collapsible section):
- "Permissions & Access" header + expand/collapse arrow
- Checkbox tree:
  ☑ Rescue Operations
    ☑ Accept requests
    ☑ Update status
    ☐ View all rescues
  ☑ Expert Consultation
    ☑ Request help
    ☐ Direct contact

NOTES:
- "Admin Notes" text area (internal, gray background)
- "Public Notes" text area (visible to user)

ACTION BUTTONS (bottom, right-aligned):
- "Cancel" button (gray outlined, 44px)
- "Save as Draft" button (blue outlined, 44px)
- "Create User" button (blue filled, 48px height, bold)

DESIGN: Multi-step form, role-based conditional fields, clear required indicators, validation feedback, professional layout.
```

---

### Screen 4: Role & Permission Management

**Screen Purpose:**  
Configure role-based permissions and create custom permission sets.

**Navigation:**
- Entry: Click "Permissions" from Settings menu
- Exit: Save → Back to previous screen

**Key Components:**

1. **Page Header:**
   - Title: "Role & Permission Management"
   - "Create Custom Role" button

2. **Role Tabs:**
   - Patient (green) | Rescuer (orange) | Expert (purple) | Admin (blue)
   - Active tab highlighted

3. **Permission Matrix (for selected role):**

   **Module Categories (Left Column):**
   - 📱 Mobile App Features
   - 🚨 Emergency Functions
   - 🗺️ Map & Navigation
   - 💬 Communication
   - 💰 Payment & Financial
   - 📊 Reports & Analytics
   - ⚙️ System Settings

   **Permission Columns:**
   - View (eye icon)
   - Create (plus icon)
   - Edit (pencil icon)
   - Delete (trash icon)

   **Example Rows:**
   
   **Emergency Functions:**
   - Report Snakebite: ✓ ✓ ✓ ✗
   - Call SOS: ✓ ✓ ✗ ✗
   - View Guidelines: ✓ ✗ ✗ ✗

   **Rescue Operations:**
   - Accept Requests: ✓ ✓ ✗ ✗
   - Update Status: ✓ ✗ ✓ ✗
   - Complete Rescue: ✓ ✓ ✗ ✗

4. **Quick Permission Templates:**
   - "Apply Template" dropdown
   - Templates: "Full Access", "Read Only", "Standard User", "Custom"

5. **User Count Badge:**
   - "45 Rescuers with this role"
   - Link: "View Users"

6. **Special Permissions Toggle:**
   - Admin-only features
   - Dangerous actions (require confirmation)

**Stitch Prompt (English):**

```
Role and permission management screen.

PAGE HEADER:
- "Role & Permission Management" (28pt bold)
- Right: "Create Custom Role" button (blue outlined)

ROLE TABS (horizontal):
- "Patient" tab (green indicator)
- "Rescuer" tab (orange indicator, ACTIVE)
- "Expert" tab (purple indicator)
- "Admin" tab (blue indicator)

PERMISSION MATRIX TABLE (white card):
- Header row:
  * "Module / Feature" (left, bold)
  * "View 👁️" (60px width)
  * "Create +" (60px)
  * "Edit ✏️" (60px)
  * "Delete 🗑️" (60px)

SECTION 1: "📱 Mobile App Features" (expandable header, bold):

ROW 1:
- "Report Snakebite" (left)
- ✓ checkbox (checked, green)
- ✓ checkbox (checked)
- ✓ checkbox (checked)
- ✗ checkbox (disabled, gray)

ROW 2:
- "Call SOS Emergency"
- ✓ checked
- ✓ checked
- ✗ disabled
- ✗ disabled

SECTION 2: "🚨 Emergency Functions":

ROW 3:
- "Accept Rescue Requests"
- ✓ checked
- ✓ checked
- ✗ disabled
- ✗ disabled

ROW 4:
- "Update Rescue Status"
- ✓ checked
- ✗ disabled
- ✓ checked
- ✗ disabled

SECTION 3: "💬 Communication":

ROW 5:
- "Chat with Expert"
- ✓ checked
- ✓ checked
- ✓ checked
- ✗ disabled

ROW 6:
- "Video Call"
- ✓ checked
- ✗ disabled
- ✗ disabled
- ✗ disabled

RIGHT SIDEBAR (info panel):
- "Quick Actions" header
- "Apply Template" dropdown button
  Options: "Full Access", "Read Only", "Standard User"
- "45 Rescuers with this role" badge (orange)
  "View Users →" link

- "Special Permissions" header (red icon)
- ☐ "Access User Data" checkbox (unchecked)
- ☐ "Modify System Settings" (unchecked)
- ☐ "Delete Any Content" (unchecked, red text)

BOTTOM ACTIONS:
- "Reset to Default" button (gray outlined, left)
- "Cancel" button (gray outlined, right)
- "Save Changes" button (blue filled, right)

DESIGN: Comprehensive permission matrix, role-based access control, clear visual indicators, template system, bulk actions.
```

---

### Screen 5: User Activity History Log

**Screen Purpose:**  
Detailed activity log for individual user or system-wide activity monitoring.

**Navigation:**
- Entry: Click "View Activity Log" from Screen 2
- Exit: Back to User Detail or User List

**Key Components:**

1. **Filter Bar:**
   - User selector: "Showing: Nguyễn Văn A" (can change to "All Users")
   - Activity type: "All Activities" | Login | CRUD | Payment | Communication
   - Date range: Last 7 days | 30 days | Custom
   - Search: "Search in activities..."

2. **Timeline View:**
   - Vertical timeline with date separators
   - Activity cards chronologically ordered

3. **Activity Cards (Examples):**

   **Today - 12/12/2025:**

   **Entry 1 (2 hours ago):**
   - Icon: Red emergency symbol
   - Time: "10:15 AM"
   - Action: "Reported Snakebite Case"
   - Details: "#INC-047 - Rắn Hổ Mang"
   - Location: "Quận 1, TP.HCM"
   - Device: "iPhone 14 Pro"
   - IP: "113.161.xxx.xxx"
   - Expand button for full details

   **Entry 2 (3 hours ago):**
   - Icon: Green payment
   - Time: "09:30 AM"
   - Action: "Completed Payment"
   - Details: "675,000 VNĐ - Expert Consultation"
   - Transaction ID: "#TXN-2025-12345"
   - Status: "Success" (green badge)

   **Entry 3 (5 hours ago):**
   - Icon: Blue login
   - Time: "07:15 AM"
   - Action: "Logged In"
   - Details: "Mobile App - iOS"
   - Method: "Phone + OTP"
   - Location: "TP. Hồ Chí Minh"

   **Yesterday - 11/12/2025:**

   **Entry 4:**
   - Icon: Purple video
   - Time: "02:30 PM"
   - Action: "Started Expert Consultation"
   - Details: "Video call with Dr. Chuyên Gia"
   - Duration: "47 minutes"
   - Rating: "5 ⭐"

4. **Activity Details Panel (when expanded):**
   - Full timestamp
   - Request/Response data (JSON view for technical)
   - Before/After states (for edits)
   - Error logs (if any)
   - Related activities (linked events)

5. **Export Options:**
   - "Export Log" button
   - Formats: CSV, JSON, PDF report
   - Date range for export

6. **Statistics Summary (Top):**
   - Total activities: 156
   - Logins: 45
   - Actions: 89
   - Transactions: 22

**Stitch Prompt (English):**

```
User activity history timeline screen.

STATISTICS BAR (top, light blue background):
- Four stat cards (horizontal):
  * "Total Activities: 156" (bold 24pt)
  * "Logins: 45"
  * "Actions: 89"
  * "Transactions: 22"

FILTER BAR (white background, padding):
- "Showing:" label + "Nguyễn Văn A" dropdown (can change to "All Users")
- "Activity Type:" dropdown showing "All Activities"
- "Date Range:" picker showing "Last 7 days"
- Search input: "Search in activities..." + magnifying glass
- "Export Log" button (blue outlined, right)

TIMELINE VIEW (white card, scrollable):

DATE HEADER: "Today - 12/12/2025" (sticky, 16pt bold, gray background)

ACTIVITY CARD 1 (white card with left blue border):
- Left: Red emergency icon (48px)
- Time badge: "10:15 AM" (gray chip)
- Action: "Reported Snakebite Case" (18pt bold)
- Details section:
  * "#INC-047 - Rắn Hổ Mang" (14pt)
  * "Location: Quận 1, TP.HCM" + map icon
  * "Device: iPhone 14 Pro" (12pt gray)
  * "IP: 113.161.xxx.xxx" (12pt gray monospace)
- Right: "Expand ∨" button

ACTIVITY CARD 2 (left green border):
- Left: Green payment icon
- "09:30 AM" badge
- "Completed Payment" (18pt bold)
- "675,000 VNĐ - Expert Consultation"
- "Transaction ID: #TXN-2025-12345" (monospace)
- "Success" green badge
- "Expand ∨"

ACTIVITY CARD 3 (left blue border):
- Left: Blue login icon
- "07:15 AM"
- "Logged In" (18pt bold)
- "Mobile App - iOS"
- "Method: Phone + OTP"
- "Location: TP. Hồ Chí Minh"

DATE HEADER: "Yesterday - 11/12/2025"

ACTIVITY CARD 4 (left purple border):
- Left: Purple video icon
- "02:30 PM"
- "Started Expert Consultation"
- "Video call with Dr. Chuyên Gia"
- "Duration: 47 minutes"
- "Rating: 5 ⭐" (gold stars)

EXPANDED DETAILS PANEL (when card expanded, light gray background):
- "Full Details" header (16pt bold)
- Timestamp: "2025-12-11 14:30:45 UTC+7"
- Request Data: Code block (JSON format, monospace, gray background)
- Response: Code block
- "Related Activities:" link list
- "Close ∧" button

PAGINATION (bottom):
- "Showing 1-20 of 156 activities"
- "Load More" button

DESIGN: Chronological timeline, clear activity categorization, expandable details, technical data for debugging, export functionality.
```

---

## Integration Points

### API Endpoints:
- `GET /api/admin/users?role=&status=&page=` - Get user list with filters
- `GET /api/admin/users/:id` - Get user details
- `POST /api/admin/users` - Create new user
- `PUT /api/admin/users/:id` - Update user
- `DELETE /api/admin/users/:id` - Delete user
- `PUT /api/admin/users/:id/status` - Change account status (lock/activate)
- `GET /api/admin/users/:id/activities` - Get activity log
- `GET /api/admin/roles` - Get all roles
- `PUT /api/admin/roles/:role/permissions` - Update role permissions
- `POST /api/admin/users/import` - Bulk import from CSV
- `GET /api/admin/users/export` - Export user data

### Validation Rules:
- Email: Valid format, unique in system
- Phone: Vietnamese format (10 digits starting with 0)
- Password: Minimum 8 characters, 1 uppercase, 1 number, 1 special char
- License Number: Required for Rescuer/Expert
- Service Area: At least 1 province for Rescuer

### Role Hierarchy:
- Super Admin: Full access to everything
- Content Admin: Manage database, users (limited), no financial
- Support Admin: View-only, handle disputes
- Expert/Rescuer: Limited to their modules
- Patient: App features only

---

## Version History
- **v1.0** - December 12, 2025: Initial user management screens design (5 screens)

---

## Design Review Checklist
- [x] Comprehensive user table with filtering and sorting
- [x] Detailed user profile with role-specific information
- [x] Multi-step user creation form with validation
- [x] Role-based permission matrix
- [x] Activity history timeline with details
- [x] Bulk actions for multiple users
- [x] Export functionality (CSV/PDF)
- [x] Professional web layout
- [x] Clear status indicators
- [x] Admin controls and danger zones

---

*This document is part of the SnakeAid Platform UI Design Documentation*  
*Related Documents: Admin-Dashboard-Screens.md, Admin-Snake-Database-Screens.md*
