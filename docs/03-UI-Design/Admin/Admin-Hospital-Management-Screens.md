# ADMIN - HOSPITAL & TREATMENT FACILITY MANAGEMENT SCREENS

## Module Information
- **Module:** Admin Hospital Management (Web Application)
- **Total Screens:** 3 screens
- **Related Features:** FE-09 to FE-12 from Major Features Summary
- **Purpose:** Manage medical facilities, antivenom inventory, and emergency treatment resources

---

## Flow Context

The Hospital Management module enables admin to maintain accurate, real-time information about treatment facilities capable of handling snakebite cases. This critical database helps patients find the nearest hospital with appropriate antivenom and ensures emergency services can route victims to equipped facilities.

**Key Functions:**
- Add, edit, delete hospital/medical station records
- Manage GPS coordinates for accurate mapping
- Track antivenom inventory by type and quantity
- Update operating hours and 24/7 emergency status
- Monitor low stock alerts for antivenom
- Generate facility reports and statistics

**Related Requirements:**
- FE-09: Add hospital/medical station information (name, address, GPS coordinates)
- FE-10: Update list of available antivenom types at each facility
- FE-11: Manage operating hours and emergency contact information
- FE-12: Mark facilities capable of treating venomous snake bites 24/7

---

## Design System

### Color Palette (Admin Portal):
- **Primary Blue:** `#007BFF` (Admin branding, primary actions)
- **Dark Navy:** `#1E3A8A` (Sidebar, headers, professional tone)
- **Success Green:** `#28A745` (Active facilities, adequate stock)
- **Warning Amber:** `#FFC107` (Low stock, limited hours)
- **Danger Red:** `#DC3545` (Out of stock, critical alerts)
- **Info Cyan:** `#17A2B8` (Informational elements)
- **Light Gray:** `#F8F9FA` (Backgrounds, cards)
- **White:** `#FFFFFF` (Card backgrounds, main content)

### Facility Type Colors:
- **Major Hospital:** Blue `#007BFF`
- **District Hospital:** Cyan `#17A2B8`
- **Medical Station:** Green `#28A745`
- **Private Clinic:** Purple `#6B46C1`

### Typography (Web):
- **Page Title:** 28pt Bold
- **Section Headers:** 20pt Semi-bold
- **Card Titles:** 18pt Semi-bold
- **Body Text:** 14pt Regular
- **Small Labels:** 12pt Regular
- **Stats Numbers:** 36pt Bold

---

## Screen Designs

### Screen 1: Hospital List with Interactive Map View

**Screen Purpose:**  
Dual-view interface combining interactive map and facility list for comprehensive hospital management and geographic visualization.

**Navigation:**
- Entry: Click "Hospitals" from Admin sidebar
- Exit: To any admin section

**Key Components:**

1. **Page Header:**
   - Title: "Treatment Facilities Management"
   - Total count: "45 facilities" badge
   - Action buttons: "+ Add Facility" (blue), "Import Data" (outlined), "Export Report" (outlined)
   - View toggle: "Map View" | "List View" (current: Map View)

2. **Filter Panel (Left Sidebar, 300px):**
   - Search input: "Search by name, location..."
   - Facility type checkboxes:
     * ☑ Major Hospital (24)
     * ☑ District Hospital (12)
     * ☑ Medical Station (7)
     * ☑ Private Clinic (2)
   - 24/7 Status:
     * ☑ 24/7 Emergency (18)
     * ☐ Limited Hours (27)
   - Antivenom availability:
     * ☑ All antivenom types (12)
     * ☑ Partial availability (28)
     * ☐ No antivenom (5)
   - Region filter (dropdown): "All Regions"
   - Stock status:
     * ☑ Adequate Stock (green)
     * ☑ Low Stock (amber)
     * ☑ Out of Stock (red)
   - Clear filters link

