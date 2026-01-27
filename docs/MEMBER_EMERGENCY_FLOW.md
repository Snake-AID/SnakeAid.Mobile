# Emergency Member Flow - Complete Documentation

## Overview
This document provides comprehensive documentation for all 15 emergency member screens in the SnakeAid mobile application's SOS flow.

---

## Complete Screen Flow

```
┌─────────────────────┐
│   Home Screen       │
│   (SOS Button)      │
└──────┬──────────────┘
       │
       v
┌─────────────────────────────┐
│ Emergency Alert Screen      │
│ - Countdown timer           │
│ - Location sharing          │
│ - Auto-call rescuers        │
└──────┬──────────────────────┘
       │
       v
┌─────────────────────────────┐
│ Snake Identification        │
│ - Live camera preview       │
│ - Capture photo             │
│ - 3 options:                │
│   • AI Recognition          │
│   • Select by Location      │
│   • Answer Questions        │
└──────┬──────────────────────┘
       │
       ├─── AI Recognition ───────┐
       │                          │
       ├─── Location Selection ───┤
       │                          │
       └─── Questions (4 steps) ──┤
                                  │
                                  v
                      ┌───────────────────────┐
                      │ Filtered Results      │
                      │ - Based on answers    │
                      │ - 4 snake options     │
                      │ - "Not found" option  │
                      └─────┬─────────────────┘
                            │
                            v
                ┌───────────────────────────┐
                │ Snake Confirmation        │
                │ - Interactive features    │
                │ - Confidence calculation  │
                │ - Warning dialog          │
                └─────┬─────────────────────┘
                      │
                      ├─── Specific Species ──┐
                      │                       │
                      └─── Unknown Species ───┤
                                              │
                                              v
                              ┌───────────────────────────┐
                              │ First Aid Steps           │
                              │ - Specific OR Generic     │
                              │ - Step-by-step guide      │
                              │ - Safety warnings         │
                              └─────┬─────────────────────┘
                                    │
                                    v
                        ┌───────────────────────────┐
                        │ Symptom Report            │
                        │ - Multi-symptom selection │
                        │ - Severity indicators     │
                        └─────┬─────────────────────┘
                              │
                              v
                  ┌───────────────────────────┐
                  │ Severity Assessment       │
                  │ - Critical/High/Moderate  │
                  │ - Auto-route to hospital  │
                  └─────┬─────────────────────┘
                        │
                        v
            ┌───────────────────────────┐
            │ Emergency Tracking        │
            │ - Real-time location      │
            │ - Rescuer ETA             │
            │ - Live updates            │
            └─────┬─────────────────────┘
                  │
                  v
      ┌───────────────────────────┐
      │ Rescuer Arrived           │
      │ - Confirm arrival         │
      │ - Transfer information    │
      └─────┬─────────────────────┘
            │
            v
┌───────────────────────────┐
│ Payment                   │
│ - Service fee             │
│ - Payment methods         │
└─────┬─────────────────────┘
      │
      v
┌───────────────────────────┐
│ Service Completion        │
│ - Review & Rating         │
│ - Session summary         │
└───────────────────────────┘
```

---

## Screen Details

### 1. Home Screen
**File**: `lib/features/member/screens/home_screen.dart`

**Features**:
- Emergency SOS button (red, prominent)
- Quick access to snake database
- News and tips section
- User profile

**SOS Dialog**:
- Uses CustomDialog widget
- Warning message about emergency activation
- Two actions: Cancel and Activate

---

### 2. Emergency Alert Screen
**File**: `lib/features/emergency/screens/members/emergency_alert_screen.dart`

**Features**:
- 10-second countdown timer
- Auto-location detection
- Auto-call nearest rescuers
- Live location sharing
- Cancel option

**Design**:
- Red alert theme
- Pulsing animation
- Clear cancel button
- Emergency contact info

---

### 3. Snake Identification Screen
**File**: `lib/features/emergency/screens/members/snake_identification_screen.dart`

**Features**:
- Live camera preview (CameraController)
- High-resolution capture
- Flash toggle
- Gallery access

**Three Identification Options**:
1. **AI Recognition** (coming soon)
   - Auto-identify from photo
   - Confidence scoring

2. **Select by Location**
   - Navigate to SnakeSelectionByLocationScreen
   - Show common species in area

3. **Answer Questions**
   - Navigate to SnakeIdentificationQuestionsScreen
   - 4-step questionnaire

---

### 4. Snake Selection by Location Screen
**File**: `lib/features/emergency/screens/members/snake_selection_by_location_screen.dart`

**Features**:
- Location badge (current location)
- Grid of 4 common snakes
- Each card shows:
  - Snake image
  - Vietnamese name
  - English name
  - Poisonous status
  - Danger icon

