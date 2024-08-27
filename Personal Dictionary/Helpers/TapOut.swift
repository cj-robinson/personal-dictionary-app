//
//  TapOut.swift
//  Personal Dictionary
//
//  Created by CJ Robinson on 7/28/24.
//

import Foundation
import SwiftUI

// View Modifier to dismiss keyboard on tap
struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())  // Ensure the tap area covers the entire view
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

// Extension to apply the view modifier easily
extension View {
    func dismissKeyboardOnTap() -> some View {
        self.modifier(DismissKeyboardOnTap())
    }
}
