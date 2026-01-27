# ADMIN - ANALYTICS & REPORTING SCREENS

## Module Information
- **Module:** Admin Analytics & Reporting (Web Application)
- **Total Screens:** 4 screens
- **Related Features:** FE-17 to FE-21 from Major Features Summary
- **Purpose:** Comprehensive data analytics, statistics, trend analysis, and report generation for platform oversight

---

## Flow Context

The Analytics & Reporting module provides admin with powerful data visualization and reporting tools to monitor platform performance, identify trends, and make data-driven decisions. This module aggregates data from all user roles (patients, rescuers, experts) to provide comprehensive insights.

**Key Functions:**
- Real-time statistics dashboard with key performance indicators (KPIs)
- Incident analysis by region, time, snake species, severity
- Rescue team performance metrics and completion rates
- Expert consultation statistics and rating analysis
- Trend analysis and predictive insights
- Heat maps for high-risk areas identification
- Customizable report generation and export (PDF, Excel, CSV)
- Time-series data visualization (daily, weekly, monthly, yearly)

**Related Requirements:**
- FE-17: Compile snakebite cases by region, time, snake species
- FE-18: Report rescue operations and rescue team completion rates
- FE-19: Compile consultation statistics and expert reviews
- FE-20: Analyze trends and high-risk areas
- FE-21: Export reports by month/quarter/year

---

## Design System

### Color Palette (Admin Portal):
- **Primary Blue:** `#007BFF` (Admin branding, primary actions)
- **Dark Navy:** `#1E3A8A` (Sidebar, headers, professional tone)
- **Success Green:** `#28A745` (Positive metrics, completed operations)
- **Warning Amber:** `#FFC107` (Moderate severity, alerts)
- **Danger Red:** `#DC3545` (Critical incidents, high-risk areas)
- **Info Cyan:** `#17A2B8` (Informational charts)
- **Purple:** `#6B46C1` (Expert-related metrics)
- **Orange:** `#FD7E14` (Rescuer-related metrics)
- **Light Gray:** `#F8F9FA` (Backgrounds, cards)
- **White:** `#FFFFFF` (Card backgrounds, main content)

### Chart Colors:
- **Line Charts:** Blue `#007BFF`, Cyan `#17A2B8`, Green `#28A745`
- **Bar Charts:** Gradient from light to dark blue
- **Pie Charts:** Multi-color palette (Blue, Orange, Green, Purple, Red)
- **Heat Maps:** Red-Orange-Yellow gradient for intensity

### Typography (Web):
- **Page Title:** 28pt Bold
- **Section Headers:** 20pt Semi-bold
- **Card Titles:** 18pt Semi-bold
- **Body Text:** 14pt Regular
- **Small Labels:** 12pt Regular
- **Stats Numbers:** 36-48pt Bold

---

## Screen Designs

### Screen 1: Analytics Dashboard (Overview)

**Screen Purpose:**  
Comprehensive analytics dashboard displaying key performance indicators, trends, and real-time statistics across all platform activities.

**Navigation:**
- Entry: Click "Analytics" from Admin sidebar
- Exit: To any admin section or drill down to detailed reports

**Key Components:**

1. **Page Header:**
   - Title: "Analytics Dashboard"
   - Date range selector: "Last 30 days" (dropdown: Today | 7 days | 30 days | 90 days | This Year | Custom)
   - "Export Dashboard" button (gray outlined)
   - "Schedule Report" button (blue outlined)
   - Last updated: "2 minutes ago" (auto-refresh indicator)

2. **Key Performance Indicators (KPI Cards - Top Row, 4 cards):**

   **Card 1: Total Incidents**
   - Icon: 🚨 Emergency
   - "Total Incidents" label
   - "1,247" (48pt bold blue)
   - "+12.5% vs last month" (green arrow ↑, 14pt)
   - Sparkline: 7-day mini chart showing trend

   **Card 2: Active Rescues**
   - Icon: 🚑 Ambulance
   - "Active Rescues"
   - "23" (48pt bold orange)
   - "8 en route, 15 at scene"
   - Live pulse animation

   **Card 3: Consultations**
   - Icon: 👨‍⚕️ Doctor
   - "Expert Consultations"
   - "456" (48pt bold purple)
   - "+8.2% vs last month" (green arrow ↑)
   - Average rating: 4.8/5 ⭐

   **Card 4: Platform Revenue**
   - Icon: 💰 Money
   - "Total Revenue"
   - "124.5M VNĐ" (48pt bold green)
   - "+18.7% vs last month" (green arrow ↑)
   - Sparkline showing revenue trend

3. **Incident Trends (Line Chart, 60% width):**
   - Title: "Incident Trends - Last 30 Days"
   - Multi-line chart:
     * Blue line: Total incidents
     * Red line: Critical severity
     * Amber line: Moderate severity
     * Green line: Minor severity
   - X-axis: Dates (last 30 days)
   - Y-axis: Number of incidents (0-60)
   - Hover tooltip showing exact values
   - Legend with color codes
   - Download chart button (icon)

