import Foundation
import CoreLocation
import MapKit

extension AppModel {
    func toggleCategory(_ category: POICategory) {
        selectedCategory = selectedCategory == category ? nil : category
    }

    func searchPlaces(_ query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            searchError = nil
            isSearching = false
            return
        }

        isSearching = true
        searchError = nil
        guard let region = searchRegion else {
            isSearching = false
            searchError = "Allow location access before searching for nearby places."
            return
        }
        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await mapKitService.search(query: trimmed, region: region)
                guard !Task.isCancelled else { return }
                searchResults = results
            } catch {
                guard !Task.isCancelled else { return }
                let fallback = places.filter { $0.name.localizedCaseInsensitiveContains(trimmed) || $0.subtitle.localizedCaseInsensitiveContains(trimmed) }
                searchResults = fallback
                searchError = fallback.isEmpty ? "Search is unavailable right now. Try another place or category." : nil
            }
            isSearching = false
        }
    }

    func addPlaceToPlan(_ place: WondrPlace) {
        guard !draft.stops.contains(where: { $0.place.id == place.id }) else {
            showRouteFeedback("\(place.name) is already in your route.")
            return
        }
        draft.stops.append(WondrWaypoint(id: UUID(), place: place))
        routePreview = nil
        routeError = nil
        showRouteFeedback("Added \(place.name) to your route.")
    }

    func removeStop(_ stop: WondrWaypoint) {
        draft.stops.removeAll { $0.id == stop.id }
        routePreview = nil
        showRouteFeedback("Removed \(stop.place.name) from your route.")
    }

    func moveStop(from offsets: IndexSet, to index: Int) {
        var updated = draft.stops
        let moving = offsets.map { updated[$0] }
        for sourceIndex in offsets.sorted(by: >) {
            updated.remove(at: sourceIndex)
        }
        let removedBeforeDestination = offsets.filter { $0 < index }.count
        let destination = min(max(0, index - removedBeforeDestination), updated.count)
        updated.insert(contentsOf: moving, at: destination)
        draft.stops = updated
        routePreview = nil
        showRouteFeedback("Route stops reordered.")
    }

    func isPlaceInRoute(_ place: WondrPlace) -> Bool {
        draft.stops.contains { $0.place.id == place.id }
    }

    func calculateRoute() {
        routeTask?.cancel()
        isCalculatingRoute = true
        routeError = nil

        routeTask = Task { [weak self] in
            guard let self else { return }
            guard let start = currentPlace else {
                isCalculatingRoute = false
                routeError = "Allow location access before calculating a route."
                return
            }
            let stops = draft.stops
            guard !stops.isEmpty else {
                isCalculatingRoute = false
                routeError = "Add at least one nearby place to calculate a route."
                return
            }
            let destinations = stops
            var points = [start] + destinations.map(\.place)
            if draft.isReturnRoute { points.append(start) }

            var combinedPath: [WondrCoordinate] = []
            var combinedSteps: [NavigationStep] = []
            var distance = 0.0
            var duration = 0.0
            var gotLiveRoute = true

            for pair in zip(points, points.dropFirst()) {
                guard !Task.isCancelled else { return }
                do {
                    let segment = try await mapKitService.calculateSegment(
                        from: pair.0,
                        to: pair.1,
                        mode: draft.mode,
                        preferences: routePreferences
                    )
                    combinedPath.append(contentsOf: combinedPath.isEmpty ? segment.path : Array(segment.path.dropFirst()))
                    combinedSteps.append(contentsOf: segment.steps)
                    distance += segment.distanceMeters
                    duration += segment.durationSeconds
                } catch {
                    gotLiveRoute = false
                    let segmentDistance = Self.distance(from: pair.0.coordinate, to: pair.1.coordinate)
                    let estimatedSpeed = draft.mode == .walk ? 1.35 : 4.7
                    distance += segmentDistance
                    duration += segmentDistance / estimatedSpeed
                    combinedPath.append(contentsOf: [pair.0.coordinate, pair.1.coordinate])
                    combinedSteps.append(NavigationStep(id: UUID(), instruction: "Continue toward \(pair.1.name)", distanceMeters: segmentDistance))
                }
            }

            guard !Task.isCancelled else { return }
            let preview = RoutePreview(
                id: UUID(),
                mode: draft.mode,
                waypoints: destinations,
                path: combinedPath,
                distanceMeters: distance,
                durationSeconds: duration,
                estimatedSteps: StepEstimator.steps(for: distance, mode: draft.mode),
                steps: combinedSteps,
                isReturnRoute: draft.isReturnRoute,
                isLiveMapKitRoute: gotLiveRoute,
                preferences: routePreferences
            )
            routePreview = preview
            isCalculatingRoute = false
            if !gotLiveRoute {
                routeError = "Showing an offline estimate. Connect to the internet for a precise route."
            } else if let targetMinutes = routePreferences.targetDuration.minutes, preview.durationMinutes > targetMinutes {
                routeError = "This route is longer than your \(targetMinutes)-minute target."
            }
        }
    }

    func saveCurrentPlan() {
        guard let routePreview else { return }
        guard !savedPlans.contains(where: { $0.id == routePreview.id }) else { return }
        savedPlans.insert(routePreview, at: 0)
        persistence.savePlans(savedPlans)
        showSaveFeedback(SaveFeedback(title: "Route saved", message: "Find it anytime in History.", isRemoval: false))
    }

    func removeCurrentPlan() {
        guard let routePreview else { return }
        savedPlans.removeAll { $0.id == routePreview.id }
        persistence.savePlans(savedPlans)
        showSaveFeedback(SaveFeedback(title: "Route removed", message: "Removed from your saved routes.", isRemoval: true))
    }

    var isCurrentPlanSaved: Bool {
        guard let routePreview else { return false }
        return savedPlans.contains { $0.id == routePreview.id }
    }

    func deleteSavedPlan(_ plan: RoutePreview) {
        savedPlans.removeAll { $0.id == plan.id }
        persistence.savePlans(savedPlans)
    }

    func duplicateSavedPlan(_ plan: RoutePreview) {
        let duplicate = RoutePreview(
            id: UUID(),
            mode: plan.mode,
            waypoints: plan.waypoints,
            path: plan.path,
            distanceMeters: plan.distanceMeters,
            durationSeconds: plan.durationSeconds,
            estimatedSteps: plan.estimatedSteps,
            steps: plan.steps,
            isReturnRoute: plan.isReturnRoute,
            isLiveMapKitRoute: plan.isLiveMapKitRoute,
            preferences: plan.preferences
        )
        savedPlans.insert(duplicate, at: 0)
        persistence.savePlans(savedPlans)
    }

    func loadSavedPlan(_ plan: RoutePreview) {
        routePreview = plan
        draft.mode = plan.mode
        draft.stops = plan.waypoints
        draft.isReturnRoute = plan.isReturnRoute
        draft.start = currentPlace
        routePreferences = plan.preferences
        routeError = nil
        selectedTab = .plan
        shouldShowRoutePreview = true
    }

    func resetPlan() {
        draft = RouteDraft(start: currentPlace, stops: [])
        routePreview = nil
        routeError = nil
        routeFeedbackTask?.cancel()
        routeFeedbackTask = nil
        routeFeedback = nil
    }

    private static func distance(from first: WondrCoordinate, to second: WondrCoordinate) -> Double {
        CLLocation(latitude: first.latitude, longitude: first.longitude).distance(from: CLLocation(latitude: second.latitude, longitude: second.longitude))
    }
}
