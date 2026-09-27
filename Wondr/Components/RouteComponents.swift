import SwiftUI

struct StopRow: View {
    let stop: WondrWaypoint
    let theme: WondrTheme
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: stop.place.category.systemImage)
                .foregroundStyle(theme.accent)
                .frame(width: 34, height: 34)
                .background(theme.softAccent, in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(stop.place.name).font(.subheadline.weight(.semibold))
                Text(stop.place.category.title).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(role: .destructive, action: onRemove) { Image(systemName: "minus.circle") }
                .accessibilityLabel("Remove \(stop.place.name)")
        }
        .padding(.vertical, 4)
    }
}

struct RouteSummaryCard: View {
    let route: RoutePreview
    let theme: WondrTheme
    let distanceUnit: DistanceUnit

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Your route", systemImage: route.mode.systemImage).font(.headline)
                Spacer()
                Text(route.isLiveMapKitRoute ? "Live" : "Estimate")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(route.isLiveMapKitRoute ? .green : .orange)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background((route.isLiveMapKitRoute ? Color.green : Color.orange).opacity(0.12), in: Capsule())
            }
            HStack(spacing: 8) {
                RouteMetricChip(value: distanceUnit.formatted(route.distanceMeters), label: "distance", systemImage: "map", tint: theme.accent)
                if route.mode == .walk {
                    RouteMetricChip(value: "\(route.estimatedSteps.formatted())", label: "steps", systemImage: "figure.walk", tint: theme.accentSecondary)
                }
                RouteMetricChip(value: "\(route.durationMinutes) min", label: "moving", systemImage: "clock", tint: theme.route)
            }
            .frame(maxWidth: .infinity)
        }
        .cardSurface()
    }
}

struct RouteMetricChip: View {
    let value: String
    let label: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 26, height: 26)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(value)
                .font(.subheadline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(tint.opacity(0.16), lineWidth: 1)
        }
    }
}

struct SaveToast: View {
    let feedback: SaveFeedback
    let theme: WondrTheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: feedback.isRemoval ? "bookmark.slash.fill" : "bookmark.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(theme.accentGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(feedback.title)
                    .font(.subheadline.weight(.bold))
                Text(feedback.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(theme.accent.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.14), radius: 18, y: 8)
    }
}
