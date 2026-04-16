# MEMBER SCREEN FLOW — SnakeAid Mobile

**Phiên bản:** 1.2 | **Ngày:** 15/04/2026

> **Screens loại bỏ** (mock data / chưa kết nối API / không còn dùng): Các màn hình cũ đã được replace bởi luồng mới

---

## 3.1 Screen Flow Diagram

`mermaid
flowchart LR
    N0[""Splash""]
    N1[""Member Registration""]
    N2[""OTP Verification""]
    N3[""Registration Success""]
    N4[""Member Login""]
    N5[""Forgot Password""]
    N6[""Forgot Password OTP""]
    N7[""Reset Password""]
    N8[""Password Reset Success""]
    N9[""Member Home""]
    N10[""Community Alert""]
    N11[""Notification Tab""]
    N12[""Emergency Action""]
    N13[""Snake Identification""]
    N14[""Snake Selection by Location""]
    N15[""Snake Confirmation""]
    N16[""First Aid Steps""]
    N17[""Symptom Report""]
    N18[""Severity Assessment""]
    N19[""Emergency Tracking""]
    N20[""Member Incident Finished""]
    N21[""Snake Catching""]
    N22[""Snake Quantity Selection""]
    N23[""Snake Report Detail""]
    N24[""Snake Catching Success""]
    N25[""Consultation Home""]
    N26[""Expert List""]
    N27[""Expert Detail""]
    N28[""Service Selection""]
    N29[""Consultation Time Selection""]
    N30[""Consultation Documents""]
    N31[""Payment Confirmation""]
    N32[""Emergency Request Waiting""]
    N33[""Video Waiting Room""]
    N34[""Video Consultation""]
    N35[""Consultation Complete""]
    N36[""Snake Library""]
    N37[""Snake Detail""]
    N38[""Snake First Aid Guide""]
    N39[""Blog List""]
    N40[""Blog Detail""]
    N41[""Profile Tab""]
    N42[""Edit Profile""]
    N43[""Role Selection""]
    N44[""Edit Community Report""]
    N45[""History Community""]
    N46[""Upload Community Report""]
    N47[""Rescuer Arrived""]
    N48[""Activity Tab""]
    N49[""Snake Catching Detail""]
    N50[""History Transaction""]
    N51[""Transaction Detail""]
    N52[""Top-up""]
    N53[""Withdrawal""]
    N54[""History Wallet""]
    N55[""Scheduled Consultation""]
    N56[""Emergency Consultation""]
    N57[""Settings""]
    N58[""Activity Detail""]
    N59[""Activity History""]
    N0 --> N43
    N4 --> N5
    N4 --> N1
    N5 --> N6
    N6 --> N7
    N7 --> N8
    N9 --> N10
    N9 --> N12
    N9 --> N41
    N9 --> N21
    N9 --> N48
    N9 --> N25
    N9 --> N11
    N9 --> N36
    N9 --> N39
    N9 --> N50
    N10 --> N46
    N10 --> N45
    N12 --> N14
    N14 --> N15
    N24 --> N49
    N28 --> N55
    N28 --> N56
    N31 --> N32
    N32 --> N33
    N41 --> N52
    N41 --> N53
    N41 --> N50
    N41 --> N54
    N41 --> N57
    N1 --> N2
    N2 --> N3
    N4 --> N9
    N12 --> N13
    N13 --> N15
    N15 --> N16
    N16 --> N17
    N17 --> N18
    N18 --> N19
    N21 --> N22
    N22 --> N23
    N23 --> N24
    N25 --> N26
    N26 --> N27
    N27 --> N28
    N29 --> N30
    N30 --> N31
    N31 --> N33
    N33 --> N34
    N36 --> N37
    N37 --> N38
    N39 --> N40
    N41 --> N42
    N43 --> N4
    N45 --> N44
    N46 --> N45
    N47 --> N20
    N48 --> N58
    N48 --> N59
    N50 --> N51
    N55 --> N29
    N56 --> N29
    N59 --> N58
`

---

## 3.2 Screen Inventory


