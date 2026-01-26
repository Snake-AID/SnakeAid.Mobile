# ADMIN - SNAKE SPECIES DATABASE MANAGEMENT SCREENS

## Module Information
- **Module:** Admin Snake Database Management (Web Application)
- **Total Screens:** 4 screens
- **Related Features:** FE-05 to FE-08 from Major Features Summary
- **Purpose:** Comprehensive snake species database management with AI training support

---

## Flow Context

The Snake Database Management module allows admin to maintain accurate, up-to-date information about snake species found in Vietnam. This database serves as the foundation for AI identification accuracy and provides critical information for patients, rescuers, and experts.

**Key Functions:**
- Add, edit, delete snake species records
- Upload and manage snake images (minimum 5 high-quality images per species)
- Classify snakes by danger level (harmless, mildly venomous, highly venomous, critically venomous)
- Manage distribution areas, habitat, behavior information
- Test AI identification accuracy with new images
- Track AI training status and model performance

**Related Requirements:**
- FE-05: Add, edit, delete snake species information (scientific name, local name, characteristics, distribution)
- FE-06: Upload snake images for each species
- FE-07: Manage information about snake behavior and habitat
- FE-08: Classify snakes by danger level and distribution area

---

## Design System

### Color Palette (Admin Portal):
- **Primary Blue:** `#007BFF` (Admin branding, primary actions)
- **Dark Navy:** `#1E3A8A` (Sidebar, headers, professional tone)
- **Success Green:** `#28A745` (Active records, successful operations)
- **Warning Amber:** `#FFC107` (Pending reviews, alerts)
- **Danger Red:** `#DC3545` (Critical danger level, delete actions)
- **Info Cyan:** `#17A2B8` (Informational elements)
- **Light Gray:** `#F8F9FA` (Backgrounds, cards)
- **White:** `#FFFFFF` (Card backgrounds, main content)

### Danger Level Colors:
- **Harmless:** Green `#28A745`
- **Mildly Venomous:** Yellow `#FFC107`
- **Highly Venomous:** Orange `#FD7E14`
- **Critically Venomous:** Red `#DC3545`

### Typography (Web):
- **Page Title:** 28pt Bold
- **Section Headers:** 20pt Semi-bold
- **Card Titles:** 18pt Semi-bold
- **Body Text:** 14pt Regular
- **Small Labels:** 12pt Regular
- **Stats Numbers:** 36pt Bold

---

## Screen Designs

### Screen 1: Snake Species List (Table View)

**Screen Purpose:**  
Main table view displaying all snake species in the database with filtering, sorting, and bulk operations.

**Navigation:**
- Entry: Click "Snake Database" from Admin sidebar
- Exit: To any admin section

**Key Components:**

1. **Page Header:**
   - Title: "Snake Species Database"
   - Total count: "87 species" badge
   - Action buttons: "+ Add Species" (blue), "Import CSV" (outlined), "Export Data" (outlined)

2. **Filter Bar:**
   - Search input: "Search by name, scientific name..."
   - Danger level dropdown: "All Levels" | Harmless | Mildly Venomous | Highly Venomous | Critically Venomous
   - Distribution dropdown: "All Areas" | Northern Vietnam | Central Vietnam | Southern Vietnam
   - Habitat dropdown: "All Habitats" | Forest | Grassland | Urban | Water | Mountain
   - AI Status dropdown: "All Status" | Trained | Pending Training | Low Accuracy
   - Clear filters link

3. **Snake Table:**
   - Columns:
     * Checkbox (select all)
     * Thumbnail (80x80px, rounded)
     * Common Name (Vietnamese)
     * Scientific Name (italic)
     * Danger Level (badge with color)
     * Distribution (chips)
     * AI Accuracy (percentage with color indicator)
     * Images (count badge)
     * Last Updated (date)
     * Actions (view, edit, delete)

   **Example Rows:**
   - Row 1: Checkbox | [thumbnail] | "Rắn Hổ Mang" | *Naja siamensis* | "Critically Venomous" red badge | "Southern, Central" chips | "94%" green | "12 images" badge | "10/12/2025" | Icons 👁️ ✏️ 🗑️
   - Row 2: "Rắn Ráo Trâu" | *Ptyas korros* | "Harmless" green badge | "All Areas" | "89%" green | "8 images" | "05/12/2025"
   - Row 3: "Rắn Lục Đuôi Đỏ" | *Trimeresurus albolabris* | "Highly Venomous" orange | "Northern, Central" | "67%" amber | "4 images" amber warning | "01/12/2025"

