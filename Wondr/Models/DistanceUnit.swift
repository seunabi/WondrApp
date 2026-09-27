import Foundation

enum DistanceUnit: String, CaseIterable, Codable, Identifiable, Sendable {
    case metres
    case kilometres
    case yards
    case feet
    case miles

    var id: Self { self }

    var title: String {
        switch self {
        case .metres: "Metres"
        case .kilometres: "Kilometres"
        case .yards: "Yards"
        case .feet: "Feet"
        case .miles: "Miles"
        }
    }

    var symbol: String {
        switch self {
        case .metres: "m"
        case .kilometres: "km"
        case .yards: "yd"
        case .feet: "ft"
        case .miles: "mi"
        }
    }

    private var metresPerUnit: Double {
        switch self {
        case .metres: 1
        case .kilometres: 1_000
        case .yards: 0.9144
        case .feet: 0.3048
        case .miles: 1_609.344
        }
    }

    func formatted(_ metres: Double) -> String {
        let value = metres / metresPerUnit
        switch self {
        case .kilometres, .miles:
            return String(format: "%.1f %@", value, symbol)
        case .metres, .yards, .feet:
            return "\(Int(value.rounded()).formatted()) \(symbol)"
        }
    }
}