| # | Screen | Route | API |
|---|--------|-------|:---:|
| 1 | Splash | | |
| 2 | Member Registration | | |
| 3 | OTP Verification | | |
| 4 | Registration Success | | |
| 5 | Member Login | | |
| 6 | Forgot Password | | |
| 7 | Forgot Password OTP | | |
| 8 | Reset Password | | |
| 9 | Password Reset Success | | |
| 10 | Member Home | | |
| 11 | Community Alert | | |
| 12 | Notification Tab | | |
| 13 | Emergency Action | | |
| 14 | Snake Identification | | |
| 15 | Snake Selection by Location | | |
| 16 | Snake Confirmation | | |
| 17 | First Aid Steps | | |
| 18 | Symptom Report | | |
| 19 | Severity Assessment | | |
| 20 | Emergency Tracking | | |
| 21 | Member Incident Finished | | |
| 22 | Snake Catching | | |
| 23 | Snake Quantity Selection | | |
| 24 | Snake Report Detail | | |
| 25 | Snake Catching Success | | |
| 26 | Consultation Home | | |
| 27 | Expert List | | |
| 28 | Expert Detail | | |
| 29 | Service Selection | | |
| 30 | Consultation Time Selection | | |
| 31 | Consultation Documents | | |
| 32 | Payment Confirmation | | |
| 33 | Emergency Request Waiting | | |
| 34 | Video Waiting Room | | |
| 35 | Video Consultation | | |
| 36 | Consultation Complete | | |
| 37 | Snake Library | | |
| 38 | Snake Detail | | |
| 39 | Snake First Aid Guide | | |
| 40 | Blog List | | |
| 41 | Blog Detail | | |
| 42 | Profile Tab | | |
| 43 | Edit Profile | | |
| 44 | Role Selection | | |
| 45 | Edit Community Report | | |
| 46 | History Community | | |
| 47 | Upload Community Report | | |
| 48 | Rescuer Arrived | | |
| 49 | Activity Tab | | |
| 50 | Snake Catching Detail | | |
| 51 | History Transaction | | |
| 52 | Transaction Detail | | |
| 53 | Top-up | | |
| 54 | Withdrawal | | |
| 55 | History Wallet | | |
| 56 | Scheduled Consultation | | |
| 57 | Emergency Consultation | | |
| 58 | Settings | | |
| 59 | Activity Detail | | |
| 60 | Activity History | | |

---

## 3.3 Screen Description & Authorization

### 3.3.1 Description

