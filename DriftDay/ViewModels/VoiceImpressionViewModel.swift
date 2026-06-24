//
//  VoiceImpressionViewModel.swift
//  DriftDay
//

import SwiftUI
import Combine

@MainActor
final class VoiceImpressionViewModel: ObservableObject {

    enum Phase {
        case idle           // before recording
        case recording
        case review         // recorded, awaiting save / re-record
        case transcribing
    }

    @Published var phase: Phase = .idle
    @Published var errorMessage: String?

    let recorder = AudioRecorder()
    let player = AudioPlayer()

    let task: DailyTask
    private let repository: DriftDayRepository
    private let onComplete: () -> Void

    init(task: DailyTask,
         repository: DriftDayRepository = .shared,
         onComplete: @escaping () -> Void) {
        self.task = task
        self.repository = repository
        self.onComplete = onComplete
    }

    var showsCountdown: Bool {
        phase == .recording && recorder.remaining <= 30
    }

    func toggleRecord() {
        switch phase {
        case .idle:
            recorder.requestPermission { [weak self] granted in
                Task { @MainActor in
                    guard let self else { return }
                    if granted {
                        self.recorder.startRecording()
                        self.phase = .recording
                    } else {
                        self.errorMessage = "Microphone access is needed to record."
                    }
                }
            }
        case .recording:
            recorder.stopRecording()
            if let url = recorder.lastRecordedURL {
                player.load(url: url)
            }
            phase = .review
        default:
            break
        }
    }

    func reRecord() {
        player.stop()
        recorder.discardRecording()
        phase = .idle
    }

    /// Transcribes, saves audio + transcript, marks done, increments streak.
    func save() {
        guard let fileName = recorder.lastRecordedFileName else { return }
        let duration = recorder.elapsed
        phase = .transcribing
        player.stop()

        TranscriptionService.shared.requestAuthorization { [weak self] _ in
            TranscriptionService.shared.transcribe(fileName: fileName) { result in
                Task { @MainActor in
                    guard let self else { return }
                    let transcript: String?
                    switch result {
                    case .success(let text): transcript = text
                    case .failure:           transcript = nil
                    }
                    self.repository.saveImpression(
                        taskID: self.task.id,
                        audioFileName: fileName,
                        transcript: transcript,
                        duration: duration
                    )
                    self.repository.completeToday(self.task)
                    self.onComplete()
                }
            }
        }
    }

    /// Completes the task without saving any audio.
    func skipRecording() {
        if recorder.isRecording { recorder.stopRecording() }
        if let name = recorder.lastRecordedFileName {
            AudioFileStore.deleteFile(named: name)
        }
        repository.completeToday(task)
        onComplete()
    }
}
