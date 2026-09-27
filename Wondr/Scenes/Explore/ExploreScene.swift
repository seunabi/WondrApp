import Combine
import SwiftUI

@MainActor
final class ExploreViewState: ObservableObject {
    @Published var selectedPlace: WondrPlace?
    @Published var showingFullScreenMap = false
}

@MainActor
final class ExploreFullScreenMapState: ObservableObject {
    @Published var selectedPlace: WondrPlace?
}

struct ExploreView: View {
    @EnvironmentObject private var model: AppModel
    @StateObject private var state = ExploreViewState()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Explore")
                        .font(.largeTitle.bold())

                    ZStack(alignment: .topTrailing) {
                        MapCanvas(showsPlaces: true, showsRoute: false) { place in
                            state.selectedPlace = place
                        }
                        .frame(height: 332)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                        }

                        Button {
                            state.showingFullScreenMap = true
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .padding(11)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(12)
                        .accessibilityLabel("Open full screen map")
                    }

                    if model.currentCoordinate == nil {
                        LocationRequiredState { model.requestLocation() }
                    }

                    CategoryStrip()

                    if model.filteredPlaces.isEmpty {
                        SearchEmptyState(query: "")
                    } else {
                        Text("Nearby")
                            .font(.title3.bold())

                        LazyVStack(spacing: 10) {
                            ForEach(model.filteredPlaces.prefix(8)) { place in
                                SearchResultRow(
                                    place: place,
                                    theme: model.theme,
                                    distanceUnit: model.distanceUnit,
                                    isAdded: model.isPlaceInRoute(place),
                                    onSelect: {
                                        state.selectedPlace = place
                                    }
                                ) {
                                    model.addPlaceToPlan(place)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 30)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(WondrBackground(theme: model.theme))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Recenter map", systemImage: "location.fill") {
                        model.recenterMap()
                    }
                    .labelStyle(.iconOnly)
                    .accessibilityLabel("Recenter map")
                }
            }
            .sheet(item: $state.selectedPlace) { place in
                ExplorePlaceDetailView(place: place)
            }
            .fullScreenCover(isPresented: $state.showingFullScreenMap) {
                ExploreFullScreenMapView()
            }
        }
    }
}


struct ExploreFullScreenMapView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var state = ExploreFullScreenMapState()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                MapCanvas(showsPlaces: true, showsRoute: false) { place in
                    state.selectedPlace = place
                }
                .ignoresSafeArea()

                CategoryStrip()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Recenter map", systemImage: "location.fill") {
                        model.recenterMap()
                    }
                    .labelStyle(.iconOnly)
                    .accessibilityLabel("Recenter map")
                }
            }
            .sheet(item: $state.selectedPlace) { place in
                ExplorePlaceDetailView(place: place)
            }
        }
    }
}

struct ExplorePlaceDetailView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    let place: WondrPlace

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 14) {
                        Image(systemName: place.category.systemImage)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .background(model.theme.accentGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(place.name)
                                .font(.title2.bold())
                            Text(place.category.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(model.theme.accent)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        if let address = place.address, !address.isEmpty {
                            PlaceDetailRow(systemImage: "mappin.and.ellipse", text: address)
                        } else if !place.subtitle.isEmpty {
                            PlaceDetailRow(systemImage: "mappin.and.ellipse", text: place.subtitle)
                        }

                        if let phoneURL {
                            Link(destination: phoneURL) {
                                PlaceDetailRow(systemImage: "phone.fill", text: place.phoneNumber ?? "Call place")
                            }
                        }

                        if let websiteURL = place.websiteURL, let url = URL(string: websiteURL) {
                            Link(destination: url) {
                                PlaceDetailRow(systemImage: "safari.fill", text: "Open website")
                            }
                        }

                        if let distanceMeters = place.distanceMeters {
                            PlaceDetailRow(systemImage: "location.fill", text: model.distanceUnit.formatted(distanceMeters))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardSurface(cornerRadius: 20)

                    WondrPrimaryButton(
                        title: model.isPlaceInRoute(place) ? "Already in route" : "Add to route",
                        systemImage: model.isPlaceInRoute(place) ? "checkmark" : "plus",
                        theme: model.theme
                    ) {
                        guard !model.isPlaceInRoute(place) else { return }
                        model.addPlaceToPlan(place)
                        dismiss()
                    }
                    .opacity(model.isPlaceInRoute(place) ? 0.7 : 1)
                }
                .padding(20)
            }
            .navigationTitle("Place details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .background(WondrBackground(theme: model.theme))
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }

    private var phoneURL: URL? {
        guard let phoneNumber = place.phoneNumber else { return nil }
        let digits = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel:\(digits)")
    }
}

private struct PlaceDetailRow: View {
    let systemImage: String
    let text: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.subheadline)
            .foregroundStyle(.primary)
    }
}
