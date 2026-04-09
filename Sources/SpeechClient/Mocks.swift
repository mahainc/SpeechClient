import Dependencies

extension SpeechClient: TestDependencyKey {
    /// Test value — unimplemented, fails if called without explicit override.
    public static let testValue = SpeechClient()

    /// Preview value — silent no-op, speech doesn't fire in previews.
    public static let previewValue = SpeechClient.noop
}

extension SpeechClient {
    /// A no-op client that silently ignores all speech requests.
    public static let noop = SpeechClient(
        speak: { _ in },
        stop: {},
        isSpeaking: { false }
    )
}

extension DependencyValues {
    public var speechClient: SpeechClient {
        get { self[SpeechClient.self] }
        set { self[SpeechClient.self] = newValue }
    }
}
