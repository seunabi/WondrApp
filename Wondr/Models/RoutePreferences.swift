import Foundation

enum RouteStyle: String, CaseIterable, Codable, Identifiable, Sendable {
    case fastest
    case scenic

    var id: Self { self }

    var title: String {
        switch self {
        case .fastest: "Fastest"
        case .scenic: "Scenic"
        }
    }
}

enum RouteDuration: Int, CaseIterable, Codable, Identifiable, Sendable {
    case any = 0
    case fifteen = 15
    case thirty = 30
    case fortyFive = 45
    case sixty = 60

    var id: Self { self }

    var title: String {
        guard let minutes else { return "Any duration" }
        return "About \(minutes) minutes"
    }

    var minutes: Int? {
        rawValue == 0 ? nil : rawValue
    }
}

struct RoutePreferences: Codable, Hashable, Sendable {
    var style: RouteStyle = .fastest
    var avoidsBusyRoads = false
    var targetDuration: RouteDuration = .any

    static let `default` = RoutePreferences()
}
