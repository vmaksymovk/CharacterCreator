import WatchConnectivity
import SwiftUI

@main
struct AvatarCreatorWatchApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                CharacterView()
            }
        }
    }
}

