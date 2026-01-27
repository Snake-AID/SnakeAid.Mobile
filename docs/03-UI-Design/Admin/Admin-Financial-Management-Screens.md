# ADMIN - FINANCIAL MANAGEMENT SCREENS

## Module Information
- **Module:** Admin Financial Management (Web Application)
- **Total Screens:** 4 screens
- **Related Features:** FE-30 to FE-35 from Major Features Summary
- **Purpose:** Comprehensive financial management including revenue tracking, transaction processing, fee management, dispute resolution, and financial reporting

---

## Flow Context

The Financial Management module provides admin with complete oversight of all platform financial operations. This includes managing service fees, tracking revenue streams, processing transactions between patients, rescuers, experts, and the platform, handling payment disputes, processing refunds, and generating comprehensive financial reports.

**Key Functions:**
- Set and manage service fee rates for rescues and consultations
- Track total revenue and distribute income to service providers
- Process payments between all parties (patient → platform → rescuer/expert)
- Monitor transaction status and payment methods
- Handle payment disputes and arbitration
- Process refund requests with approval workflow
- Manage platform commission and revenue share
- Generate financial reports (daily, monthly, quarterly, yearly)
- Track pending payments and overdue transactions
- Export financial data for accounting systems

**Related Requirements:**
- FE-30: Set fee rates for rescue services and expert consultation
- FE-31: Track total revenue and distribute income to rescuers/experts
- FE-32: Manage payments between patients – rescuers/experts – platform
- FE-33: Create periodic financial reports (monthly/quarterly/yearly)
- FE-34: Manage platform commission and refund policies
- FE-35: Handle payment disputes and refund requests

---

## Design System

### Color Palette (Admin Portal):
- **Primary Blue:** `#007BFF` (Admin branding, primary actions)
- **Dark Navy:** `#1E3A8A` (Sidebar, headers, professional tone)
- **Success Green:** `#28A745` (Completed payments, revenue positive)
- **Warning Amber:** `#FFC107` (Pending transactions, disputes)
- **Danger Red:** `#DC3545` (Failed payments, refunds, critical alerts)
- **Info Cyan:** `#17A2B8` (Informational elements)
- **Purple:** `#6B46C1` (Expert revenue)
- **Orange:** `#FD7E14` (Rescuer revenue)
- **Light Gray:** `#F8F9FA` (Backgrounds, cards)
- **White:** `#FFFFFF` (Card backgrounds, main content)

### Financial Status Colors:
- **Completed:** Green `#28A745`
- **Pending:** Amber `#FFC107`
- **Processing:** Cyan `#17A2B8`
- **Failed:** Red `#DC3545`
- **Refunded:** Purple `#6B46C1`
- **Disputed:** Orange `#FD7E14`

### Typography (Web):
- **Page Title:** 28pt Bold
- **Section Headers:** 20pt Semi-bold
- **Card Titles:** 18pt Semi-bold
- **Body Text:** 14pt Regular
- **Small Labels:** 12pt Regular
- **Money Amounts:** 36-48pt Bold (for large sums), 18pt Bold (for regular amounts)

---

## Screen Designs

### Screen 1: Financial Dashboard (Overview)

**Screen Purpose:**  
Comprehensive financial dashboard displaying key revenue metrics, transaction volumes, payment status, and financial trends across all platform services.

**Navigation:**
- Entry: Click "Financial" from Admin sidebar
- Exit: To any admin section or drill down to detailed views

**Key Components:**

1. **Page Header:**
   - Title: "Financial Dashboard"
   - Date range selector: "This Month" (dropdown: Today | This Week | This Month | This Quarter | This Year | Custom)
   - Currency: "VNĐ" (dropdown for multi-currency support)
   - "Export Financial Report" button (blue outlined)
   - Last updated: "Real-time" (live indicator 🔴)

2. **Revenue Summary Cards (Top Row, 4 cards):**

   **Card 1: Total Revenue**
   - Icon: 💰 Money bag
   - "Total Revenue" label
   - "124.5M VNĐ" (48pt bold green)
   - "+18.7% vs last month" (green arrow ↑)
   - Sparkline: 30-day revenue trend (upward)
   - Breakdown link: "View Details →"

   **Card 2: Platform Commission**
   - Icon: 🏢 Building
   - "Platform Commission"
   - "18.7M VNĐ" (48pt bold blue)
   - "15% of total revenue"
   - Commission rate badge: "15%"

   **Card 3: Paid to Service Providers**
   - Icon: 👥 People
   - "Paid to Providers"
   - "105.8M VNĐ" (48pt bold green)
   - "Rescuers: 71.2M | Experts: 34.6M"
   - Payment status: "All current ✓"

   **Card 4: Pending Payouts**
   - Icon: ⏳ Hourglass
   - "Pending Payouts"
   - "12.3M VNĐ" (48pt bold amber)
   - "87 transactions pending"
   - "Process Payouts" button (amber)

3. **Revenue Breakdown (Left, 50% width):**
   
   **By Service Type (Donut Chart):**
   - Center: "124.5M Total"
   - Segments:
     * Orange: Rescue Services (71.2M, 57%)
     * Purple: Expert Consultations (34.6M, 28%)
     * Cyan: AI Verification Fees (12.5M, 10%)
     * Blue: Subscription/Premium (6.2M, 5%)
   - Legend with amounts and percentages
   - Hover: Show detailed breakdown

   **Revenue Trend (Line Chart below):**
   - Last 12 months
   - Blue line: Total revenue
   - Orange line: Rescue revenue
   - Purple line: Consultation revenue
   - Y-axis: VNĐ (millions)
   - X-axis: Months (Dec 2024 - Nov 2025)

4. **Transaction Statistics (Right, 50% width):**

   **Transaction Volume Card:**
   - "Total Transactions: 3,456" (24pt bold)
   - "This Month"
   - Breakdown:
     * Completed: 3,234 (94%) - green badge
     * Pending: 87 (2.5%) - amber badge
     * Failed: 98 (3%) - red badge
     * Disputed: 37 (1%) - orange badge
   - Avg transaction value: "36,000 VNĐ"

   **Payment Methods (Bar Chart):**
   - Horizontal bars:
     * Credit/Debit Card: 1,876 (54%)
     * E-Wallet (Momo, ZaloPay): 1,234 (36%)
     * Bank Transfer: 289 (8%)
     * Cash: 57 (2%)
   - Color-coded bars

