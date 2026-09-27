import CoreLocation
import MapKit

extension AppModel {
    func requestLocation() {
        locationError = nil
        locationService.requestPermission()
        locationService.start()
    }

    func receiveLocation(_ coordinate: WondrCoordinate) {
        currentCoordinate = coordinate
        locationError = nil
        draft.start = currentPlace
        routePreview = nil

        nearbyPlacesTask?.cancel()
        nearbyPlacesTask = Task { [weak self] in
            guard let self else { return }
            let results = await mapKitService.searchNearby(region: searchRegion(around: coordinate))
            guard !Task.isCancelled, !results.isEmpty else { return }
            places = results.enumerated().map { index, place in
                var place = place
                place.isFeatured = index < 4
                return place
            }
        }
    }

    var searchRegion: MKCoordinateRegion? {
        guard let center = mapCenter else { return nil }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
            latitudinalMeters: 8_000,
            longitudinalMeters: 8_000
        )
    }

    private func searchRegion(around coordinate: WondrCoordinate) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            latitudinalMeters: 8_000,
            longitudinalMeters: 8_000
        )
    }
}
