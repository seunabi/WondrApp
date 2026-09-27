import SwiftUI

struct WondrTheme: Sendable {
    var accent: Color
    var accentSecondary: Color
    var accentGradient: LinearGradient
    var softAccent: Color
    var route: Color

    static let wondr = WondrTheme(
        accent: Color(red: 1.0, green: 0.18574, blue: 0.57340),
        accentSecondary: Color(red: 0.58106, green: 0.12855, blue: 0.57453),
        accentGradient: LinearGradient(
            colors: [Color(red: 1.0, green: 0.18574, blue: 0.57340), Color(red: 0.58106, green: 0.12855, blue: 0.57453)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        softAccent: Color(red: 1.0, green: 0.18574, blue: 0.57340).opacity(0.12),
        route: Color(red: 0.58106, green: 0.12855, blue: 0.57453)
    )

    static let sunset = WondrTheme(
        accent: Color(red: 0.95, green: 0.28, blue: 0.27),
        accentSecondary: Color(red: 0.98, green: 0.58, blue: 0.18),
        accentGradient: LinearGradient(colors: [Color(red: 0.95, green: 0.28, blue: 0.27), Color(red: 0.98, green: 0.58, blue: 0.18)], startPoint: .topLeading, endPoint: .bottomTrailing),
        softAccent: Color(red: 0.95, green: 0.28, blue: 0.27).opacity(0.12),
        route: Color(red: 0.84, green: 0.24, blue: 0.22)
    )

    static let meadow = WondrTheme(
        accent: Color(red: 0.14, green: 0.58, blue: 0.38),
        accentSecondary: Color(red: 0.46, green: 0.76, blue: 0.29),
        accentGradient: LinearGradient(colors: [Color(red: 0.14, green: 0.58, blue: 0.38), Color(red: 0.46, green: 0.76, blue: 0.29)], startPoint: .topLeading, endPoint: .bottomTrailing),
        softAccent: Color(red: 0.14, green: 0.58, blue: 0.38).opacity(0.12),
        route: Color(red: 0.10, green: 0.46, blue: 0.31)
    )

    static let ocean = WondrTheme(
        accent: Color(red: 0.10, green: 0.43, blue: 0.80),
        accentSecondary: Color(red: 0.19, green: 0.72, blue: 0.84),
        accentGradient: LinearGradient(colors: [Color(red: 0.10, green: 0.43, blue: 0.80), Color(red: 0.19, green: 0.72, blue: 0.84)], startPoint: .topLeading, endPoint: .bottomTrailing),
        softAccent: Color(red: 0.10, green: 0.43, blue: 0.80).opacity(0.12),
        route: Color(red: 0.08, green: 0.35, blue: 0.68)
    )

    static let lavender = WondrTheme(
        accent: Color(red: 0.40, green: 0.29, blue: 0.86),
        accentSecondary: Color(red: 0.67, green: 0.52, blue: 0.98),
        accentGradient: LinearGradient(colors: [Color(red: 0.40, green: 0.29, blue: 0.86), Color(red: 0.67, green: 0.52, blue: 0.98)], startPoint: .topLeading, endPoint: .bottomTrailing),
        softAccent: Color(red: 0.40, green: 0.29, blue: 0.86).opacity(0.12),
        route: Color(red: 0.31, green: 0.21, blue: 0.70)
    )

    static let citrus = WondrTheme(
        accent: Color(red: 0.76, green: 0.48, blue: 0.04),
        accentSecondary: Color(red: 0.94, green: 0.73, blue: 0.16),
        accentGradient: LinearGradient(colors: [Color(red: 0.76, green: 0.48, blue: 0.04), Color(red: 0.94, green: 0.73, blue: 0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
        softAccent: Color(red: 0.76, green: 0.48, blue: 0.04).opacity(0.12),
        route: Color(red: 0.61, green: 0.35, blue: 0.02)
    )

    static let plum = WondrTheme(
        accent: Color(red: 0.53, green: 0.20, blue: 0.58),
        accentSecondary: Color(red: 0.80, green: 0.34, blue: 0.61),
        accentGradient: LinearGradient(colors: [Color(red: 0.53, green: 0.20, blue: 0.58), Color(red: 0.80, green: 0.34, blue: 0.61)], startPoint: .topLeading, endPoint: .bottomTrailing),
        softAccent: Color(red: 0.53, green: 0.20, blue: 0.58).opacity(0.12),
        route: Color(red: 0.42, green: 0.14, blue: 0.47)
    )

    static let rose = WondrTheme(
        accent: Color(red: 0.76, green: 0.16, blue: 0.39),
        accentSecondary: Color(red: 0.96, green: 0.39, blue: 0.56),
        accentGradient: LinearGradient(colors: [Color(red: 0.76, green: 0.16, blue: 0.39), Color(red: 0.96, green: 0.39, blue: 0.56)], startPoint: .topLeading, endPoint: .bottomTrailing),
        softAccent: Color(red: 0.76, green: 0.16, blue: 0.39).opacity(0.12),
        route: Color(red: 0.61, green: 0.10, blue: 0.29)
    )

    static func forChoice(_ choice: AccentChoice) -> WondrTheme {
        switch choice {
        case .wondr: .wondr
        case .sunset: .sunset
        case .meadow: .meadow
        case .ocean: .ocean
        case .lavender: .lavender
        case .citrus: .citrus
        case .plum: .plum
        case .rose: .rose
        }
    }
}

extension View {
    func cardSurface(cornerRadius: CGFloat = 24) -> some View {
        self
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.primary.opacity(0.06), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
    }

    func sectionTitleStyle() -> some View {
        self.font(.title3.weight(.semibold))
    }
}

struct WondrBackground: View {
    let theme: WondrTheme

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)

            LinearGradient(
                colors: [theme.softAccent.opacity(0.8), .clear, theme.accentSecondary.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(theme.accent.opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 34)
                .offset(x: 150, y: -270)
        }
        .ignoresSafeArea()
    }
}

struct WondrPrimaryButton: View {
    let title: String
    let systemImage: String
    let theme: WondrTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Text(title)
                    .font(.headline.weight(.semibold))
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(theme.accentGradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.white.opacity(0.22), lineWidth: 1)
            }
            .shadow(color: theme.accent.opacity(0.25), radius: 14, y: 7)
        }
        .buttonStyle(.plain)
    }
}

struct BrandMark: View {
    let theme: WondrTheme
    var compact = false