4. **Bulk Actions Bar (appears when selected):**
   - "3 species selected" text
   - Buttons: "Update Danger Level" | "Update Distribution" | "Train AI Model" | "Delete" (red)
   - Cancel link

5. **Pagination:**
   - "Showing 1-20 of 87 species"
   - Page controls: ‹ 1 [2] 3 ... 5 ›
   - "Rows per page: 20" dropdown (10|20|50|100)

**Stitch Prompt (English):**

```
Snake species database table view for admin portal.

PAGE HEADER:
- "Snake Species Database" (28pt bold dark navy)
- "87 species" badge (blue background, white text, 16pt)
- Right side: 3 buttons horizontal
  * "+ Add Species" button (blue filled, white text, 44px height)
  * "Import CSV" button (blue outlined, 44px)
  * "Export Data" button (gray outlined, 44px)

FILTER BAR (light gray background #F8F9FA, padding 16px):
- Search input (300px width): "Search by name, scientific name..." + magnifying glass icon
- "Danger Level" dropdown (180px): showing "All Levels" + down arrow
- "Distribution" dropdown (180px): "All Areas"
- "Habitat" dropdown (150px): "All Habitats"
- "AI Status" dropdown (150px): "All Status"
- "Clear filters" link (blue text, right)

SNAKE TABLE (white card, rounded, shadow):

HEADER ROW (light gray background):
- Checkbox (select all, 40px)
- "Image" (80px)
- "Common Name" sortable ↕️ (180px)
- "Scientific Name" sortable ↕️ (200px)
- "Danger Level" sortable ↕️ (160px)
- "Distribution" (160px)
- "AI Accuracy %" sortable ↕️ (120px)
- "Images" (80px)
- "Last Updated" sortable ↕️ (120px)
- "Actions" (100px)

ROW 1:
- ☐ Checkbox
- Thumbnail: 80x80px rounded image of cobra (yellow-brown snake with hood)
- "Rắn Hổ Mang" (16pt bold)
- "Naja siamensis" (14pt italic gray)
- "Critically Venomous" badge (red #DC3545, white text, rounded pill)
- Two chips: "Southern" + "Central" (gray background, small)
- "94%" (green text, bold) + small green circle
- "12 images" badge (blue background)
- "10/12/2025" (14pt gray)
- Three icon buttons:
  * 👁️ View (blue)
  * ✏️ Edit (blue)
  * 🗑️ Delete (red)

ROW 2:
- ☐ Checkbox
- Thumbnail: green-brown rat snake
- "Rắn Ráo Trâu"
- "Ptyas korros" (italic gray)
- "Harmless" badge (green #28A745, white text)
- "All Areas" chip (gray)
- "89%" green text
- "8 images" badge
- "05/12/2025"
- Icons 👁️ ✏️ 🗑️

ROW 3:
- ☐ Checkbox
- Thumbnail: green viper with red tail
- "Rắn Lục Đuôi Đỏ"
- "Trimeresurus albolabris" (italic)
- "Highly Venomous" badge (orange #FD7E14, white text)
- "Northern" + "Central" chips
- "67%" amber text + amber warning icon ⚠️
- "4 images" badge (amber background) + warning icon
- "01/12/2025"
- Icons

BULK ACTIONS BAR (blue background, appears when checkboxes selected):
- "3 species selected" (white text, left)
- Button group (center-right):
  * "Update Danger Level" button (white outlined)
  * "Update Distribution" button (white outlined)
  * "Train AI Model" button (white outlined)
  * "Delete" button (red background, white text)
- "Cancel" link (white text, far right)

PAGINATION (bottom, centered):
- "Showing 1-20 of 87 species" (left, 14pt gray)
- Page controls (center): ‹ button | "1" active blue | "2" | "3" | ... | "5" | › button
- "Rows per page: 20" dropdown (right) with options 10|20|50|100

DESIGN: Professional data table, clear danger level indicators, image preview, AI accuracy tracking, bulk operations support.
```

