import SwiftUI

struct ActiveTripView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                MapCanvas(showsPlaces: false, showsRoute: true).ignoresSafeArea()

                VStack(spacing: 12) {
                    if let route = model.routePreview, !route.steps.isEmpty {
                        let nextStep = route.steps[currentStepIndex(in: route)]
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "arrow.turn.up.right")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 42, height: 42)
                                .background(model.theme.accentGradient, in: Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text(nextStep.instruction).font(.headline)
                                Text("Next · \(model.distanceUnit.formatted(nextStep.distanceMeters))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 4)
                        }
                        .cardSurface()
                    }

                    VStack(spacing: 16) {
                        HStack {
                            MetricTile(value: model.activeTrip?.mode.title ?? "Walk", label: "mode", systemImage: model.activeTrip?.mode.systemImage ?? "figure.walk", tint: model.theme.accent)
                            Spacer()
                            MetricTile(value: model.activeTrip.map { model.distanceUnit.formatted($0.distanceMeters) } ?? "—", label: "planned", systemImage: "map", tint: model.theme.accentSecondary)
                        }
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            ProgressView(value: tripProgress(at: context.date)).tint(model.theme.accent)
                        }
                        HStack(spacing: 12) {
                            Button { model.toggleTripPause() } label: {
                                Label(model.isTripPaused ? "Resume" : "Pause", systemImage: model.isTripPaused ? "play.fill" : "pause.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(model.theme.accent)
                            Button(role: .destructive) { model.finishTrip(); dismiss() } label: {
                                Label("Finish", systemImage: "flag.checkered").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(model.theme.accent)
                        }
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.14), radius: 22, y: 10)
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Exit", systemImage: "xmark") { dismiss() } }
                ToolbarItem(placement: .principal) { Text(model.isTripPaused ? "Trip paused" : "You’re on your way").font(.headline) }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Recenter map", systemImage: "location.fill") {
                        model.recenterMap()
                    }
                    .labelStyle(.iconOnly)
                    .accessibilityLabel("Recenter map on your location")
                }
            }
        }
    }

    private func tripProgress(at date: Date) -> Double {
        guard let startedAt = model.activeTripStartedAt, let route = model.routePreview, !model.isTripPaused else { return 0.35 }
        return min(0.98, max(0.02, date.timeIntervalSince(startedAt) / max(1, route.durationSeconds)))
    }

    private func currentStepIndex(in route: RoutePreview) -> Int {
        let progress = tripProgress(at: .now)
        return min(route.steps.count - 1, max(0, Int(progress * Double(route.steps.count))))
    }
}
