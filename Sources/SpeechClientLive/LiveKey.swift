import Dependencies
import NaturalLanguage
import SpeechClient

#if canImport(AVFoundation)
import AVFoundation

extension SpeechClient: DependencyKey {
    public static let liveValue: SpeechClient = {
        let engine = SpeechEngine()

        return SpeechClient(
            speak: { text in
                await engine.speak(text)
            },
            stop: {
                engine.stop()
            },
            isSpeaking: {
                engine.isSpeaking
            }
        )
    }()
}

private final class SpeechEngine: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    private let synthesizer = AVSpeechSynthesizer()
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }

    func speak(_ text: String) async {
        stopImmediately()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = Self.voice(for: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            lock.withLock { self.continuation = cont }
            synthesizer.speak(utterance)
        }
    }

    private static func voice(for text: String) -> AVSpeechSynthesisVoice? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)

        guard let detected = recognizer.dominantLanguage else {
            return AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        }

        let langCode = detected.rawValue
        return AVSpeechSynthesisVoice(language: langCode)
            ?? AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
    }

    func stop() {
        stopImmediately()
    }

    private func stopImmediately() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        resumeContinuation()
    }

    private func resumeContinuation() {
        lock.withLock {
            continuation?.resume()
            continuation = nil
        }
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        resumeContinuation()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        resumeContinuation()
    }
}

#else

extension SpeechClient: DependencyKey {
    public static let liveValue = SpeechClient.noop
}

#endif
