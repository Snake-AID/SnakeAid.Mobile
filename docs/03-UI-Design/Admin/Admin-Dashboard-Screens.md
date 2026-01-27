# ADMIN DASHBOARD SCREENS - SNAKEAID PLATFORM

## Document Information
- **Module:** Admin Web Application
- **Feature Category:** Dashboard & Real-time Monitoring
- **Total Screens:** 2 screens
- **Related Features:** FE-17 to FE-21 (Statistics), FE-26 to FE-29 (Real-time monitoring)
- **Platform:** Web Application (Desktop)
- **Color Scheme:** Blue Primary `#007BFF`, Dark Navy `#1E3A8A` for admin professionalism

---

## Flow Context

### Admin Dashboard Purpose

**Primary Goals:**
- Provide comprehensive system overview at a glance
- Real-time monitoring of all activities (incidents, rescues, consultations)
- Quick access to critical management functions
- Performance metrics and KPIs visualization
- Alert system for abnormal situations

**Key Metrics Tracked:**
1. **Incidents:** Total snakebite cases (today/week/month)
2. **Rescues:** Active rescue operations, completion rate
3. **Consultations:** Expert sessions (Patient scheduled + Rescuer urgent)
4. **Users:** Active patients, rescuers online, experts online
5. **Revenue:** Platform earnings, transaction volume
6. **System Health:** API uptime, AI model accuracy, database status

**Key Features (Reference: Major-Features-Summary.md):**
- FE-17: Statistics on snakebite cases by area, time, species
- FE-18: Reports on rescue count and completion rate
- FE-19: Statistics on consultation count and expert ratings
- FE-20: Trend analysis and high-risk areas
- FE-26: Display real-time rescue operations on map
- FE-27: Track rescuer location and task status
- FE-28: Heat map of snakebite hotspots
- FE-29: Monitor average response time

---

## Design System

### Color Palette
```
Primary Blue:       #007BFF  (Admin branding, primary actions)
Dark Navy:          #1E3A8A  (Sidebar, headers, professional tone)
Success Green:      #28A745  (Completed, positive metrics)
Warning Amber:      #FFC107  (Pending, alerts)
Danger Red:         #DC3545  (Critical incidents, errors)
Info Cyan:          #17A2B8  (Informational, neutral stats)
Light Gray:         #F8F9FA  (Background, cards)
Medium Gray:        #6C757D  (Secondary text, borders)
White:              #FFFFFF  (Card backgrounds, main content)
```

### Status Colors (Real-time Map)
```
🔴 Active Snakebite:     Red (#DC3545)     - Emergency cases being handled
🟡 Pending Rescue:       Amber (#FFC107)   - Rescue requests waiting assignment
🟢 Completed Today:      Green (#28A745)   - Successfully completed operations
🔵 Rescuer Online:       Blue (#007BFF)    - Available rescuers on duty
⚫ Expert Online:        Dark Gray (#343A40) - Experts available for consultation
🟣 Consultation Active:  Purple (#6B46C1)  - Live consultation sessions
```

### Typography (Web)
```
Dashboard Title:     32pt Bold
Section Headers:     24pt Semi-bold
Card Titles:         18pt Semi-bold
Body Text:           14pt Regular
Small Labels:        12pt Regular
Big Numbers (Stats): 36-48pt Bold
```

---

## Screen Designs

### Screen 1: Main Dashboard (Overview)

**Screen Purpose:**  
Central hub providing comprehensive system overview with key metrics, quick stats, recent activities, and shortcuts to major management functions.

**Layout:**  
Desktop Web (1920x1080 optimized, responsive for 1366x768)

**Navigation:**
- Entry: Admin login → Landing page
- Top Navigation Bar: Dashboard (active) | Users | Snake DB | Hospitals | Analytics | Financial | Settings
- Left Sidebar: Collapsible menu with icons + labels
- Exit: Click any nav item → Navigate to respective module

**Key Components:**

1. **Top Navigation Bar (Fixed):**
   - Left: SnakeAid logo + "Admin Portal"
   - Center: Global search bar "Search users, incidents, hospitals..."
   - Right: Notifications bell (badge count), Profile dropdown (avatar + name + logout)

