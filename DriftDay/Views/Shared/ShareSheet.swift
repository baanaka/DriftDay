//
//  ShareSheet.swift
//  DriftDay
//
//  Thin SwiftUI wrapper around UIActivityViewController for the Memory Detail
//  share button.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
