import SwiftData

#if DEBUG
/// In-memory `AppDependencies` for SwiftUI previews only.
@MainActor
enum PreviewDependenciesFactory {
    static func make() -> AppDependencies {
        let container = try! ModelContainer(
            for: Schema(AppSchema.allModels),
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return AppDependencies(modelContext: container.mainContext)
    }
}
#endif