4. **Top 5 Snake Species (Horizontal Bar Chart, 40% width):**
   - Title: "Most Reported Snake Species"
   - Horizontal bars:
     1. Rắn Hổ Mang (Cobra) - 187 incidents (red bar, 85% width)
     2. Rắn Ráo Trâu (Rat Snake) - 124 (green bar, 56%)
     3. Rắn Lục Đuôi Đỏ (Green Pit Viper) - 98 (orange, 44%)
     4. Rắn Hổ Chúa (King Cobra) - 67 (red, 30%)
     5. Rắn Kịch (Krait) - 54 (red, 24%)
   - Percentage and count labels
   - Color-coded by danger level

5. **Regional Distribution (Map + Table, Full Width):**
   - Title: "Incidents by Region"
   - Left: Heat map of Vietnam (50% width)
     * Red zones: High incident areas (>50 incidents)
     * Orange zones: Moderate (20-50)
     * Yellow zones: Low (5-20)
     * Green zones: Very low (<5)
   - Right: Regional statistics table (50% width)
     * Columns: Region | Incidents | Change | Avg Response Time
     * Row 1: TP. Hồ Chí Minh | 342 | +15% ↑ red | 12 min
     * Row 2: Hà Nội | 287 | +8% ↑ | 14 min
     * Row 3: Đồng Nai | 156 | -5% ↓ green | 18 min
     * Row 4: Bình Dương | 134 | +22% ↑ red | 15 min
     * Row 5: Cần Thơ | 98 | +3% ↑ | 20 min

6. **Rescue Performance Metrics (Bottom Row, 3 cards):**

   **Card A: Completion Rate**
   - Circular progress chart: 94% (green)
   - "1,173 / 1,247 completed"
   - Target: 95%

   **Card B: Avg Response Time**
   - "14.2 minutes" (36pt bold)
   - Gauge chart showing against 15-min target
   - "Below target" green badge

   **Card C: Success Rate**
   - "92.5%" (36pt bold green)
   - "Safe capture: 1,085 / 1,173"
   - "vs 90% target" green badge

7. **Recent Activity Feed (Right Sidebar, scrollable):**
   - "Live Activity" header + live indicator 🔴
   - Last 10 events:
     * "2 min ago: New incident #INC-1248 - Quận 1"
     * "5 min ago: Rescue #RSC-456 completed"
     * "8 min ago: Expert consultation started"
     * [etc...]

**Stitch Prompt (English):**

```
Analytics dashboard with KPIs, charts, and real-time metrics.

PAGE HEADER:
- "Analytics Dashboard" (28pt bold dark navy)
- Date range selector: "Last 30 days" dropdown (180px, blue border)
- Right buttons:
  * "Export Dashboard" (gray outlined, 40px)
  * "Schedule Report" (blue outlined, 40px)
- "Last updated: 2 minutes ago" (12pt gray) + refresh icon

KPI CARDS ROW (4 cards, equal width, white rounded shadow):

CARD 1:
- 🚨 Emergency icon (48px, red)
- "Total Incidents" label (14pt gray)
- "1,247" (48pt bold blue)
- "+12.5% vs last month" (14pt green) + ↑ arrow
- Sparkline chart (100px wide, 30px high, blue line showing upward trend)

CARD 2:
- 🚑 Ambulance icon (48px, orange) + pulsing animation
- "Active Rescues" label
- "23" (48pt bold orange)
- "8 en route, 15 at scene" (14pt gray)
- Live red dot "LIVE"

CARD 3:
- 👨‍⚕️ Doctor icon (48px, purple)
- "Expert Consultations"
- "456" (48pt bold purple)
- "+8.2% vs last month" green ↑
- "Avg Rating: 4.8/5" + ⭐⭐⭐⭐⭐ (14pt)

CARD 4:
- 💰 Money icon (48px, green)
- "Total Revenue"
- "124.5M VNĐ" (48pt bold green)
- "+18.7% vs last month" green ↑
- Sparkline (green line, upward trend)

MAIN CHARTS ROW (two-column):

LEFT (60% width, white card):
"Incident Trends - Last 30 Days" header (20pt bold) + download icon

LINE CHART (800x400px):
- X-axis: Dates (01/11 to 30/11, every 5 days labeled)
- Y-axis: Number of incidents (0, 20, 40, 60)
- Blue line: "Total incidents" (peak at 58 on 15/11)
- Red line: "Critical severity" (peaks at 12)
- Amber line: "Moderate" (around 20-30)
- Green line: "Minor" (around 15-25)
- Legend (top-right):
  * — Blue "Total" 
  * — Red "Critical"
  * — Amber "Moderate"
  * — Green "Minor"
- Hover tooltip: "15/11: 58 incidents (12 critical)"
- Grid lines (light gray, dashed)

RIGHT (40% width, white card):
"Most Reported Snake Species" header (20pt bold)

HORIZONTAL BAR CHART:
BAR 1: "Rắn Hổ Mang (Cobra)" | Red bar 85% width | "187" right label
BAR 2: "Rắn Ráo Trâu (Rat Snake)" | Green bar 56% | "124"
BAR 3: "Rắn Lục Đuôi Đỏ (Pit Viper)" | Orange bar 44% | "98"
BAR 4: "Rắn Hổ Chúa (King Cobra)" | Red bar 30% | "67"
BAR 5: "Rắn Kịch (Krait)" | Red bar 24% | "54"

REGIONAL DISTRIBUTION (full width, white card):

"Incidents by Region" header (20pt bold)

LEFT HALF (50%):
HEAT MAP (Vietnam map, 500x600px):
- Red zones: TP.HCM (342), Hà Nội (287) - High density
- Orange zones: Đồng Nai (156), Bình Dương (134)
- Yellow zones: Cần Thơ (98), scattered areas
- Green zones: Northern mountains, coastal areas
- Legend (bottom-left):
  * High >50 (red)
  * Moderate 20-50 (orange)
  * Low 5-20 (yellow)
  * Very Low <5 (green)

RIGHT HALF (50%):
REGIONAL TABLE:

HEADER: Region | Incidents | Change | Avg Response
ROW 1: "TP. Hồ Chí Minh" | "342" bold | "+15%" red ↑ | "12 min" green
ROW 2: "Hà Nội" | "287" | "+8%" ↑ | "14 min"
ROW 3: "Đồng Nai" | "156" | "-5%" green ↓ | "18 min"
ROW 4: "Bình Dương" | "134" | "+22%" red ↑ | "15 min"
ROW 5: "Cần Thơ" | "98" | "+3%" ↑ | "20 min"

PERFORMANCE METRICS ROW (3 cards, equal width):

CARD A:
- "Completion Rate" header (18pt)
- Circular progress chart (200px diameter):
  * 94% filled green arc
  * Center: "94%" (36pt bold green)
- "1,173 / 1,247 completed" (14pt)
- "Target: 95%" gray badge

CARD B:
- "Avg Response Time" header
- "14.2 minutes" (36pt bold blue)
- Gauge chart (semi-circle):
  * Needle pointing to 14.2
  * Green zone: 0-15 min
  * Yellow: 15-20
  * Red: >20
  * Target marker at 15
- "Below target ✓" green badge

CARD C:
- "Success Rate" header
- "92.5%" (36pt bold green)
- "Safe capture: 1,085 / 1,173" (14pt)
- "vs 90% target" green badge + checkmark
- Small bar: green 92.5% | gray 7.5%

RIGHT SIDEBAR (300px, scrollable):

"Live Activity" header + 🔴 "LIVE" red badge

ACTIVITY FEED (scrollable list):
ITEM 1: "2 min ago" gray | "New incident #INC-1248 - Quận 1" + red dot
ITEM 2: "5 min ago" | "Rescue #RSC-456 completed ✓" + green dot
ITEM 3: "8 min ago" | "Expert consultation started" + purple dot
[10 items total, scrollable]

DESIGN: Comprehensive dashboard, real-time KPIs, multi-chart visualization, heat map, performance metrics, live activity feed.
```

