﻿# RESCUER SCREEN FLOW — SnakeAid Mobile

**Phiên bản:** 1.1 | **Ngày:** 12/04/2026

> **Screens loại bỏ** (mock data / chưa kết nối API / không còn dùng trong flow rescuer): `History Detail` · `Income Management` · `ID Documents` · `Rescuer Registration` · `OTP Verification (registration)` · `Registration Pending` · `Registration Success`

---

## Screen Flow Diagram

```mermaid
flowchart LR
    SPLASH([Splash]) --> ROLE[Role Selection]

    ROLE --> LOGIN

    LOGIN --> FP[Forgot Password]
    FP --> FPOTP[Forgot Password OTP]
    FPOTP --> RPSET[Reset Password]
    RPSET --> RPSUCC[Password Reset Success]
    RPSUCC --> LOGIN

    LOGIN --> HOME[Rescuer Home]

    HOME --> JOBS[Available Jobs]
    JOBS --> REQD[Request Detail]
    REQD --> ACCEPT[Accept Request]
    ACCEPT --> ENRT[En Route]
    ENRT --> TRACK[Tracking]
    TRACK --> RESCONF[Result Confirmation]
    RESCONF --> SCSUCC[Mission Success - Snake Catching]
    SCSUCC --> JOBS

    HOME -->|SignalR SOS| EDETAIL[Mission Detail - SOS]
    EDETAIL --> ENAV[Navigation Map]
    ENAV --> ESUPPORT[On-scene Support]
    ESUPPORT --> EHOSP[Find Hospital]
    EHOSP --> ESUPPORT
    ESUPPORT --> ECOMPL[Mission Completion]
    ECOMPL --> ESUCC[Mission Success - Emergency]
    ESUCC --> HOME

    HOME --> HIST[Mission History]
    HIST --> HISTD[History Detail]
    HOME --> NOTIF[Notification Tab]

    HOME --> PROFILE[Profile Tab]
    PROFILE --> EDITP[Edit Profile]
    PROFILE --> SETTINGS[Settings]
    PROFILE --> FEEDBACK[Feedback]

    HOME --> LESSONS[Lessons]
    LESSONS --> LESSDET[Lesson Detail]

    HOME --> SNAKELIB[Snake Library]
    SNAKELIB --> SDETAIL[Snake Detail]
    SDETAIL --> GUIDE[First Aid Guide]

```

---

## Screen Inventory

| # | Screen | Route | API |
|---|--------|-------|:---:|
| 1 | Splash | app start | — |
| 2 | Role Selection | `/role-selection` | — |
| 3 | Rescuer Login | `/rescuer-login` | ✅ |
| 4 | Forgot Password | — | ✅ |
| 5 | Forgot Password OTP | — | ✅ |
| 6 | Reset Password | — | ✅ |
| 7 | Password Reset Success | — | — |
| 8 | **Rescuer Home** | `/rescuer-home` | ✅ SignalR |
| 9 | Available Jobs | `/rescuer-available-jobs` | ✅ |
| 10 | Request Detail | `Navigator.push` | ✅ |
| 11 | Accept Request | `Navigator.push` | ✅ |
| 12 | En Route | `Navigator.push` | ✅ GPS |
| 13 | Tracking | `Navigator.pushReplacement` | ✅ |
| 14 | Result Confirmation | `Navigator.push` | ✅ |
| 15 | Mission Success — Snake Catching | `Navigator.pushAndRemoveUntil` | ✅ |
| 16 | Mission Detail — SOS | `/rescuer/mission-detail/:id` | ✅ SignalR |
| 17 | Navigation Map | `/rescuer/navigation` | ✅ SignalR |
| 18 | On-scene Support | `/rescuer/support` | ✅ AI |
| 19 | Find Hospital | `/rescuer/find-hospital` | ✅ |
| 20 | Mission Completion | `/rescuer/mission-completion` | ✅ |
| 21 | Mission Success — Emergency | `/rescuer/mission-success` | ✅ |
| 22 | Mission History | `/rescuer-history` | ✅ |
| 23 | **Notification Tab** | embedded in Home shell | ✅ |
| 24 | Profile Tab | embedded in Home shell | ✅ |
| 25 | Edit Profile | `/rescuer-edit-profile` | ✅ |
| 26 | **Settings** | `/rescuer-settings` | 🚧 |
| 27 | **Feedback** | `/rescuer-feedback` | 🚧 |
| 28 | Lessons | `/rescuer-lessons` | ✅ |
| 29 | Lesson Detail | `Navigator.push` | ✅ |
| 30 | Snake Library | `/rescuer/snake-species` | ✅ |
| 31 | Snake Detail | `/snake-species/:id` | ✅ |
| 32 | First Aid Guide | `/snake-first-aid/:id` | ✅ |

