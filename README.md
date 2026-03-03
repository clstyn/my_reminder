# My Reminder

A cross-platform reminder and task management application built with Flutter. Organize your tasks, set reminders, track your progress, and stay productive across all your devices.

## Features

### 🔐 Authentication

- User registration and login
- Secure password hashing with crypto
- Session management with shared preferences

### ✅ Reminder Management

- Create, edit, and delete reminders
- Set due dates and priorities
- Mark reminders as complete
- Rich reminder details and notes

### 📅 Calendar View

- Visual calendar interface
- View reminders by date
- Track completion status
- Monthly and daily views

### 📊 Statistics & Analytics

- Track your productivity
- View completion rates
- Monitor reminder trends
- Progress visualization

### 💾 Local Database

- SQLite database integration
- Offline-first architecture
- Fast and reliable data persistence
- Automatic data seeding for development

## Tech Stack

- **Framework**: Flutter 3.11.0
- **Language**: Dart 3.11+
- **Database**: SQLite (sqflite)
- **State Management**: StatefulWidget pattern
- **Security**: crypto package for password hashing
- **Localization**: intl package
- **Storage**: shared_preferences for user sessions

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── core/
│   ├── constants/              # App-wide constants
│   ├── database/               # Database configuration
│   ├── seed/                   # Test data seeding
│   └── services/               # Core services
└── features/
    ├── auth/                   # Authentication feature
    │   ├── data/              # Models and repositories
    │   └── presentation/       # UI screens and widgets
    ├── calendar/               # Calendar view feature
    ├── navigation/             # Navigation management
    ├── reminders/              # Reminder CRUD operations
    └── statistics/             # Analytics and statistics
```

## Getting Started

### Prerequisites

- Flutter SDK 3.11.0 or higher
- Dart SDK 3.11.0 or higher
- iOS Simulator / Android Emulator / Physical Device
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd my_reminder
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Development Mode

The app includes automatic test data seeding for development. A test user and sample reminders are created on first launch.

**Test Credentials** (generated during seeding):

- Check the console output for credentials
- Or modify `lib/core/seed/seed_data_helper.dart`

To disable seeding in production, comment out the seeding call in `lib/main.dart`:

```dart
// Comment this out in production
// await _seedTestData();
```

## Platform Support

| Platform | Status |
| -------- | ------ |
| iOS      | ✅     |
| Android  | ✅     |
| Web      | ✅     |
| Windows  | ✅     |
| macOS    | ✅     |
| Linux    | ✅     |

## Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

### Desktop

```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

## Database Schema

The app uses SQLite with the following main tables:

- **Users**: User authentication and profile data
- **Reminders**: Task and reminder information
- Additional tables for tracking completion and statistics

## Dependencies

| Package              | Purpose                                  |
| -------------------- | ---------------------------------------- |
| `sqflite`            | SQLite database                          |
| `path`               | File path utilities                      |
| `intl`               | Internationalization and date formatting |
| `crypto`             | Password hashing                         |
| `shared_preferences` | Local key-value storage                  |
| `cupertino_icons`    | iOS-style icons                          |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Development Guidelines

- Follow Flutter best practices and style guide
- Use feature-based architecture
- Write meaningful commit messages
- Test on multiple platforms before submitting PRs
- Update documentation for new features

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Icons from [Cupertino Icons](https://pub.dev/packages/cupertino_icons)
- Database powered by [sqflite](https://pub.dev/packages/sqflite)

## Support

For issues, questions, or contributions, please open an issue on the repository.
