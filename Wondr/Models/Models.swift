import Foundation

enum ActivityMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case walk
    case cycle

    var id: Self { self }

    var title: String {
        switch self {
        case .walk: "Walk"
        case .cycle: "Cycle"
        }
    }

    var systemImage: String {
        switch self {
        case .walk: "figure.walk"
        case .cycle: "figure.outdoor.cycle"
        }
    }
}

enum AppTab: Hashable, Sendable {
    case plan
    case explore
    case history
}

struct SaveFeedback: Equatable, Sendable {
    let title: String
    let message: String
    let isRemoval: Bool
}

enum POICategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case park
    case bridge
    case landmark
    case food
    case drink
    case restroom
    case custom

    var id: Self { self }

    var title: String {
        switch self {
        case .park: "Parks"
        case .bridge: "Bridges"
        case .landmark: "Landmarks"
        case .food: "Food"
        case .drink: "Drinks"
        case .restroom: "Restrooms"
        case .custom: "Places"
        }
    }

    var systemImage: String {
        switch self {
        case .park: "tree.fill"
        case .bridge: "road.lanes"
        case .landmark: "building.columns.fill"
        case .food: "fork.knife"
        case .drink: "cup.and.saucer.fill"
        case .restroom: "figure.dress.line.vertical.figure"
        case .custom: "mappin.and.ellipse"
        }
    }
}

struct WondrCoordinate: Codable, Hashable, Sendable {
    var latitude: Double
    var longitude: Double
}

struct WondrPlace: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var name: String
    var category: POICategory
    var coordinate: WondrCoordinate
    var subtitle: String
    var distanceMeters: Double?
    var address: String? = nil
    var phoneNumber: String? = nil
    var websiteURL: String? = nil
    var isFeatured: Bool = false
}

struct WondrWaypoint: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var place: WondrPlace
    var isRequired: Bool = true
}

struct NavigationStep: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var instruction: String
    var distanceMeters: Double
}

struct RoutePreview: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var mode: ActivityMode
    var waypoints: [WondrWaypoint]
    var path: [WondrCoordinate]
    var distanceMeters: Double
    var durationSeconds: TimeInterval
    var estimatedSteps: Int
    var steps: [NavigationStep]
    var isReturnRoute: Bool
    var isLiveMapKitRoute: Bool
    var preferences: RoutePreferences

    init(
        id: UUID,
        mode: ActivityMode,
        waypoints: [WondrWaypoint],
        path: [WondrCoordinate],
        distanceMeters: Double,
        durationSeconds: TimeInterval,
        estimatedSteps: Int,
        steps: [NavigationStep],
        isReturnRoute: Bool,
        isLiveMapKitRoute: Bool,
        preferences: RoutePreferences = .default
    ) {
        self.id = id
        self.mode = mode
        self.waypoints = waypoints
        self.path = path
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.estimatedSteps = estimatedSteps
        self.steps = steps
        self.isReturnRoute = isReturnRoute
        self.isLiveMapKitRoute = isLiveMapKitRoute
        self.preferences = preferences
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case mode
        case waypoints
        case path
        case distanceMeters
        case durationSeconds
        case estimatedSteps
        case steps
        case isReturnRoute
        case isLiveMapKitRoute
        case preferences
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        mode = try container.decode(ActivityMode.self, forKey: .mode)
        waypoints = try container.decode([WondrWaypoint].self, forKey: .waypoints)
        path = try container.decode([WondrCoordinate].self, forKey: .path)
        distanceMeters = try container.decode(Double.self, forKey: .distanceMeters)
        durationSeconds = try container.decode(TimeInterval.self, forKey: .durationSeconds)
        estimatedSteps = try container.decode(Int.self, forKey: .estimatedSteps)
        steps = try container.decode([NavigationStep].self, forKey: .steps)
        isReturnRoute = try container.decode(Bool.self, forKey: .isReturnRoute)
        isLiveMapKitRoute = try container.decode(Bool.self, forKey: .isLiveMapKitRoute)
        preferences = try container.decodeIfPresent(RoutePreferences.self, forKey: .preferences) ?? .default
    }

    var durationMinutes: Int { max(1, Int((durationSeconds / 60).rounded())) }
}

struct WondrTrip: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var title: String
    var mode: ActivityMode
    var date: Date
    var distanceMeters: Double
    var durationSeconds: TimeInterval
    var steps: Int
    var stops: [WondrWaypoint]
    var path: [WondrCoordinate]
    var isComplete: Bool

    init(
        id: UUID,
        title: String,
        mode: ActivityMode,
        date: Date,
        distanceMeters: Double,
        durationSeconds: TimeInterval,
        steps: Int,
        stops: [WondrWaypoint],
        path: [WondrCoordinate] = [],
        isComplete: Bool
    ) {
        self.id = id
        self.title = title
        self.mode = mode
        self.date = date
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.steps = steps
        self.stops = stops
        self.path = path
        self.isComplete = isComplete
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case mode
        case date
        case distanceMeters
        case durationSeconds
        case steps
        case stops
        case path
        case isComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        mode = try container.decode(ActivityMode.self, forKey: .mode)
        date = try container.decode(Date.self, forKey: .date)
        distanceMeters = try container.decode(Double.self, forKey: .distanceMeters)
        durationSeconds = try container.decode(TimeInterval.self, forKey: .durationSeconds)
        steps = try container.decode(Int.self, forKey: .steps)
        stops = try container.decode([WondrWaypoint].self, forKey: .stops)
        path = try container.decodeIfPresent([WondrCoordinate].self, forKey: .path) ?? []
        isComplete = try container.decode(Bool.self, forKey: .isComplete)
    }
}

enum CloudSyncStatus: Equatable, Sendable {
    case checking
    case available
    case localOnly(String)
    case needsAccount
}

enum AccentChoice: String, CaseIterable, Identifiable, Sendable {
    case wondr
    case sunset
    case meadow
    case ocean
    case lavender
    case citrus
    case plum
    case rose

    var id: Self { self }

    var title: String {
        switch self {
        case .wondr: "Wondr"
        case .sunset: "Sunset"
        case .meadow: "Meadow"
        case .ocean: "Ocean"
        case .lavender: "Lavender"
        case .citrus: "Citrus"
        case .plum: "Plum"
        case .rose: "Rose"
        }
    }
}

enum AppIconChoice: String, CaseIterable, Identifiable, Sendable {
    case wondr = "icon"
    case blue = "icon-blue"
    case darkPink = "icon-dark-pink"
    case gold = "icon-gold"
    case green = "icon-green"
    case orange = "icon-orange"
    case pink = "icon-pink"
    case purple = "icon-purple"

    var id: Self { self }

    var title: String {
        switch self {
        case .wondr: "Wondr"
        case .blue: "Blue"
        case .darkPink: "Dark pink"
        case .gold: "Gold"
        case .green: "Green"
        case .orange: "Orange"
        case .pink: "Pink"
        case .purple: "Purple"
        }
    }

    var assetName: String {
        switch self {
        case .wondr: "ico-def"
        case .blue: "ico-blu"
        case .darkPink: "ico-dar-pin"
        case .gold: "ico-gol"
        case .green: "ico-gre"
        case .orange: "ico-ora"
        case .pink: "ico-pin"
        case .purple: "ico-pur"
        }
    }

    var alternateIconName: String? {
        self == .wondr ? nil : rawValue
    }
}

struct RouteDraft: Sendable {
    var mode: ActivityMode = .walk
    var isReturnRoute = true
    var start: WondrPlace?
    var stops: [WondrWaypoint] = []
}
