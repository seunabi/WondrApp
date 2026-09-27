import Foundation
import Combine
import CoreLocation
import UIKit

@MainActor
final class AppModel: ObservableObject {
    // MARK: - Shared dependencies

    let mapKitService = MapKitService()
    let locationService = LocationService()
    let cloudSync = CloudSyncCoordinator()
    let persistence: WondrPersistence

    // MARK: - Published state

    @Published var places: [WondrPlace] = []
    @Published var searchResults: [WondrPlace] = []
    @Published var searchQuery = ""
    @Published var selectedCategory: POICategory?
    @Published var draft = RouteDraft()
    @Published var routePreview: RoutePreview?
    @Published var savedPlans: [RoutePreview] = []
    @Published var completedTrips: [WondrTrip] = []
    @Published var activeTrip: WondrTrip?
    @Published var isTripPaused = false
    @Published var activeTripStartedAt: Date?
    @Published var routeError: String?
    @Published var isCalculatingRoute = false
    @Published var isSearching = false
    @Published var searchError: String?
    @Published var currentCoordinate: WondrCoordinate?
    @Published var locationError: String?
    @Published var routeFeedback: String?
    @Published var accentChoice: AccentChoice
    @Published var distanceUnit: DistanceUnit
    @Published var routePreferences: RoutePreferences
    @Published var appIconChoice: AppIconChoice
    @Published var cloudStatus: CloudSyncStatus = .checking
    @Published var hasCompletedOnboarding: Bool
    @Published var selectedTab: AppTab = .plan
    @Published var saveFeedback: SaveFeedback?
    @Published var mapRecenterRequest = UUID()
    @Published var shouldShowRoutePreview = false

    // MARK: - In-flight work

    var routeTask: Task<Void, Never>?
    var searchTask: Task<Void, Never>?
    var nearbyPlacesTask: Task<Void, Never>?
    var routeFeedbackTask: Task<Void, Never>?
    var saveFeedbackTask: Task<Void, Never>?

    // MARK: - Derived state

    var theme: WondrTheme { .forChoice(accentChoice) }

    var filteredPlaces: [WondrPlace] {
        guard let selectedCategory else { return places }
        return places.filter { $0.category == selectedCategory }
    }

    var planningPlaces: [WondrPlace] {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? filteredPlaces : searchResults
    }

    var locationIsAvailable: Bool {
        switch locationService.authorization {
        case .authorizedAlways, .authorizedWhenInUse: true
        default: false
        }
    }

    init(persistence: WondrPersistence = WondrPersistence()) {
        self.persistence = persistence
        accentChoice = persistence.loadAccent()
        appIconChoice = persistence.loadAppIcon()
        distanceUnit = persistence.loadDistanceUnit()
        routePreferences = persistence.loadRoutePreferences()
        hasCompletedOnboarding = persistence.loadOnboardingCompleted()

        locationService.onLocationChange = { [weak self] coordinate in
            self?.receiveLocation(coordinate)
        }
        locationService.onLocationError = { [weak self] message in
            self?.locationError = message
        }
        cloudSync.onStatusChange = { [weak self] status in
            self?.cloudStatus = status
        }

        completedTrips = persistence.loadTrips()
        savedPlans = persistence.loadPlans()
        cloudSync.refresh()
    }

    // MARK: - App lifecycle

    func setAccent(_ choice: AccentChoice) {
        accentChoice = choice
        persistence.saveAccent(choice)
    }

    func setAppIcon(_ choice: AppIconChoice) {
        appIconChoice = choice
        persistence.saveAppIcon(choice)

        guard UIApplication.shared.supportsAlternateIcons else { return }
        UIApplication.shared.setAlternateIconName(choice.alternateIconName, completionHandler: nil)
    }

    func setDistanceUnit(_ unit: DistanceUnit) {
        distanceUnit = unit
        persistence.saveDistanceUnit(unit)
    }

    func setRouteStyle(_ style: RouteStyle) {
        routePreferences.style = style
        persistence.saveRoutePreferences(routePreferences)
    }

    func setAvoidsBusyRoads(_ avoidsBusyRoads: Bool) {
        routePreferences.avoidsBusyRoads = avoidsBusyRoads
        persistence.saveRoutePreferences(routePreferences)
    }

    func setTargetDuration(_ duration: RouteDuration) {
        routePreferences.targetDuration = duration
        persistence.saveRoutePreferences(routePreferences)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        persistence.saveOnboardingCompleted(true)
    }

    func replayOnboarding() {
        hasCompletedOnboarding = false
        persistence.saveOnboardingCompleted(false)
    }

    func resetApp() {
        routeTask?.cancel()
        searchTask?.cancel()
        nearbyPlacesTask?.cancel()
        routeFeedbackTask?.cancel()
        saveFeedbackTask?.cancel()
        locationService.stop()
        persistence.reset()

        places = []
        searchResults = []
        searchQuery = ""
        selectedCategory = nil
        draft = RouteDraft()
        routePreview = nil
        savedPlans = []
        completedTrips = []
        activeTrip = nil
        selectedTab = .plan
        shouldShowRoutePreview = false
        isTripPaused = false
        activeTripStartedAt = nil
        routeError = nil
        isCalculatingRoute = false
        isSearching = false
        searchError = nil
        currentCoordinate = nil
        locationError = nil
        routeFeedback = nil
        saveFeedback = nil
        accentChoice = .wondr
        appIconChoice = .wondr
        distanceUnit = .kilometres
        routePreferences = .default
        hasCompletedOnboarding = false

        if UIApplication.shared.supportsAlternateIcons {
            UIApplication.shared.setAlternateIconName(nil, completionHandler: nil)
        }
    }

    func refreshCloudSync() {
        cloudSync.refresh()
    }

    func recenterMap() {
        mapRecenterRequest = UUID()
    }

    var currentPlace: WondrPlace? {
        guard let currentCoordinate else { return nil }
        return WondrPlace(
            id: "current-location",
            name: "Your current location",
            category: .custom,
            coordinate: currentCoordinate,
            subtitle: "Live location",
            distanceMeters: 0
        )
    }

    var mapCenter: WondrCoordinate? {
        currentCoordinate ?? draft.start?.coordinate
    }
}