| # | Feature | Screen | Description |
|---|---------|--------|-------------|
| 1 | App Bootstrapping | Splash | App startup screen that validates session state and performs initial routing. |
| 2 | Member Registration | Member Registration | Screen for capturing new member account credentials and details. |
| 3 | Member Registration | OTP Verification | Screen for validating member identity via phone or email OTP. |
| 4 | Member Registration | Registration Success | Screen displaying confirmation of successful member account creation. |
| 5 | Authentication | Member Login | Main authentication screen for member users to securely log in. |
| 6 | Authentication | Forgot Password | Screen to enter account/email and start the password recovery flow. |
| 7 | Authentication | Forgot Password OTP | OTP verification screen for the forgot-password flow. |
| 8 | Authentication | Reset Password | Screen for inputting and confirming a new secure password. |
| 9 | Authentication | Password Reset Success | Screen confirming that the password has been successfully updated. |
| 10 | Member Workspace | Member Home | Main dashboard providing quick access to emergency services and alerts. |
| 11 | Community Alerts | Community Alert | Screen displaying nearby active incidents and user-submitted reports. |
| 12 | Notification Tab | Notification Tab | Centralized inbox for system alerts and message updates. |
| 13 | Emergency Response | Emergency Action | Entry point for initiating SOS and triggering snake identification. |
| 14 | Emergency Response | Snake Identification | Real-time AI camera interface for scanning and identifying snake species. |
| 15 | Emergency Response | Snake Selection by Location | Search interface for manually filtering snake species based on region. |
| 16 | Emergency Response | Snake Confirmation | Final confirmation screen verifying the identified snake species. |
| 17 | Clinical Assessment | First Aid Steps | Step-by-step visual instruction guide for immediate medical response. |
| 18 | Clinical Assessment | Symptom Report | Form interface for capturing the patient's current physical symptoms. |
| 19 | Clinical Assessment | Severity Assessment | Automated system screen determining the clinical urgency level of the bite. |
| 20 | Emergency Tracking | Emergency Tracking | Live map interface tracking the inbound rescuer's geolocation. |
| 21 | Emergency Tracking | Member Incident Finished | Final mission summary detailing the resolved emergency incident. |
| 22 | Snake Catching | Snake Catching | Request interface for initiating non-emergency snake removal services. |
| 23 | Snake Catching | Snake Quantity Selection | Input screen for defining the estimated number of snakes to catch. |
| 24 | Snake Catching | Snake Report Detail | Form for providing additional situational context and attachments. |
| 25 | Snake Catching | Snake Catching Success | Confirmation screen validating the successful submission of the catch request. |
| 26 | Expert Consultation | Consultation Home | Central hub for navigating telemedicine and expert consultation services. |
| 27 | Expert Consultation | Expert List | Directory listing of verified medical and snake handling experts. |
| 28 | Expert Consultation | Expert Detail | Detailed profile showcasing expert qualifications, reviews, and availability. |
| 29 | Expert Consultation | Service Selection | Interface for selecting the appropriate tier or type of consultation. |
| 30 | Expert Consultation | Consultation Time Selection | Scheduling interface for booking future consultation appointments. |
| 31 | Expert Consultation | Consultation Documents | Upload screen for attaching media and medical notes prior to the call. |
| 32 | Expert Consultation | Payment Confirmation | Escrow payment gateway interface securing funds before the consultation. |
| 33 | Expert Consultation | Emergency Request Waiting | Queue interface while matching with an available on-call expert. |
| 34 | Expert Consultation | Video Waiting Room | Pre-call lobby verifying connection state before the live session. |
| 35 | Expert Consultation | Video Consultation | Live WebRTC video and audio interface for remote expert consultation. |
| 36 | Expert Consultation | Consultation Complete | Post-call summary providing medical prescriptions and expert notes. |
| 37 | Knowledge Base | Snake Library | Encyclopedic database of snake species, descriptions, and habitats. |
| 38 | Knowledge Base | Snake Detail | Specific informational profile detailing snake characteristics and risks. |
| 39 | Knowledge Base | Snake First Aid Guide | Comprehensive first-aid protocols mapped to specific snake species. |
| 40 | Knowledge Base | Blog List | Educational repository listing published safety and awareness articles. |
| 41 | Knowledge Base | Blog Detail | Article view screen for reading comprehensive educational content. |
| 42 | Member Profile | Profile Tab | User profile summary outlining personal information and status. |
| 43 | Member Profile | Edit Profile | Form interface for modifying user personal details and avatars. |
| 44 | Authentication | Role Selection | Screen for selecting the user role before sign-in or sign-up. |
| 45 | Community Alerts | Edit Community Report | Interface for modifying details of a previously submitted community alert. |
| 46 | Community Alerts | History Community | Historical log interface displaying the user's past community reports. |
| 47 | Community Alerts | Upload Community Report | Submission form for broadcasting a new community incident. |
| 48 | Emergency Tracking | Rescuer Arrived | Live status confirmation screen when the rescuer reaches the location. |
| 49 | Activity & History | Activity Tab | Overview dashboard summarizing the user's historical actions and requests. |
| 50 | Snake Catching | Snake Catching Detail | Detailed view of a past or completed snake catching mission. |
| 51 | Member Wallet | History Transaction | Comprehensive ledger of past fiat and wallet processing events. |
| 52 | Member Wallet | Transaction Detail | Specific receipt detailing a single financial transaction. |
| 53 | Member Wallet | Top-up | Payment gateway interface for adding funds to the user wallet. |
| 54 | Member Wallet | Withdrawal | Request interface for initiating a payout from the digital wallet. |
| 55 | Member Wallet | History Wallet | Overview interface tracking balance fluctuations and wallet history. |
| 56 | Expert Consultation | Scheduled Consultation | Log interface for viewing upcoming booked expert consultations. |
| 57 | Emergency Consultation | Emergency Consultation | Quick-access interface for initiating an immediate urgent consultation. |
| 58 | Member Profile | Settings | Application configuration interface for preferences and notification toggles. |
| 59 | Activity & History | Activity Detail | In-depth breakdown interface highlighting details of a specific past activity. |
| 60 | Activity & History | Activity History | Complete chronological list displaying all historical user events. |

### 3.3.2 Authorization

