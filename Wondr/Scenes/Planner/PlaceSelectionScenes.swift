import SwiftUI

struct PlaceResultsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                CategoryStrip()

                if model.currentCoordinate == nil {
                    LocationRequiredState { model.requestLocation() }
                } else if model.isSearching {
                    ProgressView("Finding nearby places…")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 30)
                } else if model.planningPlaces.isEmpty {
                    SearchEmptyState(query: model.searchQuery)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(model.planningPlaces) { place in
                            SearchResultRow(place: place, theme: model.theme, distanceUnit: model.distanceUnit, isAdded: model.isPlaceInRoute(place)) {
                                model.addPlaceToPlan(place)
                            }
                        }
                    }
                }

                if let searchError = model.searchError {
                    Label(searchError, systemImage: "wifi.exclamationmark")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
        }
        .navigationTitle("Nearby places")
        .navigationBarTitleDisplayMode(.large)
        .background(WondrBackground(theme: model.theme))
        .searchable(text: $model.searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search nearby places")
        .onChange(of: model.searchQuery) { _, newValue in model.searchPlaces(newValue) }
    }
}

struct StopPickerView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    CategoryStrip()
                    LazyVStack(spacing: 12) {
                        ForEach(model.planningPlaces) { place in
                            SearchResultRow(place: place, theme: model.theme, distanceUnit: model.distanceUnit, isAdded: model.isPlaceInRoute(place)) {
                                model.addPlaceToPlan(place)
                                dismiss()
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Add a stop")
            .navigationBarTitleDisplayMode(.large)
            .background(WondrBackground(theme: model.theme))
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }
}