5. **Top Revenue Generators (Bottom Row):**

   **Top Rescuers (Left Table):**
   - Title: "Top 10 Rescuers by Revenue"
   - Columns: Rank | Name | Rescues | Revenue | Commission
   - Row 1: 🥇 1 | Nguyễn Văn A | 87 | 18.5M | 2.8M
   - Row 2: 🥈 2 | Trần Thị B | 76 | 16.2M | 2.4M
   - Row 3: 🥉 3 | Lê Văn C | 68 | 14.8M | 2.2M
   - [Rows 4-10...]

   **Top Experts (Right Table):**
   - Title: "Top 10 Experts by Revenue"
   - Columns: Rank | Name | Consultations | Revenue | Commission
   - Row 1: 🥇 1 | Dr. Nguyễn X | 156 | 12.5M | 1.9M
   - Row 2: 🥈 2 | Dr. Trần Y | 134 | 10.8M | 1.6M
   - Row 3: 🥉 3 | Dr. Lê Z | 98 | 8.2M | 1.2M
   - [Rows 4-10...]

6. **Recent Financial Activity (Right Sidebar):**
   - "Recent Activity" header
   - Last 10 transactions (scrollable):
     * "2 min ago: Payment #TXN-45678 completed - 675K"
     * "8 min ago: Refund #REF-123 processed - 450K"
     * "15 min ago: Dispute #DSP-89 opened - 1.2M"
     * [etc...]

7. **Alerts & Notifications:**
   - "⚠️ 5 disputes require attention"
   - "💰 87 pending payouts ready for processing"
   - "📊 Monthly report ready for review"

**Stitch Prompt (English):**

```
Financial dashboard with revenue metrics and transaction analytics.

PAGE HEADER:
- "Financial Dashboard" (28pt bold dark navy)
- Date range selector: "This Month" dropdown (180px, blue border)
- Currency: "VNĐ" dropdown (80px)
- "Export Financial Report" button (blue outlined, 40px, right)
- "Last updated: Real-time" (12pt gray) + 🔴 live indicator pulsing

REVENUE CARDS ROW (4 cards, equal width, white rounded shadow):

CARD 1:
- 💰 Money icon (48px, green)
- "Total Revenue" label (14pt gray)
- "124.5M VNĐ" (48pt bold green)
- "+18.7% vs last month" (14pt green) + ↑ arrow
- Sparkline chart (100px wide, 30px high, green line upward trend)
- "View Details →" link (blue, 12pt)

CARD 2:
- 🏢 Building icon (48px, blue)
- "Platform Commission"
- "18.7M VNĐ" (48pt bold blue)
- "15% of total revenue" (14pt gray)
- "Commission Rate: 15%" badge (blue background)

CARD 3:
- 👥 People icon (48px, green)
- "Paid to Providers"
- "105.8M VNĐ" (48pt bold green)
- "Rescuers: 71.2M | Experts: 34.6M" (14pt gray)
- "All current ✓" green badge

CARD 4:
- ⏳ Hourglass icon (48px, amber)
- "Pending Payouts"
- "12.3M VNĐ" (48pt bold amber)
- "87 transactions pending" (14pt gray)
- "Process Payouts" button (amber filled, 40px)

MAIN CONTENT (two-column):

LEFT (50%, white card):
"Revenue Breakdown" header (20pt bold)

DONUT CHART (400px diameter):
- Center: "124.5M" (32pt bold) + "Total" (14pt gray)
- Orange segment: 57% (Rescue Services)
- Purple segment: 28% (Expert Consultations)
- Cyan segment: 10% (AI Verification)
- Blue segment: 5% (Premium Features)

LEGEND (below chart):
● Orange "Rescue Services" | 71.2M (57%)
● Purple "Expert Consultations" | 34.6M (28%)
● Cyan "AI Verification Fees" | 12.5M (10%)
● Blue "Premium Features" | 6.2M (5%)

LINE CHART "Revenue Trend - Last 12 Months" (600x300px):
- X-axis: Dec 2024 | Jan | Feb | ... | Nov 2025
- Y-axis: Revenue (millions VNĐ, 0-30M)
- Blue line: "Total Revenue" (trend 15M → 24M)
- Orange line: "Rescue Revenue" (10M → 14M)
- Purple line: "Consultation Revenue" (5M → 10M)
- Grid lines (light gray, dashed)
- Legend top-right

RIGHT (50%):

CARD "Transaction Statistics" (white card):
- "Total Transactions: 3,456" (24pt bold blue)
- "This Month" (14pt gray)

BREAKDOWN LIST:
✓ "Completed: 3,234 (94%)" green badge + green bar (94% width)
⏳ "Pending: 87 (2.5%)" amber badge + amber bar
✗ "Failed: 98 (3%)" red badge + red bar
⚠️ "Disputed: 37 (1%)" orange badge + orange bar

- "Avg Transaction Value: 36,000 VNĐ" (18pt bold)

CARD "Payment Methods" (white card, below):
- "Payment Methods Distribution" header (18pt bold)

HORIZONTAL BAR CHART:
BAR 1: "Credit/Debit Card" | Blue bar 54% | "1,876 (54%)" label
BAR 2: "E-Wallet (Momo, ZaloPay)" | Green bar 36% | "1,234 (36%)"
BAR 3: "Bank Transfer" | Orange bar 8% | "289 (8%)"
BAR 4: "Cash" | Gray bar 2% | "57 (2%)"

TOP REVENUE GENERATORS (full width, two tables side-by-side):

LEFT TABLE (50%):
"Top 10 Rescuers by Revenue" header (18pt bold) + 🏆 trophy

TABLE HEADER: Rank | Name | Rescues | Revenue | Commission
ROW 1: 🥇 "1" gold | "Nguyễn Văn A" bold | "87" | "18.5M" green bold | "2.8M" blue
ROW 2: 🥈 "2" silver | "Trần Thị B" | "76" | "16.2M" | "2.4M"
ROW 3: 🥉 "3" bronze | "Lê Văn C" | "68" | "14.8M" | "2.2M"
[Rows 4-10 without medals]

RIGHT TABLE (50%):
"Top 10 Experts by Revenue" header + 🏆

TABLE HEADER: Rank | Name | Consultations | Revenue | Commission
ROW 1: 🥇 "1" | "Dr. Nguyễn X" bold | "156" | "12.5M" green | "1.9M" blue
ROW 2: 🥈 "2" | "Dr. Trần Y" | "134" | "10.8M" | "1.6M"
ROW 3: 🥉 "3" | "Dr. Lê Z" | "98" | "8.2M" | "1.2M"
[Rows 4-10]

RIGHT SIDEBAR (300px, scrollable):

"Recent Activity" header (18pt bold) + 🔴 "LIVE"

ACTIVITY FEED:
ITEM 1: "2 min ago" gray | "Payment #TXN-45678 completed - 675K" + green dot
ITEM 2: "8 min ago" | "Refund #REF-123 processed - 450K" + purple dot
ITEM 3: "15 min ago" | "Dispute #DSP-89 opened - 1.2M" + orange dot
[10 items total]

ALERTS SECTION (amber background cards):
ALERT 1: ⚠️ "5 disputes require attention" + "Review →" link
ALERT 2: 💰 "87 pending payouts ready" + "Process →"
ALERT 3: 📊 "Monthly report ready" + "View →"

DESIGN: Comprehensive financial overview, multi-chart revenue analysis, transaction tracking, top performers leaderboard, real-time activity feed.
```

