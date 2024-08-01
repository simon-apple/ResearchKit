//
//  Color+ResearchFormColors.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 7/31/24.
//

import Foundation
import SwiftUI

extension Color {
    public enum ColorChoice {
        case background
        case secondaryBackground
        case label
        case systemGray4
        case systemGray5
    }
    
    public static func choice(for choice: ColorChoice) -> Color {
        switch choice {
        case .background:
#if os(watchOS)
            return Color.primary
#else
            return Color(uiColor: UIColor.systemBackground)
#endif
            
        case .secondaryBackground:
#if os(watchOS)
            return Color.secondary
#else
            return Color(uiColor: UIColor.secondarySystemBackground)
#endif

        case .label:
#if os(watchOS)
            return Color.primary
#else
            return Color(uiColor: UIColor.label)
#endif
        
        case .systemGray4:
#if os(watchOS)
            return Color.secondary.opacity(0.4)
#else
            return Color(uiColor: UIColor.systemGray4)
#endif
        case .systemGray5:
#if os(watchOS)
            return Color.secondary.opacity(0.5)
#else
            return Color(uiColor: UIColor.systemGray5)
#endif
        }
    }
}

