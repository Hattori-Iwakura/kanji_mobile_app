# Kanji Learning App

A beautiful Flutter application for managing and learning Japanese Kanji characters, connected to a remote REST API backend.

## Features

- 🔍 **Search & Browse**: Search kanji by character, meaning, or reading
- 📝 **Full CRUD Operations**: Create, read, update, and delete kanji entries
- 🎨 **Beautiful UI**: Modern Material Design with intuitive navigation
- 🌐 **Remote Backend**: Connects to REST API at `http://localhost:3000/api/kanji`
- 📱 **Responsive Design**: Works on different screen sizes
- 🏗️ **Clean Architecture**: Organized with Domain, Data, and Presentation layers

## Architecture

The app follows Clean Architecture principles with BLoC state management:

```
lib/
├── domain/
│   ├── entities/          # Kanji data models
│   └── repositories/      # Repository interfaces
├── data/
│   ├── remote/           # HTTP API client
│   └── repositories/     # Repository implementations
└── presentation/
    ├── blocs/            # BLoC state management
    ├── pages/            # Screen UI
    └── widgets/          # Reusable components
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / VS Code
- REST API server running on `http://localhost:3000`

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd kanji_mobile_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Backend API Setup

The app expects a REST API with the following endpoints:

- `GET /api/kanji` - Get all kanji
- `POST /api/kanji` - Create new kanji
- `PUT /api/kanji/:id` - Update kanji
- `DELETE /api/kanji/:id` - Delete kanji

Example kanji JSON structure:
```json
{
  "id": 1,
  "character": "漢",
  "meanings": "Chinese, Han dynasty",
  "onyomi": "カン",
  "kunyomi": null,
  "stroke_count": 13,
  "jlpt": 3,
  "grade": 3,
  "frequency": 755,
  "radicals": "氵丶一"
}
```

## Usage

### Adding New Kanji
1. Tap the floating action button (+)
2. Fill in the kanji details
3. Tap "Add" to save

### Searching Kanji
1. Use the search bar at the top
2. Search by character, meaning, or reading
3. Results update in real-time

### Editing Kanji
1. Tap the menu button (⋮) on any kanji card
2. Select "Edit"
3. Modify the details and save

### Viewing Details
- Tap any kanji card to view full details
- See all readings, meanings, and metadata

## Dependencies

- **flutter_bloc**: State management
- **http**: HTTP client for API calls
- **equatable**: Value equality comparisons
- **get_it**: Dependency injection (if used)

## Platform Support

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Desktop (Windows, macOS, Linux)

## API Configuration

The app automatically detects the platform and configures the backend URL:

- **Android Emulator**: `http://10.0.2.2:3000`
- **iOS Simulator/Web/Desktop**: `http://localhost:3000`
- **Physical Devices**: Update the IP address in `main.dart`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
