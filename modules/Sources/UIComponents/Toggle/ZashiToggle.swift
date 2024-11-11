//
//  ZashiToggle.swift
//
//
//  Created by Lukáš Korba on 04-16-2024.
//

import SwiftUI
import Generated

public struct ZashiToggle: View {
    @Binding var isOn: Bool
    let label: String
    let textColor: Color
    
    public init(
        isOn: Binding<Bool>,
        label: String,
        textColor: Color = Asset.Colors.primary.color
    ) {
        self._isOn = isOn
        self.label = label
        self.textColor = textColor
    }
    
    public var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Toggle(isOn: $isOn, label: {
                Text(label)
                    .font(.custom(FontFamily.Inter.medium.name, size: 14))
            })
            .toggleStyle(CheckboxToggleStyle())
        }
        .foregroundColor(textColor)
    }
}

#Preview {
    BoolStateWrapper(initialValue: false) {
        ZashiToggle(isOn: $0, label: "I acknowledge")
    }
}
