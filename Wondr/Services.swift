import CoreLocation
import Foundation
import MapKit

struct RouteSegment: Sendable {
    var path: [WondrCoordinate]
    var distanceMeters: Double
    var durationSeconds: TimeInterval
    var steps: [NavigationStep]
}

enum WondrServiceError: LocalizedError {
    case noRoute
    case noSearchResults

    var errorDescription: String? {
        switch self {
        case .noRoute: "A route could not be calculated for this leg."
        case .noSearchResults: "No places were found nearby."
        }
    }
}

@MainActor
final class MapKitService {
    func search(query: String, region: MKCoordinateRegion) async throws -> [WondrPlace] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        request.resultTypes = [.pointOfInterest, .address]

        let response = try await MKLocalSearch(request: request).start()
        let places = response.mapItems.compactMap(makePlace)
        guard !places.isEmpty else { throw WondrServiceError.noSearchResults }
        return places
    }

    func searchNearby(region: MKCoordinateRegion) async -> [WondrPlace] {
        let queries = ["park", "bridge", "landmark", "restaurant", "cafe"]
        let center = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        var placesByID: [String: WondrPlace] = [:]

        for query in queries {
            guard !Task.isCancelled else { return Array(placesByID.values) }
            guard let results = try? await search(query: query, region: region) else { continue }
            for var place in results where !isHealthPlace(place) {
                let placeLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                place.distanceMeters = center.distance(from: placeLocation)
                placesByID[place.id] = place
            }
        }

        return placesByID.values.sorted { ($0.distanceMeters ?? .greatestFiniteMagnitude) < ($1.distanceMeters ?? .greatestFiniteMagnitude) }
    }

    private func isHealthPlace(_ place: WondrPlace) -> Bool {
        let searchable = "\(place.name) \(place.subtitle)".lowercased()
        let healthTerms = [
            "nhs",
            "hospital",
            "surgery",
            "medical",
            "clinic",
            "health centre",
            "health center",
            "doctor",
            "dentist",
            "pharmacy",
            "gp practice",
            "general practice",
            "optician",
            "physio",
            "physiotherapy",
            "care home"
        ]
        return healthTerms.contains { searchable.contains($0) }
    }

    func calculateSegment(
        from: WondrPlace,
        to: WondrPlace,
        mode: ActivityMode,
        preferences: RoutePreferences = .default
    ) async throws -> RouteSegment {
        let request = MKDirections.Request()
        request.source = MKMapItem(location: CLLocation(latitude: from.coordinate.latitude, longitude: from.coordinate.longitude), address: nil)
        request.destination = MKMapItem(location: CLLocation(latitude: to.coordinate.latitude, longitude: to.coordinate.longitude), address: nil)
        request.transportType = mode == .walk ? .walking : .cycling
        request.requestsAlternateRoutes = true

        let response = try await MKDirections(request: request).calculate()
        guard let route = preferredRoute(from: response.routes, preferences: preferences) else {
            throw WondrServiceError.noRoute
        }

        let routeCoordinates = coordinates(from: route.polyline)
        let routeSteps = route.steps.compactMap { step -> NavigationStep? in
            let instruction = step.instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !instruction.isEmpty else { return nil }
            return NavigationStep(id: UUID(), instruction: instruction, distanceMeters: step.distance)
        }

        return RouteSegment(
            path: routeCoordinates,
            distanceMeters: route.distance,
            durationSeconds: route.expectedTravelTime,
            steps: routeSteps
        )
    }

    private func preferredRoute(from routes: [MKRoute], preferences: RoutePreferences) -> MKRoute? {
        switch preferences.style {
        case .fastest:
            return routes.min { lhs, rhs in
                if preferences.avoidsBusyRoads, lhs.distance != rhs.distance {
                    return lhs.distance > rhs.distance
                }
                return lhs.expectedTravelTime < rhs.expectedTravelTime
            }
        case .scenic:
            return routes.max { lhs, rhs in
                if preferences.avoidsBusyRoads, lhs.distance != rhs.distance {
                    return lhs.distance < rhs.distance
                }
                return lhs.distance < rhs.distance
            }
        }
    }

    private func makePlace(from item: MKMapItem) -> WondrPlace? {
        let coordinate = item.location.coordinate
        guard CLLocationCoordinate2DIsValid(coordinate) else { return nil }
        guard !isParkingLocation(item) else { return nil }
        let name = item.name ?? "Untitled place"
        let category = category(for: item)
        let subtitle = item.addressRepresentations?.cityWithContext ?? category.title
        return WondrPlace(
            id: item.identifier?.rawValue ?? "\(coordinate.latitude)-\(coordinate.longitude)-\(name)",
            name: name,
            category: category,
            coordinate: .init(latitude: coordinate.latitude, longitude: coordinate.longitude),
            subtitle: subtitle,
            distanceMeters: nil,
            address: item.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true),
            phoneNumber: item.phoneNumber,
            websiteURL: item.url?.absoluteString
        )
    }

    private func isParkingLocation(_ item: MKMapItem) -> Bool {
        if item.pointOfInterestCategory == .parking { return true }

        let searchableName = (item.name ?? "").lowercased()
        let parkingTerms = [
            "car park",
            "carpark",
            "parking",
            "park and ride",
            "parkade",
            "parking garage",
            "parking lot",
            "parking deck",
            "multi-storey",
            "multistorey"
        ]
        return parkingTerms.contains { searchableName.contains($0) }
    }

    private func category(for item: MKMapItem) -> POICategory {
        if let pointOfInterestCategory = item.pointOfInterestCategory {
            if pointOfInterestCategory == .park || pointOfInterestCategory == .nationalPark { return .park }
            if pointOfInterestCategory == .cafe || pointOfInterestCategory == .brewery || pointOfInterestCategory == .winery { return .drink }
            if pointOfInterestCategory == .restaurant || pointOfInterestCategory == .foodMarket || pointOfInterestCategory == .bakery { return .food }
            if pointOfInterestCategory == .landmark || pointOfInterestCategory == .castle || pointOfInterestCategory == .fortress || pointOfInterestCategory == .nationalMonument { return .landmark }
        }
        let searchable = (item.name ?? "").lowercased()
        if searchable.contains("park") || searchable.contains("garden") { return .park }
        if searchable.contains("bridge") { return .bridge }
        if searchable.contains("cafe") || searchable.contains("coffee") || searchable.contains("bar") { return .drink }
        if searchable.contains("restaurant") || searchable.contains("market") || searchable.contains("food") { return .food }
        if searchable.contains("museum") || searchable.contains("cathedral") || searchable.contains("monument") { return .landmark }
        return .custom
    }

    private func coordinates(from polyline: MKPolyline) -> [WondrCoordinate] {
        guard polyline.pointCount > 0 else { return [] }
        var coordinates = Array(repeating: CLLocationCoordinate2D(), count: polyline.pointCount)
        polyline.getCoordinates(&coordinates, range: NSRange(location: 0, length: polyline.pointCount))
        return coordinates.map { .init(latitude: $0.latitude, longitude: $0.longitude) }
    }
}

