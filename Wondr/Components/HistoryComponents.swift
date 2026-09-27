import SwiftUI

struct TripHistoryCard: View {
    let trip: WondrTrip
    let theme: WondrTheme
    let distanceUnit: DistanceUnit

    var body: some View {
        NavigationLink {
            TripHistoryDetailView(trip: trip, theme: theme, distanceUnit: distanceUnit)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: trip.mode.systemImage)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(theme.accentGradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                VStack(alignment: .leading, spacing: 5) {
                    Text(trip.title.isEmpty ? "Wondr trip" : trip.title).font(.headline)
                    Text(trip.date.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundStyle(.secondary)
                    Text(distanceSummary)
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

    private var distanceSummary: String {
        let distance = distanceUnit.formatted(trip.distanceMeters)
        guard trip.mode == .walk else { return distance }
        return "\(distance) · \(trip.steps.formatted()) steps"
    }
}

struct SavedRouteCard: View {
    let plan: RoutePreview
    let theme: WondrTheme
    let distanceUnit: DistanceUnit

    var body: some View {
        NavigationLink {
            SavedRouteDetailView(plan: plan, theme: theme)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: plan.mode.systemImage)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(theme.accentGradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(routeTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(plan.isReturnRoute ? "Loop route" : "Point-to-point")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.accent)
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

    private var routeTitle: String {
        let names = plan.waypoints.map(\.place.name)
        return names.isEmpty ? "Saved route" : names.joined(separator: " + ")
    }

    private var summary: String {
        let distance = distanceUnit.formatted(plan.distanceMeters)
        let stops = "\(plan.waypoints.count) \(plan.waypoints.count == 1 ? "stop" : "stops")"
        return plan.mode == .walk ? "\(distance) · \(stops) · \(plan.estimatedSteps.formatted()) steps" : "\(distance) · \(stops)"
    }
}

struct EmptyHistoryView: View {
    let theme: WondrTheme

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "figure.walk.motion")
                .font(.title.weight(.semibold))
                .foregroundStyle(theme.accent)
                .frame(width: 62, height: 62)
                .background(theme.softAccent, in: Circle())
            Text("No adventures yet")
                .font(.title3.bold())
            Text("Finished routes will appear here, ready to look back on.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
        .cardSurface(cornerRadius: 22)
    }
}

struct PersonalStatsCard: View {
    let weeklyDistance: String
    let weeklyTrips: Int
    let walkingTrips: Int
    let cyclingTrips: Int
    let theme: WondrTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal stats")
                .font(.title3.bold())

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                PersonalStatItem(value: weeklyDistance, label: "this week", systemImage: "calendar", tint: theme.accent)
                PersonalStatItem(value: "\(weeklyTrips)", label: "trips this week", systemImage: "figure.walk.motion", tint: theme.accentSecondary)
            }

            HStack(spacing: 10) {
                ActivityBreakdownItem(title: "Walking", value: walkingTrips, tint: theme.accent)
                ActivityBreakdownItem(title: "Cycling", value: cyclingTrips, tint: theme.route)
            }
        }
        .cardSurface()
    }
}

private struct PersonalStatItem: View {
    let value: String
    let label: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.headline)
                Text(label).font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ActivityBreakdownItem: View {
    let title: String
    let value: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(tint)
                .frame(width: 8, height: 8)
            Text(title).font(.caption.weight(.semibold))
            Text("\(value)").font(.caption).foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
    }
}
