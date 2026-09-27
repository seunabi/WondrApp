import Combine
import SwiftUI

@MainActor
final class SettingsViewState: ObservableObject {
    @Published var showingResetConfirmation = false
}

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var state = SettingsViewState()

    var body: some View {
        NavigationStack {
            ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        SettingsSectionHeading(title: "Accent color")
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 12) {
                            ForEach(AccentChoice.allCases) { choice in
                                AccentSwatch(choice: choice, selected: model.accentChoice == choice) { model.setAccent(choice) }
                            }
                    }
                    
                    .cardSurface()

                    VStack(alignment: .leading, spacing: 14) {
                        SettingsSectionHeading(title: "App icon")
                        AppIconPicker(selected: model.appIconChoice) { choice in
                            model.setAppIcon(choice)
                        }
                    }
                    .cardSurface()

                    VStack(alignment: .leading, spacing: 14) {
                        SettingsSectionHeading(title: "Route preferences")

                        LabeledContent("Route style") {
                            Picker("Route style", selection: Binding(
                                get: { model.routePreferences.style },
                                set: { model.setRouteStyle($0) }
                            )) {
                                ForEach(RouteStyle.allCases) { style in
                                    Text(style.title).tag(style)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }

                        Toggle("Avoid busy roads", isOn: Binding(
                            get: { model.routePreferences.avoidsBusyRoads },
                            set: { model.setAvoidsBusyRoads($0) }
                        ))
                        .tint(model.theme.accent)

                        LabeledContent("Target duration") {
                            Picker("Target duration", selection: Binding(
                                get: { model.routePreferences.targetDuration },
                                set: { model.setTargetDuration($0) }
                            )) {
                                ForEach(RouteDuration.allCases) { duration in
                                    Text(duration.title).tag(duration)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }
                    }
                    .cardSurface()

                    HStack(spacing: 12) {
                        Image(systemName: "ruler")
                            .font(.headline)
                            .foregroundStyle(model.theme.accent)
                            .frame(width: 28, height: 28)
                            .background(model.theme.softAccent, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

                        Text("Distance units")
                            .font(.subheadline.weight(.semibold))

                        Spacer(minLength: 8)

                        Picker("Distance units", selection: Binding(
                            get: { model.distanceUnit },
                            set: { model.setDistanceUnit($0) }
                        )) {
                            ForEach(DistanceUnit.allCases) { unit in
                                Text(unit.title).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(model.theme.accent)
                    }
                    .cardSurface(cornerRadius: 18)

                    VStack(alignment: .leading, spacing: 14) {
                        SettingsSectionHeading(title: "Onboarding")
                        Button {
                            model.replayOnboarding()
                        } label: {
                            Label("Replay onboarding", systemImage: "arrow.counterclockwise")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)
                        .tint(model.theme.accent)
                    }
                    .cardSurface()

                    VStack(alignment: .leading, spacing: 14) {
                        SettingsSectionHeading(title: "App data")
                        Text("Clear your saved routes, trip history, preferences, and onboarding progress.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Button {
                            state.showingResetConfirmation = true
                        } label: {
                            Label("Reset app", systemImage: "arrow.counterclockwise.circle")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                    .cardSurface()
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(WondrBackground(theme: model.theme))
            .confirmationDialog("Reset Wondr?", isPresented: $state.showingResetConfirmation, titleVisibility: .visible) {
                Button("Reset app", role: .destructive) {
                    model.resetApp()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This removes your saved trips, plans, preferences, and onboarding progress.")
            }
        }
    }
}

struct SettingsSectionHeading: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3.bold())
    }
}