| Screen | Member | Rescuer | Expert | Admin | Operator |
|--------|:------:|:-------:|:------:|:-----:|:--------:|
| Splash | X | X | X | | |
| Role Selection | X | X | X | | |
| Member Login | X | | | | |
| Rescuer Login | | X | | | |
| Expert Login | | | X | | |
| Forgot Password | X | X | X | | |
| Forgot Password OTP | X | X | X | | |
| Reset Password | X | X | X | | |
| Password Reset Success | X | X | X | | |
| Member Registration | X | | | | |
| Expert Registration | | | X | | |
| Expert Credentials | | | X | | |
| OTP Verification | X | X | X | | |
| Registration Success | X | X | X | | |
| Registration Pending | | | X | | |
| Member Home | X | | | | |
| Rescuer Home | | X | | | |
| Expert Home | | | X | | |
| Notification Tab | X | | | | |
| Notification Tab | | X | | | |
| Notification | | | X | | |
| Community Alert | X | | | | |
| Emergency Action | X | | | | |
| Snake Identification | X | | | | |
| Snake Selection by Location | X | | | | |
| Snake Confirmation | X | | | | |
| First Aid Steps | X | | | | |
| Symptom Report | X | | | | |
| Severity Assessment | X | | | | |
| Emergency Tracking | X | | | | |
| Member Incident Finished | X | | | | |
| Snake Catching | X | | | | |
| Snake Quantity Selection | X | | | | |
| Snake Report Detail | X | | | | |
| Snake Catching Success | X | | | | |
| Consultation Home | X | | | | |
| Expert List | X | | | | |
| Expert Detail | X | | | | |
| Service Selection | X | | | | |
| Consultation Time Selection | X | | | | |
| Consultation Documents | X | | | | |
| Payment Confirmation | X | | | | |
| Emergency Request Waiting | X | | | | |
| Video Waiting Room | X | | | | |
| Video Consultation | X | | X | | |
| Consultation Complete | X | | | | |
| Snake Library | X | X | | | |
| Expert Snake Library | | | X | | |
| Snake Detail | X | X | X | | |
| Snake First Aid Guide | X | | | | |
| First Aid Guide | | X | | | |
| Expert Snake First Aid | | | X | | |
| Blog List | X | | | | |
| Blog Detail | X | | | | |
| Expert Blog List | | | X | | |
| Expert Blog Form | | | X | | |
| Profile Tab | X | X | | | |
| Expert Profile Tab | | | X | | |
| Edit Profile | X | X | X | | |
| Edit Community Report | X | | | | |
| History Community | X | | | | |
| Upload Community Report | X | | | | |
| Rescuer Arrived | X | | | | |
| Activity Tab | X | | | | |
| Snake Catching Detail | X | | | | |
| History Transaction | X | | | | |
| Transaction Detail | X | | | | |
| Top-up | X | | | | |
| Withdrawal | X | | | | |
| History Wallet | X | | | | |
| Scheduled Consultation | X | | | | |
| Emergency Consultation | X | | | | |
| Settings | X | X | | | |
| Expert Settings | | | X | | |
| Activity Detail | X | | | | |
| Activity History | X | | | | |
| Available Jobs | | X | | | |
| Request Detail | | X | | | |
| Accept Request | | X | | | |
| En Route | | X | | | |
| Tracking | | X | | | |
| Result Confirmation | | X | | | |
| Mission Success - Snake Catching | | X | | | |
| Mission Detail - SOS | | X | | | |
| Navigation Map | | X | | | |
| On-scene Support | | X | | | |
| Find Hospital | | X | | | |
| Mission Completion | | X | | | |
| Mission Success - Emergency | | X | | | |
| Mission History | | X | | | |
| History Detail | | X | | | |
| Feedback | | X | | | |
| Expert Feedback | | | X | | |
| Lessons | | X | | | |
| Lesson Detail | | X | | | |
| Working Hours | | | X | | |
| Withdraw Money | | | X | | |
| AI Review Queue | | | X | | |
| AI Review Detail | | | X | | |
| Expert Consultation Detail | | | X | | |
| Expert Video Waiting | | | X | | |
| Expert Consultation Complete | | | X | | |
| Expert Global Emergency Popup Listener | | | X | | |
| Accept Emergency Request | | | X | | |
| Reject Emergency Request | | | X | | |
| Consultation List/History Tab | | | X | | |
| Income Tab | | | X | | |
| Web Login | | | | X | X |
| Admin Login Form | | | | X | |
| Operator Login Form | | | | | X |
| Admin Dashboard | | | | X | |
| Operator Dashboard | | | | | X |
| Workshifts Management | | | | X | |
| Users Management | | | | X | |
| Incidents Management | | | | X | X |
| Snake Catching Management | | | | X | X |
| Consultations Management | | | | X | X |
| Snakes Management | | | | X | |
| Antivenoms Management | | | | X | |
| Treatment Facilities Management | | | | X | |
| Transactions & Withdrawals Management | | | | X | |
| Management Withdrawals | | | | X | |
| Settings Management | | | | X | |
| Report Media Management | | | | X | X |
| Lessons Management | | | | X | |
| Blogs Management | | | | X | |





## 3.4 Member Portal Feature

---

