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
| 1 | Auth & Account Management | Splash | Initial app loading and routing |
| 2 | Auth & Account Management | Member Registration | Register a new member account |
| 3 | Auth & Account Management | OTP Verification | Verify phone/email with OTP |
| 4 | Auth & Account Management | Registration Success | Confirmation of successful registration |
| 5 | Auth & Account Management | Member Login | Authenticate member |
| 6 | Auth & Account Management | Forgot Password | Initiate password recovery |
| 7 | Auth & Account Management | Forgot Password OTP | Validate OTP for recovery |
| 8 | Auth & Account Management | Reset Password | Enter new password |
| 9 | Auth & Account Management | Password Reset Success | Confirmation of reset |
| 10 | Member Home & Notifications | Member Home | Main dashboard |
| 11 | Community Alerts & Reporting | Community Alert | View nearby community reports |
| 12 | Member Home & Notifications | Notification Tab | View alerts and system messages |
| 13 | Emergency SOS Initiation | Emergency Action | Start SOS and snake identification |
| 14 | Emergency SOS Initiation | Snake Identification | AI-based snake scan/identification |
| 15 | Emergency SOS Initiation | Snake Selection by Location | Manual snake search by area |
| 16 | Emergency SOS Initiation | Snake Confirmation | Confirm identified snake species |
| 17 | First Aid & Symptom Reporting | First Aid Steps | Step-by-step immediate first aid |
| 18 | First Aid & Symptom Reporting | Symptom Report | Select patient symptoms |
| 19 | First Aid & Symptom Reporting | Severity Assessment | AI/System determines emergency level |
| 20 | Emergency Tracking & Resolution | Emergency Tracking | Live tracking of inbound rescuer |
| 21 | Emergency Tracking & Resolution | Member Incident Finished | Summary after SOS resolution |
| 22 | Snake Catching Service | Snake Catching | Initiate non-emergency catch request |
| 23 | Snake Catching Service | Snake Quantity Selection | Estimate number of snakes |
| 24 | Snake Catching Service | Snake Report Detail | Provide incident context |
| 25 | Snake Catching Service | Snake Catching Success | Confirmation of request submission |
| 26 | Expert Consultation Booking | Consultation Home | Hub for telemedicine services |
| 27 | Expert Consultation Booking | Expert List | Directory of available experts |
| 28 | Expert Consultation Booking | Expert Detail | Expert profile and reviews |
| 29 | Expert Consultation Booking | Service Selection | Choose consultation type/tier |
| 30 | Expert Consultation Booking | Consultation Time Selection | Pick date/time for scheduled call |
| 31 | Expert Consultation Booking | Consultation Documents | Upload media/notes for doctor |
| 32 | Expert Consultation Booking | Payment Confirmation | Escrow payment before consultation |
| 33 | Expert Consultation Booking | Emergency Request Waiting | Wait queue for emergency consult |
| 34 | Expert Consultation Booking | Video Waiting Room | Pre-call lobby |
| 35 | Expert Consultation Booking | Video Consultation | Live WebRTC video session |
| 36 | Expert Consultation Booking | Consultation Complete | Call summary and prescription |
| 37 | Knowledge Base | Snake Library | Browse encyclopedic snake data |
| 38 | Knowledge Base | Snake Detail | Specific snake info and risks |
| 39 | Knowledge Base | Snake First Aid Guide | Detailed first-aid for species |
| 40 | Knowledge Base | Blog List | Browse educational articles |
| 41 | Knowledge Base | Blog Detail | Read article content |
| 42 | Profile, Activity & Settings | Profile Tab | User profile summary |
| 43 | Profile, Activity & Settings | Edit Profile | Modify personal details |
| 44 | Auth & Account Management | Role Selection | Choose Member or Rescuer login |
| 45 | Community Alerts & Reporting | Edit Community Report | Modify own community alert |
| 46 | Community Alerts & Reporting | History Community | Log of user's past reports |
| 47 | Community Alerts & Reporting | Upload Community Report | Submit new community alert |
| 48 | Emergency Tracking & Resolution | Rescuer Arrived | Rescuer on-scene confirmation |
| 49 | Profile, Activity & Settings | Activity Tab | Overview of past activities |
| 50 | Snake Catching Service | Snake Catching Detail | Review completed catching mission |
| 51 | User Wallet & Transactions | History Transaction | Log of fiat/wallet operations |
| 52 | User Wallet & Transactions | Transaction Detail | Specific payment receipt |
| 53 | User Wallet & Transactions | Top-up | Add funds to wallet |
| 54 | User Wallet & Transactions | Withdrawal | Request payout from wallet |
| 55 | User Wallet & Transactions | History Wallet | Balance changes overview |
| 56 | Expert Consultation Booking | Scheduled Consultation | View upcoming scheduled calls |
| 57 | Expert Consultation Booking | Emergency Consultation | Quick connect for urgent cases |
| 58 | Profile, Activity & Settings | Settings | App preferences and configurations |
| 59 | Profile, Activity & Settings | Activity Detail | Breakdown of specific past activity |
| 60 | Profile, Activity & Settings | Activity History | Full list of historical events |

