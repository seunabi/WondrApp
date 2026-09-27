import Foundation
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricTile(value: "\(model.completedTrips.count)", label: "trips completed", systemImage: "figure.walk.motion", tint: model.theme.accent)
                            .frame(maxWidth: .infinity)
                        MetricTile(value: totalDistance, label: "distance explored", systemImage: "map", tint: model.theme.accentSecondary)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)

                    PersonalStatsCard(
                        weeklyDistance: weeklyDistance,
                        weeklyTrips: tripsThisWeek.count,
                        walkingTrips: model.completedTrips.filter { $0.mode == .walk }.count,
                        cyclingTrips: model.completedTrips.filter { $0.mode == .cycle }.count,
                        theme: model.theme
                    )

                    if model.completedTrips.isEmpty {
                        EmptyHistoryView(theme: model.theme)
                    } else {
                        Text("Recent adventures")
                            .font(.title3.bold())
                            .padding(.top, 4)
                        LazyVStack(spacing: 12) {
                            ForEach(model.completedTrips) { trip in
                                TripHistoryCard(trip: trip, theme: model.theme, distanceUnit: model.distanceUnit)
                            }
                        }
                    }

                    if !model.savedPlans.isEmpty {
                        Text("Saved routes")
                            .font(.title3.bold())
                            .padding(.top, 8)
                        LazyVStack(spacing: 12) {
                            ForEach(model.savedPlans) { plan in
                                SavedRouteCard(plan: plan, theme: model.theme, distanceUnit: model.distanceUnit)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            model.deleteSavedPlan(plan)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 30)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .background(WondrBackground(theme: model.theme))
        }
    }

    private var totalDistance: String {
        let metres = model.completedTrips.reduce(0.0) { $0 + $1.distanceMeters }
        return model.distanceUnit.formatted(metres)
    }

    private var tripsThisWeek: [WondrTrip] {
        guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: .now) else { return [] }
        return model.completedTrips.filter { interval.contains($0.date) }
    }

    private var weeklyDistance: String {
        let metres = tripsThisWeek.reduce(0.0) { $0 + $1.distanceMeters }
        return model.distanceUnit.formatted(metres)
    }

}

struct SavedRouteDetailView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    let plan: RoutePreview
    let theme: WondrTheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RouteSummaryCard(route: plan, theme: theme, distanceUnit: model.distanceUnit)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Stops")
                        .font(.title3.bold())
                    ForEach(Array(plan.waypoints.enumerated()), id: \.element.id) { index, stop in
                        HStack(spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(theme.accent)
                                .frame(width: 30, height: 30)
                                .background(theme.softAccent, in: Circle())
                            VStack(alignment: .leading, spacing: 3) {
                                Text(stop.place.name)
                                    .font(.headline)
                                Text(stop.place.category.title)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                .cardSurface()

                WondrPrimaryButton(title: "Use this route", systemImage: "arrow.right", theme: theme) {
                    model.loadSavedPlan(plan)
                    dismiss()
                }

                Button {
                    model.duplicateSavedPlan(plan)
                    dismiss()
                } label: {
                    Label("Duplicate route", systemImage: "plus.square.on.square")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(theme.accent)

                Button("Delete saved route", role: .destructive) {
                    model.deleteSavedPlan(plan)
                    dismiss()
                }
                .font(.footnote.weight(.semibold))
                .frame(maxWidth: .infinity)
            }
            .padding(20)
        }
        .navigationTitle("Saved route")
        .navigationBarTitleDisplayMode(.large)
        .background(WondrBackground(theme: theme))
    }
}
