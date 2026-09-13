# Smart Glasses for Visually Impaired — AI + Flutter Companion App

An AI-assisted smart glasses prototype paired with a Flutter mobile application
that empowers visually impaired individuals with greater autonomy, safety, and
real-time human assistance.

Developed during an internship at **ESSE Laboratory (ENETcom)** .

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
[ Smart Glasses ] --(live stream + sensor data)--> [ Flutter App ] <--> [ Remote Assistant ]
|
v
[ Cloud / Firebase ]
|
v
[ Geolocation / Alerts ]