### 3.3.2 Authorization


| Screen | Member | Rescuer | Expert | Admin | Operator |
|--------|:------:|:-------:|:------:|:-----:|:--------:|
| Splash | X | | | | |
| Member Registration | X | | | | |
| OTP Verification | X | | | | |
| Registration Success | X | | | | |
| Member Login | X | | | | |
| Forgot Password | X | | | | |
| Forgot Password OTP | X | | | | |
| Reset Password | X | | | | |
| Password Reset Success | X | | | | |
| Member Home | X | | | | |
| Community Alert | X | | | | |
| Notification Tab | X | | | | |
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
| Video Consultation | X | | | | |
| Consultation Complete | X | | | | |
| Snake Library | X | | | | |
| Snake Detail | X | | | | |
| Snake First Aid Guide | X | | | | |
| Blog List | X | | | | |
| Blog Detail | X | | | | |
| Profile Tab | X | | | | |
| Edit Profile | X | | | | |
| Role Selection | X | | | | |
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
| Settings | X | | | | |
| Activity Detail | X | | | | |
| Activity History | X | | | | |




## 3.4 Member Portal Feature

---

### 3.4.1 Auth & Account Management
**Function trigger:** Launching the app unauthenticated, or choosing to log out.
**Function description:**
- **Actor:** Guest / Member.
- **Purpose:** Allow users to securely register, verify identity via OTP, log in, and recover forgotten passwords.
- **Interface:** Role selection, input forms for phone/email, OTP input fields, success confirmations.
- **Data processing:** Validates credentials against identity provider (e.g., Firebase Auth or custom backend).
- **Screen layout:** 
**Function details:**
- **Related Screens:** Splash, Role Selection, Member Registration, OTP Verification, Registration Success, Member Login, Forgot Password, Forgot Password OTP, Reset Password, Password Reset Success.
- **Data:** Credentials (email/phone, password), OTP codes, User details (name, DOB).
- **Validation:** Password strength, valid email/phone format, valid unexpired OTP.
- **Business rules:** Account must be verified via OTP before first login.
- **Normal cases:** User registers -> receives OTP -> verifies -> logs in successfully.
- **Abnormal cases:** Invalid OTP -> display error; User exists -> prompt to log in.

---

### 3.4.2 Member Home & Notifications
**Function trigger:** Successful login or navigating from bottom tabs.
**Function description:**
- **Actor:** Member.
- **Purpose:** Central hub providing quick access to primary actions (SOS, Catching, Consult) and displaying important alerts.
- **Interface:** Bottom navigation, SOS hero button, quick access grid, Notification Tab.
- **Data processing:** Fetch profile summary, unread notifications, and active ongoing incidents.
- **Screen layout:** 
**Function details:**
- **Related Screens:** Member Home, Notification Tab.
- **Data:** Profile state, Notification array (alerts, system messages).
- **Validation:** Requires active session.
- **Business rules:** If an Active Emergency exists, show a persistent tracking banner at the top of Home. 
- **Normal cases:** Dashboard loads, user taps "Notification Tab" to view read/unread alerts.
- **Abnormal cases:** Offline mode -> display cached dashboard with "No internet" indicator.

---

