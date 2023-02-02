//
//  SettingsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 21.07.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

@MainActor
class SettingsTests: XCTestCase {
    func testBackupWalletAccessRequest_AuthenticateSuccessPath() async throws {
        let mnemonic =
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
        
        let mockedWalletStorage = WalletStorageClient(
            importWallet: { _, _, _, _ in
                throw WalletStorage.WalletStorageError.alreadyImported
            },
            exportWallet: {
                StoredWallet(
                    language: .english,
                    seedPhrase: mnemonic,
                    version: 1,
                    hasUserPassedPhraseBackupTest: true
                )
            },
            areKeysPresent: {
                throw WalletStorage.WalletStorageError.uninitializedWallet
            },
            updateBirthday: { _ in
                throw WalletStorage.KeychainError.encoding
            },
            markUserPassedPhraseBackupTest: {
                throw WalletStorage.KeychainError.encoding
            },
            nukeWallet: { }
        )
        
        let store = TestStore(
            initialState: SettingsReducer.State(
                phraseDisplayState: RecoveryPhraseDisplayReducer.State(phrase: nil),
                isCrashReportingOn: false
            ),
            reducer: SettingsReducer()
        ) { dependencies in
            dependencies.localAuthentication = .mockAuthenticationSucceeded
            dependencies.mnemonic = .noOp
            dependencies.mnemonic.asWords = { _ in mnemonic.components(separatedBy: " ") }
            dependencies.walletStorage = mockedWalletStorage
        }

        _ = await store.send(.backupWalletAccessRequest)
        
        await store.receive(.backupWallet) { state in
            state.phraseDisplayState.phrase = RecoveryPhrase(words: mnemonic.components(separatedBy: " "))
        }
        await store.receive(.updateDestination(.backupPhrase)) { state in
            state.destination = .backupPhrase
        }
    }
    
    func testBackupWalletAccessRequest_AuthenticateFailedPath() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: SettingsReducer()
        ) {
            $0.localAuthentication = .mockAuthenticationFailed
        }

        _ = await store.send(.backupWalletAccessRequest)
        
        await store.finish()
    }
    
    func testRescanBlockchain() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: SettingsReducer()
        )
        
        _ = await store.send(.rescanBlockchain) { state in
            state.rescanDialog = .init(
                title: TextState("Rescan"),
                message: TextState("Select the rescan you want"),
                buttons: [
                    .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                    .default(TextState("Full rescan"), action: .send(.fullRescan)),
                    .cancel(TextState("Cancel"))
                ]
            )
        }
    }
    
    func testRescanBlockchain_Cancelling() async throws {
        let store = TestStore(
            initialState: SettingsReducer.State(
                destination: nil,
                phraseDisplayState: .init(),
                rescanDialog: .init(
                    title: TextState("Rescan"),
                    message: TextState("Select the rescan you want"),
                    buttons: [
                        .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                        .default(TextState("Full rescan"), action: .send(.fullRescan)),
                        .cancel(TextState("Cancel"))
                    ]
                ),
                isCrashReportingOn: false
            ),
            reducer: SettingsReducer()
        )
        
        _ = await store.send(.cancelRescan) { state in
            state.rescanDialog = nil
        }
    }
    
    func testRescanBlockchain_QuickRescanClearance() async throws {
        let store = TestStore(
            initialState: SettingsReducer.State(
                destination: nil,
                phraseDisplayState: .init(),
                rescanDialog: .init(
                    title: TextState("Rescan"),
                    message: TextState("Select the rescan you want"),
                    buttons: [
                        .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                        .default(TextState("Full rescan"), action: .send(.fullRescan)),
                        .cancel(TextState("Cancel"))
                    ]
                ),
                isCrashReportingOn: false
            ),
            reducer: SettingsReducer()
        )
        
        _ = await store.send(.quickRescan) { state in
            state.rescanDialog = nil
        }
    }
    
    func testRescanBlockchain_FullRescanClearance() async throws {
        let store = TestStore(
            initialState: SettingsReducer.State(
                destination: nil,
                phraseDisplayState: .init(),
                rescanDialog: .init(
                    title: TextState("Rescan"),
                    message: TextState("Select the rescan you want"),
                    buttons: [
                        .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                        .default(TextState("Full rescan"), action: .send(.fullRescan)),
                        .cancel(TextState("Cancel"))
                    ]
                ),
                isCrashReportingOn: false
            ),
            reducer: SettingsReducer()
        )
        
        _ = await store.send(.fullRescan) { state in
            state.rescanDialog = nil
        }
    }
    
    func testExportLogs_ButtonDisableShareEnable() async throws {
        let store = TestStore(
            initialState: SettingsReducer.State(
                destination: nil,
                phraseDisplayState: .init(),
                rescanDialog: .init(
                    title: TextState("Rescan"),
                    message: TextState("Select the rescan you want"),
                    buttons: [
                        .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                        .default(TextState("Full rescan"), action: .send(.fullRescan)),
                        .cancel(TextState("Cancel"))
                    ]
                ),
                isCrashReportingOn: false
            ),
            reducer: SettingsReducer()
        )
        
        store.dependencies.logsHandler = LogsHandlerClient(exportAndStoreLogs: { _, _, _ in })
        
        _ = await store.send(.exportLogs) { state in
            state.exportLogsDisabled = true
        }
        
        await store.receive(.logsExported) { state in
            state.exportLogsDisabled = false
            state.isSharingLogs = true
        }
    }
    
    func testLogShareFinished() async throws {
        let store = TestStore(
            initialState: SettingsReducer.State(
                destination: nil,
                isSharingLogs: true,
                phraseDisplayState: .init(),
                rescanDialog: .init(
                    title: TextState("Rescan"),
                    message: TextState("Select the rescan you want"),
                    buttons: [
                        .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                        .default(TextState("Full rescan"), action: .send(.fullRescan)),
                        .cancel(TextState("Cancel"))
                    ]
                ),
                isCrashReportingOn: false
            ),
            reducer: SettingsReducer()
        )
        
        _ = await store.send(.logsShareFinished) { state in
            state.isSharingLogs = false
        }
    }
}
