import Foundation

extension AppModel {
    func startTrip() {
        guard let routePreview else { return }
        let trip = WondrTrip(
            id: UUID(),
            title: routePreview.waypoints.map(\.place.name).joined(separator: " + "),
            mode: routePreview.mode,
            date: .now,
            distanceMeters: routePreview.distanceMeters,
            durationSeconds: routePreview.durationSeconds,
            steps: routePreview.estimatedSteps,
            stops: routePreview.waypoints,
            path: routePreview.path,
            isComplete: false
        )
        activeTrip = trip
        activeTripStartedAt = .now
        isTripPaused = false
        locationService.start()
    }

    func toggleTripPause() {
        guard activeTrip != nil else { return }
        isTripPaused.toggle()
    }

    func finishTrip() {
        guard let activeTrip, let startedAt = activeTripStartedAt else { return }
        let endedAt = Date()
        var finishedTrip = activeTrip
        finishedTrip.isComplete = true
        finishedTrip.durationSeconds = endedAt.timeIntervalSince(startedAt)
        completedTrips.insert(finishedTrip, at: 0)
        persistence.saveTrips(completedTrips)
        self.activeTrip = nil
        activeTripStartedAt = nil
        isTripPaused = false
        locationService.stop()
    }
}
