import Dependencies
import DependenciesMacros
import Foundation

/// A dependency client for text-to-speech synthesis.
///
/// Usage in a reducer:
/// ```swift
/// @Dependency(\.speechClient) var speechClient
///
/// case .readAloudTapped(let message):
///     return .run { [speechClient] _ in
///         await speechClient.speak(message.content)
///     }
/// ```
@DependencyClient
public struct SpeechClient: Sendable {
    /// Speak the given text aloud. Returns when speech finishes or is interrupted.
    public var speak: @Sendable (_ text: String) async -> Void = { _ in }

    /// Stop any ongoing speech immediately.
    public var stop: @Sendable () async -> Void = {}

    /// Whether speech is currently in progress.
    public var isSpeaking: @Sendable () async -> Bool = { false }
}
