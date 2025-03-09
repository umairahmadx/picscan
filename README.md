# PicScan

**PicScan** is a Flutter application that captures images and provides detailed descriptions of the objects present using AI-powered analysis. It supports both mobile and web platforms.

---

## Project Structure

```
picscan/
├── assets/               # Folder for app icons and images.
├── lib/
│   ├── main.dart        # The main entry point of the application.
│   ├── home.dart        # The home screen containing the camera interface.
│   ├── chatscreen.dart  # Displays the scanned image and AI-generated description.
│   ├── functions.dart   # Contains utility functions like image compression and API calls.
├── .gitignore           # Specifies files and directories to be ignored by Git.
├── pubspec.yaml         # Project metadata, dependencies, and asset configurations.
└── README.md            # Project overview and documentation.
```

---

## Detailed File Analysis

### 1. `lib/main.dart`
- **Imports and Dependencies:**
    - `camera`: Provides access to the device’s cameras.
    - `flutter/material.dart`: Supplies Material Design widgets for UI.
    - `flutter_dotenv`: Loads environment variables (e.g., API keys).
    - `flutter_gemini`: Integrates Gemini API for AI-driven image analysis.
    - `home.dart`: Imports the HomeScreen widget.
- **Application Setup:**
    - Loads the API key from `.env`.
    - Initializes available cameras.
    - Starts the `MyApp` widget with `HomeScreen` as the main interface.
    - **Web Compatibility:**
        - Ensures smooth initialization for web.
        - Uses `image_picker_web` for selecting images on web platforms.

### 2. `lib/home.dart`
- **Camera Interface:**
    - Uses `camera` package to provide real-time camera preview.
    - Supports flash toggle and image capture.
- **Navigation:**
    - Allows switching to `ChatScreen` after image capture for analysis.
- **Web Compatibility:**
    - Uses conditional logic to handle image selection and processing differently for web and mobile platforms.
- **UI Elements:**
    - Camera preview, action buttons, and flash control.

### 3. `lib/chatscreen.dart`
- **Displays Image and Analysis:**
    - Shows the captured image along with AI-generated descriptions.
- **Image Selection:**
    - Allows picking images from the gallery.
- **API Integration:**
    - Sends images to Gemini API for object detection and description.
- **Web Compatibility:**
    - Implements separate logic for web image selection and processing.

### 4. `lib/functions.dart`
- **Image Processing:**
    - Compresses images before sending them for analysis.
- **API Calls:**
    - Handles requests to Gemini API.
    - Supports web and mobile platforms separately.
- **Image Picker:**
    - Uses `image_picker` for mobile and `image_picker_web` for web platforms.

### 5. `pubspec.yaml`
- **Project Metadata:**
    - Name: `plantfo`
    - Version: `1.1.0+1`
- **Dependencies:**
    - `camera`, `image_picker`, `flutter_image_compress`, `flutter_gemini`, `flutter_dotenv`, `image_picker_web` (for web compatibility).
- **Assets Configuration:**
    - Loads `.env` file for API keys.

---

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/umairahmadx/picscan.git
cd picscan
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Set Up Environment Variables
- Create a `.env` file in the project root.
- Add your API key:
```env
API_KEY=your_api_key_here
```

### 4. Run the Application
#### Mobile:
```bash
flutter run
```
#### Web:
```bash
flutter run -d chrome
```

---

## Contributing
1. Fork the repository.
2. Create a new branch.
3. Commit changes with clear messages.
4. Open a pull request with details.

---

## Contact
For questions or suggestions, contact:
- **Developer**: [Umair Ahmad](https://github.com/umairahmadx)

