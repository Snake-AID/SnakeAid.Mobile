# SNAKEAID - SYSTEM TEST MODULES (TEST PLAN)

This document defines the list of Module Codes (Test Case clusters) for the entire SnakeAid system. The test matrix ensures 100% coverage for:
- **3 main flows:** Snake Catching, SOS Emergency, Expert Consultation.
- **Supporting flows:** Authentication, Wallet, History, Knowledge Base.
- **Community/Blog interactions:** Community Alerts, Blog Posts, Lessons.
- **Core system:** Real-time (SignalR), Payment, GPS Tracking.

---

| No | Module code | Passed | Failed | Pending | N/A | Number of test cases | Description | Pre-Condition |
|----|-------------|--------|--------|---------|-----|----------------------|-------------|-------------|
| **A** | **Authentication & Identity Management** | | | | | | | |
| 1 | Sign Up & Role Registration (Member, Rescuer)  | 0 | 0 | 0 | 0 | 0 | Create a new account and select the correct role. | No existing account uses the same email/phone number. |
| 2 | Sign In With Password (All Roles)  | 0 | 0 | 0 | 0 | 0 | Sign in with valid credentials for the selected role. | The account is active and the password is correct. |
| 3 | Forgot & Reset Password Flow  | 0 | 0 | 0 | 0 | 8 | Request a password reset and complete the new password setup. | The account is active and can receive OTP/email verification. |
| 4 | Manage User Profile, Avatar & Settings  | 0 | 0 | 0 | 0 | 0 | Update personal information, avatar, and account settings. | The user is logged in. |
| 5 | Identity Document Verdification (Rescuer/Expert)  | 0 | 0 | 0 | 0 | 8 | Submit, view, and update identity verification documents. | The user is logged in as Rescuer or Expert. |
| **B** | **Snake Catching Flow (Snake Catching Flow)** | | | | | | | |
| 6 | Create Snake Catching Request (Images, GPS, Species)  | 0 | 0 | 0 | 0 | 0 | Create a snake catching request with photos, location, and species details. | The user is a Member, GPS is enabled, and image upload is available. |
| 7 | Process Catching Deposit (Round 1)  | 0 | 0 | 0 | 0 | 0 | Pay the initial deposit for the snake catching request. | The snake catching request has been created and is ready for payment. |
| 8 | Operator Verification & Assignment  | 0 | 0 | 0 | 0 | 0 | Operator reviews the request and assigns a rescuer. | There is a pending request in the operator queue. |
| 9 | Rescuer EnRoute & Arrived Tracking  | 0 | 0 | 0 | 0 | 0 | Track travel status and confirm arrival at the scene. | The request has been assigned to a rescuer and is in progress. |
| 10 | Rescuer Mission Execution & Evidence Upload  | 0 | 0 | 0 | 0 | 0 | Rescuer performs the mission and uploads completion evidence. | The rescuer has entered an assigned mission. |
| 11 | Process Actual Service Payment (Round 2)  | 0 | 0 | 0 | 0 | 0 | Pay the remaining service amount after completion. | The mission is completed and an additional payment is required. |
| 12 | Cancel Catching Request & Deposit Refund  | 0 | 0 | 0 | 0 | 0 | Cancel the snake catching request and refund the deposit when allowed. | The request is still in a refundable/cancellable state. |
| **C** | **SOS Emergency Flow (SOS Emergency Flow)** | | | | | | | |
| 13 | Trigger SOS Alarm (GPS, Symptoms, AI check)  | 0 | 0 | 0 | 0 | 0 | Send an SOS alert with location, symptoms, and AI assistance checks. | The user is logged in and location permission is granted. |
| 14 | Operator Fast-Track Verification & Assignment  | 0 | 0 | 0 | 0 | 0 | Operator quickly verifies and assigns the SOS case. | There is a new SOS alert in the processing queue. |
| 15 | Rescuer On-Scene Navigation & AI Triage  | 0 | 0 | 0 | 0 | 0 | Rescuer navigates to the scene and supports initial triage. | The SOS case has been assigned to a rescuer. |
| 16 | SOS Find Nearest Hospital (Navigation)  | 0 | 0 | 0 | 0 | 0 | Find the nearest hospital for emergency navigation. | The device has GPS access and map data available. |
| 17 | Process SOS Post-Service Payment  | 0 | 0 | 0 | 0 | 0 | Process payment after the SOS support is completed. | The SOS session has ended and a payment is due. |
| **D** | **Expert Consultation Flow (Expert Consultation Flow)** | | | | | | | |
| 18 | View & Filter Expert Directory  | 0 | 0 | 0 | 0 | 0 | View the expert list and filter by specialty, price, or rating. | The user can access the expert directory screen. |
| 19 | Book Instant Consultation (On-call)  | 0 | 0 | 0 | 0 | 0 | Book an instant consultation with an available expert. | The expert is online and available for immediate support. |
| 20 | Book Scheduled Consultation (Calendar, Time Slot)  | 0 | 0 | 0 | 0 | 0 | Book a consultation using the selected date and time slot. | A valid time slot is available and booking is enabled. |
| 21 | Process Consultation Escrow Payment  | 0 | 0 | 0 | 0 | 0 | Pay the escrow amount before the consultation starts. | The consultation booking is confirmed and ready for payment. |
| 22 | WebRTC Video Room & Waiting Room Logic  | 0 | 0 | 0 | 0 | 0 | Join the waiting room and video room for the consultation. | The consultation has reached its joinable time. |
| 23 | Cancellation & Escrow Refund (Expert-only cancel rule)  | 0 | 0 | 0 | 0 | 0 | Cancel the consultation and refund escrow according to rules. | The consultation is still in a cancellable state for the allowed role. |
| **E** | **Community, Blog & Knowledge Base (Community, Blog & Knowledge Base)** | | | | | | | |
| 24 | View Community Alerts & Reports   | 0 | 0 | 0 | 0 | 0 | View the community map, alerts, and related reports. | The user is logged in and community data is available. |
| 25 | View & Create Blog  | 0 | 0 | 0 | 0 | 12 | View the blog list and create new posts when allowed. | The user has blog access and post creation permission. |
| 26 | Confirm AI Snake Detection Image (Expert)  | 0 | 0 | 0 | 0 | 8 | Let the expert review and confirm the AI snake detection result. | There is a pending detection image for expert review. |
| 27 | Search & View Snake Library (Encyclopedia)  | 0 | 0 | 0 | 0 | 8 | Search and view snake species information in the library. | Snake library data is already loaded in the system. |
| 28 | Search & View First Aid Protocol Guides  | 0 | 0 | 0 | 0 | 8 | Search and open first-aid guides for snake species. | First-aid protocol data is available in the system. |
| 29 | Access Rescuer Training Lessons  | 0 | 0 | 0 | 0 | 8 | View the list and content of training lessons for rescuers. | The user is logged in as a Rescuer. |
| **F** | **System, Wallet & Utilities** | | | | | | | |
| 30 | Manage SnakeAidPay Wallet (Top-up, History, Withdraw)  | 0 | 0 | 0 | 0 | 10 | Manage SnakeAidPay wallet balance, top-ups, history, and withdrawals. | The user is logged in and has wallet access. |
| 31 | External Payment Interface (PayOS Callback)  | 0 | 0 | 0 | 0 | 9 | Verify the PayOS payment flow and callback status handling. | A valid payment transaction has been created from the app. |
| 32 | Notification Tab & SignalR Broadcasts  | 0 | 0 | 0 | 0 | 10 | View notifications and receive realtime updates through SignalR. | A logged-in account and realtime connection are available. |
| 33 | Submit Ratings & Read Feedback  | 0 | 0 | 0 | 0 | 10 | Submit ratings and read feedback for snake catching and consultation flows. | There is a completed service or a finished consultation session. |
| 34 | View Mission & Consultation History (Filtering, Detail)  | 0 | 0 | 0 | 0 | 10 | View mission and consultation history with filters and detail screens. | The user has at least one matching history record. |
| **G** | **Web Portal & Dashboard Management (Admin/Operator)** | | | | | | | |
| 35 | Operator Dashboard & Admin Dashboard | 0 | 0 | 0 | 0 | 0 | View the overview dashboard for Operator/Admin roles. | The user is logged in with the appropriate admin account. |
| 36 | Staff Workshifts Management | 0 | 0 | 0 | 0 | 0 | Manage staff shifts and duty schedules. | The user has permission to manage staff schedules. |
| 37 | Users Account & Role Management | 0 | 0 | 0 | 0 | 0 | Manage user accounts, roles, and activation states. | The admin account has user management permission. |
| 38 | System Incidents Management | 0 | 0 | 0 | 0 | 0 | Track and handle internal system incidents. | The admin/operator has permission to view and process incidents. |
| 39 | Snake Catchings Requests Management | 0 | 0 | 0 | 0 | 0 | Manage the list of snake catching requests in the system. | There is snake catching request data available. |
| 40 | Consultations Booking Management | 0 | 0 | 0 | 0 | 0 | Manage booking status and consultation booking history. | Consultation booking data is available for handling. |
| 41 | Snakes Catalog Management | 0 | 0 | 0 | 0 | 0 | Manage the snake species catalog in the database. | The admin has catalog management permission. |
| 42 | Antivenoms Inventory & Management | 0 | 0 | 0 | 0 | 0 | Manage antivenom inventory and item records. | The user has permission to manage medical inventory. |
| 43 | Treatment Facilities Database Management | 0 | 0 | 0 | 0 | 0 | Manage treatment facilities and hospitals in the system. | The user has permission to manage facility records. |
| 44 | Finance: Transactions & Withdrawals Management | 0 | 0 | 0 | 0 | 0 | Review financial transactions and withdrawal requests. | The user has permission to view finance data. |
| 45 | Report Media (User Reports) Management | 0 | 0 | 0 | 0 | 0 | Review and process community reports with media attachments. | User reports have been submitted to the system. |
| 46 | Portal System Settings & Configuration | 0 | 0 | 0 | 0 | 0 | Adjust configuration and system settings for the portal. | The admin account has system configuration permission. |
| 47 | Learning: Lessons Database Management | 0 | 0 | 0 | 0 | 0 | Manage learning lesson content in the training database. | The user has learning content management permission. |
| 48 | Content: Blogs Database Management | 0 | 0 | 0 | 0 | 0 | Manage blog posts and publishing states. | The admin/editor account has blog management permission. |

| | **TOTAL** | **0** | **0** | **0** | **0** | **109** | | |

---

### Cover Notes:
- **Core Flows (B, C, D):** Split by each step (Create request -> Assign -> Execute -> Payment -> Cancel). The consultation escrow flow and the refund rule for expert cancellation are covered in a separate module (Module 23).
- **Payment & Wallet (F):** Separates external payment flow (PayOS) from internal wallet flow (Modules 29, 30).
- **Blog & Knowledge Base (E):** Includes supporting flows such as Community Blog reading, Blog management, Snake Library, and First Aid guides.
- **System Stability (F):** Includes test cases for WebRTC video calls, SignalR realtime sockets, and push notifications to ensure the UI updates immediately when state changes.