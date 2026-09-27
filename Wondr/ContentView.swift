import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Group {
            if model.hasCompletedOnboarding {
                TabView(selection: $model.selectedTab) {
                    PlannerView()
                        .tabItem { Label("Plan", systemImage: "point.topleft.down.to.point.bottomright.curvepath") }
                        .tag(AppTab.plan)
                    ExploreView()
                        .tabItem { Label("Explore", systemImage: "map") }
                        .tag(AppTab.explore)
                    HistoryView()
                        .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                        .tag(AppTab.history)
                }
                .fullScreenCover(item: $model.activeTrip) { _ in
                    ActiveTripView()
                }
                .toolbarBackground(.thinMaterial, for: .tabBar)
            } else {
                OnboardingView()
            }
        }
        .tint(model.theme.accent)
    }
}