---

### Screen 2: Incident Reports (Detailed Analysis)

**Screen Purpose:**  
Detailed incident analysis with advanced filtering, drill-down capabilities, and comprehensive data visualization for snakebite cases.

**Navigation:**
- Entry: Click "Incident Reports" from Analytics menu, or "View Details" from Dashboard
- Exit: Back to Analytics Dashboard or export report

**Key Components:**

1. **Page Header:**
   - Title: "Incident Analysis & Reports"
   - Subtitle: "Comprehensive snakebite incident data analysis"
   - Date range: Custom picker (Start: 01/11/2025 - End: 30/11/2025)
   - "Export Report" button (blue)

2. **Advanced Filter Panel (Top, collapsible):**
   - Search: "Search by incident ID, location..."
   - Filters (horizontal chips):
     * Severity: All | Minor | Moderate | Critical | Fatal
     * Snake Species: All | Cobra | Krait | Viper | [multi-select dropdown]
     * Region: All Regions | [multi-select provinces]
     * Status: All | Active | Completed | Cancelled
     * Time: All Day | Morning (6-12) | Afternoon (12-18) | Night (18-6)
   - "Apply Filters" button | "Clear All" link

3. **Summary Statistics (4 mini cards):**
   - Total Incidents: 1,247
   - Critical Cases: 156 (12.5%)
   - Avg Response: 14.2 min
   - Completion Rate: 94%

4. **Incident Distribution Charts:**

   **By Severity (Donut Chart):**
   - Center: "1,247 Total"
   - Segments:
     * Green: Minor (567, 45%)
     * Amber: Moderate (421, 34%)
     * Red: Critical (156, 12%)
     * Dark Red: Fatal (3, 0.2%)
     * Gray: Unknown (100, 8%)
   - Legend with percentages

   **By Time of Day (Bar Chart):**
   - X-axis: Time slots (0-2, 2-4, 4-6, ..., 22-24)
   - Y-axis: Number of incidents
   - Peak hours highlighted: 6-8 AM (87 incidents), 5-7 PM (94 incidents)
   - Color gradient: blue to dark blue

5. **Snake Species Breakdown (Stacked Bar Chart):**
   - X-axis: Months (Nov, Oct, Sep, Aug, Jul, Jun)
   - Y-axis: Incident count (0-150)
   - Stacked bars showing top 5 species:
     * Red: Cobra
     * Orange: Pit Viper
     * Green: Rat Snake (non-venomous)
     * Purple: Krait
     * Gray: Other
   - Hover shows exact counts per species