---

### Screen 2: Transaction Management (Detailed List)

**Screen Purpose:**  
Comprehensive transaction list with advanced filtering, status tracking, and detailed transaction view for all platform payments.

**Navigation:**
- Entry: Click "Transactions" from Financial menu
- Exit: Back to Financial Dashboard or view transaction details

**Key Components:**

1. **Page Header:**
   - Title: "Transaction Management"
   - Total: "3,456 transactions this month"
   - Date range: Custom picker
   - "Export Transactions" button (blue)

2. **Advanced Filter Panel (collapsible):**
   - Search: "Search by transaction ID, user, amount..."
   - Filters:
     * Status: All | Completed | Pending | Processing | Failed | Refunded | Disputed
     * Type: All | Rescue Payment | Consultation Fee | AI Verification | Refund
     * Payment Method: All | Card | E-Wallet | Bank Transfer | Cash
     * Amount Range: Min ____ to Max ____ VNĐ
     * User Role: All | Patient | Rescuer | Expert
     * Date Range: Custom picker
   - "Apply Filters" | "Clear All"

3. **Summary Statistics (4 mini cards):**
   - Total Amount: 124.5M VNĐ
   - Completed: 3,234 (green)
   - Pending: 87 (amber)
   - Disputed: 37 (orange)

4. **Transaction Table (sortable, paginated):**
   - Columns:
     * Transaction ID (sortable)
     * Date/Time
     * From (Patient)
     * To (Rescuer/Expert)
     * Service Type
     * Amount (VNĐ)
     * Platform Fee
     * Payment Method
     * Status (badge)
     * Actions

   **Example Rows:**

   **Row 1 (Completed):**
   - #TXN-045678
   - "13/12/2025 18:45"
   - "Nguyễn Văn A" (Patient avatar + name)
   - "→" arrow
   - "Đội SG Rescue" (Rescuer avatar + name)
   - "Rescue Service" tag
   - "675,000" (18pt bold)
   - "101,250" (15%, gray)
   - Credit Card icon + •••• 1234
   - "Completed ✓" green badge
   - Icons: 👁️ View | 📄 Receipt | 💬 Contact

   **Row 2 (Pending):**
   - #TXN-045677
   - "13/12/2025 17:20"
   - "Trần Thị B" (Patient)
   - "→"
   - "Dr. Nguyễn X" (Expert)
   - "Consultation" tag
   - "450,000"
   - "67,500" (15%)
   - Momo icon
   - "Pending ⏳" amber badge + timer "2h 15m"
   - Icons + "Cancel" button

   **Row 3 (Disputed):**
   - #TXN-045676
   - "13/12/2025 16:10"
   - "Lê Văn C"
   - "→"
   - "Đội HN Rescue"
   - "Rescue Service"
   - "1,200,000"
   - "180,000"
   - Bank Transfer icon
   - "Disputed ⚠️" orange badge
   - Icons + "Resolve" button (orange)

   **Row 4 (Failed):**
   - #TXN-045675
   - "13/12/2025 15:30"
   - "Phạm Thị D"
   - "→"
   - "Dr. Trần Y"
   - "Consultation"
   - "350,000"
   - "52,500"
   - Card icon (failed)
   - "Failed ✗" red badge + "Insufficient funds"
   - Icons + "Retry" button (blue)

5. **Bulk Actions (when rows selected):**
   - "12 transactions selected"
   - "Process Payments" button (green)
   - "Export Selected" button (gray)
   - "Mark as Reviewed" button
   - "Cancel" link

6. **Transaction Detail Modal (when clicking "View"):**
   - Header: "Transaction Details - #TXN-045678"
   - Status: Large badge with icon
   - Timeline:
     * Created: 13/12/2025 18:45
     * Payment Initiated: 18:45
     * Payment Authorized: 18:46
     * Funds Released to Provider: 18:47
     * Completed: 18:47 ✓
   - Parties:
     * Patient: Name, email, phone
     * Provider: Name, type, rating
   - Service Details:
     * Type: Rescue Service
     * Service ID: #RSC-456
     * Date: 13/12/2025
     * Duration: 45 minutes
   - Financial Breakdown:
     * Service Fee: 675,000 VNĐ
     * Platform Commission (15%): 101,250 VNĐ
     * Provider Receives: 573,750 VNĐ
     * Payment Method: Visa •••• 1234
     * Transaction Fee: 10,000 VNĐ
   - Actions:
     * Download Receipt (PDF)
     * Send Email Receipt
     * Initiate Refund
     * Report Issue

7. **Pagination:**
   - "Showing 1-20 of 3,456 transactions"
   - Page controls
   - Export options

**Stitch Prompt (English):**