2. **Left Sidebar (Collapsible, Dark Navy background):**
   - 📊 Dashboard (active, blue highlight)
   - 👥 User Management
   - 🐍 Snake Database
   - 🏥 Hospital Management
   - 📈 Analytics & Reports
   - 💰 Financial Management
   - 🔔 Alerts & Notifications
   - ⚙️ Settings
   - Collapse button (bottom)

3. **Hero Stats Row (4 Large Cards):**
   
   **Card 1: Total Incidents Today**
   - Icon: Emergency symbol (red)
   - Label: "Snakebite Incidents Today"
   - Big Number: "47" (48pt bold)
   - Comparison: "+12 vs yesterday" (green arrow up)
   - Sub-stats: "32 resolved | 15 active"

   **Card 2: Active Rescues**
   - Icon: Ambulance (amber)
   - Label: "Rescue Operations"
   - Big Number: "8" (48pt bold amber)
   - Comparison: "5 en route | 3 at scene"
   - Sub-stats: "Avg response: 14 min"

   **Card 3: Expert Consultations**
   - Icon: Video call (purple)
   - Label: "Consultations Today"
   - Big Number: "23" (48pt bold purple)
   - Comparison: "18 Patient | 5 Rescuer"
   - Sub-stats: "12 scheduled upcoming"

   **Card 4: System Revenue**
   - Icon: Money (green)
   - Label: "Revenue Today"
   - Big Number: "12.5M VNĐ" (48pt bold green)
   - Comparison: "+18% vs yesterday"
   - Sub-stats: "156 transactions"

4. **Real-time Activity Map (Center Large Panel):**
   - Title: "Live System Activity" + View Full Map button (→ Screen 2)
   - Interactive map (Google Maps/Mapbox)
   - Markers with different colors (as per status colors above)
   - Legend: Color codes explained
   - Zoom controls
   - Click marker → Quick popup with basic info
   - Time display: "Last updated: 10 seconds ago" (auto-refresh every 10s)

5. **Quick Stats Grid (Below Map - 3 columns):**

   **Column 1: User Stats**
   - "Active Users Now"
   - 🧑 Patients: 1,234 online
   - 🚑 Rescuers: 45 online (out of 120 total)
   - 🧑‍🔬 Experts: 12 online (out of 35 total)
   - Link: "Manage Users →"

   **Column 2: AI Performance**
   - "AI Model Accuracy"
   - Snake ID: 87.3% (↑ 2% this week)
   - Severity Assessment: 92.1%
   - Last retrain: 2 days ago
   - Link: "View Details →"

   **Column 3: System Health**
   - "Platform Status"
   - ✅ API: Operational (99.8% uptime)
   - ✅ Database: Healthy
   - ⚠️ Payment Gateway: Slow (550ms)
   - Link: "System Status →"

6. **Recent Activities Feed (Right Sidebar - Scrollable):**
   - Title: "Recent Activities (Last 30 min)"
   - List of 10 most recent events:
     
     **Event 1:**
     - Icon: Red dot + Emergency icon
     - "New snakebite case reported"
     - Location: "Quận 1, TP.HCM"
     - Time: "2 minutes ago"
     - Quick action: "View Details"

     **Event 2:**
     - Icon: Blue dot + Rescuer icon
     - "Rescuer #34 accepted rescue request"
     - "Đội SG - Rắn Hổ Mang"
     - Time: "5 minutes ago"

     **Event 3:**
     - Icon: Green dot + Checkmark
     - "Rescue completed successfully"
     - "Patient: Nguyễn Văn A"
     - Time: "8 minutes ago"

     **Event 4:**
     - Icon: Purple dot + Video
     - "Expert consultation started"
     - "Dr. Trần - Patient consultation"
     - Time: "12 minutes ago"

   - Show More button (bottom)

7. **Pending Actions Alert Box (If any):**
   - Red/Amber banner at top
   - "⚠️ 3 Actions Required"
   - "2 disputes pending resolution"
   - "1 hospital inventory low on antivenom"
   - Button: "Review Now"