6. **Incident Table (Detailed List, sortable, filterable):**
   - Columns:
     * Incident ID (sortable)
     * Date/Time
     * Location (Province + District)
     * Snake Species
     * Severity (badge)
     * Response Time
     * Status (badge)
     * Actions (view, export)

   **Example Rows:**

   **Row 1 (Critical):**
   - #INC-1247
   - "30/11/2025 18:45"
   - "Quận 1, TP.HCM" + map icon
   - "Rắn Hổ Mang (Cobra)"
   - "Critical" red badge
   - "11 min" green
   - "Completed ✓" green badge
   - Icons: 👁️ View | 📄 Report

   **Row 2 (Moderate):**
   - #INC-1246
   - "30/11/2025 16:20"
   - "Quận 7, TP.HCM"
   - "Rắn Lục Đuôi Đỏ (Pit Viper)"
   - "Moderate" amber badge
   - "18 min" amber
   - "Completed ✓"
   - Icons

   **Row 3 (Minor):**
   - #INC-1245
   - "30/11/2025 14:10"
   - "Huyện Nhà Bè, TP.HCM"
   - "Rắn Ráo Trâu (Rat Snake)"
   - "Minor" green badge
   - "22 min" red
   - "Completed ✓"
   - Icons

7. **Pagination & Export:**
   - "Showing 1-20 of 1,247 incidents"
   - Page controls
   - "Export Current View" (CSV/Excel/PDF)
   - "Export Full Dataset" button

**Stitch Prompt (English):**

```
Detailed incident analysis and reporting screen.

PAGE HEADER:
- "Incident Analysis & Reports" (28pt bold)
- "Comprehensive snakebite incident data analysis" (14pt gray)
- Date range picker: "01/11/2025" to "30/11/2025" (two inputs with calendar icons)
- "Export Report" button (blue filled, 44px, right)

FILTER PANEL (white card, rounded, collapsible):

"Advanced Filters" header (18pt bold) + collapse arrow

ROW 1:
- Search input (300px): "Search by incident ID, location..." + magnifying glass

ROW 2 (filter chips, horizontal):
- "Severity:" label + chips:
  * "All" (blue selected)
  * "Minor" (gray)
  * "Moderate"
  * "Critical"
  * "Fatal"
- "Snake Species:" + "All ▼" dropdown (multi-select)
- "Region:" + "All Regions ▼"
- "Status:" + "All ▼"
- "Time:" + "All Day ▼"

ROW 3:
- "Apply Filters" button (blue filled, 40px)
- "Clear All" link (blue text, right)

SUMMARY CARDS (4 mini cards, horizontal):

CARD 1: "Total Incidents" | "1,247" (32pt bold blue)
CARD 2: "Critical Cases" | "156" (32pt red) | "(12.5%)"
CARD 3: "Avg Response" | "14.2 min" (32pt green)
CARD 4: "Completion Rate" | "94%" (32pt green)

CHARTS SECTION (three-column):

COLUMN 1 (33%, white card):
"By Severity" header (18pt bold)

DONUT CHART (300px diameter):
- Center: "1,247" (24pt bold) + "Total" (12pt gray)
- Green segment: 45% (Minor, 567)
- Amber segment: 34% (Moderate, 421)
- Red segment: 12% (Critical, 156)
- Dark red segment: 0.2% (Fatal, 3)
- Gray segment: 8% (Unknown, 100)

LEGEND (below chart):
● Green "Minor" | 567 (45%)
● Amber "Moderate" | 421 (34%)
● Red "Critical" | 156 (12%)
● Dark Red "Fatal" | 3 (0.2%)
● Gray "Unknown" | 100 (8%)

COLUMN 2 (33%, white card):
"By Time of Day" header (18pt bold)

BAR CHART (300x250px):
- X-axis: Time slots (0-2, 2-4, 4-6, 6-8, ..., 22-24)
- Y-axis: Incidents (0-100)
- Blue bars:
  * 6-8: 87 (tallest, highlighted)
  * 17-19: 94 (highlighted)
  * Other hours: 20-50 range
- Peak hours label: "Peak: 6-8 AM, 5-7 PM"

COLUMN 3 (33%, white card):
"Species Breakdown (6 Months)" header

STACKED BAR CHART (300x250px):
- X-axis: Jun | Jul | Aug | Sep | Oct | Nov
- Y-axis: 0-150
- Stacked bars (November example):
  * Red (Cobra): 40
  * Orange (Pit Viper): 25
  * Green (Rat Snake): 30
  * Purple (Krait): 15
  * Gray (Other): 20
- Legend: [colors] Cobra | Pit Viper | Rat Snake | Krait | Other

INCIDENT TABLE (full width, white card):

"Detailed Incident List (1,247)" header (20pt bold) + filter icon

TABLE HEADER (light gray background):
- "Incident ID" sortable ↕️ (120px)
- "Date/Time" ↕️ (150px)
- "Location" ↕️ (200px)
- "Snake Species" (180px)
- "Severity" ↕️ (100px)
- "Response Time" ↕️ (120px)
- "Status" (100px)
- "Actions" (80px)

ROW 1 (hover: light blue background):
- "#INC-1247" (blue monospace link)
- "30/11/2025 18:45" (14pt)
- "Quận 1, TP.HCM" + 📍 map icon (clickable)
- "Rắn Hổ Mang (Cobra)" (14pt)
- "Critical" badge (red background, white text)
- "11 min" (green bold)
- "Completed ✓" (green badge)
- Icons: 👁️ View | 📄 Report

ROW 2:
- "#INC-1246"
- "30/11/2025 16:20"
- "Quận 7, TP.HCM" + 📍
- "Rắn Lục Đuôi Đỏ (Pit Viper)"
- "Moderate" amber badge
- "18 min" amber
- "Completed ✓" green
- Icons

ROW 3:
- "#INC-1245"
- "30/11/2025 14:10"
- "Huyện Nhà Bè, TP.HCM" + 📍
- "Rắn Ráo Trâu (Rat Snake)"
- "Minor" green badge
- "22 min" red (over target)
- "Completed ✓"
- Icons

[Rows 4-20...]

PAGINATION (bottom):
- "Showing 1-20 of 1,247 incidents" (left, 14pt gray)
- Page controls: ‹ 1 [2] 3 ... 63 › (center)
- "Rows per page: 20" dropdown (right)
- "Export Current View" button (gray outlined)
- "Export Full Dataset" button (blue outlined)

DESIGN: Advanced filtering, multi-chart analysis, comprehensive incident table, drill-down capabilities, multiple export formats.
```