```
Transaction management screen with detailed list and filtering.

PAGE HEADER:
- "Transaction Management" (28pt bold)
- "3,456 transactions this month" badge (blue, 18pt)
- Date range: "01/12/2025" to "13/12/2025" (pickers)
- "Export Transactions" button (blue outlined, 40px, right)

FILTER PANEL (white card, collapsible):

"Advanced Filters" header (18pt bold) + ▼ collapse arrow

ROW 1:
- Search input (400px): "Search by transaction ID, user, amount..." + 🔍

ROW 2 (filter dropdowns, horizontal):
- "Status:" + "All" dropdown ▼
- "Type:" + "All" dropdown
- "Payment Method:" + "All" dropdown
- "Amount Range:" + Min "____" to Max "____" VNĐ inputs
- "User Role:" + "All" dropdown
- Date range pickers

ROW 3:
- "Apply Filters" button (blue filled, 40px)
- "Clear All" link (blue text, right)

SUMMARY CARDS (4 mini cards):
CARD 1: "Total Amount" | "124.5M VNĐ" (28pt blue)
CARD 2: "Completed" | "3,234" (28pt green)
CARD 3: "Pending" | "87" (28pt amber)
CARD 4: "Disputed" | "37" (28pt orange)

TRANSACTION TABLE (white card, full width):

"All Transactions (3,456)" header (20pt bold) + filter icon

TABLE HEADER (light gray background):
- "Transaction ID" ↕️ sortable (120px)
- "Date/Time" ↕️ (150px)
- "From" (180px)
- "→" (30px)
- "To" (180px)
- "Service" (120px)
- "Amount" ↕️ (120px)
- "Platform Fee" (100px)
- "Payment" (100px)
- "Status" ↕️ (120px)
- "Actions" (150px)

ROW 1 (hover: light blue background):
- "#TXN-045678" (blue monospace link)
- "13/12/2025 18:45" (14pt)
- Avatar 32px + "Nguyễn Văn A" + "Patient" gray text
- "→" arrow (blue)
- Avatar 32px + "Đội SG Rescue" + "Rescuer" orange text
- "Rescue Service" tag (gray rounded)
- "675,000" (18pt bold)
- "101,250" (14pt gray) + "(15%)"
- Credit card icon 💳 + "•••• 1234"
- "Completed ✓" green badge
- Icons: 👁️ View | 📄 Receipt | 💬 Contact

ROW 2:
- "#TXN-045677"
- "13/12/2025 17:20"
- Avatar + "Trần Thị B" + "Patient"
- "→"
- Avatar + "Dr. Nguyễn X" + "Expert" purple
- "Consultation" tag
- "450,000" bold
- "67,500" (15%)
- Momo icon + "Momo Wallet"
- "Pending ⏳" amber badge + "2h 15m" timer
- Icons + "Cancel" button (red outlined)

ROW 3:
- "#TXN-045676"
- "13/12/2025 16:10"
- Avatar + "Lê Văn C" + "Patient"
- "→"
- Avatar + "Đội HN Rescue" + "Rescuer"
- "Rescue Service"
- "1,200,000" bold
- "180,000"
- Bank icon + "Bank Transfer"
- "Disputed ⚠️" orange badge
- Icons + "Resolve" button (orange filled, 36px)

ROW 4:
- "#TXN-045675"
- "13/12/2025 15:30"
- Avatar + "Phạm Thị D" + "Patient"
- "→"
- Avatar + "Dr. Trần Y" + "Expert"
- "Consultation"
- "350,000"
- "52,500"
- Card icon (red X overlay) + "Card Failed"
- "Failed ✗" red badge + "Insufficient funds" (12pt)
- Icons + "Retry" button (blue outlined)

[Rows 5-20...]

BULK ACTIONS BAR (blue background, appears when selected):
- "12 transactions selected" (white text, left)
- "Process Payments" button (green filled, 40px)
- "Export Selected" button (gray outlined, 40px)
- "Mark as Reviewed" button (blue outlined)
- "Cancel" link (white text, right)

TRANSACTION DETAIL MODAL (overlay, 800px width, white):

MODAL HEADER:
- "Transaction Details - #TXN-045678" (24pt bold)
- × Close button (top-right)

STATUS BANNER (green background):
- ✓ Large checkmark icon (64px)
- "Completed" (32pt bold white)
- "13/12/2025 18:47"

TIMELINE SECTION:
"Transaction Timeline" header (18pt bold)

VERTICAL TIMELINE (left line, green):
● "Created" | "13/12/2025 18:45" | ✓ green checkmark
● "Payment Initiated" | "18:45" | ✓
● "Payment Authorized" | "18:46" | ✓
● "Funds Released to Provider" | "18:47" | ✓
● "Completed" | "18:47" | ✓ (bold)

PARTIES SECTION (two columns):
LEFT: "Patient"
- Avatar 64px
- "Nguyễn Văn A" (18pt bold)
- "nguyenvana@email.com"
- "090 123 4567"

RIGHT: "Service Provider"
- Avatar 64px
- "Đội SG Rescue" (18pt bold)
- "Rescuer" badge orange
- "Rating: 4.9/5" ⭐

SERVICE DETAILS:
- "Type:" "Rescue Service"
- "Service ID:" "#RSC-456" (link blue)
- "Date:" "13/12/2025"
- "Duration:" "45 minutes"
- "Location:" "Quận 1, TP.HCM"

FINANCIAL BREAKDOWN (card, light blue background):
"Financial Details" header (18pt bold)

TABLE (key-value):
- "Service Fee:" | "675,000 VNĐ" (right-aligned bold)
- "Platform Commission (15%):" | "- 101,250 VNĐ" (red)
- "Provider Receives:" | "573,750 VNĐ" (green bold)
- Divider line
- "Payment Method:" | Visa icon "•••• 1234"
- "Transaction Fee:" | "10,000 VNĐ"
- "Total Charged:" | "685,000 VNĐ" (bold)

ACTION BUTTONS (bottom):
- "Download Receipt" button (blue outlined, 44px) + PDF icon
- "Send Email Receipt" button (blue outlined)
- "Initiate Refund" button (red outlined)
- "Report Issue" button (gray outlined)

PAGINATION (bottom):
- "Showing 1-20 of 3,456 transactions" (left)
- Page controls: ‹ 1 [2] 3 ... 173 › (center)
- "Export Current View" button (gray outlined, right)

DESIGN: Comprehensive transaction list, advanced filtering, detailed modal view, timeline tracking, financial breakdown, bulk operations.
```

---

### Screen 3: Dispute Resolution & Refund Management

**Screen Purpose:**  
Handle payment disputes, arbitration, and refund requests with complete workflow from submission to resolution.

**Navigation:**
- Entry: Click "Disputes" from Financial menu, or "Resolve" from transaction list
- Exit: Back to Transaction Management or Financial Dashboard

**Key Components:**