---

### Screen 2: Add/Edit Snake Species (Comprehensive Form)

**Screen Purpose:**  
Detailed form for creating new snake species records or editing existing ones with comprehensive taxonomic, physical, behavioral, and distribution information.

**Navigation:**
- Entry: Click "+ Add Species" from Screen 1, or "Edit" icon
- Exit: Cancel → Screen 1, Save → Screen 1 or Screen 3 (Image Upload)

**Key Components:**

1. **Form Header:**
   - Breadcrumb: "Snake Database > Add New Species" or "Edit Species: Rắn Hổ Mang"
   - Progress indicator: "Step 1 of 2: Species Information" (Step 2 = Image Upload)

2. **Basic Information Section:**
   - Common Name (Vietnamese)* required
   - Common Name (English)
   - Scientific Name* (Latin, italic preview)
   - Family (dropdown: Colubridae, Elapidae, Viperidae, Pythonidae, etc.)
   - Genus and Species (auto-populated from scientific name)

3. **Classification & Danger Level:**
   - Venomous Status* (radio buttons):
     * ○ Non-venomous (Harmless) - green
     * ○ Mildly Venomous - yellow
     * ○ Highly Venomous - orange
     * ○ Critically Venomous - red
   - Venom Type (if venomous): checkboxes for Neurotoxic, Hemotoxic, Cytotoxic, Myotoxic
   - Medical Significance (dropdown): None | Low | Moderate | High | Critical
   - Antivenom Available (toggle ON/OFF)
   - Antivenom Names (text input, comma-separated)

4. **Physical Characteristics:**
   - Average Length (cm): Min ____ to Max ____ (number inputs)
   - Maximum Length (cm)
   - Body Shape (dropdown): Slender, Stout, Thick-bodied, Elongated
   - Head Shape (dropdown): Triangular, Rounded, Oval, Arrow-shaped
   - Scale Pattern (textarea)
   - Color Pattern (textarea with rich text)
   - Distinctive Features (textarea): e.g., "White spectacle mark on hood"

5. **Distribution & Habitat:**
   - Distribution Areas* (multi-select chips):
     * ☐ Northern Vietnam
     * ☐ Central Highlands
     * ☐ Central Coastal
     * ☐ Southern Vietnam
     * ☐ Mekong Delta
   - Habitat Types* (multi-select):
     * ☐ Forest (primary, secondary)
     * ☐ Grassland
     * ☐ Urban/Suburban
     * ☐ Wetland/Water
     * ☐ Mountain (altitude range)
     * ☐ Agricultural areas
   - Altitude Range (m): ____ to ____ meters
   - Activity Pattern (checkboxes): Diurnal, Nocturnal, Crepuscular

6. **Behavior & Ecology:**
   - Temperament (radio): Docile | Defensive | Aggressive | Highly Aggressive
   - Diet (textarea): Primary prey types
   - Reproduction (dropdown): Oviparous (egg-laying) | Viviparous (live-bearing)
   - Conservation Status (dropdown): Least Concern | Near Threatened | Vulnerable | Endangered | Critically Endangered

7. **First Aid & Treatment:**
   - Symptoms (rich text editor): List common symptoms of bite
   - First Aid Steps (rich text editor): Immediate actions to take
   - Medical Treatment (rich text editor): Hospital treatment protocol
   - Notes for Rescuers (textarea): Safety tips for capture

8. **Admin Metadata:**
   - Status (radio): ● Active | ○ Draft | ○ Archived
   - Priority (dropdown): Normal | High (for dangerous species)
   - Internal Notes (textarea, admin-only)

9. **Action Buttons:**
   - "Cancel" (gray outlined, left)
   - "Save as Draft" (blue outlined)
   - "Save & Upload Images" (blue filled, primary action)