8. **Quick Actions Menu (Bottom Left):**
   - Floating action buttons:
     - + Create Alert
     - 📊 Generate Report
     - 🔔 Send Notification
     - 📤 Export Data

**Stitch Prompt (English):**

```
Admin dashboard main screen for SnakeAid platform management.

TOP NAV BAR (white, shadow):
- Left: "SnakeAid" logo + "Admin Portal" (18pt bold)
- Center: Search bar (400px wide, gray border, magnifying glass icon) "Search users, incidents, hospitals..."
- Right: Bell icon (red badge "5") + Avatar (40px circle) + "Admin Name" + dropdown arrow

LEFT SIDEBAR (dark navy #1E3A8A, 240px width, collapsible):
- Menu items (white text, 16pt):
  * 📊 "Dashboard" (ACTIVE - blue #007BFF background)
  * 👥 "User Management"
  * 🐍 "Snake Database"
  * 🏥 "Hospital Management"
  * 📈 "Analytics & Reports"
  * 💰 "Financial Management"
  * 🔔 "Alerts & Notifications"
  * ⚙️ "Settings"
- Bottom: Collapse button "«"

HERO STATS ROW (4 cards, equal width, white background, rounded, shadow):

CARD 1:
- Red emergency icon (48px)
- "Snakebite Incidents Today" (14pt gray)
- "47" (48pt bold dark)
- "+12 vs yesterday" (12pt green) + up arrow
- "32 resolved | 15 active" (12pt gray)

CARD 2:
- Amber ambulance icon (48px)
- "Rescue Operations"
- "8" (48pt bold amber)
- "5 en route | 3 at scene" (14pt)
- "Avg response: 14 min" (12pt gray)

CARD 3:
- Purple video icon (48px)
- "Consultations Today"
- "23" (48pt bold purple)
- "18 Patient | 5 Rescuer" (14pt)
- "12 scheduled upcoming" (12pt gray)

CARD 4:
- Green money icon (48px)
- "Revenue Today"
- "12.5M VNĐ" (48pt bold green)
- "+18% vs yesterday" (12pt green) + up arrow
- "156 transactions" (12pt gray)

MAP PANEL (large white card, 60% width, center):
- Header: "Live System Activity" (20pt bold) + "View Full Map →" blue button
- Interactive map with colored markers:
  * 🔴 Red dots (5 markers - active incidents)
  * 🟡 Amber dots (3 markers - pending rescues)
  * 🟢 Green dots (8 markers - completed)
  * 🔵 Blue dots (12 markers - rescuers online)
  * ⚫ Dark dots (4 markers - experts online)
- Legend box (bottom-right corner of map): Color code explanations
- "Last updated: 10 seconds ago" (small gray text, bottom-left)

QUICK STATS GRID (3 columns below map):

COLUMN 1 (User Stats):
- "Active Users Now" header
- 🧑 "Patients: 1,234 online"
- 🚑 "Rescuers: 45 online (out of 120 total)"
- 🧑‍🔬 "Experts: 12 online (out of 35 total)"
- "Manage Users →" link (blue)

COLUMN 2 (AI Performance):
- "AI Model Accuracy" header
- "Snake ID: 87.3%" + "↑ 2% this week" (green)
- "Severity: 92.1%"
- "Last retrain: 2 days ago" (gray)
- "View Details →" link

COLUMN 3 (System Health):
- "Platform Status" header
- "✅ API: Operational (99.8%)"
- "✅ Database: Healthy"
- "⚠️ Payment: Slow (550ms)" (amber warning)
- "System Status →" link

RIGHT SIDEBAR (30% width, scrollable):
- "Recent Activities (Last 30 min)" header (18pt bold)
- Activity feed (10 items):
  
  ITEM 1:
  * Red dot + emergency icon
  * "New snakebite case reported" (bold)
  * "Quận 1, TP.HCM" (gray)
  * "2 minutes ago" (gray, small)
  * "View Details" link

  ITEM 2:
  * Blue dot + rescuer icon
  * "Rescuer #34 accepted rescue request"
  * "Đội SG - Rắn Hổ Mang"
  * "5 minutes ago"

  ITEM 3:
  * Green dot + checkmark
  * "Rescue completed successfully"
  * "Patient: Nguyễn Văn A"
  * "8 minutes ago"

  ITEM 4:
  * Purple dot + video icon
  * "Expert consultation started"
  * "Dr. Trần - Patient consultation"
  * "12 minutes ago"

- "Show More" button (bottom)

ALERT BOX (if alerts exist, top of main content, red/amber background):
- "⚠️ 3 Actions Required" (bold white text)
- "• 2 disputes pending resolution"
- "• 1 hospital inventory low on antivenom"
- "Review Now" button (white outlined)

FLOATING ACTION BUTTONS (bottom-right):
- + "Create Alert" (blue)
- 📊 "Generate Report" (blue)
- 🔔 "Send Notification" (blue)
- 📤 "Export Data" (blue)

DESIGN: Professional admin interface, data-dense but organized, real-time updates, color-coded status system, quick access to critical functions, responsive web layout.
```

