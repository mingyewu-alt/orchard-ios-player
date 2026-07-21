import AVFoundation
import SwiftUI

@main
struct OrchardPlayerApp: App {
    init() {
        AudioSessionManager.activate()
    }

    var body: some Scene {
        WindowGroup {
            PlayerView()
        }
    }

}

enum AudioSessionManager {
    static func activate() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .moviePlayback,
                policy: .longFormAudio
            )
            try session.setActive(true)
        } catch {
            // Playback in the foreground can still work if audio-session setup fails.
            print("Audio session setup failed: \(error.localizedDescription)")
        }
    }
}
