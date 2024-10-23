//
//  RequestPaymentConfirmationView.swift
//  Zashi
//
//  Created by Lukáš Korba on 28.11.2023.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils
import PartialProposalError

public struct RequestPaymentConfirmationView: View {
    @Perception.Bindable var store: StoreOf<SendConfirmation>
    let tokenName: String
    
    public init(store: StoreOf<SendConfirmation>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        BalanceWithIconView(balance: store.amount)
                        
                        Text(store.currencyAmount.data)
                            .zFont(.semiBold, size: 16, style: Design.Text.primary)
                            .padding(.top, 10)
                    }
                    .screenHorizontalPadding()
                    .padding(.top, 40)
                    .padding(.bottom, 24)

                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.Send.RequestPayment.requestedBy)
                                .zFont(.medium, size: 14, style: Design.Text.tertiary)

                            if let alias = store.alias {
                                Text(alias)
                                    .zFont(.medium, size: 14, style: Design.Inputs.Filled.label)
                            }
                            
                            Text(store.addressToShow)
                                .zFont(size: 12, style: Design.Text.primary)
                        }
                        
                        Spacer()
                    }
                    .screenHorizontalPadding()
                    .padding(.bottom, 16)

                    if !store.isTransparentAddress || store.alias == nil {
                        HStack(spacing: 0) {
                            if !store.isTransparentAddress {
                                if store.isAddressExpanded {
                                    ZashiButton(
                                        L10n.General.hide,
                                        type: .tertiary,
                                        infinityWidth: false,
                                        prefixView:
                                            Asset.Assets.chevronDown.image
                                            .zImage(size: 20, style: Design.Btns.Tertiary.fg)
                                            .rotationEffect(Angle(degrees: 180))
                                    ) {
                                        store.send(.showHideButtonTapped)
                                    }
                                    .padding(.trailing, 12)
                                } else {
                                    ZashiButton(
                                        L10n.General.show,
                                        type: .tertiary,
                                        infinityWidth: false,
                                        prefixView:
                                            Asset.Assets.chevronDown.image
                                            .zImage(size: 20, style: Design.Btns.Tertiary.fg)
                                    ) {
                                        store.send(.showHideButtonTapped)
                                    }
                                    .padding(.trailing, 12)
                                }
                            }
                            
                            if store.alias == nil {
                                ZashiButton(
                                    L10n.General.save,
                                    type: .tertiary,
                                    infinityWidth: false,
                                    prefixView:
                                        Asset.Assets.Icons.userPlus.image
                                        .zImage(size: 20, style: Design.Btns.Tertiary.fg)
                                ) {
                                    store.send(.saveAddressTapped(store.address.redacted))
                                }
                            }
                            
                            Spacer()
                        }
                        .screenHorizontalPadding()
                        .padding(.bottom, 24)
                    }

                    if !store.message.isEmpty {
                        VStack(alignment: .leading) {
                            Text(L10n.Send.RequestPayment.for)
                                .zFont(.medium, size: 14, style: Design.Text.tertiary)

                            HStack {
                                Text(store.message)
                                    .zFont(.medium, size: 14, style: Design.Inputs.Filled.text)
                                
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Design.Inputs.Filled.bg.color)
                            }
                        }
                        .screenHorizontalPadding()
                        .padding(.bottom, 40)
                    }
                    
                    HStack {
                        Text(L10n.Send.feeSummary)
                            .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        
                        Spacer()

                        ZatoshiRepresentationView(
                            balance: store.feeRequired,
                            fontName: FontFamily.Inter.semiBold.name,
                            mostSignificantFontSize: 14,
                            leastSignificantFontSize: 7,
                            format: .expanded
                        )
                        .padding(.trailing, 4)
                    }
                    .screenHorizontalPadding()
                    .padding(.bottom, 20)
                    
                    HStack {
                        Text(L10n.Send.RequestPayment.total)
                            .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        
                        Spacer()

                        ZatoshiRepresentationView(
                            balance: store.amount + store.feeRequired,
                            fontName: FontFamily.Inter.semiBold.name,
                            mostSignificantFontSize: 14,
                            leastSignificantFontSize: 7,
                            format: .expanded
                        )
                        .padding(.trailing, 4)
                    }
                    .screenHorizontalPadding()
                    .padding(.bottom, 20)
                }
                .padding(.vertical, 1)
                .navigationLinkEmpty(
                    isActive: $store.partialProposalErrorViewBinding,
                    destination: {
                        PartialProposalErrorView(
                            store: store.scope(
                                state: \.partialProposalErrorState,
                                action: \.partialProposalError
                            )
                        )
                    }
                )
                .alert($store.scope(state: \.alert, action: \.alert))
                
                Spacer()
                
                if store.isSending {
                    ZashiButton(
                        L10n.Send.sending,
                        accessoryView:
                            ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: Asset.Colors.secondary.color
                                )
                            )
                    ) { }
                    .screenHorizontalPadding()
                    .padding(.vertical, 24)
                    .disabled(store.isSending)
                } else {
                    ZashiButton(L10n.General.send) {
                        store.send(.sendPressed)
                    }
                    .screenHorizontalPadding()
                    .padding(.vertical, 24)
                }
            }
            .onAppear { store.send(.onAppear) }
            .screenTitle(L10n.Send.RequestPayment.title.uppercased())
        }
        .navigationBarBackButtonHidden()
        .padding(.vertical, 1)
        .applyScreenBackground()
        .zashiBackV2 {
            store.send(.goBackPressedFromRequestZec)
        }
    }
}

#Preview {
    NavigationView {
        RequestPaymentConfirmationView(
            store: SendConfirmation.initial,
            tokenName: "ZEC"
        )
    }
}