**Stitch Prompt (English):**

```
Add/edit snake species comprehensive form.

FORM HEADER:
- Breadcrumb: "Snake Database > Add New Species" (14pt gray, blue links)
- Progress: "Step 1 of 2: Species Information" (16pt bold) + progress bar 50% blue

FORM LAYOUT (white card, two-column where appropriate):

SECTION 1: "Basic Information" (20pt bold header)

LEFT COLUMN:
- "Common Name (Vietnamese) *" label + text input full width
  Placeholder: "Rắn Hổ Mang"
- "Common Name (English)" label + input
  Placeholder: "Monocled Cobra"

RIGHT COLUMN:
- "Scientific Name *" label + input (auto-italic preview)
  Placeholder: "Naja siamensis"
- "Family *" dropdown showing "Select family..."
  Options: Colubridae | Elapidae | Viperidae | Pythonidae | Homalopsidae

SECTION 2: "Classification & Danger Level" (20pt bold, red icon)

DANGER LEVEL (large radio cards, horizontal):
- ○ "Non-venomous" green card #28A745, snake icon
- ○ "Mildly Venomous" yellow card #FFC107
- ● "Highly Venomous" orange card #FD7E14 SELECTED (checkmark)
- ○ "Critically Venomous" red card #DC3545

VENOM TYPE (appears when venomous selected):
- "Venom Type" label (16pt)
- Checkboxes (horizontal):
  ☑ Neurotoxic  ☐ Hemotoxic  ☐ Cytotoxic  ☐ Myotoxic

TWO COLUMNS:
LEFT:
- "Medical Significance" dropdown: "High"
- "Antivenom Available" toggle switch (ON, green)

RIGHT:
- "Antivenom Names" text input
  Value: "Snake Venom Antiserum, Thailand Red Cross"

SECTION 3: "Physical Characteristics" (20pt bold)

GRID (2 columns):
- "Average Length (cm)" label
  Two inputs: "Min: 80" + "Max: 150"
- "Maximum Length (cm)": "180"
- "Body Shape" dropdown: "Slender"
- "Head Shape" dropdown: "Rounded"

FULL WIDTH:
- "Scale Pattern" textarea (3 rows)
  "Smooth scales, 19-21 rows at midbody"
- "Color Pattern" rich text editor (4 rows, toolbar: bold, italic, list)
  "Olive-brown to gray with pale crossbands. Distinctive white spectacle mark on hood."
- "Distinctive Features" textarea (3 rows)

SECTION 4: "Distribution & Habitat" (20pt bold + map icon)

DISTRIBUTION AREAS (multi-select chips):
- ☑ "Northern Vietnam" chip (blue) with × remove
- ☐ "Central Highlands" gray chip
- ☑ "Central Coastal" blue chip ×
- ☑ "Southern Vietnam" blue chip ×
- ☐ "Mekong Delta" gray

HABITAT TYPES (multi-select checkboxes, 2 columns):
LEFT:
☑ Forest (primary, secondary)
☑ Grassland
☐ Urban/Suburban

RIGHT:
☑ Wetland/Water
☐ Mountain
☑ Agricultural areas

- "Altitude Range (m)" label
  Two inputs: "0" to "800" meters
- "Activity Pattern" checkboxes (horizontal):
  ☐ Diurnal  ☑ Nocturnal  ☑ Crepuscular

SECTION 5: "Behavior & Ecology"

- "Temperament" radio buttons (horizontal with icons):
  ○ Docile  ● Aggressive (selected)  ○ Highly Aggressive
- "Diet" textarea (2 rows): "Frogs, toads, small mammals, birds"
- "Reproduction" dropdown: "Oviparous (egg-laying)"
- "Conservation Status" dropdown: "Least Concern"

SECTION 6: "First Aid & Treatment" (red icon)

- "Symptoms" rich text editor (5 rows):
  "Immediate pain, swelling, difficulty breathing, paralysis..."
- "First Aid Steps" editor (5 rows):
  "1. Keep victim calm and immobilized..."
- "Medical Treatment" editor (4 rows)
- "Notes for Rescuers" textarea (3 rows)

SECTION 7: "Admin Metadata" (gray background box)

- "Status" radio: ● Active  ○ Draft  ○ Archived
- "Priority" dropdown: "High (for dangerous species)"
- "Internal Notes" textarea (3 rows, light gray background)

ACTION BUTTONS (bottom, sticky):
- "Cancel" button (gray outlined, 44px, left)
- "Save as Draft" button (blue outlined, 44px, center-right)
- "Save & Upload Images" button (blue filled, 48px height, bold, right, primary)

DESIGN: Comprehensive form, clear sections, visual danger indicators, conditional fields, rich text support, professional medical terminology.
```

