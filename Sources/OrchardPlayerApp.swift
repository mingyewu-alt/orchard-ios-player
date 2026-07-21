import AVFoundation
import SwiftUI

@main
struct OrchardPlayerApp: App {
    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            PlayerView()
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            // Playback in the foreground can still work if audio-session setup fails.
            print("Audio session setup failed: \(error.localizedDescription)")
        }
    }
}
