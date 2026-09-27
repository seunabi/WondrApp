import Foundation

extension AppModel {
    func dismissRouteFeedback() {
        routeFeedbackTask?.cancel()
        routeFeedbackTask = nil
        routeFeedback = nil
    }

    func showRouteFeedback(_ message: String) {
        routeFeedbackTask?.cancel()
        routeFeedback = message
        routeFeedbackTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            guard !Task.isCancelled else { return }
            self?.routeFeedback = nil
        }
    }

    func showSaveFeedback(_ feedback: SaveFeedback) {
        saveFeedbackTask?.cancel()
        saveFeedback = feedback
        saveFeedbackTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            self?.saveFeedback = nil
        }
    }
}