---

### Screen 3: Performance Metrics (Rescuers & Experts)

**Screen Purpose:**  
Track and analyze performance metrics for rescuers and experts including response times, success rates, ratings, and revenue.

**Navigation:**
- Entry: Click "Performance" from Analytics menu
- Exit: Back to Analytics Dashboard

**Key Components:**

1. **Page Header:**
   - Title: "Performance Metrics"
   - Tab selector: "Rescuers" ACTIVE | "Experts"
   - Date range: "Last 30 days"
   - "Export Performance Report" button

2. **RESCUER TAB:**

   **Overall Metrics (Top Row, 4 cards):**
   - Total Rescuers: 45 (8 active now)
   - Total Rescues: 1,173
   - Avg Response: 14.2 min
   - Success Rate: 92.5%

   **Performance Distribution Charts:**

   **Response Time Distribution (Histogram):**
   - X-axis: Response time ranges (<10 min, 10-15, 15-20, 20-25, >25)
   - Y-axis: Number of rescues
   - Bars:
     * <10 min: 234 (green)
     * 10-15 min: 487 (green)
     * 15-20 min: 312 (amber)
     * 20-25 min: 98 (red)
     * >25 min: 42 (red)
   - Target line at 15 minutes

   **Success Rate by Snake Type (Bar Chart):**
   - Cobra: 88% (red bar)
   - Pit Viper: 94% (orange)
   - Rat Snake: 98% (green)
   - Krait: 85% (red)
   - King Cobra: 79% (dark red)

   **Top Performers Table:**
   - Columns: Rank | Avatar | Name | Team | Rescues | Avg Time | Success % | Rating | Revenue
   
   **Row 1 (Gold medal):**
   - 🥇 1
   - Avatar (48px)
   - "Nguyễn Văn A"
   - "Đội SG Rescue"
   - 87 rescues
   - 11.2 min (green)
   - 96% (green)
   - 4.9/5 ⭐⭐⭐⭐⭐
   - 18.5M VNĐ
   - "View Profile" link

   **Row 2 (Silver):**
   - 🥈 2
   - Avatar
   - "Trần Thị B"
   - "Đội HN Rescue"
   - 76
   - 12.8 min
   - 94%
   - 4.8/5 ⭐
   - 16.2M

   **Row 3 (Bronze):**
   - 🥉 3
   - Avatar
   - "Lê Văn C"
   - "Đội DN Rescue"
   - 68
   - 13.5 min
   - 93%
   - 4.7/5
   - 14.8M

   [Rows 4-10...]

   **Performance Trends (Line Chart):**
   - Multi-line showing last 6 months
   - Lines: Avg Response Time | Success Rate | Rescues per Month
   - Trend analysis: "Response time improving by 5%/month"

3. **EXPERT TAB (when switched):**

   **Overall Metrics:**
   - Total Experts: 12 (6 available now)
   - Total Consultations: 456
   - Avg Rating: 4.8/5
   - Total Revenue: 34.2M VNĐ

   **Consultation Distribution (Pie Chart):**
   - Patient Direct: 65% (blue)
   - Rescuer Request: 30% (orange)
   - AI Verification: 5% (green)

   **Top Experts Table:**
   - Rank | Avatar | Name | Specialization | Consultations | Avg Duration | Rating | Revenue
   - Similar format to rescuer table

4. **Comparison & Benchmarking:**
   - Regional comparison selector
   - Benchmark against platform averages
   - Goal tracking (set targets)

**Stitch Prompt (English):**

