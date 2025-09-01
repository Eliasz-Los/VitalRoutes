# VitalRoutes

# Authors
- Eliasz Los: Backend & Frontend, Pathfinding Algorithm, Firebase Auth, PostgreSQL
- Marcin Bujas: Backend & Frontend, Trilateration with BLE Beacons, Floorplan Management, Docker
- Ilyasse Jmida: Backend & Frontend, Employee/Patient Management, Patients Alert System, UI/UX Design

# Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Start the project](#start-the-project)


# Introduction
Vital Routes is a mobile flutter application designed to assist hospitals in managing employees and patients. 
The app provides functionalities for adding, editing, and deleting employees and patients, as well as assigning patients to specific doctors/nurses. 
It also solves the problem of finding the shortest path between two locations within a hospital using A* algorithm, 
ensuring efficient navigation for doctors and nurses to their patients.

# Tech Stack
- Containerization: Docker to containerize the application and its dependencies
- Database: PostgreSQL With Docker for containerization and local development
- Backend: C# With .NET Framework
- Frontend: Dart with Flutter
- Authentication: Firebase Authentication & Authorisation for secure user login and registration

# Features
- Patients Alert System: Notify nurses of their patients' needs through the app. Then the nurse can see which patient needs help and go to their room and even led by the pathfinding. If the nurse sees that the patients needs the doctor, they can notify them through the app with their location.
- Employee/Patient Management: Add, edit, and delete employees (doctors,nurses, head-nurses and patients) and their relations since they need to take care of specific patients.
- Trilateral Localization: Determine the location of a device within the hospital using signals from three known points.  Using BLE beacons to get the signal strength from three different beacons and then applying trilateration techniques to calculate the device's position inside the buildings.
- Shortest Path Calculation: A* algorithm to find the shortest path between two points in the hospital. Making Doctors who manage multiple patients in different rooms more efficient and less time-consuming for finding them.
- User Authentication: Secure login and registration system for employees to access the app.
- Responsive Design: User-friendly interface that adapts to different screen sizes and orientations.

# Start the project
This project uses Rider's Multi Launch feature to start the backend and after that flutter for completion.
- Start the Backend Api: `dotnet run --project BackendApi`
- Start the Flutter App: 
  - In this case you also going to need flutter-intellij plugin for Intelij because none are for Rider, but that doesn't matter because you can still use the plugin for. (`ui/flutter-intellij`) you can find it there and just add is a plugin.
  - cd to the `ui` directory: `cd ui`
  - `flutter run` (for that you need to have an emulator or a device connected, like Pixel 7 API 35)