---

### Screen 3: Image Upload & Gallery Management

**Screen Purpose:**  
Upload, manage, and organize high-quality snake images for AI training and identification purposes. Minimum 5 images required per species.

**Navigation:**
- Entry: Click "Save & Upload Images" from Screen 2, or "Edit Images" from Screen 1
- Exit: Back to Screen 1 (species list) or Screen 4 (AI Testing)

**Key Components:**

1. **Header:**
   - Breadcrumb: "Snake Database > Rắn Hổ Mang > Image Gallery"
   - Species info card (compact): thumbnail + name + danger badge
   - Image count: "12 images uploaded" (minimum 5 required)
   - Quality score: "Overall Quality: 92%" (green)

2. **Upload Zone (if < 5 images, show prominently):**
   - Large drag-drop area
   - "Drag & drop images here or Browse"
   - File requirements: "JPG/PNG, max 10MB each, minimum 1200x800px"
   - Bulk upload support: "Upload up to 10 images at once"
   - Upload button (blue)

3. **Image Gallery Grid (if ≥ 5 images):**
   - Grid layout: 4 columns on desktop
   - Each image card:
     * 250x250px image preview
     * Zoom icon on hover
     * Image filename
     * Body part tag (dropdown): "Full Body" | "Head Close-up" | "Scale Pattern" | "Fangs" | "Coiled" | "Defensive Posture"
     * Quality score: "95%" green or "45%" red
     * Primary image toggle (star icon, only 1 can be primary)
     * Delete button (trash icon)

4. **Image Quality Requirements Panel (right sidebar):**
   - Title: "Quality Guidelines"
   - Requirements checklist:
     * ✓ Minimum 5 images
     * ✓ At least 1 full body shot
     * ✓ At least 1 head close-up
     * ⚠️ At least 1 scale pattern detail (if missing)
     * ✓ Good lighting & focus
     * ✓ Clear background
   - Quality metrics:
     * Resolution: ✓ All images ≥ 1200x800px
     * File size: ✓ Average 2.5 MB
     * Blur detection: ⚠️ 2 images slightly blurred
     * Color balance: ✓ Good

5. **Bulk Actions:**
   - Select multiple images (checkboxes)
   - "Tag Selected" button (assign body part tag to multiple)
   - "Delete Selected" button (red)

6. **Action Buttons:**
   - "Cancel" (gray outlined, bottom-left)
   - "Test AI Model" (blue outlined, bottom-right, if ≥ 5 images)
   - "Save & Finish" (blue filled, bottom-right)

**Stitch Prompt (English):**

