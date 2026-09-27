import Combine
import MapKit
import SwiftUI

@MainActor
final class MapCanvasState: ObservableObject {
    @Published var position: MapCameraPosition = .automatic
}

struct MapCanvas: View {
    @EnvironmentObject private var model: AppModel
    let showsPlaces: Bool
    let showsRoute: Bool
    var onSelectPlace: ((WondrPlace) -> Void)? = nil
    @StateObject private var state = MapCanvasState()

    var body: some View {
        Map(position: $state.position) {
            if showsRoute, let route = model.routePreview {
                MapPolyline(coordinates: route.path.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
                    .stroke(model.theme.route, lineWidth: 6)
            }

            if showsPlaces {
                ForEach(model.filteredPlaces) { place in
                    Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)) {
                        Button {
                            onSelectPlace?(place)
                        } label: {
                            Image(systemName: place.category.systemImage)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(model.theme.accentGradient, in: Circle())
                                .shadow(color: .black.opacity(0.14), radius: 6, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if let route = model.routePreview {
                ForEach(route.waypoints) { waypoint in
                    Annotation(waypoint.place.name, coordinate: CLLocationCoordinate2D(latitude: waypoint.place.coordinate.latitude, longitude: waypoint.place.coordinate.longitude)) {
                        Text(waypoint.place.name.prefix(1))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(model.theme.accent, in: Circle())
                            .overlay { Circle().strokeBorder(.white, lineWidth: 2) }
                    }
                }
            }

            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .safeAreaPadding(.top, 12)
        .onAppear { recenter() }
        .onChange(of: model.currentCoordinate) { recenter() }
        .onChange(of: model.mapRecenterRequest) { recenter() }
    }

    private func recenter() {
        guard let center = model.mapCenter else {
            state.position = .automatic
            return
        }
        state.position = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
            latitudinalMeters: 7_500,
            longitudinalMeters: 7_500
        ))
    }
}