---

### Screen 2: Real-time Monitoring Map (Full Screen)

**Screen Purpose:**  
Dedicated full-screen monitoring interface for tracking all system activities on an interactive map with detailed filtering, heat map overlay, and comprehensive incident details.

**Layout:**  
Full-screen web interface with minimal UI elements to maximize map visibility.

**Navigation:**
- Entry: Click "View Full Map" from Screen 1, or "Real-time Monitoring" from sidebar
- Exit: Back button → Screen 1, or sidebar navigation

**Key Components:**

1. **Minimal Top Bar (Semi-transparent overlay):**
   - Left: Back button "← Dashboard" + "Real-time Monitoring" title
   - Center: Time display "Last updated: 5 seconds ago" (auto-refresh)
   - Right: Notifications + Profile (same as Screen 1)

2. **Left Control Panel (Collapsible, floating on map):**
   
   **Filter Section:**
   - "Filters" header + Collapse button
   - Checkboxes (toggle visibility on map):
     - 🔴 Active Incidents (15) ✓
     - 🟡 Pending Rescues (8) ✓
     - 🟢 Completed Today (32) ✓
     - 🔵 Rescuers Online (45) ✓
     - ⚫ Experts Online (12) ✓
     - 🟣 Active Consultations (6) ✓
   
   **Time Range Filter:**
   - Dropdown: "Last 24 hours" (default)
   - Options: Last 1 hour, 6 hours, 24 hours, This week, Custom range
   
   **Location Filter:**
   - Dropdown: "All Locations"
   - Options: By Province/City
   - Or: Draw area on map (rectangle/circle tool)

   **Snake Type Filter:**
   - Dropdown: "All Species"
   - Show common species list
   - Checkbox: "Venomous only"

   **View Options:**
   - Toggle: "Heat Map" (on/off)
   - Toggle: "Clustering" (group nearby markers)
   - Toggle: "Show Routes" (rescuer paths)
   - Slider: "Marker Size" (small/medium/large)

3. **Interactive Map (Full Screen):**
   - High-quality map (Google Maps/Mapbox)
   - Zoom controls (+ / -)
   - Full screen toggle
   - Map type: Road / Satellite / Hybrid
   - Current view: Vietnam overview, auto-zoom to activity clusters

   **Marker Types:**
   - 🔴 **Active Incident Marker:**
     - Pulsing red circle
     - Click → Info popup appears
   
   - 🟡 **Pending Rescue Marker:**
     - Amber exclamation icon
     - Shows countdown timer overlay
   
   - 🟢 **Completed Marker:**
     - Green checkmark
     - Slightly faded (completed = less urgent)
   
   - 🔵 **Rescuer Online Marker:**
     - Blue person icon
     - Shows direction arrow if moving
     - Trail line showing recent path (last 30 min)
   
   - ⚫ **Expert Online Marker:**
     - Dark badge icon with star
   
   - 🟣 **Active Consultation Marker:**
     - Purple video icon with pulse animation

4. **Heat Map Overlay (When toggled on):**
   - Color gradient overlay:
     - Red (high density): 10+ incidents
     - Orange (medium): 5-10 incidents
     - Yellow (low): 1-5 incidents
   - Opacity: 60% (see-through)
   - Time-based: Last 7 days by default
   - Legend: Color scale explanation (top-right corner)