3. **Interactive Map (Center Panel, 60% width):**
   - Full Vietnam map (Google Maps/Mapbox)
   - Facility markers (color-coded by type):
     * 🏥 Blue markers: Major hospitals
     * 🏥 Cyan markers: District hospitals
     * ⚕️ Green markers: Medical stations
     * 🏨 Purple markers: Private clinics
   - Marker clustering for dense areas
   - Zoom controls
   - Map type selector: Road | Satellite | Hybrid

   **Marker Popup (on click):**
   - Facility name: "Bệnh viện Chợ Rẫy"
   - Type badge: "Major Hospital" blue
   - 24/7 status: "✓ 24/7 Emergency" green or "Limited Hours" amber
   - Address: "201B Nguyễn Chí Thanh, Q.5, TP.HCM"
   - Phone: "028 3855 4137" (clickable)
   - Antivenom status: "8/12 types available" green
   - Quick actions:
     * "View Details" button
     * "Edit" button
     * "Directions" link

4. **Facility List Panel (Right Sidebar, 25% width, scrollable):**
   - List of facilities (cards):
   
   **Card 1 (active, blue border):**
   - "Bệnh viện Chợ Rẫy" (16pt bold)
   - "Major Hospital" badge blue
   - "✓ 24/7 Emergency" green badge
   - "8/12 antivenom types" text
   - "Stock: Adequate" green dot
   - "0.5 km away" (if user location enabled)
   - "View Details →" link
   - Hover: Highlight marker on map

   **Card 2:**
   - "Bệnh viện Nhân Dân 115"
   - "District Hospital" cyan badge
   - "✓ 24/7" green
   - "5/12 types" amber warning
   - "Stock: Low" amber dot
   - "1.2 km"

   **Card 3:**
   - "Trạm Y Tế Quận 1"
   - "Medical Station" green badge
   - "Mon-Fri 7AM-5PM" gray
   - "2/12 types"
   - "Stock: Adequate" green
   - "2.8 km"

5. **Statistics Summary (Top Bar):**
   - "Total: 45 facilities" bold
   - "24/7 Available: 18" green
   - "Full Antivenom: 12" green
   - "Low Stock Alerts: 5" amber warning

**Stitch Prompt (English):**

```
Hospital and treatment facility management with interactive map view.

PAGE HEADER:
- "Treatment Facilities Management" (28pt bold dark navy)
- "45 facilities" badge (blue background, 18pt)
- Right side buttons:
  * "+ Add Facility" (blue filled, 44px)
  * "Import Data" (blue outlined, 44px)
  * "Export Report" (gray outlined, 44px)
- View toggle (right): "Map View" ACTIVE blue | "List View" gray

STATISTICS BAR (light blue background, full width):
- "Total: 45 facilities" (20pt bold)
- "24/7 Available: 18" green badge
- "Full Antivenom: 12" green badge
- "Low Stock Alerts: 5" amber badge with ⚠️

LAYOUT (three-column):

LEFT SIDEBAR (300px, white card, scrollable):

"Filters" header (18pt bold)

SEARCH:
- Input: "Search by name, location..." + magnifying glass icon

"Facility Type" section:
☑ "Major Hospital" checkbox + "(24)" gray count
☑ "District Hospital" + "(12)"
☑ "Medical Station" + "(7)"
☑ "Private Clinic" + "(2)"

"24/7 Status" section:
☑ "24/7 Emergency (18)" green text
☐ "Limited Hours (27)" gray

"Antivenom Availability" section:
☑ "All antivenom types (12)"
☑ "Partial availability (28)"
☐ "No antivenom (5)"

"Region" dropdown:
- Showing "All Regions"

"Stock Status" section:
☑ "Adequate Stock" green circle
☑ "Low Stock" amber circle
☑ "Out of Stock" red circle

"Clear filters" link (blue, bottom)

CENTER PANEL (60% width):

INTERACTIVE MAP (full height, Google Maps):
- Vietnam map centered on Ho Chi Minh City
- Zoom level showing Southern region

MARKERS (cluster when zoomed out):
- 🏥 Blue marker 1: Bệnh viện Chờ Rẫy (SELECTED, pulsing)
- 🏥 Cyan marker 2: Bệnh viện Nhân Dân 115
- ⚕️ Green marker 3: Trạm Y Tế Q1
- 🏥 Blue marker 4: Bệnh viện Nhi Đồng 1
- [Additional 41 markers across map]

MARKER POPUP (for selected blue marker):
- "Bệnh viện Chờ Rẫy" (18pt bold)
- "Major Hospital" blue badge
- "✓ 24/7 Emergency" green badge
- "201B Nguyễn Chí Thanh, Q.5, TP.HCM" (14pt)
- "Phone: 028 3855 4137" (blue link, clickable)
- "Antivenom: 8/12 types available" green text
- Buttons:
  * "View Details" blue filled
  * "Edit" blue outlined
  * "Directions" gray link

MAP CONTROLS (bottom-right):
- Zoom + / - buttons
- "Road | Satellite | Hybrid" toggle
- "My Location" button

RIGHT SIDEBAR (25% width, white card, scrollable):

"Facilities (45)" header (16pt bold)

FACILITY CARD 1 (blue left border, white background):
- "Bệnh viện Chờ Rẫy" (16pt bold)
- "Major Hospital" badge blue
- "✓ 24/7 Emergency" small green badge
- "8/12 antivenom types" (14pt)
- "Stock: Adequate" green dot + text
- "0.5 km away" gray text
- "View Details →" link blue

FACILITY CARD 2:
- "Bệnh viện Nhân Dân 115"
- "District Hospital" cyan badge
- "✓ 24/7" green badge
- "5/12 types" amber warning ⚠️
- "Stock: Low" amber dot
- "1.2 km"
- "View Details →"

FACILITY CARD 3:
- "Trạm Y Tế Quận 1"
- "Medical Station" green badge
- "Mon-Fri 7AM-5PM" gray badge (no 24/7)
- "2/12 types"
- "Stock: Adequate" green
- "2.8 km"
- "View Details →"

[Additional cards...]

DESIGN: Dual-view interface, geographic visualization, real-time filtering, color-coded facility types, 24/7 status indicators, antivenom availability tracking.
```