---

## Screen Description

| # | Feature | Screen | Description |
|---|---------|--------|-------------|
| 1 | App Bootstrapping | Splash | App startup screen that validates session state and performs initial routing. |
| 2 | Authentication | Role Selection | Screen for selecting the user role before sign-in or sign-up. |
| 3 | Authentication | Rescuer Login | Login screen for rescuer users. |
| 4 | Authentication | Forgot Password | Screen to enter account/email and start the password recovery flow. |
| 5 | Authentication | Forgot Password OTP | OTP verification screen for the forgot-password flow. |
| 6 | Authentication | Reset Password | Screen for inputting and confirming a new secure password. |
| 7 | Authentication | Password Reset Success | Screen confirming that the password has been successfully updated. |
| 8 | Rescuer Workspace | Rescuer Home | Primary mission control dashboard providing daily statistics and current status. |
| 9 | Snake Catching | Available Jobs | List interface displaying open and active snake-catching requests nearby. |
| 10 | Snake Catching | Request Detail | Detailed view of a snake-catching request including photos and context. |
| 11 | Snake Catching | Accept Request | Confirmation dialog for committing to a dispatched rescue mission. |
| 12 | Snake Catching | En Route | Status screen tracking transit progress toward the target location. |
| 13 | Snake Catching | Tracking | Live monitoring interface maintaining system state during an active mission. |
| 14 | Snake Catching | Result Confirmation | Validation screen for confirming caught snake quantities and species. |
| 15 | Snake Catching | Mission Success - Snake Catching | Final summary screen concluding the completion of a snake catching job. |
| 16 | Emergency Response | Mission Detail - SOS | In-depth operational view for an active SOS medical emergency dispatch. |
| 17 | Emergency Response | Navigation Map | Real-time map interface mapping the optimal routing to the victim. |
| 18 | Emergency Response | On-scene Support | Interface detailing AI-recommended first-aid actions to perform on-scene. |
| 19 | Emergency Response | Find Hospital | Directory and routing interface for locating the nearest equipped hospital. |
| 20 | Emergency Response | Mission Completion | Check-out interface for finalizing the rescue operation and capturing evidence. |
| 21 | Emergency Response | Mission Success - Emergency | Final summary screen outlining the completed SOS emergency response. |
| 22 | Activity & History | Mission History | Chronological log displaying completed past rescue and catching operations. |
| 23 | Activity & History | History Detail | In-depth breakdown validating operational and financial specifics of a past mission. |
| 24 | Notification Tab | Notification Tab | Centralized paginated inbox handling system alerts and read/unread tracking. |
| 25 | Rescuer Profile | Profile Tab | Rescuer profile summary detailing performance metrics and ratings. |
| 26 | Rescuer Profile | Edit Profile | Form interface for modifying personal rescuer details and avatars. |
| 27 | Rescuer Profile | Settings | Application configuration interface for work modes and notification toggles. |
| 28 | Rescuer Reputation | Feedback | Interface for reviewing customer ratings and textual feedback. |
| 29 | Knowledge Base | Lessons | Educational hub providing modular training and procedural guides. |
| 30 | Knowledge Base | Lesson Detail | Content viewer screen for accessing specific training multimedia. |
| 31 | Knowledge Base | Snake Library | Encyclopedic database outlining snake species for field reference. |
| 32 | Knowledge Base | Snake Detail | Specific informational profile highlighting characteristics and handling risks. |
| 33 | Knowledge Base | First Aid Guide | Structured guide supplying exact first-aid procedures linked to species. |


---

## Screen Authorization

