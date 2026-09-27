import SwiftUI

struct RouteReadyCard: View {
    let route: RoutePreview
    let theme: WondrTheme
    let distanceUnit: DistanceUnit
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "map.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(theme.accentGradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Route ready")
                        .font(.headline)
                    Text("\(distanceUnit.formatted(route.distanceMeters)) · \(route.durationMinutes) min · \(route.waypoints.count) \(route.waypoints.count == 1 ? "stop" : "stops")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .cardSurface()
    }
}
