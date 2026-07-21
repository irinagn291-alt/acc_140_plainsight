import Alamofire
import SwiftData
import SwiftUI

@main
struct PlainsightApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var isInitializing = true
    @State private var displayMode: DisplayMode = .loading
    @State private var webContentURL: String?

    var sharedModelContainer: ModelContainer = {
        let schema = Schema(AppSchema.allModels)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            rootView
                .onAppear { performRegistration() }
        }
        .modelContainer(sharedModelContainer)
    }

    @ViewBuilder
    private var rootView: some View {
        ZStack {
            if isInitializing {
                AppColor.background.ignoresSafeArea()
            } else if displayMode == .webContent, let url = webContentURL {
                let fullURL = url.hasPrefix("http") ? url : "https://\(url)"
                ZStack {
                    Color.black.ignoresSafeArea()
                    WebContentView(url: fullURL)
                }
                .preferredColorScheme(.dark)
            } else {
                RootView()
            }
        }
    }

    private func performRegistration() {
        if let saved = DataCache.shared.contentURL, !saved.isEmpty {
            finishLaunch(mode: .webContent, url: saved)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            finishLaunch(mode: .nativeInterface, url: nil)
        }

        NetworkService.shared.performRegistration { mode, url in
            DispatchQueue.main.async {
                finishLaunch(mode: mode, url: url)
            }
        }
    }

    private func finishLaunch(mode: DisplayMode, url: String?) {
        guard isInitializing else { return }
        displayMode = mode
        webContentURL = url
        isInitializing = false
    }
}
