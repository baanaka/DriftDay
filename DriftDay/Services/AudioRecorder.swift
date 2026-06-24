//
//  AudioRecorder.swift
//  DriftDay
//
//  AVFoundation voice recording with a hard 3-minute cap and live metering
//  for the waveform visualizer.
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class AudioRecorder: NSObject, ObservableObject {

    static let maxDuration: TimeInterval = 180   // 3 minutes

    @Published private(set) var isRecording = false
    @Published private(set) var elapsed: TimeInterval = 0
    /// Normalized 0...1 input level for the waveform.
    @Published private(set) var level: CGFloat = 0
    @Published private(set) var lastRecordedURL: URL?
    @Published private(set) var lastRecordedFileName: String?

    private var recorder: AVAudioRecorder?
    private var timer: Timer?

    var remaining: TimeInterval { max(0, Self.maxDuration - elapsed) }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
            return
        }

        let fileName = AudioFileStore.newRecordingFileName()
        let url = AudioFileStore.url(for: fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.isMeteringEnabled = true
            recorder.record(forDuration: Self.maxDuration)
            self.recorder = recorder
            self.lastRecordedURL = url
            self.lastRecordedFileName = fileName
            self.isRecording = true
            self.elapsed = 0
            startTimer()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording() {
        recorder?.stop()
        stopTimer()
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Discards the current take and prepares for a re-record.
    func discardRecording() {
        if isRecording { stopRecording() }
        if let name = lastRecordedFileName {
            AudioFileStore.deleteFile(named: name)
        }
        lastRecordedURL = nil
        lastRecordedFileName = nil
        elapsed = 0
        level = 0
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard let recorder, recorder.isRecording else {
            stopTimer()
            isRecording = false
            return
        }
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)        // dB, typically -160...0
        let normalized = max(0, (power + 50) / 50)              // map -50dB...0dB to 0...1
        level = CGFloat(min(1, normalized))
        elapsed = recorder.currentTime
        if elapsed >= Self.maxDuration {
            stopRecording()
        }
    }
}