---

### Screen 2: Add/Edit Facility (Comprehensive Form)

**Screen Purpose:**  
Detailed form for creating new medical facilities or editing existing ones with complete facility information, GPS location, antivenom inventory, and operating hours.

**Navigation:**
- Entry: Click "+ Add Facility" from Screen 1, or "Edit" from marker popup
- Exit: Cancel → Screen 1, Save → Screen 1 or Screen 3 (Inventory)

**Key Components:**

1. **Form Header:**
   - Breadcrumb: "Hospitals > Add New Facility" or "Edit: Bệnh viện Chờ Rẫy"
   - Progress indicator: "Step 1 of 2: Facility Information" (Step 2 = Antivenom Inventory)

2. **Basic Information Section:**
   - Facility Name* (Vietnamese) required
   - Facility Name (English)
   - Facility Type* (radio cards):
     * ○ Major Hospital (blue icon)
     * ○ District Hospital (cyan icon)
     * ○ Medical Station (green icon)
     * ○ Private Clinic (purple icon)
   - Registration Number/License
   - Established Year

3. **Location Information:**
   - Address Line 1* required
   - Address Line 2
   - Ward/Commune* (dropdown)
   - District* (dropdown)
   - City/Province* (dropdown: TP. Hồ Chí Minh, Hà Nội, etc.)
   - Postal Code

   **GPS Coordinates (with map picker):**
   - Latitude* (auto-filled from map click)
   - Longitude* (auto-filled)
   - "📍 Pick Location on Map" button
   - Small embedded map (400x300px) showing selected pin
   - "Use My Location" button
   - Accuracy indicator: "±5 meters"

4. **Contact Information:**
   - Primary Phone* (Vietnamese format)
   - Emergency Hotline (24/7 if available)
   - Email Address
   - Website URL
   - Emergency Contact Person Name
   - Emergency Contact Person Phone

5. **Operating Hours & Availability:**
   - 24/7 Emergency Service* (toggle ON/OFF)
   
   **If 24/7 OFF, show schedule:**
   - Monday: Time picker (Start: 07:00 - End: 17:00) + checkbox "Closed"
   - Tuesday: (same)
   - Wednesday: (same)
   - Thursday: (same)
   - Friday: (same)
   - Saturday: (same)
   - Sunday: (same)
   - "Copy to All Days" button
   
   **If 24/7 ON:**
   - "Emergency department operates 24 hours, 7 days a week" green badge