| Screen | Member | Rescuer | Expert | Admin | Operator |
|--------|:------:|:-------:|:------:|:-----:|:--------:|
| Splash | X | X | X |  |  |
| Role Selection | X | X | X |  |  |
| Rescuer Login |  | X |  |  |  |
| Forgot Password | X | X | X |  |  |
| Forgot Password OTP | X | X | X |  |  |
| Reset Password | X | X | X |  |  |
| Password Reset Success | X | X | X |  |  |
| Rescuer Home |  | X |  |  |  |
| Available Jobs |  | X |  |  |  |
| Request Detail |  | X |  |  |  |
| Accept Request |  | X |  |  |  |
| En Route |  | X |  |  |  |
| Tracking |  | X |  |  |  |
| Result Confirmation |  | X |  |  |  |
| Mission Success - Snake Catching |  | X |  |  |  |
| Mission Detail - SOS |  | X |  |  |  |
| Navigation Map |  | X |  |  |  |
| On-scene Support |  | X |  |  |  |
| Find Hospital |  | X |  |  |  |
| Mission Completion |  | X |  |  |  |
| Mission Success - Emergency |  | X |  |  |  |
| Mission History |  | X |  |  |  |
| History Detail |  | X |  |  |  |
| Notification Tab |  | X |  |  |  |
| Profile Tab |  | X |  |  |  |
| Edit Profile |  | X |  |  |  |
| Settings |  | X |  |  |  |
| Feedback |  | X |  |  |  |
| Lessons |  | X |  |  |  |
| Lesson Detail |  | X |  |  |  |
| Snake Library |  | X |  |  |  |
| Snake Detail |  | X |  |  |  |
| First Aid Guide |  | X |  |  |  |

---

---

---

## 3.4 Rescuer Portal Feature

---

### 3.4.1 Authentication
**Function trigger:** App initializes with an unauthenticated state or user initiates logout. Navigation path: Splash -> Role Selection -> Rescuer Login -> (Forgot Password -> Forgot Password OTP -> Reset Password -> Password Reset Success).
**Function description:**
- **Actor:** Rescuer.
- **Purpose:** Ensure secure identity verification, account access, and credential recovery for rescuer personnel.
- **Interface:** Role selection toggle, secure login forms, OTP input fields, and success confirmation overlays.
- **Data processing:** Validate credentials via Auth API, process OTP generation/verification for recovery, establish secure JWT sessions.
- **Screen layout:** 

**Function details:**
- **Data:** User credentials (email, password), OTP tokens, session JWT.
- **Validation:** Strict format enforcement for email/password; OTP must match and validate within the expiry window.
- **Business rules:** Rescuers must maintain an active authenticated session to access dispatch features; OTP expires after 5 minutes.
- **Normal cases:** Rescuer authenticates successfully and routes to Rescuer Home.
- **Abnormal cases:** Invalid credentials or expired OTP yield explicit error states; Auth API timeouts prompt retry.

---

### 3.4.2 Rescuer Workspace & Notifications
**Function trigger:** User successfully authenticated. Navigation path: Rescuer Login -> Rescuer Home <-> Notification Tab.
**Function description:**
- **Actor:** Rescuer (with system event triggers).
- **Purpose:** Serve as the central mission control hub, providing daily operational stats and global alert management.
- **Interface:** Dashboard with metrics, bottom navigation bar, active duty toggle, and paginated notification list.
- **Data processing:** Fetch daily statistics, establish SignalR connection for live dispatch events, synchronize read/unread notification states.
- **Screen layout:** 

**Function details:**
- **Data:** Rescuer ID, operational stats (completed missions, rating), active duty status, notification payload array.
- **Validation:** Rescuer must hold an active JWT and valid role mapping.
- **Business rules:** Notifications are marked read immediately upon interaction; Rescuer must toggle 'Active' to receive inbound dispatch events.
- **Normal cases:** Dashboard data loads seamlessly; Real-time dispatch alerts surface cleanly.
- **Abnormal cases:** SignalR connection drops trigger silent background reconnects; Network partitions show offline indicators.

---

### 3.4.3 Snake Catching Workflow
**Function trigger:** Rescuer selects an available job. Navigation path: Rescuer Home -> Available Jobs -> Request Detail -> Accept Request -> En Route -> Tracking -> Result Confirmation -> Mission Success - Snake Catching.
**Function description:**
- **Actor:** Rescuer (interacting with User request events).
- **Purpose:** Provide an end-to-end operational flow for accepting and executing non-emergency snake removal requests.
- **Interface:** Tabular job list, detailed request context cards, live route mapping, camera capture for evidence, and fee breakdown summaries.
- **Data processing:** Query geospatial job queues, calculate ETA via OSRM, process media evidence uploads, and submit finalized mission payloads.
- **Screen layout:** 

