# EveM - Event Management Application Blueprint

## 1. Overview

EveM is a comprehensive Flutter application designed for both event managers and attendees. The app provides tools for managers to create and oversee events, while offering attendees a platform to discover, register for, and engage with them. The application is built with a focus on a clean, modern user interface and a robust, scalable architecture.

## 2. Project Outline

This section documents the style, design, and features of the EveM application.

### 2.1. Architecture

*   **Structure**: The project follows a feature-first layered architecture. Code is organized into `presentation`, `domain`, and `data` layers within each feature folder.
*   **State Management**: `provider` is used for state management and dependency injection.
*   **Navigation**: `go_router` is used for declarative routing, enabling deep linking and a structured navigation system. The app is divided into public, manager-authenticated, and attendee-authenticated routes using `ShellRoute`.
*   **UI/UX**: The application adheres to Material Design 3 principles, featuring a modern design with expressive typography, a vibrant color palette, and interactive, mobile-responsive components.

### 2.2. Implemented Features

*   **Firebase Integration**: Core, Authentication, and Cloud Firestore are fully integrated.
*   **Public Access & Onboarding**:
    *   **Default Entry Point**: The app now opens directly to the `EventDiscoveryScreen`, which is accessible to all users without requiring login.
    *   **Public Navigation**: A `PublicScaffold` provides a consistent side navigation for unauthenticated users with options to "Explore Events," "Attendee Login," "Attendee Register," and "Manager Login."
    *   The `WelcomeScreen` has been fully removed from the project.
*   **Authentication**:
    *   **Role-Based Login**: Separate login and registration flows for Event Managers and Attendees.
    *   **UI Enhancements**: The Login and Register screens have been visually improved with a constrained width to prevent stretching on web/desktop and a more polished design.
    *   **Auth Flow Fix**: An issue causing managers to be logged out after creating or editing an event has been resolved.
*   **Manager Experience**:
    *   **Unified Scaffold**: A consistent `ManagerScaffold` is used across all manager-side screens, featuring a navigation rail with "Dashboard," "Add Event," and "Profile" links.
    *   **Logout**: A dedicated logout button is now present at the bottom of the manager's navigation rail for easy access.
    *   **Event Management**: Full CRUD functionality for events, including a "Publish" switch.
    *   **Dashboard**: Includes a calendar view of events, an overview of managed events, and detailed views with budget, task, and collaborator management.
*   **Attendee Experience**:
    *   **Unified Scaffold**: A consistent `AttendeeScaffold` is used across all attendee-side screens, featuring a navigation rail with "Dashboard," and "Profile" links.
    *   **Logout**: A dedicated logout button is now present at the bottom of the attendee's navigation rail for easy access.
    *   **Event Discovery**: Attendees can search and view all *published* events.
    *   **Event Details & Registration**: View detailed event information and register for events.
    *   **Authenticated Dashboard**: Logged-in attendees have a dashboard to view their registrations, notifications, and profile.
*   **Navigation Fix**: The GoRouter navigation has been fixed and the selected index is now passed correctly to the `PublicScaffold`, `ManagerScaffold`, and `AttendeeScaffold` widgets.

### 2.3. Design System

*   **Color Palette**: A modern color scheme generated from a `Colors.deepPurple` seed.
*   **Typography**: `google_fonts` (Oswald, Roboto, Open Sans) are used for a clear typographic hierarchy.
*   **Iconography**: Material Design icons enhance usability and visual communication.
*   **Components**: Reusable and themed widgets are used for UI consistency.

## 3. Current Plan: Final Polish & Future Enhancements

This plan outlines the final steps for the application's development, focusing on overall polish and potential future features.

**Plan Steps:**

1.  **Final Polish & Bug Squashing**:
    *   Review the entire application for any remaining bugs or UI inconsistencies.
    *   Add loading indicators where needed for a smoother user experience during data fetching.
    *   Ensure all error messages are user-friendly.
    *   Verify that the application is fully responsive and accessible on both mobile and web platforms.
    *   Conduct thorough end-to-end testing of all user flows (Public, Attendee, and Manager).

2.  **Future Enhancements (Post-MVP)**:
    *   Implement more robust security using Firebase Security Rules to protect data at the backend.
    *   Add profile picture upload functionality for both managers and attendees.
    *   Integrate real-time chat for event collaborators.
    *   Implement push notifications using Firebase Cloud Messaging to alert attendees of event updates.