6. **Facility Capabilities:**
   - Snakebite Treatment Capacity* (radio):
     * ○ Full treatment capability
     * ○ Limited treatment (stabilization only)
     * ○ No specialized treatment
   
   - Available Departments (checkboxes):
     * ☑ Emergency Room
     * ☑ Intensive Care Unit (ICU)
     * ☑ Toxicology Department
     * ☐ Pediatric Emergency
     * ☐ Surgery Department
   
   - Bed Capacity: ____ beds (number input)
   - Emergency Beds: ____ beds

7. **Antivenom Inventory Summary:**
   - "Antivenom types available: 8/12" (preview, link to full inventory)
   - Quick stock status:
     * ✓ Polyvalent antivenom: Adequate (green)
     * ⚠️ Cobra antivenom: Low stock (amber)
     * ✗ Krait antivenom: Out of stock (red)
   - "Manage Full Inventory →" button (goes to Screen 3)

8. **Additional Information:**
   - Parking Available (checkbox)
   - Wheelchair Accessible (checkbox)
   - Languages Spoken (multi-select): Vietnamese, English, Chinese, etc.
   - Payment Methods (checkboxes): Cash, Credit Card, Insurance, etc.
   - Notes (textarea): Special instructions, access directions, etc.

9. **Admin Metadata:**
   - Status* (radio): ● Active | ○ Temporarily Closed | ○ Permanently Closed
   - Priority Level (dropdown): Normal | High (for major facilities)
   - Verified (checkbox): ✓ Information verified by admin
   - Last Verified Date: (auto-filled)
   - Internal Notes (textarea, admin-only)

10. **Action Buttons:**
    - "Cancel" (gray outlined, left)
    - "Save as Draft" (blue outlined)
    - "Save & Manage Inventory" (blue filled, primary action)

**Stitch Prompt (English):**