1. **Page Header:**
   - Title: "Dispute Resolution & Refunds"
   - Tab selector: "Active Disputes" ACTIVE | "Resolved" | "Refund Requests"
   - "37 active disputes" badge (orange)
   - Filter: Priority (All | High | Medium | Low)

2. **ACTIVE DISPUTES TAB:**

   **Summary Cards:**
   - Total Active: 37 (orange)
   - High Priority: 8 (red)
   - Awaiting Admin: 15 (amber)
   - Avg Resolution Time: 2.3 days

   **Dispute Queue (List View):**

   **Dispute Card 1 (High Priority, red left border):**
   - Header:
     * Dispute ID: #DSP-089
     * Status: "Awaiting Admin Review" amber badge
     * Priority: "High" red badge
     * Opened: "2 days ago" (timer)
     * Deadline: "1 day remaining" (red countdown)
   
   - Parties:
     * Patient: "Lê Văn C" (avatar + name)
     * ⚠️ Dispute Icon
     * Rescuer: "Đội HN Rescue"
   
   - Dispute Details:
     * Transaction: #TXN-045676
     * Amount: 1,200,000 VNĐ
     * Service: Rescue Service on 10/12/2025
     * Reason: "Service not completed as agreed" (dropdown)
   
   - Patient Claim (expandable):
     * "Rescuer arrived 2 hours late and did not capture snake. Snake was already gone when they arrived."
     * Evidence: 📷 3 photos | 📹 1 video | 📄 2 documents
     * Requested Action: "Full refund"
   
   - Rescuer Response (expandable):
     * "Patient provided incorrect address. We arrived at correct GPS location but no snake was found."
     * Evidence: 📍 GPS log | 📷 2 photos | 📞 Call records
     * Counter-claim: "Partial payment justified for travel"
   
   - Admin Notes (internal):
     * Text area for admin comments
     * History: "Assigned to Admin A - 1 day ago"
   
   - Actions:
     * "Review Evidence" button (blue)
     * "Contact Patient" button (blue outlined)
     * "Contact Rescuer" button (blue outlined)
     * Resolution dropdown: "Full Refund" | "Partial Refund" | "No Refund" | "Split Payment"
     * Amount slider (if partial): 0% to 100%
     * "Resolve Dispute" button (green, large)
     * "Escalate" button (red outlined)

   **Dispute Card 2 (Medium Priority):**
   - Similar structure
   - Dispute: Service quality complaint
   - Amount: 450,000 VNĐ
   - 4 days ago

   [Additional dispute cards...]

3. **RESOLVED TAB:**

   **Resolved Disputes Table:**
   - Columns: Dispute ID | Date Resolved | Parties | Amount | Resolution | Refund Amount | Resolved By
   - Filters: Resolution type, Date range
   - Export resolved disputes

4. **REFUND REQUESTS TAB:**

   **Pending Refund Queue:**

   **Refund Card 1:**
   - Header:
     * Refund ID: #REF-234
     * Status: "Awaiting Approval" amber badge
     * Requested: "5 hours ago"
   
   - Request Details:
     * Original Transaction: #TXN-044523
     * Patient: "Nguyễn Văn A"
     * Provider: "Dr. Nguyễn X" (Expert)
     * Original Amount: 450,000 VNĐ
     * Refund Requested: 450,000 VNĐ (100%)
     * Reason: "Consultation cancelled by expert at last minute"
   
   - Refund Policy Check:
     * ✓ Within 7-day refund window
     * ✓ Service not delivered
     * ⚠️ Expert already received payment (needs clawback)
   
   - Financial Impact:
     * Refund to Patient: 450,000 VNĐ
     * Deduct from Expert: 382,500 VNĐ (85%)
     * Platform absorbs: 67,500 VNĐ (commission)
   
   - Actions:
     * "Approve Full Refund" button (green)
     * "Approve Partial" button (amber)
     * Amount input (if partial)
     * "Deny Refund" button (red outlined)
     * Reason text area (required if deny)
     * "Process Refund" button (green, large)

5. **Statistics & Analytics:**
   - Dispute Rate: 1.1% of transactions
   - Resolution Time: Avg 2.3 days
   - Refund Rate: 2.8%
   - Common Reasons (pie chart):
     * Service not completed: 45%
     * Late arrival: 28%
     * Quality issues: 18%
     * Cancellation: 9%

**Stitch Prompt (English):**

