# EveM - Event Management Application Blueprint

## 1. Overview

EveM is a comprehensive Flutter application designed for both event managers and attendees. The primary focus of the initial development is on the event manager's experience. The app will provide tools for managers to create, manage, and monitor events, while attendees will have the ability to discover, register for, and receive updates about events.

The application will be built following modern Flutter best practices, including a clean architecture, state management, and a rich, interactive user interface.

## 2. Project Outline

This section documents the style, design, and features of the EveM application.

### 2.1. Architecture

*   **Structure**: The project will follow a feature-first layered architecture. Code will be organized into `presentation`, `domain`, and `data` layers within each feature folder.
    *   `lib/src/features`: Contains individual features like `auth`, `dashboard`, `event_management`, `onboarding`, `attendee`, etc.
    *   `lib/src/core`: Contains core application logic like routing, theming, and dependency injection.
    *   `lib/src/shared`: Contains shared components, utilities, and models used across multiple features.
*   **State Management**: `provider` will be used for state management and dependency injection to ensure a clear and scalable data flow.
*   **Navigation**: `go_router` will be used for declarative routing, enabling deep linking and a structured navigation system.
*   **UI/UX**: The application will adhere to Material Design 3 principles, with a focus on creating a beautiful, intuitive, and accessible user interface. It will feature a modern design with expressive typography, a vibrant color palette, and interactive components.

### 2.2. Implemented Features

*   **Firebase Integration**:
    *   Firebase Core, Authentication, and Cloud Firestore dependencies added.
    *   Firebase initialized in `main.dart`.
    *   Firebase MCP configured.
*   **Onboarding**:
    *   `WelcomeScreen` as the initial entry point, allowing users to choose between Event Manager and Event Attendee roles.
*   **Authentication**:
    *   `AuthService` for user registration and login using Firebase Authentication.
    *   Manager Login and Registration screens integrated with `AuthService`.
    *   Attendee Login and Registration screens integrated with `AuthService`.
    *   Logout functionality implemented on both Manager Profile and Attendee Dashboard.
*   **Manager Dashboard**:
    *   Bottom navigation bar for switching between Calendar, Events, and Profile sections.
    *   A floating action button on the Events page to add new events.
*   **Event Management (Manager)**:
    *   `Event` model updated with `isPublished` flag.
    *   `EventService` created for handling Firestore CRUD operations for events.
    *   An "Add Event" form with fields for title, description, date, time, and a "Publish Event" switch, now saving data to Firestore.
    *   An "Event Details" screen, fetching event details dynamically from Firestore based on the event ID.
        *   Includes dynamic Budget Summary, Task List, and Collaborator List using Firestore data.
        *   Functionality to add/edit budget, add/delete tasks, and add/delete collaborators implemented.
        *   Functionality to send notifications to attendees for a specific event.
    *   `EditEventScreen` implemented for modifying existing event details, pre-populating fields with current data, including the "Publish Event" switch.
    *   The "Events" overview page fetches and displays events specific to the logged-in manager from Firestore.
    *   Models for `Collaborator`, `Task`, and `Budget` created.
    *   Services for `CollaboratorService`, `TaskService`, and `BudgetService` created for Firestore operations.
*   **Calendar (Manager)**:
    *   A calendar view that fetches events from Firestore, highlights days with events, and displays a list of events for the selected day.
*   **Profile (Manager)**:
    *   A profile page with user information and a logout button.
    *   `EditProfileScreen` implemented for updating user's display name using Firebase Authentication.
*   **Attendee Dashboard**:
    *   Bottom navigation bar for switching between Event Discovery, Notifications, and My Registrations.
    *   `EventDiscoveryScreen` now fetches and displays all *published* events from Firestore with search and filtering capabilities.
    *   `AttendeeEventDetailsScreen` displays event details for attendees and allows them to register for events.
    *   `MyRegistrationsScreen` displays events the attendee has registered for.
    *   `NotificationsScreen` displays all event notifications.
    *   `AttendeeProfileScreen` implemented for updating user's display name using Firebase Authentication.
*   **Notifications**:
    *   `Notification` model and `NotificationService` for sending and receiving event notifications.
*   **Registrations**:
    *   `Registration` model and `RegistrationService` for handling event registrations.

### 2.3. Design System

*   **Color Palette**: A modern and vibrant color scheme has been defined using `ColorScheme.fromSeed` with `Colors.deepPurple` as the primary seed color.
*   **Typography**: `google_fonts` has been integrated to use the Oswald, Roboto, and Open Sans fonts for a clear and expressive typographic hierarchy.
*   **Iconography**: Material Design icons are used throughout the application to enhance usability and visual communication.
*   **Components**: Reusable and themed widgets have been created for common UI elements like buttons, text fields, and cards.

## 3. Current Plan: Next Steps

This plan outlines the final steps for the application's development, focusing on overall polish and potential future enhancements.

**Plan Steps:**

1.  **Final Polish**:
    *   Review the entire application for any remaining bugs or UI inconsistencies.
    *   Add loading indicators where needed for a smoother user experience.
    *   Ensure accessibility standards are met throughout the application.
    *   Conduct thorough testing of all features.
2.  **Future Enhancements (Consideration)**:
    *   Implement user roles more robustly with Firebase Security Rules.
    *   Add profile picture upload functionality.
    *   Integrate real-time chat for event collaborators.
    *   Implement push notifications using Firebase Cloud Messaging.