```
Add/edit medical facility comprehensive form.

FORM HEADER:
- Breadcrumb: "Hospitals > Add New Facility" (14pt gray, blue links)
- Progress: "Step 1 of 2: Facility Information" (16pt bold) + progress bar 50% blue

FORM LAYOUT (white card, two-column where appropriate):

SECTION 1: "Basic Information" (20pt bold header + hospital icon)

LEFT COLUMN:
- "Facility Name (Vietnamese) *" label + text input
  Placeholder: "Bệnh viện Chợ Rẫy"
- "Facility Name (English)" input
  Placeholder: "Cho Ray Hospital"

RIGHT COLUMN:
- "Registration Number/License" input
- "Established Year" number input: "1900"

FACILITY TYPE (large radio cards, 4 columns):
- ○ "Major Hospital" card (blue background, hospital icon, 🏥)
- ● "District Hospital" SELECTED (cyan background, ✓ checkmark)
- ○ "Medical Station" (green background, ⚕️)
- ○ "Private Clinic" (purple background, 🏨)

SECTION 2: "Location Information" (20pt bold + 📍 icon)

FULL WIDTH:
- "Address Line 1 *" input
  Value: "201B Nguyễn Chí Thanh"
- "Address Line 2" input

THREE COLUMNS:
- "Ward/Commune *" dropdown: "Phường 15"
- "District *" dropdown: "Quận 5"
- "City/Province *" dropdown: "TP. Hồ Chí Minh"

TWO COLUMNS:
- "Postal Code" input: "70000"

GPS COORDINATES subsection:
- "GPS Coordinates" label (16pt semi-bold)
- Two inputs side-by-side:
  * "Latitude *": "10.7558" (read-only gray background)
  * "Longitude *": "106.6672"
- "📍 Pick Location on Map" button (blue outlined, 44px)
- Embedded map (400x300px, rounded):
  * Google Maps showing pin at coordinates
  * Draggable red pin 📍
  * "Use My Location" button (bottom-left of map)
  * "Accuracy: ±5 meters" green text (bottom-right)

SECTION 3: "Contact Information" (20pt bold + 📞 icon)

TWO COLUMNS:
LEFT:
- "Primary Phone *" input: "028 3855 4137"
- "Emergency Hotline" input: "028 3855 4138"
- "Email Address" input: "info@choray.vn"

RIGHT:
- "Website URL" input: "https://choray.vn"
- "Emergency Contact Person" input: "Dr. Nguyễn Văn A"
- "Contact Person Phone" input: "090 123 4567"

SECTION 4: "Operating Hours & Availability" (20pt bold + 🕐 icon)

- "24/7 Emergency Service *" label
  Toggle switch: ON (green, showing ✓)

IF TOGGLE ON:
- Green badge: "Emergency department operates 24 hours, 7 days a week"

IF TOGGLE OFF (show this in example):
- Weekly schedule table:

HEADER: Day | Opening Hours | Status
ROW 1: "Monday" | Time pickers "07:00" - "17:00" | ☐ Closed checkbox
ROW 2: "Tuesday" | "07:00" - "17:00" | ☐ Closed
ROW 3: "Wednesday" | "07:00" - "17:00" | ☐ Closed
...
ROW 7: "Sunday" | "Closed" gray | ☑ Closed (checked)

- "Copy to All Days" button (gray outlined, below table)

SECTION 5: "Facility Capabilities" (20pt bold)

"Snakebite Treatment Capacity *" radio buttons (large):
● "Full treatment capability" (selected, green border)
○ "Limited treatment (stabilization only)"
○ "No specialized treatment"

"Available Departments" checkboxes (2 columns):
LEFT:
☑ Emergency Room
☑ Intensive Care Unit (ICU)
☑ Toxicology Department

RIGHT:
☐ Pediatric Emergency
☐ Surgery Department

TWO COLUMNS:
- "Bed Capacity" number input: "1,200 beds"
- "Emergency Beds" number input: "50 beds"

SECTION 6: "Antivenom Inventory Summary" (20pt bold + 💉 icon)

- "Antivenom types available: 8/12" (18pt) + "View Full Inventory →" link blue

QUICK STOCK STATUS (3 rows):
ROW 1: ✓ green checkmark | "Polyvalent antivenom" | "Adequate" green badge
ROW 2: ⚠️ amber warning | "Cobra antivenom" | "Low stock" amber badge
ROW 3: ✗ red X | "Krait antivenom" | "Out of stock" red badge

- "Manage Full Inventory →" button (blue outlined)

SECTION 7: "Additional Information"

CHECKBOXES (horizontal):
☑ "Parking Available"
☑ "Wheelchair Accessible"

TWO COLUMNS:
- "Languages Spoken" multi-select chips:
  "Vietnamese ×" "English ×" "+ Add"
- "Payment Methods" checkboxes:
  ☑ Cash  ☑ Credit Card  ☑ Insurance

FULL WIDTH:
- "Notes" textarea (5 rows):
  "Accessible via Gate 3 after hours. Parking available for emergency vehicles only."

SECTION 8: "Admin Metadata" (gray background box)

- "Status *" radio: ● Active  ○ Temporarily Closed  ○ Permanently Closed
- "Priority Level" dropdown: "High (for major facilities)"
- ☑ "Verified" checkbox + "Information verified by admin"
- "Last Verified Date" (read-only): "10/12/2025"
- "Internal Notes" textarea (3 rows, light gray background)

ACTION BUTTONS (bottom, sticky):
- "Cancel" button (gray outlined, 44px, left)
- "Save as Draft" button (blue outlined, 44px, center)
- "Save & Manage Inventory" button (blue filled, 48px, bold, right, primary)

DESIGN: Comprehensive facility form, interactive GPS map picker, 24/7 toggle with conditional schedule, quick inventory preview, verification system.
```

---

### Screen 3: Antivenom Inventory Management

**Screen Purpose:**  
Detailed antivenom inventory tracking with stock levels, expiration dates, low stock alerts, and supplier information.

**Navigation:**
- Entry: Click "Manage Full Inventory" from Screen 2, or "Inventory" tab from facility detail
- Exit: Back to Screen 2 (facility form) or Screen 1 (facility list)

**Key Components:**

1. **Header:**
   - Breadcrumb: "Hospitals > Bệnh viện Chợ Rẫy > Antivenom Inventory"
   - Facility info card (compact): name + type + 24/7 badge
   - Overall status: "8/12 types in stock" (green) + "2 Low Stock Alerts" (amber warning)

