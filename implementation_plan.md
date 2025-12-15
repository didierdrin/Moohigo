# Implementation Plan - Moohigo App

## Overview
This plan outlines the implementation of the Moohigo mobile app, a legal/reading app with Light/Dark mode, Discover, Read, Search, and Profile features.

## Completed Tasks

### 1. Foundation & Configuration
- [x] Updated `pubspec.yaml` with dependencies: `firebase_core`, `cloud_firestore`, `flutter_bloc`, `shared_preferences`, `google_fonts`, `flutter_tts`, `intl`.
- [x] Enabled assets (`assets/images/`) in `pubspec.yaml`.
- [x] Generated `moohigo_light.png` and `moohigo_dark.png` assets.
- [x] Setup `MainScreen` with `BottomNavigationBar` and `MultiBlocProvider`.
- [x] Setup `AppTheme` with Light/Dark modes using `GoogleFonts.outfit`.

### 2. State Management (Bloc/Cubit)
- [x] `ThemeCubit`: Manages theme pulsing `SharedPreferences`.
- [x] `MainScreenCubit`: Manages bottom navigation index.
- [x] `DiscoverCubit`: Fetches daily readings and recent reads.
- [x] `ReadCubit`: Manages document reading state, TTS logic.
- [x] `SearchCubit`: Manages search state, AI toggle, and chat history.
- [x] `ProfileCubit`: Manages user profile data.

### 3. Data Layer
- [x] Created `LegalDocument` model matching the provided JSON structure.
- [x] Created `LawRepository` with:
    - `fetchDailyReading()` (Mock/Firestore).
    - `searchArticles()` (Mock/Firestore logic).
    - Mock data generation for demo purposes.

### 4. Screens Implementation
- [x] **Discover Screen**:
    - Dynamic logo based on theme.
    - "Today's Reading" slideshow (PageView) -> Navigates to Read tab.
    - "Recent Reads" horizontal list -> Navigates to Read tab.
    - "Legal Domains" list.
- [x] **Read Screen**:
    - `CustomScrollView` with `SliverAppBar` (collapsible header).
    - Article content display with `GoogleFonts.merriweather`.
    - Floating navigation buttons (Previous/Next) for article navigation.
    - Floating Play/Pause button for AI TTS.
- [x] **Search Screen**:
    - Toggle between Normal Search and AI Chat.
    - Normal Search: ListTiles -> Navigates to Read tab.
    - AI Search: Chat interface with document context.
- [x] **Profile Screen**:
    - User details display.
    - Dark Mode toggle switch.

## Next Steps for User
1.  Run `flutter run` to start the app.
2.  Test the Light/Dark mode toggle in Profile.
3.  Navigate through Discover -> Read -> Search flows.
4.  Test Text-to-Speech in Read screen (ensure volume is up).
5.  Test Search functionalities (Normal vs AI).

## Notes
- Firebase configuration (`firebase_options.dart`) is assumed to be present/working or placeholders are used.
- Actual Firestore connection will work if `google-services.json` is set up properly; otherwise, mock data is used by `LawRepository`.
