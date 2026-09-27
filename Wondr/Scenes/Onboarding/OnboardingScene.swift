import Combine
import SwiftUI

@MainActor
final class OnboardingViewState: ObservableObject {
    @Published var page = 0
}

struct OnboardingView: View {
    @EnvironmentObject private var model: AppModel
    @StateObject private var state = OnboardingViewState()

    private let pageCount = 5

    var body: some View {
        ZStack {
            OnboardingBackdrop(theme: model.theme)

            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    OnboardingProgress(currentPage: state.page, pageCount: pageCount, tint: model.theme.accent)

                    Button("Skip") {
                        model.completeOnboarding()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                TabView(selection: $state.page) {
                    OnboardingIntroPage(
                        kicker: "A little more outside",
                        title: "Make time for outside.",
                        message: "Turn nearby places into walks and cycles worth taking."
                    )
                    .tag(0)

                    OnboardingThemePage()
                        .tag(1)

                    OnboardingIconPage()
                        .tag(2)

                    OnboardingPreferencesPage()
                        .tag(3)

                    OnboardingPermissionPage(
                        title: "Bring Wondr with you.",
                        message: "Use your location to find parks, landmarks, food, and more nearby.",
                        tint: model.theme.accent,
                        isEnabled: model.currentCoordinate != nil || model.locationIsAvailable,
                        enabledLabel: "Location enabled",
                        actionLabel: "Allow location",
                        action: model.requestLocation
                    )
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                WondrPrimaryButton(
                    title: state.page == pageCount - 1 ? "Start exploring" : "Continue",
                    systemImage: state.page == pageCount - 1 ? "arrow.right" : "chevron.right",
                    theme: model.theme
                ) {
                    if state.page == pageCount - 1 {
                        model.completeOnboarding()
                    } else {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            state.page += 1
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 14)
            }
        }
        .onAppear { state.page = 0 }
    }
}

private struct OnboardingBackdrop: View {
    let theme: WondrTheme

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)

            LinearGradient(
                colors: [theme.softAccent.opacity(0.7), .clear, theme.accentSecondary.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(theme.accent.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 42)
                .offset(x: 150, y: -280)
        }
        .ignoresSafeArea()
    }
}

private struct OnboardingProgress: View {
    let currentPage: Int
    let pageCount: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index <= currentPage ? tint : Color.primary.opacity(0.10))
                    .frame(maxWidth: .infinity)
                    .frame(height: 4)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding step \(currentPage + 1) of \(pageCount)")
    }
}

private struct OnboardingCopy: View {
    let kicker: String
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(kicker.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .tracking(-1)
                .fixedSize(horizontal: false, vertical: true)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct OnboardingIntroPage: View {
    let kicker: String
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingCopy(kicker: kicker, title: title, message: message)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 34)
        .padding(.bottom, 28)
    }
}

struct OnboardingThemePage: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingCopy(
                kicker: "Your Wondr, your colour",
                title: "Choose your colour.",
                message: "Pick an accent that feels right. You can change it whenever you like."
            )

            Spacer(minLength: 0)

            VStack(spacing: 0) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 68), spacing: 10)], spacing: 10) {
                    ForEach(AccentChoice.allCases) { choice in
                        AccentSwatch(choice: choice, selected: model.accentChoice == choice) {
                            model.setAccent(choice)
                        }
                    }
                }
                .frame(maxWidth: 360)
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 16)
        }
        .padding(.horizontal, 24)
        .padding(.top, 34)
        .padding(.bottom, 20)
    }
}

struct OnboardingIconPage: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingCopy(
                kicker: "A familiar home",
                title: "Choose your app icon.",
                message: "Pick the version of Wondr you want to see on your Home Screen."
            )

            Spacer(minLength: 0)

            VStack(spacing: 0) {
                AppIconPicker(selected: model.appIconChoice) { choice in
                    model.setAppIcon(choice)
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 16)
        }
        .padding(.horizontal, 24)
        .padding(.top, 34)
        .padding(.bottom, 20)
    }
}

struct OnboardingPreferencesPage: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingCopy(
                kicker: "Set it once",
                title: "Make every route feel right.",
                message: "Choose the defaults Wondr should use when you build a route."
            )

            Spacer(minLength: 0)

            VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Route style")
                            .font(.subheadline.weight(.semibold))

                        Picker("Route style", selection: Binding(
                            get: { model.routePreferences.style },
                            set: { model.setRouteStyle($0) }
                        )) {
                            ForEach(RouteStyle.allCases) { style in
                                Text(style.title).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(model.theme.accent)
                    }
                    .padding(14)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    HStack(spacing: 12) {
                        Image(systemName: "figure.walk")
                            .foregroundStyle(model.theme.accent)
                            .frame(width: 28, height: 28)
                            .background(model.theme.softAccent, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

                        Text("Avoid busy roads")
                            .font(.subheadline.weight(.semibold))

                        Spacer(minLength: 8)

                        Toggle("Avoid busy roads", isOn: Binding(
                            get: { model.routePreferences.avoidsBusyRoads },
                            set: { model.setAvoidsBusyRoads($0) }
                        ))
                        .labelsHidden()
                        .tint(model.theme.accent)
                    }
                    .padding(14)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    HStack(spacing: 12) {
                        Image(systemName: "ruler")
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
                    .padding(14)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    HStack(spacing: 12) {
                        Image(systemName: "clock")
                            .foregroundStyle(model.theme.accent)
                            .frame(width: 28, height: 28)
                            .background(model.theme.softAccent, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

                        Text("Target duration")
                            .font(.subheadline.weight(.semibold))

                        Spacer(minLength: 8)

                        Picker("Target duration", selection: Binding(
                            get: { model.routePreferences.targetDuration },
                            set: { model.setTargetDuration($0) }
                        )) {
                            ForEach(RouteDuration.allCases) { duration in
                                Text(duration.title).tag(duration)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(model.theme.accent)
                    }
                    .padding(14)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            Spacer(minLength: 16)
        }
        .padding(.horizontal, 24)
        .padding(.top, 34)
        .padding(.bottom, 20)
    }
}

struct OnboardingPermissionPage: View {
    let title: String
    let message: String
    let tint: Color
    let isEnabled: Bool
    let enabledLabel: String
    let actionLabel: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingCopy(
                kicker: "A better starting point",
                title: title,
                message: message
            )

            Spacer()

            if isEnabled {
                Label(enabledLabel, systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Button(actionLabel, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 34)
        .padding(.bottom, 28)
    }
}