2. **Inventory Summary Cards (Top Row):**
   - Card 1: "Total Types: 8/12" (blue)
   - Card 2: "Adequate Stock: 6" (green)
   - Card 3: "Low Stock: 2" (amber)
   - Card 4: "Out of Stock: 4" (red)

3. **Quick Actions:**
   - "+ Add New Antivenom" button (blue)
   - "Reorder Low Stock" button (amber outlined)
   - "Export Inventory" button (gray outlined)
   - "Print Stock Report" button (gray outlined)

4. **Antivenom Inventory Table:**
   - Columns:
     * Status Icon (green/amber/red dot)
     * Antivenom Name (Vietnamese + English)
     * Snake Types (tags)
     * Current Stock (vials)
     * Minimum Stock (threshold)
     * Expiration Date (earliest)
     * Supplier
     * Last Updated
     * Actions (edit, reorder, delete)

   **Example Rows:**

   **Row 1 (adequate stock):**
   - ● Green dot
   - "Huyết thanh kháng nọc đa giá" | "Polyvalent Antivenom"
   - Snake tags: "Cobra" + "Viper" + "Krait" + "+3"
   - Current: "120 vials" green bold
   - Minimum: "50 vials"
   - Expiration: "15/08/2026" green (18 months away)
   - Supplier: "Queen Saovabha Memorial Institute, Thailand"
   - Updated: "10/12/2025"
   - Icons: ✏️ Edit | 🔄 Reorder | 🗑️ Delete

   **Row 2 (low stock):**
   - ● Amber dot + ⚠️ warning icon
   - "Huyết thanh kháng nọc rắn hổ mang" | "Cobra Antivenom"
   - "Cobra" tag
   - Current: "18 vials" amber bold + amber background highlight
   - Minimum: "20 vials"
   - Expiration: "10/03/2026" amber (3 months away)
   - Supplier: "Thai Red Cross"
   - Updated: "12/12/2025"
   - Icons + "🔔 Low Stock Alert" badge

   **Row 3 (out of stock):**
   - ● Red dot + ✗ icon
   - "Huyết thanh kháng nọc rắn kịch" | "Krait Antivenom"
   - "Krait" tag
   - Current: "0 vials" red bold + red background
   - Minimum: "15 vials"
   - Expiration: "—" (none available)
   - Supplier: "Myanmar Pharmaceutical"
   - Updated: "01/12/2025"
   - Icons + "⚠️ Out of Stock" red badge

   **Row 4 (expiring soon):**
   - ● Green dot + 📅 calendar warning
   - "Huyết thanh kháng nọc rắn lục" | "Green Pit Viper Antivenom"
   - "Trimeresurus" tag
   - Current: "45 vials" green
   - Minimum: "20 vials"
   - Expiration: "20/01/2026" red bold (1 month away) + "⚠️ Expiring Soon" badge
   - Supplier: "Vietnam Pasteur Institute"
   - Updated: "08/12/2025"

5. **Bulk Actions (when rows selected):**
   - "3 items selected" text
   - "Update Stock Levels" button
   - "Reorder All" button
   - "Delete" button (red)

6. **Automated Alerts Section (Right Sidebar):**
   - Title: "Inventory Alerts"
   
   **Alert Card 1 (amber):**
   - ⚠️ "Low Stock Warning"
   - "Cobra Antivenom: 18 vials (Min: 20)"
   - "Action: Reorder 50 vials"
   - "Reorder Now" button

   **Alert Card 2 (red):**
   - 🚨 "Out of Stock Critical"
   - "Krait Antivenom: 0 vials"
   - "Action: Immediate reorder required"
   - "Emergency Order" button (red)

   **Alert Card 3 (amber):**
   - 📅 "Expiring Soon"
   - "Green Pit Viper: 45 vials expire in 1 month"
   - "Action: Use or transfer to another facility"
   - "Mark for Transfer" button

7. **Notification Settings:**
   - "Email alerts when stock < minimum" (checkbox, checked)
   - "Alert 2 months before expiration" (checkbox, checked)
   - Alert recipients: admin@example.com (editable)