### 3.4.3 Community Alerts & Reporting
**Function trigger:** Selecting Community Alert on the home page.
**Function description:**
- **Actor:** Member.
- **Purpose:** View nearby community alerts or upload new alert/report.
- **Interface:** Map or list of alerts, History Community, form to create/edit new reports.
- **Data processing:** Fetching geolocated alerts and posting user reports.
- **Screen layout:** 
**Function details:**
- **Related Screens:** Community Alert, History Community, Upload Community Report, Edit Community Report.
- **Data:** Location (lat/lng), description, photos.
- **Validation:** Report needs at least a photo and description.
- **Business rules:** Reports might require moderation or are shown with a warning label.
- **Normal cases:** User sees a snake -> Uploads Community Report -> Report is broadcasted.

---

### 3.4.4 Emergency SOS Initiation & Identification
**Function trigger:** Tapping the prominent "Emergency Action" (SOS) button on the Home screen.
**Function description:**
- **Actor:** Member.
- **Purpose:** Start the crucial emergency flow to identify the threat quickly.
- **Interface:** AI Camera view for real-time scanning, Filtered Results, Location-based selection, and Final Confirmation.
- **Data processing:** Camera feed processing using ML models. Question-based/location-based filtering logic.
- **Screen layout:** 
**Function details:**
- **Related Screens:** Emergency Action, Snake Identification, Snake Selection by Location, Snake Confirmation.
- **Data:** Image frames, Device Location (lat/lng), manual IDs.
- **Validation:** Camera/Location permissions required.
- **Business rules:** Speed is critical. If AI fails, fallback to Question-based or Location-based filtering securely.
- **Normal cases:** User takes a photo -> AI identifies snake -> Filtered Results -> Confirmation.
- **Abnormal cases:** AI fails to predict -> Fallback gracefully to manual location search.

---

### 3.4.5 First Aid & Symptom Reporting
**Function trigger:** Post-snake-identification or directly if the snake is unknown.
**Function description:**
- **Actor:** Member.
- **Purpose:** Provide immediate life-saving instructions and assess patient condition.
- **Interface:** Step-by-step visual guides, Symptom ticking/selection forms.
- **Data processing:** Map the identified snake to correct first aid protocols. Calculate priority based on reported symptoms.
- **Screen layout:** 
**Function details:**
- **Related Screens:** First Aid Steps, Symptom Report, Severity Assessment.
- **Data:** Chosen symptoms, time elapsed since bite.
- **Validation:** Must select at least "No symptoms yet" to proceed.
- **Business rules:** Never give medical diagnostic guarantees, only triage severity to push to rescuer/hospital.
- **Normal cases:** Reads first aid -> Inputs symptoms -> System assesses severity -> Continues to tracking.
- **Abnormal cases:** User skips -> Default to highest unknown severity to be safe.

---

### 3.4.6 Emergency Tracking & Resolution
**Function trigger:** After SOS is fully dispatched and help is en route.
**Function description:**
- **Actor:** Member.
- **Purpose:** Real-time visibility into the rescue operation and incident closure.
- **Interface:** Live map, ETA timers, status updates, completion summary.
- **Data processing:** WebSocket/MQTT location streaming from responding rescuer.
- **Screen layout:** 
**Function details:**
- **Related Screens:** Emergency Tracking, Rescuer Arrived, Member Incident Finished.
- **Data:** Rescuer live coordinates, Status milestones (Assigned, En Route, Arrived, Resolved).
- **Validation:** Location tracking relies on active background services of the rescuer.
- **Business rules:** Member cannot cancel if rescuer is already arrived.
- **Normal cases:** Watch rescuer approach -> Rescuer Arrived -> Incident finishes -> Shows summary.
- **Abnormal cases:** Rescuer disconnects -> Reassign to another rescuer automatically.

---

### 3.4.7 Snake Catching Service
**Function trigger:** User selects the "Snake Catching" feature from the Home Screen.
**Function description:**
- **Actor:** Member.
- **Purpose:** Request professional help to remove a snake from a property (Non-medical emergency).
- **Interface:** Location pin, quantity selection, detailed report form.
- **Data processing:** Matches request with available catchers nearby.
- **Screen layout:** 
**Function details:**
- **Related Screens:** Snake Catching, Snake Quantity Selection, Snake Report Detail, Snake Catching Success, Snake Catching Detail.
- **Data:** Address, Number of snakes, Situation description/photo.
- **Validation:** Address must be valid and within service range.
- **Business rules:** Catching requests are prioritized lower than SOS medical emergencies.
- **Normal cases:** Selects location -> Details the issue -> Catches dispatched -> Success summary.
- **Abnormal cases:** No catchers available -> Display "No nearby responders" message.