```
Performance metrics tracking for rescuers and experts.

PAGE HEADER:
- "Performance Metrics" (28pt bold)
- Tab selector (horizontal):
  * "Rescuers" tab (ACTIVE, blue underline)
  * "Experts" tab (gray)
- Date range: "Last 30 days" dropdown (right)
- "Export Performance Report" button (blue outlined, right)

[RESCUER TAB CONTENT]

METRICS CARDS (4 cards, horizontal):

CARD 1:
- "Total Rescuers" label (14pt gray)
- "45" (36pt bold blue)
- "8 active now" (14pt) + green dot 🟢

CARD 2:
- "Total Rescues"
- "1,173" (36pt bold)
- "+12% vs last month" green ↑

CARD 3:
- "Avg Response Time"
- "14.2 min" (36pt bold green)
- "Target: 15 min ✓"

CARD 4:
- "Success Rate"
- "92.5%" (36pt bold green)
- "Target: 90% ✓"

CHARTS SECTION (two-column):

LEFT (50%, white card):
"Response Time Distribution" header (18pt bold)

HISTOGRAM (600x300px):
- X-axis: Time ranges
- Y-axis: Number of rescues (0-500)
- Bars:
  * "<10 min": 234 (green bar)
  * "10-15 min": 487 (green, tallest)
  * "15-20 min": 312 (amber)
  * "20-25 min": 98 (red)
  * ">25 min": 42 (red)
- Target line (red dashed) at 15 min mark
- Label: "Target: 15 minutes"

RIGHT (50%, white card):
"Success Rate by Snake Type" header

HORIZONTAL BAR CHART (600x300px):
BAR 1: "Rat Snake" | Green bar 98% | "98%" label
BAR 2: "Pit Viper" | Orange bar 94% | "94%"
BAR 3: "Cobra" | Red bar 88% | "88%"
BAR 4: "Krait" | Red bar 85% | "85%"
BAR 5: "King Cobra" | Dark red 79% | "79%"

TOP PERFORMERS TABLE (full width, white card):

"Top Performing Rescuers" header (20pt bold) + trophy icon 🏆

TABLE HEADER:
- "Rank" (60px)
- "Avatar" (80px)
- "Name" (180px)
- "Team" (150px)
- "Rescues" sortable ↕️ (100px)
- "Avg Time" ↕️ (100px)
- "Success %" ↕️ (100px)
- "Rating" ↕️ (100px)
- "Revenue" ↕️ (120px)
- "Actions" (80px)

ROW 1 (gold background highlight):
- 🥇 "1" (gold medal icon)
- Avatar image (48px circle)
- "Nguyễn Văn A" (16pt bold)
- "Đội SG Rescue" (14pt)
- "87" (bold)
- "11.2 min" (green bold)
- "96%" (green bold)
- "4.9/5" + ⭐⭐⭐⭐⭐
- "18.5M VNĐ" (green)
- "View Profile" link (blue)

ROW 2 (silver background):
- 🥈 "2" (silver medal)
- Avatar
- "Trần Thị B"
- "Đội HN Rescue"
- "76"
- "12.8 min" green
- "94%" green
- "4.8/5" ⭐⭐⭐⭐⭐
- "16.2M"
- Link

ROW 3 (bronze background):
- 🥉 "3" (bronze medal)
- Avatar
- "Lê Văn C"
- "Đội DN Rescue"
- "68"
- "13.5 min" green
- "93%" green
- "4.7/5" ⭐
- "14.8M"
- Link

ROWS 4-10: (white background, no medals)
[Similar format, decreasing performance metrics]

PERFORMANCE TRENDS (full width, white card):

"Performance Trends - Last 6 Months" header (20pt bold)

MULTI-LINE CHART (1200x400px):
- X-axis: Jun | Jul | Aug | Sep | Oct | Nov
- Y-axis (left): Response time (10-18 min)
- Y-axis (right): Success rate (85-100%)
- Blue line: "Avg Response Time" (decreasing trend 16→14.2)
- Green line: "Success Rate" (steady around 92-94%)
- Orange bars (background): "Rescues per Month" (bars showing 180, 195, 210, etc.)

TREND INSIGHT BOX (below chart, green background):
📈 "Trend Analysis: Response time improving by 5% per month. Success rate stable above 90% target."

DESIGN: Comprehensive performance tracking, leaderboard system, multi-metric analysis, trend visualization, benchmarking.
```

---

### Screen 4: Custom Report Builder & Export

**Screen Purpose:**  
Flexible report builder allowing admin to create custom reports with selected metrics, filters, visualizations, and export in multiple formats.

**Navigation:**
- Entry: Click "Create Report" from Analytics menu, or "Export" buttons
- Exit: Save report template or download export

**Key Components:**

1. **Page Header:**
   - Title: "Custom Report Builder"
   - "Load Template" dropdown (saved reports)
   - "Save as Template" button
   - "Generate Report" button (blue, large)