**Navigation**:
- Tap snake → SnakeConfirmationScreen

---

### 5. Snake Identification Questions Screen
**File**: `lib/features/emergency/screens/members/snake_identification_questions_screen.dart`

**Features**:
- 4-step questionnaire
- Progress bar (25% → 50% → 75% → 100%)
- Visual options with images

**Questions**:
1. **Head Shape**: Round / Triangle
2. **Pattern**: Patterned / Solid
3. **Size**: Small / Medium / Large
4. **Environment**: Water / Tree / Ground

**Navigation**:
- Complete → SnakeFilteredResultsScreen with answers
- Each step: Next button / Skip button

---

### 6. Snake Filtered Results Screen
**File**: `lib/features/emergency/screens/members/snake_filtered_results_screen.dart`

**Features**:
- Blue info banner: "Based on your answers..."
- Yellow warning banner: "Choose the MOST SIMILAR"
- Location badge
- Grid of 4 filtered snakes
- Footer: "Still not found?" → GenericFirstAidScreen

**Design**:
- Same card style as location screen
- Confidence percentage
- Poisonous status

---

### 7. Snake Confirmation Screen
**File**: `lib/features/emergency/screens/members/snake_confirmation_screen.dart`

**Features**:
- Large snake image (BoxFit.contain)
- Snake info card:
  - Vietnamese name
  - English name
  - Poisonous status
  - Confidence level (dynamic)

**Interactive Features** (5 checkboxes):
1. Triangle head shape
2. Characteristic pattern
3. Appropriate size
4. Correct habitat
5. Activity time

**Confidence Calculation**:
- 4-5 features selected: 95%
- 3 features: 85%
- 2 features: 75%
- 1 feature: 65%