```
Snake species image upload and gallery management screen.

HEADER:
- Breadcrumb: "Snake Database > Rắn Hổ Mang > Image Gallery" (14pt gray, blue links)
- Species info card (horizontal, compact, white rounded shadow):
  * 60px thumbnail (cobra image)
  * "Rắn Hổ Mang" (18pt bold)
  * "Naja siamensis" (italic gray)
  * "Critically Venomous" red badge
  * "12 images uploaded" green badge
  * "Overall Quality: 92%" green text + green checkmark

UPLOAD ZONE (white dashed border card, if < 5 images show large):
- Large upload icon (cloud with up arrow, blue, 64px)
- "Drag & drop images here or Browse" (18pt bold)
- "JPG/PNG, max 10MB each, minimum 1200x800px" (14pt gray)
- "Upload up to 10 images at once" (12pt gray)
- "Browse Files" button (blue filled, 44px)

IMAGE GALLERY GRID (4 columns, gap 16px):

CARD 1 (primary image, gold border):
- 250x250px image: cobra full body on ground, yellow-brown color
- Hover: zoom icon overlay (magnifying glass)
- Bottom overlay (semi-transparent):
  * "cobra_fullbody_001.jpg" (12pt, truncated)
  * "Full Body" tag dropdown (gray chip)
  * "98%" quality score (green text, bold)
  * ⭐ Star icon (filled gold) = primary image
  * 🗑️ Trash icon (red)

CARD 2:
- 250x250px: cobra head close-up
- Filename: "cobra_head_closeup.jpg"
- "Head Close-up" tag (gray chip)
- "95%" green score
- ☆ Star outline (not primary)
- 🗑️ Trash icon

CARD 3:
- 250x250px: cobra scale pattern detail
- "cobra_scales_detail.jpg"
- "Scale Pattern" tag
- "87%" green score
- ☆ Star
- 🗑️

CARD 4:
- 250x250px: slightly blurry coiled cobra
- "cobra_coiled.jpg"
- "Coiled" tag
- "45%" red score + ⚠️ warning icon "Low quality"
- ☆ Star
- 🗑️

[Additional 8 cards similar pattern...]

RIGHT SIDEBAR (300px width, white card):

"Quality Guidelines" header (18pt bold) + info icon

REQUIREMENTS CHECKLIST:
✓ "Minimum 5 images" (green checkmark)
✓ "At least 1 full body shot" green
✓ "At least 1 head close-up" green
⚠️ "At least 1 scale pattern detail" amber warning
✓ "Good lighting & focus" green
✓ "Clear background" green

"Quality Metrics" header (16pt bold)

METRICS LIST:
- "Resolution" label
  "✓ All images ≥ 1200x800px" (green)
- "File Size"
  "✓ Average 2.5 MB" (green)
- "Blur Detection"
  "⚠️ 2 images slightly blurred" (amber)
- "Color Balance"
  "✓ Good" (green)

"AI Training Status" header
- "Status: Ready for Training" green badge
- "Last Trained: 10/12/2025" gray text
- "Current Accuracy: 94%" green text

BULK ACTIONS BAR (appears when images selected):
- "5 images selected" (blue background, white text)
- "Tag Selected" button (white outlined)
- "Delete Selected" button (red background)

ACTION BUTTONS (bottom, sticky):
- "Cancel" button (gray outlined, left)
- "Test AI Model" button (blue outlined, center-right)
- "Save & Finish" button (blue filled, right, primary)

DESIGN: Visual gallery grid, quality scoring, primary image indicator, drag-drop upload, comprehensive quality guidelines, AI training readiness.
```

---

### Screen 4: AI Model Testing & Accuracy Verification

**Screen Purpose:**  
Test AI snake identification model accuracy with uploaded images and trigger retraining if needed.

**Navigation:**
- Entry: Click "Test AI Model" from Screen 3, or "AI Status" from Screen 1
- Exit: Back to Screen 1 (species list)

**Key Components:**

1. **Header:**
   - Title: "AI Model Testing - Rắn Hổ Mang"
   - Species info card (same as Screen 3)
   - Current accuracy: "94%" green badge (large, 36pt)
   - Last trained: "10/12/2025 14:30"

2. **Testing Panel:**
   - Upload test image section:
     * Drag-drop or browse for new test image
     * "Upload Test Image" button
     * Or select from existing gallery (thumbnails)
   
3. **Test Results Display (after upload):**
   - Two-column comparison:
   
   **Left: Test Image**
   - Large image preview (600x400px)
   - Filename and metadata
   
   **Right: AI Prediction Results**
   - Top prediction (large card):
     * Species name: "Rắn Hổ Mang"
     * Confidence: "97.8%" (green, large)
     * Danger level badge
     * ✓ "Correct" or ✗ "Incorrect" indicator (admin confirms)
   
   - Top 5 predictions list:
     1. Rắn Hổ Mang - 97.8% ✓ (green)
     2. Rắn Hổ Chúa - 1.2% (gray)
     3. Rắn Kịch - 0.5%
     4. Rắn Ráo - 0.3%
     5. Other - 0.2%
   
   - Processing time: "0.34 seconds"
   - Model version: "v2.5.0"