2. **Report Configuration Panel (Left Sidebar, 30%):**

   **Step 1: Report Type**
   - Radio buttons:
     * ○ Incident Analysis Report
     * ○ Performance Summary Report
     * ○ Financial Report
     * ○ Custom Dashboard Report

   **Step 2: Date Range**
   - Preset: Last 7 days | 30 days | 90 days | This Year
   - Custom: Start Date | End Date pickers
   - Compare to previous period (checkbox)

   **Step 3: Data Sources (checkboxes)**
   - ☑ Incidents
   - ☑ Rescue Operations
   - ☑ Expert Consultations
   - ☐ User Activity
   - ☐ Financial Transactions
   - ☐ Snake Database Updates

   **Step 4: Metrics to Include (multi-select)**
   - Checkboxes with categories:
     * **Volume Metrics:**
       ☑ Total incidents count
       ☑ Active rescues
       ☑ Consultations
     * **Performance Metrics:**
       ☑ Response time (avg, min, max)
       ☑ Success rate
       ☑ Completion rate
     * **Quality Metrics:**
       ☑ User ratings
       ☑ Expert ratings
       ☐ AI accuracy
     * **Financial:**
       ☐ Revenue by service
       ☐ Commission breakdown

   **Step 5: Filters**
   - Region: Multi-select provinces
   - Severity: All | Minor | Moderate | Critical
   - Snake Species: Multi-select
   - User Roles: Patient | Rescuer | Expert

   **Step 6: Visualizations**
   - Chart types (checkboxes):
     ☑ Line charts (trends)
     ☑ Bar charts (comparisons)
     ☑ Pie charts (distributions)
     ☑ Heat maps (geographic)
     ☐ Scatter plots (correlations)
     ☐ Funnel charts (conversions)

   **Step 7: Export Format**
   - Radio buttons:
     * ○ PDF Report (formatted)
     * ○ Excel Spreadsheet (.xlsx)
     * ○ CSV Data (.csv)
     * ○ PowerPoint Presentation (.pptx)
   
   - Include options (checkboxes):
     ☑ Executive summary
     ☑ Detailed tables
     ☑ Chart images
     ☑ Raw data sheet

3. **Report Preview Panel (Right, 70%):**

   **Preview Header:**
   - "Report Preview" title
   - "Refresh Preview" button
   - "Full Screen" button

   **Dynamic Preview:**
   - Shows report as it will be exported
   - Scrollable preview of:
     * Cover page (with logo, title, date range)
     * Executive summary section
     * Charts and visualizations
     * Data tables
     * Footer with metadata

   **Example Preview Content:**

   **Cover Page:**
   - SnakeAid Logo
   - "Incident Analysis Report"
   - "November 1-30, 2025"
   - "Generated: December 13, 2025"
   - "Prepared by: Admin User"

   **Page 1: Executive Summary**
   - Key highlights in bullet points
   - "1,247 total incidents (+12.5% vs Oct)"
   - "94% completion rate"
   - "14.2 min avg response time"

   **Page 2: Incident Trends Chart**
   - Full-page line chart

   **Page 3: Regional Breakdown Table**
   - Data table with statistics

   **Page 4: Snake Species Analysis**
   - Bar chart and pie chart

4. **Saved Templates Section (Bottom):**
   - "My Saved Templates" header
   - Template cards:
     * "Monthly Performance Report" - Last used: 01/12/2025
     * "Quarterly Analysis" - Last used: 01/10/2025
     * "Weekly Summary" - Last used: 06/12/2025
   - Each card: Load button | Edit | Delete

5. **Schedule Report (Optional Panel):**
   - "Schedule Automatic Reports" toggle
   - Frequency: Daily | Weekly | Monthly
   - Send to: Email addresses (multi-input)
   - Time: Dropdown (00:00 - 23:00)
   - "Save Schedule" button

**Stitch Prompt (English):**