**Function details:**
- **Data:** Job request payload, target coordinates, equipment checklist state, photo evidence, confirmed snake species ID, calculated service fee.
- **Validation:** Target location must be resolvable; Mandatory photo evidence required before mission closure.
- **Business rules:** Acceptance binds the rescuer to the request SLA; System deducts platform commission from the final service fee.
- **Normal cases:** Rescuer navigates to location, captures snake, uploads evidence, and system records successful mission closure.
- **Abnormal cases:** OSRM routing fails gracefully to straight-line fallback; Evidence upload interruptions trigger retry queue.

---

### 3.4.4 Emergency Response Workflow
**Function trigger:** System emits high-priority SOS dispatch. Navigation path: Rescuer Home (SOS Alert) -> Mission Detail - SOS -> Navigation Map -> On-scene Support -> (Find Hospital) -> Mission Completion -> Mission Success - Emergency.
**Function description:**
- **Actor:** Rescuer (responding to SOS system events).
- **Purpose:** Orchestrate critical, time-sensitive emergency interventions including navigation, AI-backed first-aid, and medical facility routing.
- **Interface:** High-contrast SOS modal, live multi-pin tracking map, AI clinical support cards, and hospital proximity directory.
- **Data processing:** Bidirectional live GPS streaming via WebSocket, query AI triage models, fetch geospatial medical facility data.
- **Screen layout:** 

**Function details:**
- **Data:** Victim live coordinates, clinical symptoms payload, AI first-aid recommendations, hospital geodata, mission resolution timestamp.
- **Validation:** Requires real-time GPS permissions and persistent telemetry connection.
- **Business rules:** SOS missions explicitly override standard job queues; AI recommendations dynamically adjust based on mapped snake species/symptoms.
- **Normal cases:** Rapid dispatch acceptance, precise victim location tracking, successful on-scene stabilization, and optional hospital handover.
- **Abnormal cases:** Victim tracking telemetry cuts out (retains last known pin); AI recommendation endpoint degrades (shows cached generic first-aid).

---

### 3.4.5 Profile, Activity & Settings
**Function trigger:** Navigation via global menubar. Navigation path: Rescuer Home -> (Profile Tab -> Edit Profile / Settings / Feedback) or (Mission History -> History Detail).
**Function description:**
- **Actor:** Rescuer.
- **Purpose:** Manage personal identity, configure application behavior, and audit historical operational performance.
- **Interface:** Profile summaries, editable form fields, historical timeline lists, reputation badges, and preference toggles.
- **Data processing:** Retrieve and mutate profile records, fetch paginated historical mission ledgers, aggregate user reputation scores.
- **Screen layout:** 

**Function details:**
- **Data:** Rescuer biographical data, historical mission payloads (financials & status), application configuration states, aggregated review text.
- **Validation:** Input constraints on profile updates (e.g., valid phone regex).
- **Business rules:** Mission history ledgers are immutable read-only records; Reputation status recalibrates nightly based on user feedback.
- **Normal cases:** Rescuer updates profile avatar successfully; Historical ledger loads deep pagination correctly.
- **Abnormal cases:** Avatar media upload fails returning standard server error; Corrupted historical records render safe fallback states.

---

### 3.4.6 Knowledge Base
**Function trigger:** Rescuer explores educational modules. Navigation path: Rescuer Home -> (Lessons -> Lesson Detail) or (Snake Library -> Snake Detail -> First Aid Guide).
**Function description:**
- **Actor:** Rescuer.
- **Purpose:** Provide authoritative reference materials for species identification and procedural training.
- **Interface:** Categorized lesson lists, article viewers, searchable species dictionary, and structured first-aid protocol cards.
- **Data processing:** Fetch static CMS content, process client-side search filtering, load high-resolution taxonomy imagery.
- **Screen layout:** 

**Function details:**
- **Data:** Structured training content, species taxonomy (venom type, identifiers), procedural first-aid step arrays.
- **Validation:** Search queries sanitize input strings.
- **Business rules:** Critical first-aid data must be heavily cached for offline/remote access during field operations.
- **Normal cases:** Rescuer seamlessly searches and identifies an unknown species, immediately accessing its targeted first-aid protocol.
- **Abnormal cases:** Remote media loading stalls in low-bandwidth areas (displays cached placeholders).
