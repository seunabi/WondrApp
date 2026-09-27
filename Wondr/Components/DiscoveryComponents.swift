import SwiftUI

struct CategoryStrip: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(POICategory.allCases.filter { $0 != .custom }) { category in
                    Button { model.toggleCategory(category) } label: {
                        Label(category.title, systemImage: category.systemImage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(model.selectedCategory == category ? model.theme.accent : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(model.selectedCategory == category ? model.theme.softAccent : Color.clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(model.selectedCategory == category ? model.theme.accent.opacity(0.32) : Color.primary.opacity(0.10), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct SearchResultRow: View {
    let place: WondrPlace
    let theme: WondrTheme
    let distanceUnit: DistanceUnit
    var isAdded = false
    var onSelect: (() -> Void)? = nil
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: place.category.systemImage)
                .font(.headline)
                .foregroundStyle(theme.accent)
                .frame(width: 42, height: 42)
                .background(theme.softAccent, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name).font(.headline)
                Text(place.subtitle).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                HStack(spacing: 6) {
                    Text(place.category.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.accent)
                    if let distanceMeters = place.distanceMeters {
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Text(distanceUnit.formatted(distanceMeters))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer(minLength: 8)
            Button(action: onAdd) {
                Image(systemName: isAdded ? "checkmark" : "plus")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isAdded ? .white : theme.accent)
                    .frame(width: 36, height: 36)
                    .background(isAdded ? theme.accent : theme.softAccent, in: Circle())
            }
            .accessibilityLabel(isAdded ? "\(place.name) is already in your route" : "Add \(place.name) to route")
        }
        .contentShape(Rectangle())
        .onTapGesture { onSelect?() }
        .cardSurface(cornerRadius: 16)
    }
}

struct LocationRequiredState: View {
    @EnvironmentObject private var model: AppModel
    let action: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "location.magnifyingglass")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(model.theme.accentGradient, in: Circle())
            Text("Allow location to find places nearby")
                .font(.headline)
                .multilineTextAlignment(.center)
            Button("Use my location", action: action)
                .buttonStyle(.borderedProminent)
                .tint(model.theme.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .cardSurface(cornerRadius: 22)
    }
}

struct SearchEmptyState: View {
    @EnvironmentObject private var model: AppModel
    let query: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: query.isEmpty ? "sparkles" : "mappin.slash")
                .font(.title.weight(.semibold))
                .foregroundStyle(model.theme.accent)
                .frame(width: 58, height: 58)
                .background(model.theme.softAccent, in: Circle())
            Text(query.isEmpty ? "Search for a stop" : "No places found").font(.headline)
            Text(query.isEmpty ? "Search for a park, landmark, café, or more." : "Try another search.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 42)
        .cardSurface(cornerRadius: 22)
    }
}
