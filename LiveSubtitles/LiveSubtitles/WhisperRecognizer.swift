import Foundation
import AVFoundation

// C functions exposed by whisper.cpp built as a static library
@_silgen_name("whisper_init_from_file")
private func whisper_init_from_file(_ path: UnsafePointer<Int8>) -> OpaquePointer?

@_silgen_name("whisper_free")
private func whisper_free(_ ctx: OpaquePointer)

@_silgen_name("whisper_full_default_params")
private func whisper_full_default_params(_ strategy: Int32) -> WhisperFullParams

@_silgen_name("whisper_full")
private func whisper_full(_ ctx: OpaquePointer?, _ params: WhisperFullParams, _ samples: UnsafePointer<Float>, _ nSamples: Int32) -> Int32

@_silgen_name("whisper_full_n_segments")
private func whisper_full_n_segments(_ ctx: OpaquePointer?) -> Int32

@_silgen_name("whisper_full_get_segment_text")
private func whisper_full_get_segment_text(_ ctx: OpaquePointer?, _ index: Int32) -> UnsafePointer<Int8>?

// Structures matching whisper.cpp API
struct WhisperFullParams {
    var strategy: Int32
    var threads: Int32
    var translate: Bool
    var language: (Int8, Int8, Int8)
    // Additional fields omitted for brevity
    init() {
        self.strategy = 0
        self.threads = 0
        self.translate = false
        self.language = (0,0,0)
    }
}

/// Simple wrapper around whisper.cpp for offline speech recognition.
@MainActor
class WhisperRecognizer {
    private let audioEngine = AVAudioEngine()
    private var audioBuffer: [Float] = []
    private var ctx: OpaquePointer?

    init?(modelPath: String) {
        guard let cctx = modelPath.withCString({ whisper_init_from_file($0) }) else {
            return nil
        }
        ctx = cctx
    }

    deinit {
        if let ctx = ctx {
            whisper_free(ctx)
        }
    }

    /// Begin capturing microphone audio.
    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        audioBuffer.removeAll()
        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            guard let data = buffer.floatChannelData?[0] else { return }
            let count = Int(buffer.frameLength)
            self.audioBuffer.append(contentsOf: UnsafeBufferPointer(start: data, count: count))
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    /// Stop recording and run whisper on the captured audio.
    func stopRecording() -> String? {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        try? AVAudioSession.sharedInstance().setActive(false)

        guard let ctx = ctx, !audioBuffer.isEmpty else { return nil }

        var params = whisper_full_default_params(0)
        params.translate = true
        params.language = (Int8(UInt8(ascii: "e")), Int8(UInt8(ascii: "n")), 0)

        let result = audioBuffer.withUnsafeBufferPointer { buf in
            whisper_full(ctx, params, buf.baseAddress!, Int32(buf.count))
        }
        guard result == 0 else { return nil }

        var text = ""
        let count = whisper_full_n_segments(ctx)
        for i in 0..<count {
            if let ptr = whisper_full_get_segment_text(ctx, i) {
                text += String(cString: ptr)
            }
        }
        audioBuffer.removeAll()
        return text
    }
}