### 3.4.1 Authentication & Registration
**Function trigger:** App launches unauthenticated. Navigation path: Splash -> Role Selection -> (Member Registration -> OTP Verification -> Registration Success) or (Member Login -> Forgot Password flow).
**Function description:**
- **Actor:** Guest / Member.
- **Purpose:** Securely onboard new members, verify identity, and manage authenticated session lifecycles.
- **Interface:** Role selection cards, data capture forms, OTP keypad, and standardized identity validation views.
- **Data processing:** Issue registration payloads to Auth service, dispatch and verify SMS/Email OTP, return session tokens.
- **Screen layout:** 

**Function details:**
- **Data:** PII credentials (phone, email, DOB, name), validation tokens, JWT session objects.
- **Validation:** Enforce strong password complexity; Ensure unique identity (no duplicate emails/phones); OTP strict expiration.
- **Business rules:** Unverified accounts cannot access core emergency or consultation features; Logins demand exact credential matches.
- **Normal cases:** User registers, validates OTP, and seamlessly drops into Member Workspace.
- **Abnormal cases:** Identity collision triggers "Account Exists" warning; Exhausted OTP attempts halt registration temporarily.

---

### 3.4.2 Member Workspace & Notifications
**Function trigger:** Authenticated user enters the app. Navigation path: Member Login -> Member Home <-> Notification Tab.
**Function description:**
- **Actor:** Member (with System alerting).
- **Purpose:** Serve as the primary routing hub, surfacing critical emergency CTAs and personal alerts.
- **Interface:** Dominant SOS action hero button, service navigation grid, and system alert inbox.
- **Data processing:** Fetch active user state, aggregate unread notification counts, identify any ongoing active emergency operations.
- **Screen layout:** 

**Function details:**
- **Data:** User contextual profile, system notification payload array, active mission state flags.
- **Validation:** Valid member session.
- **Business rules:** If the member has an active emergency dispatch, the Home screen must forcefully display an immediate "Return to Tracking" persistent banner.
- **Normal cases:** Workspace renders fully; User taps Notification Tab to review unread system updates.
- **Abnormal cases:** Network failure gracefully loads offline cache with a disabled SOS warning banner.

---

### 3.4.3 Community Alerts
**Function trigger:** User investigates local environment safety. Navigation path: Member Home -> Community Alert -> (Upload Community Report) or (Edit Community Report / History Community).
**Function description:**
- **Actor:** Member.
- **Purpose:** Enable crowdsourced hazard reporting and situational awareness of nearby snake sightings.
- **Interface:** Geospatial map/list of incidents, media upload forms, and historical logs of personal reports.
- **Data processing:** Query geofenced hazard datasets, process multipart form uploads (images + location), log reporting history.
- **Screen layout:** 

**Function details:**
- **Data:** Incident coordinates, sighting descriptions, image media, timestamp metadata.
- **Validation:** Location coordinates are mandatory; At least one visual evidence attachment must be provided.
- **Business rules:** User-submitted reports append a "Community Verified" metadata flag; Users can only edit their own active reports.
- **Normal cases:** Member spots a hazard, maps the coordinates, uploads a photo, and the alert broadcasts to nearby users.
- **Abnormal cases:** GPS permission denied blocks report creation; Media upload timeouts generate robust retry prompts.

---

### 3.4.4 Emergency SOS & Identification
**Function trigger:** Member triggers critical emergency workflow. Navigation path: Member Home -> Emergency Action -> Snake Identification -> Snake Selection by Location -> Snake Confirmation.
**Function description:**
- **Actor:** Member.
- **Purpose:** Provide rapid, high-stress interface to initiate SOS protocols and utilize AI for immediate threat identification.
- **Interface:** Distraction-free camera scanner, ML bounding-box view, geolocation-based fallback lists, and definitive confirmation modals.
- **Data processing:** Stream camera frames to Edge/Cloud ML models, execute computer vision inference, return top-K species matches, fallback to geospatial narrowing.
- **Screen layout:** 

**Function details:**
- **Data:** Real-time visual frames, inferred species ID arrays, confidence thresholds, fallback regional species logic.
- **Validation:** Device camera and location permissions are strictly required to proceed.
- **Business rules:** Execution speed is paramount; AI inference must return within set latency bounds or auto-trigger the location-based manual fallback flow.
- **Normal cases:** AI detects species with high confidence -> User confirms -> System progresses to Clinical Assessment.
- **Abnormal cases:** Pitch-black image or blurry motion fails AI thresholds -> Instantly redirects user to manual "Snake Selection by Location".

