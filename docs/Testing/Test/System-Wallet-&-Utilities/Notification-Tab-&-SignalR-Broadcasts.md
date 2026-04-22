# Notification Tab & SignalR Broadcasts

## Summary

| Field | Value |
|---|---|
| Feature | Notification Tab & SignalR Broadcasts |
| Test requirement | Verify notification inbox behavior (badge, list, read/unread, refresh, error) and realtime SignalR broadcasts for emergency flows (RescuerHub/MissionHub) including reconnect behavior |
| Number of TCs | 10 |

## Testing Round Summary

| Testing Round | Passed | Failed | Pending | N/A |
|---|---:|---:|---:|---:|
| Round 1 | 0 | 0 | 10 | 0 |
| Round 2 | 0 | 0 | 10 | 0 |
| Round 3 | 0 | 0 | 10 | 0 |

## Test Cases

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Round 1 | Test date | Tester | Round 2 | Test date | Tester | Round 3 | Test date | Tester | Note |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC3201 | Open notification inbox from app entry points | 1) Login as Member, Rescuer, or Expert<br>2) Tap notification icon / open route `/notifications`<br>3) Observe screen | App opens screen titled "Thông báo" and loads inbox list UI | Account is logged in and authorized | Pending |  |  | Pending |  |  | Pending |  |  | Multi-role entry |
| TC3202 | Unread badge appears when unreadCount > 0 | 1) Prepare account with unread notifications<br>2) Open Home/MainScaffold header or tab bar<br>3) Observe notification icon | Red badge/dot is displayed while unread notifications exist | Notification inbox data contains unread items | Pending |  |  | Pending |  |  | Pending |  |  | Badge visibility |
| TC3203 | Load initial notifications and render list state | 1) Open notification inbox<br>2) Wait for initial API load<br>3) Verify tile content | App calls notifications API, renders items with title/message/time, and highlights unread entries | `/api/notifications` returns valid page data | Pending |  |  | Pending |  |  | Pending |  |  | Initial load |
| TC3204 | Pull-to-refresh and app-bar refresh reload inbox | 1) Open inbox with existing items<br>2) Pull down to refresh<br>3) Tap app-bar refresh icon | Inbox reloads latest page, preserving stable UI and updated unread count | Notification screen is open and network/API is reachable | Pending |  |  | Pending |  |  | Pending |  |  | Manual refresh |
| TC3205 | Infinite scroll loads additional pages | 1) Seed account with notifications across multiple pages<br>2) Scroll near end of list<br>3) Observe loader and appended items | App triggers load-more once threshold is reached and appends next-page results without replacing existing items | API provides `hasNextPage=true` for page 1 | Pending |  |  | Pending |  |  | Pending |  |  | Pagination |
| TC3206 | Open notification detail and mark as read | 1) Tap one unread notification tile<br>2) Observe detail dialog<br>3) Close dialog and inspect tile/badge | Notification is marked read via API, unread indicator disappears, and unread badge/count decreases accordingly | At least one unread notification exists | Pending |  |  | Pending |  |  | Pending |  |  | Read flow |
| TC3207 | Notification API error state and retry recovery | 1) Simulate notification API failure (network/server)<br>2) Open inbox<br>3) Tap "Thử lại" | App shows error state instead of crashing; retry triggers fresh load and recovers when API is available | Test environment can simulate API failure and recovery | Pending |  |  | Pending |  |  | Pending |  |  | Error handling |
| TC3208 | RescuerHub broadcast delivers new dispatch request | 1) Login as Rescuer and connect realtime rescue mode<br>2) Trigger backend event `DispatchRequested` (or legacy `NewRescueRequest`)<br>3) Observe rescue request UI | App receives SignalR event in realtime, parses payload, and surfaces new rescue request workflow without manual refresh | Rescuer is connected to RescuerHub (`JoinAsRescuer`) | Pending |  |  | Pending |  |  | Pending |  |  | SignalR broadcast |
| TC3209 | MissionHub broadcasts mission status/location updates | 1) Connect Member/Rescuer to MissionHub for active incident<br>2) Trigger events: `RescuerAccepted`, `RescuerLocationUpdated`, `MissionStarted`, `RescuerArrived`<br>3) Observe tracking/status UI | App receives events in realtime, updates mission state and tracking data immediately | Active incident exists and MissionHub connection is established | Pending |  |  | Pending |  |  | Pending |  |  | Realtime tracking |
| TC3210 | SignalR reconnect behavior after app resume | 1) Login as Rescuer and establish SignalR connection<br>2) Move app to background then resume<br>3) Observe connection state and incoming events | App attempts reconnect on resume when disconnected and resumes receiving realtime events after reconnection | Rescuer lifecycle observer is initialized and rescuer account is online | Pending |  |  | Pending |  |  | Pending |  |  | Lifecycle reliability |
