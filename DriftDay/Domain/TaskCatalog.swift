//
//  TaskCatalog.swift
//  DriftDay
//
//  The static pool of micro-adventures. Each template carries a `boldness`
//  rating (0.0 familiar → 1.0 adventurous) so the generator can match a task
//  to the user's effective boldness for the day.
//

import Foundation

struct TaskTemplate {
    let title: String          // max 60 chars
    let description: String     // one sentence
    let category: Category
    let estimatedMinutes: Int
    let boldness: Double        // 0.0 ... 1.0
}

enum TaskCatalog {
    static let all: [TaskTemplate] = [
        // MARK: Food
        .init(title: "Order a drink you can't pronounce",
              description: "Walk into a café and pick the menu item with the most unfamiliar name.",
              category: .food, estimatedMinutes: 15, boldness: 0.3),
        .init(title: "Cook with one ingredient you've never used",
              description: "Buy a single new ingredient and build a small dish around it.",
              category: .food, estimatedMinutes: 45, boldness: 0.55),
        .init(title: "Eat lunch somewhere you've walked past for years",
              description: "Visit that one place you keep meaning to try and finally order.",
              category: .food, estimatedMinutes: 30, boldness: 0.4),
        .init(title: "Ask a stranger for their favorite local bite",
              description: "Get a food recommendation from someone nearby and go get it.",
              category: .food, estimatedMinutes: 25, boldness: 0.8),

        // MARK: Routes
        .init(title: "Take the long way home on purpose",
              description: "Pick a route you'd normally avoid and notice three new things.",
              category: .routes, estimatedMinutes: 20, boldness: 0.2),
        .init(title: "Get off one stop early and walk",
              description: "Leave your usual transit a stop sooner and explore the gap.",
              category: .routes, estimatedMinutes: 20, boldness: 0.35),
        .init(title: "Follow a street until it surprises you",
              description: "Choose a street you've never finished and walk it end to end.",
              category: .routes, estimatedMinutes: 40, boldness: 0.6),
        .init(title: "Let a coin flip choose every turn",
              description: "Wander for fifteen minutes deciding each turn by a coin toss.",
              category: .routes, estimatedMinutes: 25, boldness: 0.85),

        // MARK: Social
        .init(title: "Compliment a stranger sincerely",
              description: "Give one honest, specific compliment to someone you don't know.",
              category: .social, estimatedMinutes: 10, boldness: 0.7),
        .init(title: "Text someone you've lost touch with",
              description: "Reach out to a person you haven't spoken to in over a year.",
              category: .social, estimatedMinutes: 15, boldness: 0.45),
        .init(title: "Ask a barista about their day and listen",
              description: "Start a small, genuine conversation with someone serving you.",
              category: .social, estimatedMinutes: 10, boldness: 0.5),
        .init(title: "Invite someone to do something spontaneous",
              description: "Message a friend with a same-day, low-stakes plan.",
              category: .social, estimatedMinutes: 20, boldness: 0.65),

        // MARK: Culture
        .init(title: "Visit a place that's free and you've ignored",
              description: "Step into a gallery, library, or hall you've never entered.",
              category: .culture, estimatedMinutes: 35, boldness: 0.3),
        .init(title: "Read a page from a genre you avoid",
              description: "Open a book in a genre you never pick and read one full page.",
              category: .culture, estimatedMinutes: 15, boldness: 0.25),
        .init(title: "Learn one phrase in a new language",
              description: "Pick a language and learn to say a full sentence out loud.",
              category: .culture, estimatedMinutes: 20, boldness: 0.4),
        .init(title: "Attend something on a topic you know nothing about",
              description: "Find a local talk, class, or meetup outside your world.",
              category: .culture, estimatedMinutes: 60, boldness: 0.75),

        // MARK: Movement
        .init(title: "Stretch for five minutes in the morning sun",
              description: "Find a patch of light and move slowly through a short stretch.",
              category: .movement, estimatedMinutes: 10, boldness: 0.15),
        .init(title: "Try a movement your body forgot",
              description: "Skip, balance, or climb something the way you did as a kid.",
              category: .movement, estimatedMinutes: 15, boldness: 0.5),
        .init(title: "Walk a mile without your phone",
              description: "Leave the screen behind and pay attention with all your senses.",
              category: .movement, estimatedMinutes: 30, boldness: 0.55),
        .init(title: "Take a free trial class for a sport you've never tried",
              description: "Book a beginner session in something physical and new.",
              category: .movement, estimatedMinutes: 60, boldness: 0.8),

        // MARK: Creativity
        .init(title: "Sketch the first object you see for two minutes",
              description: "Grab anything to draw with and capture one nearby object.",
              category: .creativity, estimatedMinutes: 10, boldness: 0.2),
        .init(title: "Write a six-word story about today",
              description: "Sum up your day so far in exactly six words.",
              category: .creativity, estimatedMinutes: 10, boldness: 0.3),
        .init(title: "Photograph the same spot from five angles",
              description: "Pick one location and find five completely different shots.",
              category: .creativity, estimatedMinutes: 20, boldness: 0.45),
        .init(title: "Make something and give it away today",
              description: "Create a small thing and hand it to someone before the day ends.",
              category: .creativity, estimatedMinutes: 45, boldness: 0.85),
    ]

    static func templates(for categories: [Category]) -> [TaskTemplate] {
        let active = Set(categories)
        let filtered = all.filter { active.contains($0.category) }
        return filtered.isEmpty ? all : filtered
    }
}