---

### 3.4.5 Clinical Assessment & First Aid
**Function trigger:** SOS species is confirmed or declared unknown. Navigation path: Snake Confirmation -> First Aid Steps -> Symptom Report -> Severity Assessment.
**Function description:**
- **Actor:** Member (aided by Automated Assessment).
- **Purpose:** Administer immediate life-saving directives and autonomously triage the victim's clinical severity to inform dispatch systems.
- **Interface:** High-visibility procedural steps, symptom ticking checklists, and urgent severity determination outcome screens.
- **Data processing:** Map identified species to specific clinical protocols, process selected symptoms against severity matrix algorithms.
- **Screen layout:** 

**Function details:**
- **Data:** Snake species ID, Boolean symptom array, computed triage level (e.g., Low, High, Critical).
- **Validation:** At least one symptom state (including "No symptoms") must be explicitly selected to advance.
- **Business rules:** App never provides definitive medical diagnoses, only algorithmic triage to rank dispatch priorities; Unknown species default to High/Critical precaution levels.
- **Normal cases:** Member reads protocol -> checks symptoms -> system determines "Critical" -> directly initiates Rescuer dispatch sequence.
- **Abnormal cases:** User abandons flow mid-way -> System holds the SOS state active and prompts resumption upon next app launch.

---

### 3.4.6 Emergency Tracking & Incident Billing
**Function trigger:** SOS is actively dispatched to a rescuer. Navigation path: Severity Assessment -> Emergency Tracking -> Rescuer Arrived -> Member Incident Finished -> Payment Interface.
**Function description:**
- **Actor:** Member (receiving telemetry from Rescuer).
- **Purpose:** Provide psychological relief and operational visibility by tracking the inbound emergency responder in real-time, and settle the financial invoice once the threat is resolved.
- **Interface:** Live map rendering dynamic polylines, ETA countdowns, responder profile snippets, final incident resolution summaries, and billing checkout interface.
- **Data processing:** Consume incoming WebSocket/SignalR geolocation points, calculate route recalculations, sync final state closure, and interface with SnakeAidPay Wallet or PayOS gateway for bill settlement.
- **Screen layout:** 

**Function details:**
- **Data:** Rescuer live coordinates, updated ETA metrics, discrete mission states (Assigned, En Route, Arrived, Resolved), billing invoice totals.
- **Validation:** Ensures rescuer maintains an active transmit heartbeat. Payment requires sufficient wallet balance or successful transaction verification from PayOS.
- **Business rules:** 
  - Member cannot abort the mission once the rescuer transitions to "Arrived" state.
  - **Execute-First, Pay-Later Priority:** SOS operations bypass upfront payments to prioritize life-safety. Payment is mandated only after the rescuer marks the incident as "Resolved" (Hoàn thành cứu hộ).
- **Normal cases:** Rescuer dot approaches on map -> State flips to Arrived -> Operation concludes -> System generates billing summary -> Member pays via SnakeAidPay Wallet or directly via PayOS.
- **Abnormal cases:** 
  - Rescuer goes offline -> UI shows "Signal Lost" while system attempts re-routing or re-assignment in background.
  - Payment Failed/Canceled -> Incident cannot be closed until Member successfully completes the payment.

---

### 3.4.7 Snake Catching Request & Initial Payment
**Function trigger:** Member opts for non-medical snake removal. Navigation path: Member Home -> Snake Catching -> Snake Quantity Selection -> Snake Report Detail -> Initial Payment (Travel Fee) -> Snake Catching Success.
**Function description:**
- **Actor:** Member.
- **Purpose:** Orchestrate the creation of a professional, non-urgent snake catching request and process the upfront travel fee.
- **Interface:** Address confirmation map, quantity counter, environmental context forms, checkout interface (phase 1), and success confirmation.
- **Data processing:** Geocode address endpoints, construct dispatch payloads, query availability of non-emergency responders, and process the initial payment via SnakeAidPay Wallet or PayOS.
- **Screen layout:** 

**Function details:**
- **Data:** Geocoordinates, quantity integer, environmental text description, attached situational photographs, Phase 1 invoice (Travel fee).
- **Validation:** Provided address must fall within the platform's operational service polygons. Payment requires sufficient wallet balance or active PayOS transaction success.
- **Business rules:** 
  - Snake Catching requests explicitly sit at a lower dispatch priority compared to SOS Medical workflows.
  - **Phase 1 Payment:** Member must pay the "Travel Fee" (Phí di chuyển) before the system dispatches a snake catcher.
