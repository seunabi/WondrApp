import SwiftUI

struct RoutePreviewView: View {
    @EnvironmentObject private var model: AppModel
    let route: RoutePreview

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    MapCanvas(showsPlaces: false, showsRoute: true)
                        .frame(minHeight: 300, maxHeight: 420)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.12), radius: 18, y: 8)

                    RouteSummaryCard(route: route, theme: model.theme, distanceUnit: model.distanceUnit)

                    if let routeError = model.routeError {
                        Label(routeError, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                    }

                    VStack(spacing: 10) {
                        WondrPrimaryButton(title: "Start this trip", systemImage: "arrowtriangle.forward.fill", theme: model.theme) {
                            model.startTrip()
                        }

                        Button {
                            if model.isCurrentPlanSaved {
                                model.removeCurrentPlan()
                            } else {
                                model.saveCurrentPlan()
                            }
                        } label: {
                            Label(
                                model.isCurrentPlanSaved ? "Remove saved route" : "Save this route",
                                systemImage: model.isCurrentPlanSaved ? "bookmark.slash" : "bookmark"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(model.isCurrentPlanSaved ? .red : model.theme.accent)
                    }
                }
                .padding(20)
            }

            if let feedback = model.saveFeedback {
                SaveToast(feedback: feedback, theme: model.theme)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: model.saveFeedback)
        .navigationTitle("Route preview")
        .navigationBarTitleDisplayMode(.large)
        .background(WondrBackground(theme: model.theme))
    }
}