---

### 3.4.8 Expert Consultation Booking & Live Video
**Function trigger:** Navigating to "Consultation Home" from Home.
**Function description:**
- **Actor:** Member.
- **Purpose:** Schedule a telemedicine or advice session with a verified snake/medical expert. Also conduct the video call.
- **Interface:** Expert directory, scheduled or emergency options, document uploads, and video/audio interface.
- **Data processing:** Booking slots handling. Setting up WebRTC streams for video calls.
- **Screen layout:** 
**Function details:**
- **Related Screens:** Consultation Home, Scheduled Consultation, Emergency Consultation, Expert List, Expert Detail, Service Selection, Consultation Time Selection, Consultation Documents, Payment Confirmation, Emergency Request Waiting, Video Waiting Room, Video Consultation, Consultation Complete.
- **Data:** Selected expert, Timeslot, Uploaded images (e.g., wound), WebRTC streams.
- **Validation:** Selected time must not overlap. Payment must succeed.
- **Business rules:** Payment held in escrow until consultation concludes. Emergency consultation routes to any available on-call expert directly.
- **Normal cases:** Books expert -> Waits for time -> Joins Waiting Room -> Video Consults -> Complete.

---

### 3.4.9 Knowledge Base (Library & Blogs)
**Function trigger:** Tapping Library or Blog sections.
**Function description:**
- **Actor:** Member.
- **Purpose:** Educate users on snake species, habitats, and general safety tips.
- **Interface:** Searchable lists, detailed encyclopedic views.
- **Data processing:** Fetching CMS data.
- **Screen layout:** 
**Function details:**
- **Related Screens:** Snake Library, Snake Detail, Snake First Aid Guide, Blog List, Blog Detail.
- **Data:** Species taxonomies, high-res images, markdown blog articles.
- **Validation:** N/A (Read-only).
- **Business rules:** Keep data cached for offline access where possible.
- **Normal cases:** Searching for "Cobra" -> views details -> reads specific first aid.
- **Abnormal cases:** Search yields no results -> "Not found" illustration.

---

### 3.4.10 User Wallet & Transactions
**Function trigger:** Navigating to Wallet or Transaction History.
**Function description:**
- **Actor:** Member.
- **Purpose:** Manage platform funds for paying consultations or premium catching services.
- **Interface:** Wallet overview, Top-up forms, Withdrawal requests, Transaction logs.
- **Data processing:** Handling logic with payment gateways (Stripe/Paypal/Momo).
- **Screen layout:** 
**Function details:**
- **Related Screens:** History Wallet, History Transaction, Transaction Detail, Top-up, Withdrawal.
- **Data:** Account balance, Fiat currency logs, Gateway tokens.
- **Validation:** Minimum withdrawal amounts. Successful top-up callbacks.
- **Business rules:** Balance is deducted instantly when a paid service is locked in.
- **Normal cases:** User tops up -> Balance updates -> Uses for consultation.

---

### 3.4.11 Profile, Activity & Settings
**Function trigger:** Navigating to Profile Tab or Settings.
**Function description:**
- **Actor:** Member.
- **Purpose:** Manage personal settings, modify profile, and review past incidents/consultations.
- **Interface:** Standard settings lists, historical timeline cards, edit forms.
- **Data processing:** Fetching detailed user history logs and updating profile states.
- **Screen layout:** 
**Function details:**
- **Related Screens:** Profile Tab, Edit Profile, Settings, Activity Tab, Activity Detail, Activity History.
- **Data:** User details, app preferences (language, notification).
- **Validation:** Profile updates must meet constraints.
- **Business rules:** Incident history cannot be deleted by the user for legal/safety tracking reasons.
- **Normal cases:** Open Profile -> Edits info -> Save -> Open Settings -> Toggles dark mode.
