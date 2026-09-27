import Combine
import SwiftUI

@MainActor
final class PlannerViewState: ObservableObject {
    @Published var showingStopPicker = false
    @Published var showingRoutePreview = false
    @Published var showingSettings = false
}

struct PlannerView: View {
    @EnvironmentObject private var model: AppModel
    @StateObject private var state = PlannerViewState()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 10) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                        Text("wondr")
                            .font(.largeTitle.weight(.bold))
                            .tracking(-1)

                        Spacer(minLength: 12)

                        Button {
                            state.showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.headline.weight(.semibold))
                                .frame(width: 38, height: 38)
                                .background(.thinMaterial, in: Circle())
                        }
                        .accessibilityLabel("Settings")
                    }

                    if let feedback = model.routeFeedback {
                        HStack(spacing: 10) {
                            Label(feedback, systemImage: "checkmark.circle.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(model.theme.accent)
                            Spacer(minLength: 8)
                            Button("Dismiss", systemImage: "xmark") { model.dismissRouteFeedback() }
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("Dismiss route update")
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(model.theme.accent.opacity(0.16), lineWidth: 1)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Choose stops").sectionTitleStyle()
                            Spacer()
                            if !model.draft.stops.isEmpty {
                                Text("\(model.draft.stops.count) selected")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        CategoryStrip()

                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("Search nearby places", text: $model.searchQuery)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 11)
                        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        if model.currentCoordinate == nil {
                            LocationRequiredState { model.requestLocation() }
                        } else if model.isSearching {
                            ProgressView("Finding nearby places…")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 22)
                        } else if model.planningPlaces.isEmpty {
                            SearchEmptyState(query: model.searchQuery)
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(model.planningPlaces.prefix(5)) { place in
                                    SearchResultRow(place: place, theme: model.theme, distanceUnit: model.distanceUnit, isAdded: model.isPlaceInRoute(place)) {
                                        model.addPlaceToPlan(place)
                                    }
                                }
                            }

                            if model.planningPlaces.count > 5 {
                                NavigationLink {
                                    PlaceResultsView()
                                } label: {
                                    Label("View all \(model.planningPlaces.count) nearby places", systemImage: "arrow.up.right")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(model.theme.accent)
                            }
                        }

                        if let searchError = model.searchError {
                            Label(searchError, systemImage: "wifi.exclamationmark")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .cardSurface()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity").font(.headline)
                        Picker("Activity", selection: $model.draft.mode) {
                            ForEach(ActivityMode.allCases) { mode in
                                Label(mode.title, systemImage: mode.systemImage).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .cardSurface()

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Route", systemImage: "point.topleft.down.to.point.bottomright.curvepath").font(.headline)
                            Spacer()
                            Toggle("Loop back", isOn: $model.draft.isReturnRoute)
                                .tint(model.theme.accent)
                        }
                    }
                    .cardSurface()

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Stops").font(.headline)
                            Spacer()
                            Button("Add stop", systemImage: "plus") { state.showingStopPicker = true }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(model.theme.accent)
                        }

                        if model.draft.stops.isEmpty {
                            Text("Add a place to your route.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(model.draft.stops) { stop in
                                StopRow(stop: stop, theme: model.theme) { model.removeStop(stop) }
                            }
                            .onMove(perform: model.moveStop)
                        }
                    }
                    .cardSurface()

                    if let route = model.routePreview {
                        RouteReadyCard(route: route, theme: model.theme, distanceUnit: model.distanceUnit) {
                            state.showingRoutePreview = true
                        }
                    } else if model.isCalculatingRoute {
                        HStack(spacing: 10) {
                            ProgressView().tint(.white)
                            Text("Building your route…")
                                .font(.headline.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(model.theme.accentGradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    } else {
                        WondrPrimaryButton(title: "Build my route", systemImage: "wand.and.stars", theme: model.theme) {
                            model.calculateRoute()
                        }
                    }

                    if !model.draft.stops.isEmpty || model.routePreview != nil {
                        Button("Clear plan", role: .destructive) { model.resetPlan() }
                            .frame(maxWidth: .infinity)
                            .font(.footnote.weight(.semibold))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
            .toolbar(.hidden, for: .navigationBar)
            .background(WondrBackground(theme: model.theme))
            .onChange(of: model.searchQuery) { _, newValue in model.searchPlaces(newValue) }
            .onChange(of: model.routePreview) { _, newValue in
                if newValue != nil {
                    state.showingRoutePreview = true
                }
            }
            .onChange(of: model.shouldShowRoutePreview) { _, shouldShow in
                guard shouldShow else { return }
                model.shouldShowRoutePreview = false
                state.showingRoutePreview = true
            }
            .onAppear {
                guard model.shouldShowRoutePreview else { return }
                model.shouldShowRoutePreview = false
                state.showingRoutePreview = true
            }
            .navigationDestination(isPresented: $state.showingRoutePreview) {
                if let route = model.routePreview {
                    RoutePreviewView(route: route)
                }
            }
            .sheet(isPresented: $state.showingStopPicker) { StopPickerView() }
            .sheet(isPresented: $state.showingSettings) {
                SettingsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
            }
        }
    }
}