@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var currentCoordinate: WondrCoordinate?
    private(set) var authorization: CLAuthorizationStatus = .notDetermined
    var onLocationChange: ((WondrCoordinate) -> Void)?
    var onLocationError: ((String) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
        authorization = manager.authorizationStatus
    }

    func requestPermission() {
        guard authorization == .notDetermined else { return }
        manager.requestWhenInUseAuthorization()
    }

    func start() {
        switch authorization {
        case .notDetermined:
            requestPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            onLocationError?("Location access is disabled. Enable it in Settings to use live nearby places.")
        @unknown default:
            onLocationError?("Location access is unavailable on this device.")
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        if authorization == .authorizedWhenInUse || authorization == .authorizedAlways {
            manager.startUpdatingLocation()
        } else if authorization == .denied || authorization == .restricted {
            onLocationError?("Location access is disabled. Enable it in Settings to use live nearby places.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
        let coordinate = WondrCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        currentCoordinate = coordinate
        onLocationChange?(coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onLocationError?(error.localizedDescription)
    }
}

@MainActor
final class CloudSyncCoordinator {
    private(set) var status: CloudSyncStatus = .localOnly("CloudKit sync is not configured yet.")
    var onStatusChange: ((CloudSyncStatus) -> Void)?

    private func update(_ status: CloudSyncStatus) {
        self.status = status
        onStatusChange?(status)
    }

    func refresh() {
        update(.localOnly("CloudKit sync is not configured yet."))
    }
}

enum StepEstimator {
    static func steps(for meters: Double, mode: ActivityMode) -> Int {
        let metersPerStep = mode == .walk ? 0.76 : 2.4
        return max(0, Int((meters / metersPerStep).rounded()))
    }
}