5. **Marker Info Popup (When clicked):**
   
   **For Active Incident:**
   - Header: "🔴 Active Snakebite Case" (red background)
   - Incident ID: "#INC-20251211-047"
   - Time: "Reported 15 minutes ago"
   - Location: "123 Nguyễn Huệ, Q.1, TP.HCM"
   - Patient: "Nguyễn Văn A" (phone: 090 123 4567)
   - Snake: "AI: Rắn Hổ Mang (92% confidence)" + thumbnail
   - Severity: "Severe" (red badge)
   - Status: "Rescuer en route (ETA: 8 min)"
   - Assigned Rescuer: "Đội SG #34" + photo
   - Quick Actions:
     - "View Full Details" button
     - "Contact Patient" button
     - "Track Rescuer" button

   **For Rescuer:**
   - Header: "🔵 Rescuer Online" (blue background)
   - Name: "Đội Cứu Hộ SG #34"
   - Photo: Avatar (60px)
   - Status: "En route to rescue"
   - Current task: "Rắn Hổ Mang rescue"
   - Location: Real-time GPS coordinates
   - Speed: "35 km/h"
   - ETA: "8 minutes to destination"
   - Last updated: "3 seconds ago"
   - Quick Actions:
     - "View Profile"
     - "Contact Rescuer"
     - "View Task Details"

   **For Expert:**
   - Header: "⚫ Expert Online" (dark background)
   - Name: "Dr. Nguyễn Văn Chuyên Gia"
   - Photo: Avatar
   - Status: "Available" or "In consultation"
   - Specialization: "Venomous snakes of Southern Vietnam"
   - Rating: 4.8/5 ⭐ (156 consultations)
   - Current consultations: "1 active video call"
   - Location: "Ho Chi Minh City" (not exact GPS)
   - Quick Actions:
     - "View Profile"
     - "View Consultation History"

6. **Right Statistics Panel (Collapsible, floating):**
   - "Live Statistics" header + Collapse button
   
   **Today's Summary:**
   - "Total Incidents: 47" (red text)
   - "Active Now: 15" (amber text)
   - "Completed: 32" (green text)
   - "Avg Response Time: 14 min" (blue text)
   
   **Rescuer Performance:**
   - "Rescuers Online: 45/120"
   - "En Route: 8"
   - "At Scene: 3"
   - "Available: 34"
   - Bar chart showing distribution
   
   **Expert Activity:**
   - "Experts Online: 12/35"
   - "Active Consultations: 6"
   - "Available: 6"
   
   **Top Snakes Today:**
   - List of top 5 species causing incidents:
     1. Rắn Hổ Mang (12 cases) - red bar
     2. Rắn Ráo Trâu (8 cases) - orange bar
     3. Rắn Lục Đuôi Đỏ (6 cases) - yellow bar
     4. Rắn Hổ Chúa (5 cases) - red bar
     5. Other (16 cases) - gray bar
   
   **High-Risk Areas Alert:**
   - "⚠️ High Activity Detected"
   - "Quận 1, TP.HCM: 8 incidents (last 6h)"
   - "Quận 7, TP.HCM: 6 incidents (last 6h)"
   - Button: "Send Community Alert"

7. **Bottom Timeline Scrubber (Optional feature):**
   - Horizontal timeline bar
   - Slider to "replay" activities from past hours
   - Play/Pause button
   - Speed control: 1x, 2x, 5x, 10x
   - Shows how markers appeared/moved over time
   - Useful for analyzing patterns

8. **Quick Action Buttons (Floating, bottom-right):**
   - 📊 "Export Map" (save screenshot)
   - 📄 "Generate Report"
   - 🔔 "Create Alert"
   - 🎯 "Focus on Active"
   - 🔄 "Refresh Data"

**Stitch Prompt Part A (Map Interface):**

