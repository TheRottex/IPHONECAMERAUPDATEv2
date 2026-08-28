import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Group {
            if appModel.hasCompletedOnboarding {
                CameraContainerView()
            } else {
                OnboardingView {
                    appModel.hasCompletedOnboarding = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