```
Dispute resolution and refund management screen.

PAGE HEADER:
- "Dispute Resolution & Refunds" (28pt bold)
- Tabs (horizontal):
  * "Active Disputes" (ACTIVE, blue underline) + "37" orange badge
  * "Resolved"
  * "Refund Requests" + "12" amber badge
- Filter: "Priority: All" dropdown (right)

[ACTIVE DISPUTES TAB]

SUMMARY CARDS (4 mini cards):
CARD 1: "Total Active" | "37" (24pt orange)
CARD 2: "High Priority" | "8" (24pt red)
CARD 3: "Awaiting Admin" | "15" (24pt amber)
CARD 4: "Avg Resolution" | "2.3 days" (24pt blue)

DISPUTE QUEUE (scrollable list):

DISPUTE CARD 1 (white card, red left border 4px, rounded):

HEADER ROW:
- "Dispute ID: #DSP-089" (18pt bold monospace)
- "Awaiting Admin Review" amber badge
- "High" red badge (PRIORITY)
- "Opened: 2 days ago" gray + ⏱️ timer icon
- "Deadline: 1 day remaining" red countdown (right)

PARTIES SECTION (horizontal):
LEFT: Patient avatar 48px + "Lê Văn C" (16pt bold) + "Patient" gray
CENTER: ⚠️ Large orange dispute icon (48px)
RIGHT: Rescuer avatar + "Đội HN Rescue" + "Rescuer" orange

DISPUTE DETAILS (gray background box):
- "Transaction: #TXN-045676" (blue link)
- "Amount: 1,200,000 VNĐ" (20pt bold)
- "Service: Rescue Service on 10/12/2025"
- "Reason: Service not completed as agreed" (dropdown selected)

PATIENT CLAIM (expandable section, expanded):
"Patient's Claim" header (16pt bold) + ▼ collapse arrow

- Text: "Rescuer arrived 2 hours late and did not capture snake. Snake was already gone when they arrived." (14pt)
- "Evidence Provided:" label
  * 📷 "3 photos" link (blue)
  * 📹 "1 video" link
  * 📄 "2 documents" link
- "Requested Action: Full refund" (bold)

RESCUER RESPONSE (expandable, collapsed):
"Rescuer's Response" header + ▶ expand arrow

[When expanded:]
- Text: "Patient provided incorrect address. We arrived at correct GPS location but no snake was found."
- Evidence:
  * 📍 "GPS log" link
  * 📷 "2 photos"
  * 📞 "Call records"
- Counter-claim: "Partial payment justified for travel"

ADMIN NOTES (light blue background):
"Admin Notes (Internal Only)" header (14pt bold)
- Text area (3 rows, editable)
- "History:" label + "Assigned to Admin A - 1 day ago" gray text

ACTION SECTION:
- "Review Evidence" button (blue filled, 40px)
- "Contact Patient" button (blue outlined, 40px)
- "Contact Rescuer" button (blue outlined)

RESOLUTION PANEL (light green background):
"Resolution Decision" header (16pt bold)
- "Resolution Type:" dropdown showing "Full Refund" (options: Full Refund | Partial Refund | No Refund | Split Payment)
- IF PARTIAL selected:
  * "Refund Amount:" slider (0% - 100%)
  * Value display: "600,000 VNĐ (50%)"
- "Reason for Decision:" text area (required, 5 rows)
- "Resolve Dispute" button (green filled, 48px height, bold)
- "Escalate to Supervisor" button (red outlined, right)

DISPUTE CARD 2 (amber left border, medium priority):
[Similar structure]
- #DSP-088
- "Medium" amber badge
- 4 days ago
- Amount: 450,000 VNĐ
- Quality complaint

[Additional cards 3-10...]

STATISTICS SIDEBAR (right, 300px):

"Dispute Statistics" header (18pt bold)

CARD "Dispute Rate":
- "1.1%" (32pt bold)
- "of all transactions"
- Line chart showing trend

CARD "Avg Resolution Time":
- "2.3 days" (32pt bold green)
- "Target: 3 days ✓"

"Common Dispute Reasons" header
PIE CHART (250px):
- Red 45%: "Service not completed"
- Orange 28%: "Late arrival"
- Yellow 18%: "Quality issues"
- Blue 9%: "Cancellation"

LEGEND below chart

[REFUND REQUESTS TAB - when switched]

"Pending Refund Requests (12)" header

REFUND CARD 1 (white card, amber left border):

HEADER:
- "Refund ID: #REF-234" (18pt bold monospace)
- "Awaiting Approval" amber badge
- "Requested: 5 hours ago"

REQUEST DETAILS:
- "Original Transaction: #TXN-044523" (blue link)
- Patient: Avatar + "Nguyễn Văn A"
- "→" arrow
- Provider: Avatar + "Dr. Nguyễn X" + "Expert" purple
- "Original Amount: 450,000 VNĐ" (18pt bold)
- "Refund Requested: 450,000 VNĐ (100%)"
- "Reason: Consultation cancelled by expert at last minute"

POLICY CHECK (checklist):
✓ "Within 7-day refund window" green
✓ "Service not delivered" green
⚠️ "Expert already received payment (needs clawback)" amber

FINANCIAL IMPACT (table, gray background):
- "Refund to Patient:" | "450,000 VNĐ" bold
- "Deduct from Expert:" | "- 382,500 VNĐ" red (85%)
- "Platform absorbs:" | "- 67,500 VNĐ" red (commission)
- "Net Impact:" | "- 450,000 VNĐ" red bold

ACTIONS:
- "Approve Full Refund" button (green filled, 44px)
- "Approve Partial" button (amber outlined, 44px)
- Amount input: "____" VNĐ (if partial)
- "Deny Refund" button (red outlined)
- "Denial Reason:" text area (shows if deny clicked)
- "Process Refund" button (green filled, 48px, bold, right)

DESIGN: Comprehensive dispute management, evidence review, resolution workflow, refund processing, policy checks, financial impact analysis.
```

---

### Screen 4: Financial Reports & Revenue Analytics

**Screen Purpose:**  
Generate comprehensive financial reports with customizable parameters, export capabilities, and detailed revenue analytics for accounting and business intelligence.

**Navigation:**
- Entry: Click "Reports" from Financial menu
- Exit: Back to Financial Dashboard or download report

**Key Components:**

1. **Page Header:**
   - Title: "Financial Reports & Analytics"
   - "Generate New Report" button (blue, large)
   - "Scheduled Reports" link (view automated reports)

2. **Quick Report Templates (Top Row):**

   **Template Cards (4 cards):**

   **Card 1: Monthly Summary**
   - Icon: 📊 Chart
   - "Monthly Summary Report"
   - "Revenue, transactions, commissions"
   - "Last Run: 01/12/2025"
   - "Run Now" button (blue)
   - "Schedule" link

   **Card 2: Tax Report**
   - Icon: 📋 Document
   - "Tax & Accounting Report"
   - "VAT, income tax, deductions"
   - "Last Run: 05/12/2025"
   - Buttons

   **Card 3: Provider Earnings**
   - Icon: 👥 People
   - "Provider Earnings Report"
   - "Rescuer & expert payouts"
   - "Last Run: 10/12/2025"
   - Buttons

   **Card 4: Custom Report**
   - Icon: ⚙️ Settings
   - "Custom Report Builder"
   - "Build your own report"
   - "Create New" button (blue outlined)

3. **Recent Reports Table:**
   - Columns: Report Name | Type | Period | Generated | Generated By | Status | Actions
   - Row 1: "November 2025 Summary" | Monthly | 01-30/11/2025 | 01/12/2025 10:30 | Admin A | "Ready ✓" green | Download | View | Share
   - Row 2: "Q4 2025 Tax Report" | Quarterly | Q4 2025 | 05/12/2025 | Admin B | "Processing ⏳" amber | —
   - Row 3: "Rescuer Earnings Nov" | Provider | 01-30/11/2025 | 28/11/2025 | Admin A | "Ready ✓" | Download | View
   - [Additional rows...]