- **Normal cases:** Member defines parameters, submits form -> Pays Travel Fee -> System secures a catcher -> Shows success confirmation dispatch.
- **Abnormal cases:** 
  - No active responders available -> UI declines the request.
  - Phase 1 Payment Fails -> Request is aborted/not dispatched.

---

### 3.4.8 Snake Catching Tracking & Final Payment
**Function trigger:** Snake catching request is accepted by a rescuer. Navigation path: Activity Tab -> Activity Detail -> (Mission Execution) -> Final Payment (Service Fee).
**Function description:**
- **Actor:** Member & Rescuer.
- **Purpose:** Allow members to track the ongoing snake catching mission and finalize the remaining service fee once the rescuer completes the job.
- **Interface:** Live map/status updates, rescuer profile snippets, mission completion summary, and phase 2 checkout interface.
- **Data processing:** Consume incoming location/status updates, sync final mission closure, and process the final payment phase via SnakeAidPay Wallet or PayOS.
- **Screen layout:** 

**Function details:**
- **Data:** Rescuer live coordinates, discrete mission states (En Route, Arrived, Resolved), Phase 2 invoice (Remaining service fee).
- **Validation:** Payment requires sufficient wallet balance or active PayOS transaction success.
- **Business rules:** 
  - **Phase 2 Payment:** Member pays the "Remaining Balance" (Phí dịch vụ còn lại) once the catcher marks the mission as successfully resolved.
- **Normal cases:** Catcher arrives -> Completes the job -> System generates final bill -> Member pays Remaining Balance via Wallet/PayOS.
- **Abnormal cases:** 
  - Phase 2 Payment Fails -> Incident remains in "Pending Final Settlement" state until the user successfully completes the second payment.

---

### 3.4.9 Scheduled Expert Consultation
**Function trigger:** Member requires scheduled professional clinical or zoological advice. Navigation path: Member Home -> Consultation Home -> Expert List -> Expert Detail -> Service Selection -> Consultation Time Selection -> Consultation Documents -> Payment Confirmation.
**Function description:**
- **Actor:** Member.
- **Purpose:** Schedule future synchronous telemedicine and expert advisory sessions.
- **Interface:** Filterable expert directories, calendar pickers, medical document upload forms, and checkout gateways.
- **Data processing:** Execute calendar scheduling logic, process escrow payment transactions.
- **Screen layout:** 

**Function details:**
- **Data:** Selected expert ID, ISO8601 timeslots, multipart clinical documents, payment intent tokens.
- **Validation:** Scheduled timeslots must strictly avoid overlap; Escrow payment capture must perfectly succeed before session locks.
- **Business rules:** Scheduled sessions commit funds into escrow pending successful timeline execution and session completion.
- **Normal cases:** Member schedules doc -> pays -> receives scheduled appointment confirmation.
- **Abnormal cases:** Scheduling conflicts return block errors; Payment gateway rejects card.

---

### 3.4.10 Instant Expert Consultation
**Function trigger:** Member requires immediate professional advice without waiting. Navigation path: Member Home -> Consultation Home -> Expert List -> Expert Detail -> Service Selection -> Consultation Documents -> Payment Confirmation -> Emergency Request Waiting.
**Function description:**
- **Actor:** Member & On-Call Expert.
- **Purpose:** Immediately request an ad-hoc consultation with an available on-call expert and enter the priority queue.
- **Interface:** Filterable active directories, instant-connect medical document upload forms, checkout gateways, and queue waiting interface.
- **Data processing:** Query active status (On-Call) logic, process immediate escrow payment, assign expert.
- **Screen layout:** 

**Function details:**
- **Data:** Targeted active expert ID, multipart clinical payloads, payment intent tokens.
- **Validation:** Selected expert must be flagged 'Active/On-Call'; Payment processing must be prioritized for instant clearance.
- **Business rules:** Bypasses standard scheduling grids; Locks current availability immediately upon successful escrow commit.
- **Normal cases:** Member selects on-call expert -> pays -> instantly routes to Emergency Request Waiting.
- **Abnormal cases:** Selected expert drops offline just before payment clears (system triggers refund or re-routes).

---

### 3.4.11 Video Consultation & Completion
**Function trigger:** Time arrives for a scheduled appointment OR an instant consultation request is accepted. Navigation path: Video Waiting Room -> Video Consultation -> Consultation Complete.
**Function description:**
- **Actor:** Member & Expert.
- **Purpose:** Facilitate the actual synchronous telemedicine video session and provide final medical notes/prescriptions.
- **Interface:** Pre-call lobby, live WebRTC video and audio interfaces, and post-call summary views.
- **Data processing:** Instantiate WebRTC signaling and media streams, process session completion to release escrow funds.
- **Screen layout:** 

