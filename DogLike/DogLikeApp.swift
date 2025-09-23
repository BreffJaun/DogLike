import SwiftUI

@main
struct DogLikeApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