4. **Verification Actions:**
   - If correct: "✓ Confirm Correct" button (green)
   - If incorrect: "✗ Mark as Incorrect" button (red) + "Correct Species" dropdown to select right answer

5. **Training History & Statistics:**
   - Line chart: Accuracy over time (last 30 days)
   - Training sessions table:
     * Date | Images Added | Accuracy Before | Accuracy After | Status
     * 10/12/2025 | 12 | 89% | 94% | Complete ✓
     * 05/12/2025 | 8 | 85% | 89% | Complete ✓
   
6. **Retrain Model Section:**
   - "Trigger Retraining" button (blue, large)
   - Warning: "Retraining will take approximately 2-4 hours"
   - Estimated new accuracy: "96-98%" (prediction)
   - Requirements met:
     * ✓ Minimum 5 images uploaded
     * ✓ At least 1 full body shot
     * ✓ Quality score ≥ 80%

7. **Action Buttons:**
   - "Back to Species List" (gray outlined)
   - "Upload More Images" (blue outlined)
   - "Trigger Retraining" (blue filled, if requirements met)

**Stitch Prompt (English):**

```
AI model testing and accuracy verification screen.

PAGE HEADER:
- "AI Model Testing - Rắn Hổ Mang" (28pt bold dark navy)
- Species info card (horizontal):
  * 60px thumbnail
  * "Rắn Hổ Mang" bold + "Naja siamensis" italic gray
  * "Critically Venomous" red badge
  * "Current Accuracy: 94%" green badge (36pt bold)
  * "Last Trained: 10/12/2025 14:30" gray text

TESTING PANEL (white card):

"Upload Test Image" section:
- "Test the AI model by uploading a snake image" (16pt)
- Drag-drop box (400x300px, dashed border gray):
  * Upload icon (cloud, blue)
  * "Drag image here or Browse"
  * "JPG/PNG, max 10MB"
- "Upload Test Image" button (blue filled)

OR

"Select from Gallery" section:
- Horizontal scrollable thumbnails (100x100px each, 6 visible):
  * Thumbnail 1 (bordered blue = selected)
  * Thumbnails 2-6 (gray border)
- "Test Selected Image" button (blue outlined)

TEST RESULTS (two-column layout):

LEFT COLUMN (50% width):
"Test Image" header (18pt bold)
- Large image preview: 600x400px, cobra full body
- Filename: "test_cobra_001.jpg" (14pt gray)
- Dimensions: "1920x1280 px" | Size: "3.2 MB"

RIGHT COLUMN (50% width):
"AI Prediction Results" header (18pt bold)

TOP PREDICTION CARD (blue border, rounded):
- "Rắn Hổ Mang" (24pt bold)
- "Naja siamensis" (italic gray)
- "Confidence: 97.8%" (36pt bold green)
- "Critically Venomous" red badge
- Large green checkmark ✓ "Prediction looks correct"

"Top 5 Predictions" list (table):
1. "Rắn Hổ Mang" | "97.8%" green bar (98% width) | ✓ green
2. "Rắn Hổ Chúa" | "1.2%" gray bar (tiny) | gray
3. "Rắn Kịch" | "0.5%" gray bar
4. "Rắn Ráo" | "0.3%" gray bar
5. "Other" | "0.2%" gray bar

Metadata:
- "Processing Time: 0.34 seconds" (12pt gray)
- "Model Version: v2.5.0" (12pt gray)

VERIFICATION ACTIONS (button group):
- "✓ Confirm Correct" button (green filled, 44px)
- "✗ Mark as Incorrect" button (red outlined, 44px)
- If incorrect clicked, show:
  * "Correct Species" dropdown (search enabled)
  * "Submit Correction" button (blue filled)

TRAINING HISTORY & STATISTICS (full width section):

"Accuracy Over Time" header (18pt bold)
- Line chart (800x300px):
  * X-axis: Dates (last 30 days)
  * Y-axis: Accuracy % (70% - 100%)
  * Blue line showing: 85% → 89% → 94%
  * Green upward trend arrow

"Training Sessions" header (18pt bold)
- Table (white card):
  HEADER: Date | Images Added | Accuracy Before | Accuracy After | Status
  
  ROW 1: "10/12/2025" | "12 images" | "89%" | "94% (+5%)" green | "Complete" ✓ green
  ROW 2: "05/12/2025" | "8 images" | "85%" | "89% (+4%)" green | "Complete" ✓
  ROW 3: "01/12/2025" | "5 images" | "82%" | "85% (+3%)" | "Complete" ✓

RETRAIN MODEL SECTION (light blue background card):

"Retrain AI Model" header (20pt bold) + AI icon

- "Trigger model retraining with new images to improve accuracy" (14pt)
- ⚠️ "Retraining will take approximately 2-4 hours" (amber text)
- "Estimated new accuracy: 96-98%" (green text, bold)

REQUIREMENTS CHECKLIST:
✓ "Minimum 5 images uploaded" green
✓ "At least 1 full body shot" green
✓ "Quality score ≥ 80%" green

"Trigger Retraining" button (blue filled, 48px height, bold)

ACTION BUTTONS (bottom):
- "Back to Species List" button (gray outlined, left)
- "Upload More Images" button (blue outlined, center)
- "Trigger Retraining" button (blue filled, right, primary)

DESIGN: AI testing interface, confidence visualization, accuracy tracking, retraining workflow, comprehensive model performance metrics.
```