**Stitch Prompt (English):**

```
Antivenom inventory management with stock tracking and alerts.

HEADER:
- Breadcrumb: "Hospitals > Bệnh viện Chợ Rẫy > Antivenom Inventory" (14pt gray, blue links)
- Facility info card (horizontal, compact):
  * 60px hospital icon
  * "Bệnh viện Chợ Rẫy" (18pt bold)
  * "District Hospital" cyan badge
  * "✓ 24/7" green badge
- Overall status: "8/12 types in stock" green badge + "2 Low Stock Alerts" amber badge ⚠️

SUMMARY CARDS (4 cards, horizontal row):

CARD 1 (blue border):
- Icon: 💉 large
- "Total Types" label gray
- "8/12" (36pt bold)

CARD 2 (green border):
- Icon: ✓ green
- "Adequate Stock"
- "6" (36pt bold green)

CARD 3 (amber border):
- Icon: ⚠️ amber
- "Low Stock"
- "2" (36pt bold amber)

CARD 4 (red border):
- Icon: ✗ red
- "Out of Stock"
- "4" (36pt bold red)

QUICK ACTIONS BAR:
- "+ Add New Antivenom" button (blue filled, 44px)
- "Reorder Low Stock" button (amber outlined, 44px)
- "Export Inventory" button (gray outlined, 44px)
- "Print Stock Report" button (gray outlined, 44px)

INVENTORY TABLE (white card, full width):

HEADER ROW (light gray background):
- "Status" (40px)
- "Antivenom Name" sortable ↕️ (280px)
- "Snake Types" (180px)
- "Current Stock" sortable ↕️ (120px)
- "Min Stock" (100px)
- "Expiration" sortable ↕️ (120px)
- "Supplier" (200px)
- "Last Updated" (120px)
- "Actions" (120px)

ROW 1 (adequate stock):
- ● Green dot (large)
- "Huyết thanh kháng nọc đa giá" (16pt bold)
  "Polyvalent Antivenom" (14pt gray italic)
- Tags: "Cobra" gray chip + "Viper" + "Krait" + "+3" chip
- "120 vials" (18pt bold green)
- "50 vials" (14pt gray)
- "15/08/2026" green text (18 months)
- "Queen Saovabha Memorial Institute, Thailand" (14pt)
- "10/12/2025"
- Icons: ✏️ Edit (blue) | 🔄 Reorder (blue) | 🗑️ Delete (red)

ROW 2 (low stock, amber background highlight):
- ● Amber dot + ⚠️ warning
- "Huyết thanh kháng nọc rắn hổ mang"
  "Cobra Antivenom" (italic gray)
- "Cobra" tag only
- "18 vials" (18pt bold amber) + amber background
- "20 vials" (bold)
- "10/03/2026" amber (3 months)
- "Thai Red Cross"
- "12/12/2025"
- Icons + "🔔 Low Stock Alert" badge (amber)

ROW 3 (out of stock, red background highlight):
- ● Red dot + ✗ icon
- "Huyết thanh kháng nọc rắn kịch"
  "Krait Antivenom"
- "Krait" tag
- "0 vials" (18pt bold red) + red background
- "15 vials" (bold)
- "—" (gray, no stock)
- "Myanmar Pharmaceutical"
- "01/12/2025"
- Icons + "⚠️ Out of Stock" red badge

ROW 4 (expiring soon):
- ● Green dot + 📅 calendar icon amber
- "Huyết thanh kháng nọc rắn lục"
  "Green Pit Viper Antivenom"
- "Trimeresurus" tag
- "45 vials" green
- "20 vials"
- "20/01/2026" (red bold) + "⚠️ Expiring Soon" amber badge
- "Vietnam Pasteur Institute"
- "08/12/2025"
- Icons

[Additional rows 5-12...]

BULK ACTIONS BAR (blue background, appears when selected):
- "3 items selected" white text
- "Update Stock Levels" button (white outlined)
- "Reorder All" button (white outlined)
- "Delete" button (red background)

RIGHT SIDEBAR (300px width):

"Inventory Alerts" header (18pt bold) + 🔔 icon

ALERT CARD 1 (amber border, light amber background):
- ⚠️ Large amber icon
- "Low Stock Warning" (16pt bold)
- "Cobra Antivenom: 18 vials (Min: 20)"
- "Action: Reorder 50 vials"
- "Reorder Now" button (amber filled, 40px)

ALERT CARD 2 (red border, light red background):
- 🚨 Large red icon
- "Out of Stock Critical" (16pt bold red)
- "Krait Antivenom: 0 vials"
- "Action: Immediate reorder required"
- "Emergency Order" button (red filled, 40px)

ALERT CARD 3 (amber border):
- 📅 Calendar icon amber
- "Expiring Soon" (16pt bold)
- "Green Pit Viper: 45 vials expire in 1 month"
- "Action: Use or transfer to another facility"
- "Mark for Transfer" button (amber outlined, 40px)

"Notification Settings" section (gray box):
☑ "Email alerts when stock < minimum"
☑ "Alert 2 months before expiration"
"Alert recipients:" label
"admin@choray.vn" input (editable)

DESIGN: Comprehensive inventory tracking, visual stock status indicators, automated alerts system, expiration monitoring, bulk reorder support.
```

