import Combine
import MapKit
import SwiftUI

struct TripHistoryDetailView: View {
    let trip: WondrTrip
    let theme: WondrTheme
    let distanceUnit: DistanceUnit

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HistoricalRouteMap(trip: trip, theme: theme)
                    .frame(minHeight: 340, maxHeight: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        MetricTile(value: distanceUnit.formatted(trip.distanceMeters), label: "distance", systemImage: "map", tint: theme.accent)
                        if trip.mode == .walk {
                            MetricTile(value: trip.steps.formatted(), label: "steps", systemImage: "figure.walk", tint: theme.accentSecondary)
                        }
                        MetricTile(value: durationLabel, label: "moving", systemImage: "clock", tint: theme.route)
                    }
                }
                .scrollIndicators(.hidden)

                if !trip.stops.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stops")
                            .font(.headline)

                        ForEach(Array(trip.stops.enumerated()), id: \.element.id) { index, stop in
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(theme.accent)
                                    .frame(width: 28, height: 28)
                                    .background(theme.softAccent, in: Circle())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stop.place.name)
                                        .font(.subheadline.weight(.semibold))
                                    Text(stop.place.category.title)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .cardSurface()
                }
            }
            .padding(20)
        }
        .navigationTitle(trip.title.isEmpty ? "Trip" : trip.title)
        .navigationBarTitleDisplayMode(.large)
        .background(WondrBackground(theme: theme))
    }

    private var durationLabel: String {
        "\(max(1, Int((trip.durationSeconds / 60).rounded()))) min"
    }
}

@MainActor
final class HistoricalRouteMapState: ObservableObject {
    @Published var position: MapCameraPosition = .automatic
}

struct HistoricalRouteMap: View {
    let trip: WondrTrip
    let theme: WondrTheme
    @StateObject private var state = HistoricalRouteMapState()

    private var displayPath: [WondrCoordinate] {
        trip.path.isEmpty ? trip.stops.map(\.place.coordinate) : trip.path
    }

    var body: some View {
        Map(position: $state.position) {
            if displayPath.count > 1 {
                MapPolyline(coordinates: displayPath.map(coordinate))
                    .stroke(theme.route, lineWidth: 6)
            }

            ForEach(trip.stops) { stop in
                Annotation(stop.place.name, coordinate: coordinate(stop.place.coordinate)) {
                    Text(stop.place.name.prefix(1))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(theme.accent, in: Circle())
                        .overlay { Circle().strokeBorder(.white, lineWidth: 2) }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .onAppear(perform: fitMap)
    }

    private func coordinate(_ value: WondrCoordinate) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: value.latitude, longitude: value.longitude)
    }

    private func fitMap() {
        guard let first = displayPath.first else {
            state.position = .automatic
            return
        }

        let latitudes = displayPath.map(\.latitude)
        let longitudes = displayPath.map(\.longitude)
        let minimumLatitude = latitudes.min() ?? first.latitude
        let maximumLatitude = latitudes.max() ?? first.latitude
        let minimumLongitude = longitudes.min() ?? first.longitude
        let maximumLongitude = longitudes.max() ?? first.longitude
        let center = CLLocationCoordinate2D(
            latitude: (minimumLatitude + maximumLatitude) / 2,
            longitude: (minimumLongitude + maximumLongitude) / 2
        )

        state.position = .region(MKCoordinateRegion(
            center: center,
            latitudinalMeters: max(1_500, (maximumLatitude - minimumLatitude) * 111_000 * 1.5),
            longitudinalMeters: max(1_500, (maximumLongitude - minimumLongitude) * 111_000 * 1.5)
        ))
    }
}