---

## Integration Points

### API Endpoints:
- `GET /api/admin/snakes?filter=&sort=&page=` - Get snake species list with filters
- `GET /api/admin/snakes/:id` - Get snake species details
- `POST /api/admin/snakes` - Create new snake species
- `PUT /api/admin/snakes/:id` - Update snake species
- `DELETE /api/admin/snakes/:id` - Delete snake species
- `POST /api/admin/snakes/:id/images` - Upload images for species
- `DELETE /api/admin/snakes/:id/images/:imageId` - Delete image
- `PUT /api/admin/snakes/:id/images/:imageId/primary` - Set primary image
- `POST /api/admin/ai/test` - Test AI model with image
- `POST /api/admin/ai/retrain` - Trigger AI model retraining
- `GET /api/admin/ai/training-history` - Get training history
- `GET /api/admin/ai/accuracy` - Get current model accuracy
- `POST /api/admin/snakes/import` - Bulk import from CSV
- `GET /api/admin/snakes/export` - Export snake data

### Validation Rules:
- Common Name (Vietnamese): Required, max 100 characters
- Scientific Name: Required, valid Latin binomial nomenclature format
- Images: Minimum 5 per species, JPG/PNG, max 10MB, min 1200x800px resolution
- At least 1 full body image required
- At least 1 head close-up recommended
- Danger Level: Required selection
- Distribution: At least 1 area must be selected
- Quality Score: Minimum 80% average for AI training eligibility

### AI Model Integration:
- Model accepts images 224x224px (auto-resized)
- Returns top 5 predictions with confidence scores
- Minimum 5 images per species for training
- Retraining takes 2-4 hours
- Model version tracking (semantic versioning)
- Accuracy threshold: Target ≥ 90% for production use

---

## Version History
- **v1.0** - December 13, 2025: Initial snake database management screens design (4 screens)

---

## Design Review Checklist
- [x] Comprehensive species database table with filtering
- [x] Detailed species information form (taxonomic, physical, behavioral)
- [x] Image upload with quality requirements (min 5, resolution, body part tags)
- [x] AI testing interface with confidence scores
- [x] Training history and accuracy tracking
- [x] Retrain model workflow
- [x] Danger level visual indicators
- [x] Professional scientific terminology
- [x] Bulk operations support
- [x] Export/import functionality

---

*This document is part of the SnakeAid Platform UI Design Documentation*  
*Related Documents: Admin-Dashboard-Screens.md, Admin-User-Management-Screens.md, Admin-Hospital-Management-Screens.md*
