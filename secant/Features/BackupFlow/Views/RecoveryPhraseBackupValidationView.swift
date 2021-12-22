//
//  RecoveryPhraseBackupView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/29/21.
//

import SwiftUI
import ComposableArchitecture

struct RecoveryPhraseBackupValidationView: View {
    let store: RecoveryPhraseValidationStore

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                header(for: viewStore)
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                VStack(spacing: 20) {
                    let state = viewStore.state
                    let chunks = state.phrase.toChunks()
                    ForEach(Array(zip(chunks.indices, chunks)), id: \.0) { index, chunk in
                        WordChipGrid(
                            state: state,
                            group: index,
                            chunk: chunk,
                            misingIndex: index
                        )
                        .background(Asset.Colors.BackgroundColors.phraseGridDarkGray.color)
                        .whenIsDroppable(!state.groupCompleted(index: index), dropDelegate: state.dropDelegate(for: viewStore, group: index))
                    }
                }
                .padding()
                .background(Asset.Colors.BackgroundColors.phraseGridDarkGray.color)
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForRoute(.success),
                    destination: { view(for: .success) }
                )
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForRoute(.failure),
                    destination: { view(for: .failure) }
                )
            }
            .applyScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("Verify Your Backup"))
        }
    }

    @ViewBuilder func header(for viewStore: RecoveryPhraseValidationViewStore) -> some View {
        switch viewStore.step {
        case .initial, .incomplete:
            VStack {
                Text("Drag the words below to match your backed-up copy.")
                    .bodyText()

                viewStore.state.missingWordGrid()
            }
            .padding(.horizontal, 30)
        case .complete:
            VStack {
                completeHeader(for: viewStore.state)
            }
        }
    }
    
    @ViewBuilder func completeHeader(for state: RecoveryPhraseValidationState) -> some View {
        if state.isValid {
            Text("Congratulations! You validated your secret recovery phrase.")
                .bodyText()
        } else {
            Text("Your placed words did not match your secret recovery phrase")
                .bodyText()
        }
    }

    @ViewBuilder func view(for route: RecoveryPhraseValidationState.Route) -> some View {
        switch route {
        case .success:
            SuccessView()
        case .failure:
            ValidationFailed(store: store)
        }
    }
}

private extension RecoveryPhraseValidationState {
    @ViewBuilder func missingWordGrid() -> some View {
        let columns = Array(repeating: GridItem(.flexible(minimum: 40, maximum: 120), spacing: 20), count: 2)
        LazyVGrid(columns: columns, alignment: .center, spacing: 20 ) {
            ForEach(0..<missingWordChips.count) { chipIndex in
                PhraseChip(kind: missingWordChips[chipIndex])
                    .makeDraggable()
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 30
                    )
            }
        }
        .padding(0)
    }
}

extension RecoveryPhraseValidationState {
    func wordsChips(for group: Int, groupSize: Int, from chunk: RecoveryPhrase.Chunk) -> [PhraseChip.Kind] {
        let wordCompletion = completion.first(where: { $0.groupIndex == group })

        var chips: [PhraseChip.Kind] = []
        for (i, word) in chunk.words.enumerated() {
            if i == missingIndices[group] {
                if let completedWord = wordCompletion?.word {
                    chips.append(.unassigned(word: completedWord))
                } else {
                    chips.append(.empty)
                }
            } else {
                chips.append(.ordered(position: (groupSize * group) + i + 1, word: word))
            }
        }
        return chips
    }
}

extension RecoveryPhraseValidationState {
    static let placeholder = RecoveryPhraseValidationState.random(phrase: RecoveryPhrase.placeholder)
}

extension RecoveryPhraseValidationStore {
    private static let scheduler = DispatchQueue.main

    static let demo = Store(
        initialState: RecoveryPhraseValidationState.placeholder,
        reducer: .default,
        environment: BackupPhraseEnvironment.demo
    )
}

private extension WordChipGrid {
    init(
        state: RecoveryPhraseValidationState,
        group: Int,
        chunk: RecoveryPhrase.Chunk,
        misingIndex: Int
    ) {
        let chips = state.wordsChips(for: group, groupSize: RecoveryPhraseValidationState.wordGroupSize, from: chunk)
        self.init(chips: chips, coloredChipColor: state.coloredChipColor)
    }
}

private extension RecoveryPhraseValidationState {
    var coloredChipColor: Color {
        switch self.step {
        case .initial, .incomplete:
            return Asset.Colors.Buttons.activeButton.color
        case .complete:
            return isValid ? Asset.Colors.Buttons.activeButton.color : Asset.Colors.BackgroundColors.red.color
        }
    }
}

struct RecoveryPhraseBackupView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseBackupValidationView(store: RecoveryPhraseValidationStore.demo)
    }
}