**Color Coding**:
- ≥85%: Green (#228B22)
- 70-84%: Orange (#FF9800)
- <70%: Red (#DC3545)

**Confirmation Dialog**:
- Uses CustomDialog
- Shows snake name and poisonous status
- Two actions:
  - "No, choose again" → Back to selection
  - "Yes, continue" → FirstAidStepsScreen

---

### 8. First Aid Steps Screen (Specific)
**File**: `lib/features/emergency/screens/members/first_aid_steps_screen.dart`

**Features**:
- Snake name badge
- Poisonous status (red/green alert)
- Venom type info (Neurotoxic/Hemotoxic)
- Step-by-step instructions
- DO NOT section
- Emergency buttons

**Navigation**:
- "Report Symptoms" → SymptomReportScreen

---

### 9. Generic First Aid Screen
**File**: `lib/features/emergency/screens/members/generic_first_aid_screen.dart`

**Features**:
- "Unknown species" badge (amber)
- Yellow warning banner
- Red important alert (assume venomous)
- 6 general first aid steps
- DO NOT section (4 cards grid)

**Steps**:
1. Stay calm
2. Immobilize limb
3. Remove jewelry
4. Clean gently
5. Light bandage
6. Go to hospital NOW

**DO NOT Cards** (2x2 grid):
- Don't suck venom
- Don't cut wound
- Don't tourniquet
- Don't apply ice

**Emergency Buttons**:
- "Call 115" (red outlined)
- "Find Hospital" (green outlined)

---

### 10. Symptom Report Screen
**File**: `lib/features/emergency/screens/members/symptom_report_screen.dart`

**Features**:
- Multi-select symptoms
- Categories:
  - Pain level (1-10 slider)
  - Local symptoms (swelling, redness, bleeding)
  - Systemic symptoms (nausea, dizziness, difficulty breathing)
  - Neurological (blurred vision, numbness, paralysis)

**Navigation**:
- "Continue" → SeverityAssessmentScreen

---

### 11. Severity Assessment Screen
**File**: `lib/features/emergency/screens/members/severity_assessment_screen.dart`

**Features**:
- Auto-calculation based on symptoms
- Three levels:
  - **Critical**: Red, immediate hospital
  - **High**: Orange, urgent care
  - **Moderate**: Yellow, monitor closely

**Actions**:
- Critical: Auto-route to nearest hospital with antivenom
- High/Moderate: Continue tracking

---

### 12. Emergency Tracking Screen
**File**: `lib/features/emergency/screens/members/emergency_tracking_screen.dart`

**Features**:
- Real-time map
- Patient location (blue marker)
- Rescuer location (green marker)
- Route visualization
- ETA countdown
- Rescuer info card

**Updates**:
- Live location every 5 seconds
- Push notifications for status changes

**Navigation**:
- Auto → RescuerArrivedScreen when rescuer nearby

---

### 13. Rescuer Arrived Screen
**File**: `lib/features/emergency/screens/members/rescuer_arrived_screen.dart`

**Features**:
- Confirmation prompt
- Rescuer verification (photo, name, ID)
- Transfer checklist:
  - Snake information
  - Symptoms reported
  - First aid performed
  - Time of bite

**Navigation**:
- "Confirm Arrival" → PaymentScreen

---

### 14. Payment Screen
**File**: `lib/features/payment/screens/payment_screen.dart`

**Features**:
- Service fee breakdown:
  - Emergency response fee
  - Distance charge
  - Time charge
  - Specialist fee (if applicable)
- Payment methods:
  - Wallet balance
  - Credit/debit card
  - QR code
  - Cash

**Navigation**:
- "Pay Now" → ServiceCompletionScreen

---

### 15. Service Completion Screen
**File**: `lib/features/emergency/screens/members/service_completion_screen.dart`

**Features**:
- Success message
- Session summary:
  - Snake identified
  - Response time
  - Rescuer name
  - Total cost
- Rating system (1-5 stars)
- Review textarea
- Download receipt

**Navigation**:
- "Done" → Home Screen

---

## Design System

### Color Palette
```dart
// Primary Colors
const primaryGreen = Color(0xFF228B22);    // Forest Green
const dangerRed = Color(0xFFDC3545);       // Red
const warningOrange = Color(0xFFFF9800);   // Orange
const infoBlue = Color(0xFF2196F3);        // Blue

// Background
const background = Color(0xFFF8F8F6);      // Off-white

// Text
const textPrimary = Colors.black87;
const textSecondary = Colors.grey[600];
```

### Typography
```dart
// Headings
const heading1 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
const heading2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
const heading3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

// Body
const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);
```

### Components

#### CustomDialog
**File**: `lib/features/shared/widgets/custom_dialog.dart`

**Usage**:
```dart
CustomDialog(
  icon: Icons.warning_amber_rounded,
  iconColor: Colors.orange,
  title: 'Dialog Title',
  content: Text('Dialog content'),
  actions: [
    DialogAction(
      label: 'Cancel',
      onPressed: () => Navigator.pop(context),
      isPrimary: false,
    ),
    DialogAction(
      label: 'Confirm',
      onPressed: () { /* action */ },
      isPrimary: true,
    ),
  ],
)
```

#### Buttons
- **Primary**: Green (#228B22), white text, 50px height
- **Secondary**: Outlined, gray border
- **Danger**: Red (#DC3545)

#### Cards
- White background
- 12px border radius
- Subtle shadow (0.05 opacity, 8px blur)

---

## Navigation Patterns

### Forward Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NextScreen()),
);
```

### Replace Navigation
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => NextScreen()),
);
```

### Pop with Result
```dart
Navigator.pop(context, result);
```

---

## Technical Notes

### Camera Package
- **Package**: `camera: ^0.10.5+5`
- **Permissions**: AndroidManifest.xml updated
- **Preview**: ResolutionPreset.high

### State Management
- StatefulWidget with setState
- Local state for interactive components
- Future: Consider Provider/Riverpod for global state

### Image Handling
- BoxFit.contain for snake images (prevents distortion)
- Placeholder icon for loading states
- Future: NetworkImage with caching

---

## Future Enhancements

1. **Backend Integration**
   - Real-time database for rescuer tracking
   - Push notifications via Firebase
   - Snake identification API

2. **AI Features**
   - Machine learning model for snake identification
   - Confidence scoring based on image quality
   - Auto-detect dangerous features

3. **Offline Support**
   - Cache snake database
   - Offline first aid instructions
   - Queue symptom reports

4. **Analytics**
   - Track identification accuracy
   - Response time metrics
   - User behavior analysis

5. **Accessibility**
   - Screen reader support
   - High contrast mode
   - Voice commands for emergency

---

## Testing Checklist

- [ ] Camera permissions work on Android/iOS
- [ ] All navigation paths functional
- [ ] CustomDialog displays correctly
- [ ] Confidence calculation accurate
- [ ] Feature selection updates UI
- [ ] Multi-step questionnaire progresses correctly
- [ ] Filtered results receive answers parameter
- [ ] Generic first aid accessible from multiple paths
- [ ] Payment flow completes
- [ ] Session summary shows correct data

---

## Git Commit History

This emergency member flow was developed across multiple sessions:

1. `feat: add camera package for snake identification feature`
2. `feat: add camera and location permissions in AndroidManifest`
3. `feat: create reusable CustomDialog widget for professional popups`
4. `feat: update home screen SOS dialog to use CustomDialog widget`
5. `feat: create snake identification questions screen (4-step questionnaire)`
6. `feat: create snake filtered results screen based on user answers`
7. `feat: create generic first aid screen for unknown snake species`
8. `feat: update snake confirmation screen with interactive features and dialog`
9. `feat: add emergency member flow documentation`

---

**Last Updated**: January 28, 2026  
**Version**: 1.0.0  
**Author**: GitHub Copilot
