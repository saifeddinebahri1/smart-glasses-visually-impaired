# Smart Glasses for Visually Impaired — AI + Flutter Companion App

An AI-assisted smart glasses prototype paired with a Flutter mobile application
that empowers visually impaired individuals with greater autonomy, safety, and
real-time human assistance.

Developed during an internship at **ESSE Laboratory (ENETcom)**.

---

## Overview

The system combines embedded AI, computer vision, IoT, and mobile development
into a single assistive solution. The smart glasses capture the surrounding
environment, while the mobile app acts as the bridge between the user, a remote
assistant, and cloud services.

## Key Features

### Smart Glasses (Embedded AI + Computer Vision)
- Real-time object and obstacle detection using embedded AI models
- Scene understanding to help users navigate safely
- Lightweight, wearable prototype designed for daily use

### Flutter Mobile Application
- Real-time remote assistance — a helper can guide the user through live audio/video
- Live streaming from the glasses to the mobile app
- Geolocation of the visually impaired person for safety and emergency response
- Intuitive, accessible UI built with Flutter

## Tech Stack

| Layer              | Technologies                                  |
|--------------------|-----------------------------------------------|
| Mobile App         | Flutter, Dart                                 |
| Embedded AI        | Computer Vision, Edge Inference               |
| Communication      | IoT protocols, Live Streaming                 |
| Backend / Services | Firebase (Auth, Realtime DB, Cloud Messaging) |
| Hardware           | Smart glasses prototype (camera + sensors)    |

## Architecture

```
[ Smart Glasses ] --(live stream + sensor data)--> [ Flutter App ] <--> [ Remote Assistant ]
                                                          |
                                                          v
                                                  [ Cloud / Firebase ]
                                                          |
                                                          v
                                                  [ Geolocation / Alerts ]
```

## Screenshots

> Add images here: prototype photo, app home screen, live streaming view,
> map/geolocation screen, and remote assistance view.

```markdown
![Prototype](screenshots/prototype.png)
![App Home](screenshots/home.png)
![Live Streaming](screenshots/streaming.png)
```

## Getting Started

### Prerequisites
- Flutter SDK (>= 3.x)
- Android Studio or Xcode
- Firebase project (see below)

### Installation

```bash
git clone https://github.com/saifeddinebahri1/smart-glasses-visually-impaired.git
cd smart-glasses-visually-impaired
flutter pub get
flutter run
```

### Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Run `flutterfire configure` to generate `firebase_options.dart`.
3. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
4. Enable Authentication, Firestore / Realtime Database, and Cloud Messaging.
5. Set strict Security Rules before deploying.

> Do not commit `.env`, service account keys, or signing keys.

## Usage

1. Power on the smart glasses and pair them with the mobile app.
2. Log in to the Flutter app.
3. The app starts receiving the live camera feed and sensor data.
4. A remote assistant can connect and guide the user in real time.
5. The user's location is shared securely for safety and emergencies.

## Project Context

Developed as part of an internship at **ESSE Laboratory (ENETcom)**,
focusing on assistive technology that improves the daily autonomy of visually
impaired individuals.

## Authors

- **Saifeddine Bahri** — [@saifeddinebahri1](https://github.com/saifeddinebahri1)

## License

This project is released under the [MIT License](LICENSE).