4. **Report Builder Panel (when "Create New" clicked):**

   **Step 1: Report Type**
   - Radio buttons:
     * ○ Revenue Summary Report
     * ○ Transaction Analysis Report
     * ○ Commission & Fees Report
     * ○ Provider Earnings Report
     * ○ Tax & Accounting Report
     * ○ Custom Report

   **Step 2: Time Period**
   - Preset: This Month | Last Month | This Quarter | Last Quarter | This Year | Custom
   - Custom: Start Date to End Date
   - Compare to: Previous period (checkbox)

   **Step 3: Include Metrics**
   - Checkboxes:
     * ☑ Total revenue breakdown
     * ☑ Transaction volumes
     * ☑ Platform commissions
     * ☑ Provider payouts
     * ☑ Payment methods distribution
     * ☐ Refunds & chargebacks
     * ☐ Outstanding balances
     * ☐ Tax calculations

   **Step 4: Filters**
   - Service Type: All | Rescue | Consultation | AI Verification
   - Provider Type: All | Rescuer | Expert
   - Region: Multi-select provinces
   - Minimum Amount: ____ VNĐ

   **Step 5: Format & Delivery**
   - Output Format:
     * ○ PDF Report (formatted with charts)
     * ○ Excel Spreadsheet (.xlsx)
     * ○ CSV Data (.csv)
   - Include:
     * ☑ Executive summary
     * ☑ Charts & visualizations
     * ☑ Detailed tables
     * ☑ Raw transaction data
   - Delivery:
     * ○ Download now
     * ○ Email to: ______________ (input)
     * ○ Schedule recurring (frequency dropdown)

   **Preview Section:**
   - Mini preview of report structure
   - Sample data shown

   **Actions:**
   - "Generate Report" button (green, large)
   - "Save as Template" button (blue outlined)
   - "Cancel" button (gray)

5. **Revenue Analytics Dashboard (Bottom Half):**

   **Revenue by Service Type (Stacked Area Chart):**
   - Last 12 months
   - Areas: Rescue Services (orange) + Consultations (purple) + AI Verification (cyan)
   - Tooltip showing breakdown per month

   **Commission Analysis (Line Chart):**
   - Blue line: Total platform commission
   - Green line: Commission rate %
   - Target line at 15%

   **Top Revenue Days (Calendar Heat Map):**
   - Calendar view of current month
   - Color intensity based on revenue
   - Hover: Show exact amount and transactions

   **Provider Payout Statistics:**
   - Total Paid Out: 105.8M VNĐ
   - Rescuers: 71.2M (67%)
   - Experts: 34.6M (33%)
   - Avg per Rescuer: 1.58M
   - Avg per Expert: 2.88M

**Stitch Prompt (English):**

```
Financial reports and revenue analytics screen.

PAGE HEADER:
- "Financial Reports & Analytics" (28pt bold)
- "Generate New Report" button (blue filled, 48px height, bold, right)
- "Scheduled Reports" link (blue text, 14pt, right)

QUICK REPORT TEMPLATES (4 cards, horizontal):

CARD 1 (white rounded shadow):
- 📊 Chart icon (48px, blue)
- "Monthly Summary Report" (18pt bold)
- "Revenue, transactions, commissions" (14pt gray)
- "Last Run: 01/12/2025" (12pt gray)
- "Run Now" button (blue filled, 40px)
- "Schedule" link (blue text)

CARD 2:
- 📋 Document icon (48px, green)
- "Tax & Accounting Report"
- "VAT, income tax, deductions"
- "Last Run: 05/12/2025"
- Buttons

CARD 3:
- 👥 People icon (48px, orange)
- "Provider Earnings Report"
- "Rescuer & expert payouts"
- "Last Run: 10/12/2025"
- Buttons

CARD 4:
- ⚙️ Settings icon (48px, purple)
- "Custom Report Builder"
- "Build your own report"
- "Create New" button (blue outlined, 40px)

RECENT REPORTS TABLE (white card):

"Recent Reports" header (20pt bold) + "View All →" link

TABLE HEADER (light gray):
- "Report Name" (250px)
- "Type" (120px)
- "Period" (150px)
- "Generated" (150px)
- "Generated By" (120px)
- "Status" (100px)
- "Actions" (150px)

ROW 1:
- "November 2025 Summary" (16pt bold)
- "Monthly" gray badge
- "01-30/11/2025"
- "01/12/2025 10:30"
- "Admin A" + avatar
- "Ready ✓" green badge
- Icons: 📥 Download | 👁️ View | 📤 Share

ROW 2:
- "Q4 2025 Tax Report"
- "Quarterly" blue badge
- "Q4 2025"
- "05/12/2025"
- "Admin B" + avatar
- "Processing ⏳" amber badge + progress bar 67%
- "—" (no actions yet)

ROW 3:
- "Rescuer Earnings Nov"
- "Provider" orange badge
- "01-30/11/2025"
- "28/11/2025"
- "Admin A"
- "Ready ✓" green
- Icons: 📥 | 👁️ | 📤

REPORT BUILDER MODAL (overlay, 900px width, white):

MODAL HEADER:
- "Custom Report Builder" (24pt bold)
- × Close button

WIZARD STEPS (horizontal progress):
1 ● Report Type (active blue)
2 ○ Time Period (gray)
3 ○ Metrics (gray)
4 ○ Filters (gray)
5 ○ Format (gray)

STEP 1 CONTENT:
"Select Report Type" header (20pt bold)

RADIO CARDS (large, 2 columns):
● "Revenue Summary Report" (selected, blue border)
  "Total revenue, breakdown by service, trends"
○ "Transaction Analysis Report"
  "Transaction volumes, success rates, methods"
○ "Commission & Fees Report"
  "Platform earnings, fee analysis"
○ "Provider Earnings Report"
  "Payouts to rescuers and experts"
○ "Tax & Accounting Report"
  "Tax calculations, VAT, deductions"
○ "Custom Report"
  "Build from scratch"

STEP 2 (when clicked Next):
"Select Time Period" header

PRESET CHIPS (horizontal):
"This Month" | "Last Month" (selected blue) | "This Quarter" | "Last Quarter" | "This Year"

CUSTOM RANGE:
- "Start Date:" picker "01/11/2025"
- "End Date:" picker "30/11/2025"
- ☑ "Compare to previous period" checkbox

STEP 3:
"Include Metrics" header

CHECKBOXES (2 columns):
☑ "Total revenue breakdown"
☑ "Transaction volumes"
☑ "Platform commissions"
☑ "Provider payouts"
☑ "Payment methods distribution"
☐ "Refunds & chargebacks"
☐ "Outstanding balances"
☐ "Tax calculations"

STEP 4:
"Apply Filters" header

- "Service Type:" dropdown "All"
- "Provider Type:" dropdown "All"
- "Region:" multi-select chips "All Regions"
- "Minimum Amount:" input "_____" VNĐ

STEP 5:
"Format & Delivery" header

OUTPUT FORMAT (radio):
● "PDF Report (formatted with charts)" (selected)
○ "Excel Spreadsheet (.xlsx)"
○ "CSV Data (.csv)"

INCLUDE (checkboxes):
☑ "Executive summary"
☑ "Charts & visualizations"
☑ "Detailed tables"
☑ "Raw transaction data"

DELIVERY (radio):
● "Download now" (selected)
○ "Email to:" + email input
○ "Schedule recurring" + frequency dropdown

PREVIEW PANEL (right, 40%):
"Report Preview" header
- Miniature preview of report pages
- "Page 1: Cover"
- "Page 2: Summary"
- "Page 3: Charts"
- [etc...]

ACTION BUTTONS (bottom):
- "Back" button (gray outlined, left)
- "Cancel" button (gray outlined)
- "Save as Template" button (blue outlined)
- "Generate Report" button (green filled, 48px, bold, right)

REVENUE ANALYTICS SECTION (full width, below tables):

"Revenue Analytics" header (24pt bold)

CHART ROW 1 (two charts):

LEFT (60%):
"Revenue by Service Type - Last 12 Months" header

STACKED AREA CHART (800x400px):
- X-axis: Dec 2024 | Jan | Feb | ... | Nov 2025
- Y-axis: Revenue (millions VNĐ, 0-25M)
- Orange area: "Rescue Services" (bottom, largest)
- Purple area: "Expert Consultations" (middle)
- Cyan area: "AI Verification" (top, smallest)
- Legend top-right
- Tooltip on hover: "Nov 2025: Total 24.5M (Rescue: 14M, Consult: 8M, AI: 2.5M)"

RIGHT (40%):
"Commission Analysis" header

LINE CHART (500x400px):
- Blue line: "Total Platform Commission" (left Y-axis, VNĐ)
- Green dashed line: "Commission Rate %" (right Y-axis, %)
- Red target line at 15%
- Both axes labeled

CHART ROW 2:

LEFT (50%):
"Top Revenue Days - December 2025" header

CALENDAR HEAT MAP (600x400px):
- Calendar grid layout (7 columns x 5 rows)
- Each day colored by revenue:
  * Light green: 1-3M
  * Medium green: 3-5M
  * Dark green: >5M
  * Gray: <1M
- Example: Dec 13 (today) dark green = 6.2M
- Hover: Show exact amount + transactions
- Legend bottom

RIGHT (50%):
"Provider Payout Statistics" header

CARD (light blue background):
- "Total Paid Out" (16pt)
- "105.8M VNĐ" (36pt bold green)

BREAKDOWN (horizontal bars):
BAR 1: "Rescuers" | Orange bar 67% | "71.2M (67%)"
BAR 2: "Experts" | Purple bar 33% | "34.6M (33%)"

AVERAGES:
- "Avg per Rescuer: 1.58M VNĐ"
- "Avg per Expert: 2.88M VNĐ"

DESIGN: Comprehensive report builder, template system, scheduled reports, multi-format export, detailed analytics, revenue visualizations.
```