```
Real-time monitoring map full-screen interface for admin.

MINIMAL TOP BAR (semi-transparent white overlay, shadow):
- Left: "← Dashboard" back button + "Real-time Monitoring" (20pt bold)
- Center: "Last updated: 5 seconds ago" (auto-refresh indicator, green dot pulsing)
- Right: Bell icon (badge "5") + Avatar + dropdown

LEFT CONTROL PANEL (white floating card, 300px width, rounded, shadow, collapsible):
- "Filters" header (18pt bold) + collapse button

FILTER CHECKBOXES (each with color dot + label + count):
- 🔴 "Active Incidents (15)" ✓ checked
- 🟡 "Pending Rescues (8)" ✓
- 🟢 "Completed Today (32)" ✓
- 🔵 "Rescuers Online (45)" ✓
- ⚫ "Experts Online (12)" ✓
- 🟣 "Active Consultations (6)" ✓

DROPDOWNS:
- "Time Range: Last 24 hours" dropdown
- "Location: All Locations" dropdown
- "Snake Type: All Species" dropdown

VIEW OPTIONS (toggles):
- "Heat Map" toggle switch (ON)
- "Clustering" toggle (ON)
- "Show Routes" toggle (OFF)
- "Marker Size" slider (medium position)

FULL-SCREEN MAP (Google Maps/Mapbox style):
- Vietnam overview, focused on major cities
- Multiple colored markers scattered:
  * 15 red pulsing dots (active incidents)
  * 8 amber exclamation markers (pending)
  * 32 green checkmarks (completed, faded)
  * 45 blue person icons (rescuers, some with direction arrows)
  * 12 dark star badges (experts)
  * 6 purple video icons with pulse (consultations)

HEAT MAP OVERLAY (when enabled):
- Red-orange-yellow gradient overlay (60% opacity)
- Hot spots: Quận 1, Quận 7, Bình Thạnh
- Legend (top-right): "High (10+)" red → "Low (1-5)" yellow

ZOOM CONTROLS (right side):
- + button
- - button
- Full screen button
- Map type dropdown (Road/Satellite/Hybrid)

DESIGN: Immersive monitoring interface, minimal distractions, focus on map data, professional GIS style, real-time updates, intuitive filtering.
```

**Stitch Prompt Part B (Info Popups & Statistics):**

```
Map marker popups and statistics panel for real-time monitoring.

MARKER INFO POPUP (when clicked, white card, 350px width, rounded shadow):

ACTIVE INCIDENT POPUP:
- Header bar: "🔴 Active Snakebite Case" (white text on red background)
- Incident ID: "#INC-20251211-047" (gray monospace)
- "Reported 15 minutes ago" (gray small)
- Location: "123 Nguyễn Huệ, Q.1, TP.HCM" + map pin icon
- Patient: "Nguyễn Văn A" | "090 123 4567" (phone icon)
- Snake section:
  * Thumbnail image (80x80px)
  * "AI: Rắn Hổ Mang (92% confidence)"
  * "Severity: Severe" (red badge)
- Status: "Rescuer en route (ETA: 8 min)" (amber badge)
- Assigned: "Đội SG #34" + small avatar
- Buttons (bottom):
  * "View Full Details" (blue filled)
  * "Contact Patient" (blue outlined)
  * "Track Rescuer" (blue outlined)

RESCUER POPUP:
- Header: "🔵 Rescuer Online" (blue background)
- Avatar (60px circle) + "Đội Cứu Hộ SG #34" (16pt bold)
- Status: "En route to rescue" (amber badge)
- Current task: "Rắn Hổ Mang rescue" (14pt)
- GPS: "10.7756°N, 106.7019°E" (small gray monospace)
- Speed: "35 km/h" + speedometer icon
- ETA: "8 minutes" (large bold amber)
- "Last updated: 3 seconds ago" (green dot)
- Buttons:
  * "View Profile"
  * "Contact Rescuer"
  * "View Task Details"

EXPERT POPUP:
- Header: "⚫ Expert Online" (dark background)
- Avatar + "Dr. Nguyễn Văn Chuyên Gia"
- Status: "Available" (green badge) or "In consultation" (purple badge)
- "Venomous snakes of Southern Vietnam" (italic gray)
- Rating: "4.8/5 ⭐" + "(156 consultations)"
- "1 active video call" (purple)
- Location: "Ho Chi Minh City"
- Buttons: "View Profile" | "View History"

RIGHT STATISTICS PANEL (white floating card, 300px width, right side, scrollable):
- "Live Statistics" header + collapse button

TODAY'S SUMMARY BOX:
- "Total Incidents: 47" (28pt bold red)
- "Active Now: 15" (20pt amber)
- "Completed: 32" (20pt green)
- "Avg Response: 14 min" (20pt blue)

RESCUER PERFORMANCE:
- "Rescuers Online: 45/120" header
- Horizontal bar chart:
  * "En Route: 8" (amber segment)
  * "At Scene: 3" (red segment)
  * "Available: 34" (green segment)

EXPERT ACTIVITY:
- "Experts Online: 12/35"
- "Active Consultations: 6" (purple)
- "Available: 6" (green)

TOP SNAKES TODAY:
- "Top 5 Species" header
- Horizontal bar chart:
  1. "Rắn Hổ Mang" - 12 (red bar, 60%)
  2. "Rắn Ráo Trâu" - 8 (orange bar, 40%)
  3. "Rắn Lục Đuôi Đỏ" - 6 (yellow bar, 30%)
  4. "Rắn Hổ Chúa" - 5 (red bar, 25%)
  5. "Other" - 16 (gray bar, 80%)

HIGH-RISK ALERT (amber background box):
- "⚠️ High Activity Detected" (bold)
- "• Quận 1, TP.HCM: 8 incidents (last 6h)"
- "• Quận 7, TP.HCM: 6 incidents (last 6h)"
- "Send Community Alert" button (red)

FLOATING ACTION BUTTONS (bottom-right corner, stacked):
- 📊 "Export Map" (blue)
- 📄 "Generate Report" (blue)
- 🔔 "Create Alert" (red)
- 🎯 "Focus on Active" (amber)
- 🔄 "Refresh Data" (blue)

DESIGN: Detailed information popups, comprehensive statistics, actionable alerts, professional monitoring interface, data visualization.
```