---

## Integration Points

### API Endpoints:
- `GET /api/admin/hospitals?filter=&sort=&page=` - Get hospital list with filters
- `GET /api/admin/hospitals/:id` - Get hospital details
- `POST /api/admin/hospitals` - Create new hospital
- `PUT /api/admin/hospitals/:id` - Update hospital
- `DELETE /api/admin/hospitals/:id` - Delete hospital
- `GET /api/admin/hospitals/map` - Get all hospitals for map view with coordinates
- `GET /api/admin/hospitals/:id/inventory` - Get antivenom inventory for hospital
- `PUT /api/admin/hospitals/:id/inventory/:antivenomId` - Update antivenom stock
- `POST /api/admin/hospitals/:id/inventory` - Add new antivenom type
- `DELETE /api/admin/hospitals/:id/inventory/:antivenomId` - Remove antivenom
- `GET /api/admin/hospitals/alerts` - Get low stock and expiration alerts
- `POST /api/admin/hospitals/import` - Bulk import from CSV
- `GET /api/admin/hospitals/export` - Export hospital data
- `GET /api/admin/hospitals/statistics` - Get overall statistics

### Validation Rules:
- Facility Name: Required, max 200 characters
- GPS Coordinates: Required, valid latitude (-90 to 90), longitude (-180 to 180)
- Phone: Required, Vietnamese format (10 digits starting with 0)
- 24/7 Status: Required boolean
- Operating Hours: Required if not 24/7, valid time format
- Address: Complete address with city/province/district required
- Antivenom Stock: Non-negative integer
- Minimum Stock: Positive integer, must be > 0
- Expiration Date: Future date required for active stock

### Map Integration:
- Google Maps API or Mapbox for interactive map
- Geocoding API for address to coordinates conversion
- Marker clustering for dense areas (zoom level based)
- Real-time location services for "My Location" feature
- Distance calculation from user location (if permission granted)
- Directions API integration for "Get Directions" feature

### Alert System:
- Low stock alert: When current < minimum threshold
- Critical alert: When stock = 0
- Expiration warning: 2 months before expiration date
- Email notifications to facility admin and system admin
- Dashboard widget showing active alerts count
- Weekly inventory report generation

---

## Version History
- **v1.0** - December 13, 2025: Initial hospital management screens design (3 screens)

---

## Design Review Checklist
- [x] Interactive map view with facility markers
- [x] Comprehensive facility information form
- [x] GPS coordinate picker with interactive map
- [x] 24/7 status and operating hours management
- [x] Detailed antivenom inventory tracking
- [x] Stock level alerts (low stock, out of stock, expiring)
- [x] Bulk operations for inventory management
- [x] Color-coded facility types and stock status
- [x] Export and reporting functionality
- [x] Real-time alert system

---

*This document is part of the SnakeAid Platform UI Design Documentation*  
*Related Documents: Admin-Dashboard-Screens.md, Admin-User-Management-Screens.md, Admin-Snake-Database-Screens.md*