---

## Integration Points

### API Endpoints:
- `GET /api/admin/financial/dashboard?dateRange=` - Get financial dashboard data
- `GET /api/admin/financial/transactions?filter=&sort=&page=` - Get transaction list
- `GET /api/admin/financial/transactions/:id` - Get transaction details
- `POST /api/admin/financial/disputes/:id/resolve` - Resolve dispute
- `POST /api/admin/financial/refunds/:id/process` - Process refund
- `GET /api/admin/financial/disputes?status=` - Get dispute list
- `GET /api/admin/financial/refunds?status=` - Get refund requests
- `POST /api/admin/financial/reports/generate` - Generate financial report
- `GET /api/admin/financial/reports` - Get report list
- `POST /api/admin/financial/reports/schedule` - Schedule recurring report
- `GET /api/admin/financial/analytics/revenue?period=` - Get revenue analytics
- `GET /api/admin/financial/commission-settings` - Get commission rates
- `PUT /api/admin/financial/commission-settings` - Update commission rates
- `POST /api/admin/financial/payouts/process` - Process batch payouts

### Payment Integration:
- Payment gateway APIs (Stripe, PayPal, local VN gateways)
- E-wallet APIs (Momo, ZaloPay, VNPay)
- Bank transfer APIs for local banks
- Refund processing APIs
- Chargeback handling

### Accounting Integration:
- Export to QuickBooks, Xero formats
- Generate invoices automatically
- VAT calculation for Vietnam tax system
- Income/expense categorization
- Reconciliation support

### Security & Compliance:
- PCI DSS compliance for card data
- End-to-end encryption for financial data
- Audit logging for all financial operations
- Two-factor authentication for high-value transactions
- Role-based access control for financial data

---

## Version History
- **v1.0** - December 13, 2025: Initial financial management screens design (4 screens) - FINAL MODULE COMPLETION 🎉

---

## Design Review Checklist
- [x] Comprehensive financial dashboard with revenue metrics
- [x] Detailed transaction management with filtering
- [x] Dispute resolution workflow with evidence review
- [x] Refund processing with policy checks
- [x] Financial impact analysis for disputes/refunds
- [x] Custom report builder with multiple formats
- [x] Revenue analytics and visualizations
- [x] Provider payout tracking
- [x] Commission management
- [x] Export capabilities for accounting systems
- [x] Real-time transaction monitoring
- [x] Payment method tracking
- [x] Top performers leaderboards

---

*This document is part of the SnakeAid Platform UI Design Documentation*  
*Related Documents: Admin-Dashboard-Screens.md, Admin-User-Management-Screens.md, Admin-Snake-Database-Screens.md, Admin-Hospital-Management-Screens.md, Admin-Analytics-Reporting-Screens.md*

---

## 🎉 COMPLETION MILESTONE

**THIS IS THE FINAL ADMIN MODULE DOCUMENT!**

**Complete SnakeAid Platform UI Design:**
- ✅ Patient Module: 36/36 screens (100%)
- ✅ Rescuer Module: 40/40 screens (100%)
- ✅ Expert Module: 22/22 screens (100%)
- ✅ Admin Module: 22/22 screens (100%)

**TOTAL: 120/120 screens (100% COMPLETE) 🎊**
