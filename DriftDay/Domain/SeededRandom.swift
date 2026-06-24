//
//  SeededRandom.swift
//  DriftDay
//
//  SystemRandomNumberGenerator is not seedable, so we use a deterministic
//  SplitMix64 generator. Given the same seed it always produces the same
//  sequence — that is what makes the daily task reproducible without a backend.
//

import Foundation

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        // Avoid a zero state which would degenerate the sequence.
        state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

extension UInt64 {
    /// A stable, process-independent hash for a string. Swift's `Hashable` is
    /// salted per launch, so we roll our own FNV-1a for deterministic seeds.
    static func stableHash(_ string: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return hash
    }
}
