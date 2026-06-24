//
//  TranscriptionService.swift
//  DriftDay
//
//  On-device transcription of a recorded voice impression via the Speech
//  framework.
//

import Foundation
import Speech

enum TranscriptionError: Error {
    case notAuthorized
    case unavailable
    case failed(Error)
}

final class TranscriptionService {
    static let shared = TranscriptionService()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    /// Transcribes an audio file on-device. Falls back gracefully — a nil
    /// transcript simply means "No transcript available" downstream.
    func transcribe(fileName: String, completion: @escaping (Result<String, TranscriptionError>) -> Void) {
        let url = AudioFileStore.url(for: fileName)

        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            completion(.failure(.notAuthorized))
            return
        }
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            completion(.failure(.unavailable))
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        request.shouldReportPartialResults = false

        recognizer.recognitionTask(with: request) { result, error in
            if let error {
                DispatchQueue.main.async { completion(.failure(.failed(error))) }
                return
            }
            guard let result, result.isFinal else { return }
            let text = result.bestTranscription.formattedString
            DispatchQueue.main.async { completion(.success(text)) }
        }
    }
}