```
Custom report builder with preview and export options.

PAGE HEADER:
- "Custom Report Builder" (28pt bold)
- "Load Template" dropdown (180px, gray, right)
- "Save as Template" button (blue outlined, right)
- "Generate Report" button (blue filled, 48px height, bold, right)

LAYOUT (two-column):

LEFT SIDEBAR (30%, white card, scrollable):

"Report Configuration" header (20pt bold)

STEP 1: "Report Type" (16pt bold)
Radio buttons (large):
● "Incident Analysis Report" (selected, blue)
○ "Performance Summary Report"
○ "Financial Report"
○ "Custom Dashboard Report"

STEP 2: "Date Range" (16pt bold)
- Preset chips (horizontal):
  "Last 7 days" | "30 days" | "90 days" (selected blue) | "This Year"
- Custom range:
  * "Start Date:" picker showing "01/11/2025"
  * "End Date:" picker showing "30/11/2025"
- ☑ "Compare to previous period" checkbox

STEP 3: "Data Sources" (16pt bold)
Checkboxes:
☑ "Incidents"
☑ "Rescue Operations"
☑ "Expert Consultations"
☐ "User Activity"
☐ "Financial Transactions"
☐ "Snake Database Updates"

STEP 4: "Metrics to Include" (16pt bold)
Expandable sections:

"Volume Metrics" (expanded):
☑ "Total incidents count"
☑ "Active rescues"
☑ "Consultations"

"Performance Metrics" (expanded):
☑ "Response time (avg, min, max)"
☑ "Success rate"
☑ "Completion rate"

"Quality Metrics" (collapsed):
☑ "User ratings"
☑ "Expert ratings"
☐ "AI accuracy"

STEP 5: "Filters" (16pt bold)
- "Region:" multi-select chips
  "TP.HCM ×" "Hà Nội ×" "+ Add"
- "Severity:" dropdown "All"
- "Snake Species:" multi-select
- "User Roles:" checkboxes

STEP 6: "Visualizations" (16pt bold)
☑ "Line charts (trends)"
☑ "Bar charts (comparisons)"
☑ "Pie charts (distributions)"
☑ "Heat maps (geographic)"
☐ "Scatter plots (correlations)"
☐ "Funnel charts"

STEP 7: "Export Format" (16pt bold)
● "PDF Report (formatted)" (selected)
○ "Excel Spreadsheet (.xlsx)"
○ "CSV Data (.csv)"
○ "PowerPoint (.pptx)"

Include:
☑ "Executive summary"
☑ "Detailed tables"
☑ "Chart images"
☑ "Raw data sheet"

RIGHT PANEL (70%):

"Report Preview" header (20pt bold) + icons: 🔄 Refresh | ⛶ Full Screen

PREVIEW WINDOW (white background, document format, scrollable):

PAGE 1 (Cover):
- SnakeAid logo (top-center, 120px)
- "Incident Analysis Report" (32pt bold, center)
- "November 1-30, 2025" (20pt, center)
- "Generated: December 13, 2025" (14pt gray)
- "Prepared by: Admin User"

PAGE 2 (Executive Summary):
- "Executive Summary" header (24pt bold)
- Bullet points:
  • "1,247 total incidents (+12.5% vs October)"
  • "94% completion rate (target: 95%)"
  • "14.2 min avg response time (below 15 min target)"
  • "156 critical cases (12.5% of total)"
- Small KPI cards showing key numbers

PAGE 3 (Chart):
- "Incident Trends - November 2025" header
- Full-page line chart image (placeholder)
- Caption: "Figure 1: Daily incident trends showing peak activity..."

PAGE 4 (Table):
- "Regional Breakdown" header
- Data table with regions, counts, percentages
- Footer: "Table 1: Incident distribution by region"

PAGE 5 (Charts):
- Two charts side-by-side:
  * Pie chart: Snake species distribution
  * Bar chart: Response times by region

[Additional pages...]

BOTTOM SECTION (full width):

"My Saved Templates" header (18pt bold)

TEMPLATE CARDS (3 cards, horizontal):

CARD 1:
- "Monthly Performance Report" (16pt bold)
- "Includes: Incidents, Rescues, Performance"
- "Last used: 01/12/2025" (12pt gray)
- Buttons: "Load" blue | "Edit" | "Delete" red

CARD 2:
- "Quarterly Analysis"
- "Includes: All metrics, Financial"
- "Last used: 01/10/2025"
- Buttons

CARD 3:
- "Weekly Summary"
- "Includes: Incidents, Quick stats"
- "Last used: 06/12/2025"
- Buttons

SCHEDULE SECTION (collapsible, light blue background):

"Schedule Automatic Reports" toggle (OFF)

IF TOGGLE ON:
- "Frequency:" dropdown "Weekly ▼"
- "Send to:" email chips "admin@example.com ×" "+ Add"
- "Time:" dropdown "09:00 ▼"
- "Save Schedule" button (blue)

DESIGN: Flexible report builder, step-by-step configuration, live preview, template system, multiple export formats, scheduling capability.
```

---

## Integration Points

### API Endpoints:
- `GET /api/admin/analytics/dashboard?dateRange=` - Get dashboard KPIs and charts
- `GET /api/admin/analytics/incidents?filter=&sort=&page=` - Get incident data
- `GET /api/admin/analytics/performance/rescuers` - Get rescuer performance metrics
- `GET /api/admin/analytics/performance/experts` - Get expert performance metrics
- `GET /api/admin/analytics/trends?metric=&period=` - Get trend data
- `GET /api/admin/analytics/regional?region=` - Get regional statistics
- `POST /api/admin/reports/generate` - Generate custom report
- `POST /api/admin/reports/export` - Export report to file
- `GET /api/admin/reports/templates` - Get saved report templates
- `POST /api/admin/reports/templates` - Save new template
- `POST /api/admin/reports/schedule` - Schedule recurring report
- `GET /api/admin/analytics/realtime` - WebSocket for real-time updates

### Chart Libraries:
- Chart.js or D3.js for interactive visualizations
- Plotly for advanced scientific charts
- Google Charts for heat maps
- Export libraries: jsPDF, ExcelJS, pptxgenjs

### Performance Optimization:
- Data aggregation for large datasets
- Caching frequently accessed metrics (5-minute cache)
- Lazy loading for charts and tables
- Progressive data loading (load visible data first)
- WebSocket for real-time dashboard updates

### Export Features:
- PDF: Multi-page formatted reports with charts as images
- Excel: Multiple sheets with raw data + pivot tables
- CSV: Flat file export for data analysis tools
- PowerPoint: Slide deck with charts and summary tables
- Scheduled exports via email

---

## Version History
- **v1.0** - December 13, 2025: Initial analytics and reporting screens design (4 screens)

---

## Design Review Checklist
- [x] Comprehensive analytics dashboard with real-time KPIs
- [x] Detailed incident analysis with advanced filtering
- [x] Performance metrics for rescuers and experts
- [x] Custom report builder with flexible configuration
- [x] Multiple chart types (line, bar, pie, donut, heat map)
- [x] Export functionality (PDF, Excel, CSV, PowerPoint)
- [x] Report template system for reusability
- [x] Scheduled reports with email delivery
- [x] Regional and temporal analysis
- [x] Trend visualization and predictive insights

---

*This document is part of the SnakeAid Platform UI Design Documentation*  
*Related Documents: Admin-Dashboard-Screens.md, Admin-User-Management-Screens.md, Admin-Snake-Database-Screens.md, Admin-Hospital-Management-Screens.md*