    var body: some View {
        HStack(spacing: compact ? 8 : 10) {
            Image(systemName: "figure.walk.motion")
                .font(.system(size: compact ? 15 : 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: compact ? 30 : 36, height: compact ? 30 : 36)
                .background(theme.accentGradient, in: RoundedRectangle(cornerRadius: compact ? 9 : 11, style: .continuous))

            if !compact {
                Text("wondr")
                    .font(.title2.weight(.bold))
                    .tracking(-0.4)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Wondr")
    }
}

struct MetricTile: View {
    let value: String
    let label: String
    let systemImage: String
    var tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.headline)
                Text(label).font(.caption).foregroundStyle(.secondary)
            }
            .lineLimit(1)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(minWidth: 118, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(tint.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
    }
}

struct AccentSwatch: View {
    let choice: AccentChoice
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            let theme = WondrTheme.forChoice(choice)
            VStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(theme.accentGradient)
                    .frame(height: 48)
                    .overlay(alignment: .topTrailing) {
                        if selected {
                            Image(systemName: "checkmark")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(theme.accent)
                                .frame(width: 22, height: 22)
                                .background(.white, in: Circle())
                                .padding(5)
                        }
                    }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(selected ? theme.softAccent : Color.clear, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(selected ? theme.accent.opacity(0.55) : Color.primary.opacity(0.08), lineWidth: selected ? 1.5 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(choice.title) accent")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct AppIconPicker: View {
    let selected: AppIconChoice
    let action: (AppIconChoice) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 10)], spacing: 10) {
            ForEach(AppIconChoice.allCases) { choice in
                AppIconSwatch(choice: choice, selected: selected == choice) {
                    action(choice)
                }
            }
        }
    }
}

private struct AppIconSwatch: View {
    let choice: AppIconChoice
    let selected: Bool
    let action: () -> Void

    private var previewTheme: WondrTheme {
        switch choice {
        case .wondr: .wondr
        case .blue: .ocean
        case .darkPink: .plum
        case .gold: .citrus
        case .green: .meadow
        case .orange: .sunset
        case .pink: .rose
        case .purple: .lavender
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.clear)
                    .frame(height: 70)
                    .overlay {
                        Image(choice.assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .overlay(alignment: .topTrailing) {
                        if selected {
                            Image(systemName: "checkmark")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(previewTheme.accent)
                                .frame(width: 22, height: 22)
                                .background(.white, in: Circle())
                                .padding(5)
                        }
                    }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(selected ? previewTheme.softAccent : Color.clear, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(selected ? previewTheme.accent.opacity(0.55) : Color.primary.opacity(0.08), lineWidth: selected ? 1.5 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(choice.title) app icon")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
