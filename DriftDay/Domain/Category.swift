//
//  Category.swift
//  DriftDay
//

import SwiftUI

/// The six interest categories used across onboarding, profile, and task generation.
enum Category: String, CaseIterable, Identifiable {
    case food
    case routes
    case social
    case culture
    case movement
    case creativity

    var id: String { rawValue }

    var title: String {
        switch self {
        case .food: return "Food"
        case .routes: return "Routes"
        case .social: return "Social"
        case .culture: return "Culture"
        case .movement: return "Movement"
        case .creativity: return "Creativity"
        }
    }

    /// SF Symbol name for the category icon.
    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .routes: return "map"
        case .social: return "person.2"
        case .culture: return "building.columns"
        case .movement: return "figure.walk"
        case .creativity: return "paintpalette"
        }
    }

    var tint: Color {
        switch self {
        case .food: return .orange
        case .routes: return .green
        case .social: return .pink
        case .culture: return .purple
        case .movement: return .blue
        case .creativity: return .teal
        }
    }
}
