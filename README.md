# Flutter Seminar 2 Project

This is a simple Flutter application developed for Seminar 2. It demonstrates basic user authentication including registration and login, and navigation between screens.

## Features

-   **User Registration:** New users can create an account with a username and password.
-   **User Login:** Existing users can log in to access the application.
-   **Protected Route:** A home screen that is only accessible to authenticated users.
-   **Basic Form Validation:** Ensures that user inputs for registration and login are not empty.

## Screenshots

*(Add screenshots of your application here to provide a visual overview.)*

| Login Screen | Register Screen | Home Screen |
| :---: |:---:|:---:|
| *Login Screen Screenshot* | *Register Screen Screenshot* | *Home Screen Screenshot* |

## Built With

*   [Flutter](https://flutter.dev/) - UI toolkit for building natively compiled applications.
*   [Dart](https://dart.dev/) - The programming language for Flutter.

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

-   Flutter SDK: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

### Installation

1.  Clone the repo
    ```sh
    git clone <repository-url>
    ```
2.  Install packages
    ```sh
    flutter pub get
    ```
3.  Run the app
    ```sh
    flutter run
    ```

## Project Structure

The project follows a standard Flutter application structure, with logic separated into screens, services, and models.

```
seminar2/
├── android/                    # Android specific project files.
├── build/                      # Build output directory.
├── ios/                        # iOS specific project files.
├── lib/                        # Main application code.
│   ├── main.dart               # App entry point, sets up routing.
│   ├── models/
│   │   └── user.dart           # Defines the User data model.
│   ├── screens/
│   │   ├── home_screen.dart    # The screen shown after a successful login.
│   │   ├── login_screen.dart   # The user login screen.
│   │   └── register_screen.dart# The user registration screen.
│   └── services/
│       └── auth_service.dart   # Handles authentication logic (login, register).
├── test/                       # Contains all the tests for the project.
│   └── widget_test.dart        # Example widget test.
├── .gitignore                  # Specifies intentionally untracked files to ignore.
├── analysis_options.yaml       # Linter rules for static analysis.
├── pubspec.lock                # Auto-generated file specifying package versions.
├── pubspec.yaml                # Project dependencies and configuration.
└── README.md                   # This file.
```

### File Descriptions

-   **`android/`**: Contains the Android-specific project files. You would edit files here to configure Android-native settings.
-   **`ios/`**: Contains the iOS-specific project files. You would edit files here to configure iOS-native settings.
-   **`lib/`**: The most important directory, containing all the Dart code for your Flutter application.
    -   **`main.dart`**: The main entry point for the application. It initializes the app and defines the initial route.
    -   **`models/user.dart`**: Contains the `User` class, which is a data model for representing user information.
    -   **`screens/`**: This directory contains all the UI screens for the application.
        -   `login_screen.dart`: A stateful widget that provides a form for users to log in.
        -   `register_screen.dart`: A stateful widget that provides a form for new users to register.
        -   `home_screen.dart`: A simple screen that is displayed to authenticated users.
    -   **`services/auth_service.dart`**: A service class that encapsulates the business logic for user authentication. It communicates with a backend API for registration and login.
-   **`test/`**: Contains automated tests for your project.
-   **`pubspec.yaml`**: The project's configuration file, used to manage dependencies (packages), assets (like images and fonts), and other metadata.
-   **`README.md`**: This file, providing information about the project.

## API Reference

The application communicates with a backend service for authentication.

#### Register User

```http
  POST /api/register
```

**Request Body:**

```json
{
  "username": "your_username",
  "password": "your_password"
}
```

**Responses:**

-   `201 Created`: If the user is successfully registered.
-   `400 Bad Request`: If the username already exists or the input is invalid.

#### Login User

```http
  POST /api/login
```

**Request Body:**

```json
{
  "username": "your_username",
  "password": "your_password"
}
```

**Responses:**

-   `200 OK`: On successful login, returns a token.
-   `401 Unauthorized`: If the credentials are incorrect.
