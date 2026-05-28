# SpeechClient

A TCA dependency client wrapping `AVSpeechSynthesizer` for text-to-speech synthesis. Single async `speak(_:)` call awaits until the utterance finishes or is interrupted.

## Layout

- **`SpeechClient`** — interface: `speak(_:)`, `stop()`, `isSpeaking`.
- **`SpeechClientLive`** — `AVSpeechSynthesizer` wrapper with a `final class SpeechEngine: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable` that bridges the delegate callbacks to a `CheckedContinuation` so `speak(_:)` reads as a plain `async` call.

## Installation

```swift
.package(url: "https://github.com/mahainc/SpeechClient.git", from: "0.1.0"),
```

`SpeechClient` on feature targets; `SpeechClientLive` on the app target.

## Usage

```swift
import SpeechClient
import ComposableArchitecture

@Reducer
struct ChatBubbleFeature {
    @ObservableState
    struct State {
        let message: String
    }

    enum Action {
        case readAloudTapped
        case stopTapped
    }

    @Dependency(\.speechClient) var speech

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .readAloudTapped:
                return .run { [text = state.message] _ in
                    await speech.speak(text)
                }

            case .stopTapped:
                return .run { _ in await speech.stop() }
            }
        }
    }
}
```

`speak(_:)` returns when the utterance finishes naturally OR when `stop()` interrupts it — so you can `await` it without worrying about leaking the call.

## Testing

```swift
let store = TestStore(initialState: ChatBubbleFeature.State(message: "hi")) {
    ChatBubbleFeature()
} withDependencies: {
    $0.speechClient.speak = { _ in /* no-op */ }
}
```

## Dependencies

- `swift-composable-architecture` from 1.25.5

## Platform support

- iOS 17+, macOS 14+ (AVSpeechSynthesizer is available on both)

## License

MIT — see [LICENSE](./LICENSE).
