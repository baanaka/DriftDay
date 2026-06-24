//
//  DayStyle.swift
//  DriftDay
//
//  Five visual themes for the sealed card. The active theme for a given day is
//  carried on the DailyTask as `visualThemeIndex`.
//

import SwiftUI

struct DayStyle {
    let name: String
    let gradient: [Color]
    let sealSymbol: String

    static let all: [DayStyle] = [
        DayStyle(name: "Dawn",   gradient: [Color(red: 0.98, green: 0.55, blue: 0.36), Color(red: 0.93, green: 0.27, blue: 0.49)], sealSymbol: "sun.haze.fill"),
        DayStyle(name: "Tide",   gradient: [Color(red: 0.16, green: 0.50, blue: 0.73), Color(red: 0.10, green: 0.74, blue: 0.61)], sealSymbol: "water.waves"),
        DayStyle(name: "Dusk",   gradient: [Color(red: 0.40, green: 0.22, blue: 0.62), Color(red: 0.18, green: 0.22, blue: 0.50)], sealSymbol: "moon.stars.fill"),
        DayStyle(name: "Grove",  gradient: [Color(red: 0.18, green: 0.55, blue: 0.34), Color(red: 0.42, green: 0.66, blue: 0.20)], sealSymbol: "leaf.fill"),
        DayStyle(name: "Ember",  gradient: [Color(red: 0.85, green: 0.33, blue: 0.16), Color(red: 0.62, green: 0.13, blue: 0.29)], sealSymbol: "flame.fill"),
    ]

    static func style(at index: Int) -> DayStyle {
        all[((index % all.count) + all.count) % all.count]
    }
}
