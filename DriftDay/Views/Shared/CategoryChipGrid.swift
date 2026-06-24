//
//  CategoryChipGrid.swift
//  DriftDay
//
//  Reusable interest-chip grid used in both Onboarding and Profile.
//

import SwiftUI

struct CategoryChipGrid: View {
    let selected: Set<Category>
    let onToggle: (Category) -> Void

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Category.allCases) { category in
                CategoryChip(
                    category: category,
                    isSelected: selected.contains(category),
                    action: { onToggle(category) }
                )
            }
        }
    }
}

private struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                Text(category.title)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? category.tint.opacity(0.22) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? category.tint : Color.clear, lineWidth: 2)
            )
            .foregroundStyle(isSelected ? category.tint : .primary)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
