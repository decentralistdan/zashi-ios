//
//  ActiveButton.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/14/21.
//

import SwiftUI
import Generated

extension Button {
    public var activeButtonStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Text.activeButtonText.color,
                background: Asset.Colors.Buttons.activeButton.color,
                pressedBackgroundColor: Asset.Colors.Buttons.activeButtonPressed.color,
                disabledBackgroundColor: Asset.Colors.Buttons.activeButtonDisabled.color,
                overlayColor: Asset.Colors.Text.activeButtonText.color
            )
        )
    }
    
    public var activeWhiteButtonStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Buttons.activeButton.color,
                background: Asset.Colors.Text.activeButtonText.color,
                pressedBackgroundColor: Asset.Colors.Buttons.activeButtonPressed.color,
                disabledBackgroundColor: Asset.Colors.Buttons.activeButtonDisabled.color,
                overlayColor: Asset.Colors.Buttons.activeButton.color
            )
        )
    }
 
    public var disableButtonStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Text.activeButtonText.color,
                background: Asset.Colors.Text.transactionRowSubtitle.color,
                pressedBackgroundColor: Asset.Colors.Buttons.activeButtonPressed.color,
                disabledBackgroundColor: Asset.Colors.Buttons.activeButtonDisabled.color,
                overlayColor: Asset.Colors.Text.activeButtonText.color
            )
        )
    }
}

struct ActiveButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Active Button") { dump("Active button") }
            .activeButtonStyle
            .frame(width: 250, height: 50)
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.light)
    }
}