---

## Integration Points

### API Endpoints:
- `GET /api/admin/dashboard/stats` - Get all dashboard statistics
- `GET /api/admin/monitoring/realtime` - Real-time map data (WebSocket)
- `GET /api/admin/monitoring/heatmap` - Heat map data for past 7 days
- `GET /api/admin/monitoring/incidents?status=active` - Filter incidents
- `GET /api/admin/monitoring/rescuers?online=true` - Get online rescuers
- `GET /api/admin/monitoring/experts?status=available` - Get available experts
- `GET /api/admin/activities/recent?limit=10` - Recent activity feed
- `POST /api/admin/alerts/community` - Send community alert
- `GET /api/admin/reports/daily` - Generate daily report
- `GET /api/admin/system/health` - System health check

### Real-time Features (WebSocket):
- Live marker updates every 5-10 seconds
- Rescuer GPS tracking (continuous)
- New incident notifications (instant)
- Status change updates (consultation start/end, rescue complete)
- Activity feed updates (push new events to feed)

### Data Refresh Rates:
- Map markers: 5 seconds
- Statistics: 10 seconds
- Activity feed: Real-time (push)
- Heat map: 5 minutes
- System health: 1 minute

### Export Functions:
- Export map as PNG/PDF
- Export statistics as CSV/Excel
- Generate daily/weekly/monthly reports
- Export heat map data for analysis

---

## Version History
- **v1.0** - December 11, 2025: Initial admin dashboard design (2 screens)

---

## Design Review Checklist
- [x] Comprehensive dashboard overview with key metrics
- [x] Real-time map monitoring with auto-refresh
- [x] Color-coded status system for quick recognition
- [x] Detailed marker popups with actionable buttons
- [x] Heat map overlay for hotspot analysis
- [x] Advanced filtering and view options
- [x] Live statistics panel with performance metrics
- [x] Activity feed for recent events
- [x] Responsive web layout (1920x1080 and 1366x768)
- [x] Professional admin color scheme (Blue/Navy)
- [x] Quick access to critical functions
- [x] Alert system for abnormal situations

---

*This document is part of the SnakeAid Platform UI Design Documentation*  
*Related Documents: Admin-User-Management-Screens.md, Admin-Analytics-Reporting-Screens.md*
