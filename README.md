# Wondr

Wondr is an iOS app for planning walking and cycling routes around places you want to visit. It uses your location to find nearby places, build a route, and save trips for later.

## Features

- Plan walking or cycling routes with selected stops.
- Explore nearby places such as parks, landmarks, food, and drinks.
- View route details and follow a trip in progress.
- Review saved trips in your history.
- Customize route preferences, distance units, and app appearance.

## Requirements

- Xcode
- iOS 26 or later

Location access is required to discover nearby places and calculate routes. Wondr uses MapKit for maps and routing.

## Build and run

1. Open `Wondr.xcodeproj` in Xcode.
2. Select the Wondr scheme and an iOS 26 or later simulator or device.
3. Build and run the app.

## Project structure

- `Wondr/Scenes`: Main app screens.
- `Wondr/Components`: Reusable interface and map components.
- `Wondr/Models`: App state and data models.
- `Wondr/Features`: Planning, location, trip, and feedback logic.
- `Wondr/Infrastructure`: Persistence and visual theme.
