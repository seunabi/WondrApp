import Foundation

struct WondrPersistence {
    private enum Key {
        static let accent = "wondr.accent"
        static let appIcon = "wondr.app.icon"
        static let distanceUnit = "wondr.distance.unit"
        static let routePreferences = "wondr.route.preferences"
        static let onboardingCompleted = "wondr.onboarding.completed"
        static let trips = "wondr.trips"
        static let plans = "wondr.plans"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadAccent() -> AccentChoice {
        AccentChoice(rawValue: defaults.string(forKey: Key.accent) ?? "wondr") ?? .wondr
    }

    func saveAccent(_ choice: AccentChoice) {
        defaults.set(choice.rawValue, forKey: Key.accent)
    }

    func loadAppIcon() -> AppIconChoice {
        AppIconChoice(rawValue: defaults.string(forKey: Key.appIcon) ?? AppIconChoice.wondr.rawValue) ?? .wondr
    }

    func saveAppIcon(_ choice: AppIconChoice) {
        defaults.set(choice.rawValue, forKey: Key.appIcon)
    }

    func loadDistanceUnit() -> DistanceUnit {
        DistanceUnit(rawValue: defaults.string(forKey: Key.distanceUnit) ?? "kilometres") ?? .kilometres
    }

    func saveDistanceUnit(_ unit: DistanceUnit) {
        defaults.set(unit.rawValue, forKey: Key.distanceUnit)
    }

    func loadRoutePreferences() -> RoutePreferences {
        guard let data = defaults.data(forKey: Key.routePreferences), let preferences = try? JSONDecoder().decode(RoutePreferences.self, from: data) else {
            return .default
        }
        return preferences
    }

    func saveRoutePreferences(_ preferences: RoutePreferences) {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        defaults.set(data, forKey: Key.routePreferences)
    }

    func loadOnboardingCompleted() -> Bool {
        defaults.bool(forKey: Key.onboardingCompleted)
    }

    func saveOnboardingCompleted(_ completed: Bool) {
        defaults.set(completed, forKey: Key.onboardingCompleted)
    }

    func loadTrips() -> [WondrTrip] {
        guard let data = defaults.data(forKey: Key.trips), let trips = try? JSONDecoder().decode([WondrTrip].self, from: data) else {
            return []
        }
        return trips
    }

    func saveTrips(_ trips: [WondrTrip]) {
        guard let data = try? JSONEncoder().encode(trips) else { return }
        defaults.set(data, forKey: Key.trips)
    }

    func loadPlans() -> [RoutePreview] {
        guard let data = defaults.data(forKey: Key.plans), let plans = try? JSONDecoder().decode([RoutePreview].self, from: data) else {
            return []
        }
        return plans
    }

    func savePlans(_ plans: [RoutePreview]) {
        guard let data = try? JSONEncoder().encode(plans) else { return }
        defaults.set(data, forKey: Key.plans)
    }

    func reset() {
        [Key.accent, Key.appIcon, Key.distanceUnit, Key.routePreferences, Key.onboardingCompleted, Key.trips, Key.plans]
            .forEach { defaults.removeObject(forKey: $0) }
    }
}