**Function details:**
- **Data:** RTC connection descriptors, final medical prescription data, expert notes.
- **Validation:** Device camera/mic permissions required. Stable network connection.
- **Business rules:** Consultation is officially marked complete only after the expert ends the session and provides the summary, triggering the release of escrow funds.
- **Normal cases:** Member enters waiting room -> connects with expert -> finishes call -> views completion summary.
- **Abnormal cases:** WebRTC ICE failure drops video -> UI gracefully downgrades to audio-only or text chat; ICE server fails connection completely.

---
### 3.4.12 Knowledge Base
**Function trigger:** Member accesses educational resources. Navigation path: Member Home -> (Snake Library -> Snake Detail -> Snake First Aid Guide) or (Blog List -> Blog Detail).
**Function description:**
- **Actor:** Member.
- **Purpose:** Equip the general public with authoritative zoological parameters and comprehensive safety/preventative literature.
- **Interface:** Rich media libraries, searchable encyclopedic UI, detailed taxonomy cards, and long-form markdown blog readers.
- **Data processing:** Fetch structured JSON/CMS taxonomies, cache heavy assets locally, parse and render markdown safely.
- **Screen layout:** 

**Function details:**
- **Data:** Species taxonomy databases, risk classification metrics, geographical habitats, raw markdown blog payloads.
- **Validation:** N/A (Mostly Read-only queries).
- **Business rules:** Snake Detail views must prominently feature a direct CTA to that specific species' First Aid Guide to cut down navigation time in edge-case panics.
- **Normal cases:** Member queries "Viper" -> Reads habitat detail -> Swipes to verify recommended first-aid.
- **Abnormal cases:** Heavy network latency -> App serves last cached version of the Library to ensure availability.

---

### 3.4.13 Member Wallet & Transactions
**Function trigger:** User accesses financial settings or completes a paid flow. Navigation path: Profile Tab -> History Wallet -> (Top-up / Withdrawal / History Transaction -> Transaction Detail).
**Function description:**
- **Actor:** Member.
- **Purpose:** Manage platform-native funds serving as the primary payment method for consultations and premium catching services.
- **Interface:** Financial ledger dashboards, input fields for deposit/withdraw amounts, and detailed transactional receipts.
- **Data processing:** Mutate digital ledger states, interface with 3rd-party Payment Processor APIs (e.g., Stripe/PayOS/Momo), process webhooks.
- **Screen layout:** 

**Function details:**
- **Data:** Integer/Decimal balance structures, fiat currency exchange mappings, unique transaction IDs, status enumerations (Pending, Completed, Failed).
- **Validation:** Withdrawal requests must exceed minimum systemic thresholds and cannot exceed available unheld balance.
- **Business rules:** Wallet balances are instantly deducted and held in escrow when a service is booked; Failed services automatically refund to the wallet.
- **Normal cases:** Member tops up via Momo -> webhook confirms -> Balance reflects change -> Member pays for Consultation.
- **Abnormal cases:** Third-party gateway delays webhook -> UI marks transaction as "Processing" and polls until definitive state is reached.

---

### 3.4.14 Profile & Activity Overviews
**Function trigger:** Member inspects personal records. Navigation path: Profile Tab -> (Edit Profile / Settings) or Activity Tab -> (Activity Detail / Activity History).
**Function description:**
- **Actor:** Member.
- **Purpose:** Authorize profile modifications, toggle application configurations, and maintain a rigorous audit trail of all historical engagements.
- **Interface:** Interactive form components, global toggle switches (dark mode/language), and complex chronologically sorted activity cards.
- **Data processing:** Perform CRUD operations on user schematics, aggregate scattered microservice logs into unified Activity timelines.
- **Screen layout:** 

**Function details:**
- **Data:** Core demographic PII, application state preferences, unified incident/consultation discrete historical payload objects.
- **Validation:** PII changes subject to strict regex constraints (Email/Phone format integrity).
- **Business rules:** Historical activity records are tightly bound and immutable (cannot be deleted by user for legal/audit safety reasons).
- **Normal cases:** Member adjusts App Language -> Preferences save locally and sync -> UI re-renders instantly.
- **Abnormal cases:** Upstream microservice failure preventing Activity History aggregation -> UI informs user of temporary partial data availability.
