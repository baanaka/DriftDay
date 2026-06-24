//
//  AudioFileStore.swift
//  DriftDay
//
//  Manages voice memo files inside the app's sandboxed Documents directory.
//  Only relative file names are persisted in Core Data so the store survives
//  container path changes between launches.
//

import Foundation

enum AudioFileStore {
    static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func url(for fileName: String) -> URL {
        documentsURL.appendingPathComponent(fileName)
    }

    static func newRecordingFileName() -> String {
        "impression-\(UUID().uuidString).m4a"
    }

    static func deleteFile(named fileName: String) {
        let url = url(for: fileName)
        try? FileManager.default.removeItem(at: url)
    }

    /// Removes every audio file we manage. Used by "Clear All Data".
    static func deleteAllAudioFiles() {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(
            at: documentsURL,
            includingPropertiesForKeys: nil
        ) else { return }
        for file in files where file.pathExtension.lowercased() == "m4a" {
            try? fm.removeItem(at: file)
        }
    }
}
