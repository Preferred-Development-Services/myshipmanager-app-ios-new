//
//  MultiSelectionView.swift
//  MyShipManager
//
//  Created by Hayden Peeples on 5/21/22.
//

import SwiftUI

struct MultiSelectionView<Selectable: Identifiable & Hashable>: View {
    let options: [Selectable]
    let optionToString: (Selectable) -> String

    @Binding
    var selected: Set<Selectable>
    @Binding var selectedStr: String
    var body: some View {
        List {
            ForEach(options) { selectable in
                Button(action: { toggleSelection(selectable: selectable) }) {
                    HStack {
                        Text(optionToString(selectable)).foregroundColor(.black)

                        Spacer()

                        if selected.contains { $0.id == selectable.id } {
                            Image(systemName: "checkmark").foregroundColor(.accentColor)
                        }
                    }
                }.tag(selectable.id)
            }
        }.listStyle(GroupedListStyle())
    }

    private func toggleSelection(selectable: Selectable) {
        if let existingIndex = selected.firstIndex(where: { $0.id == selectable.id }) {
            selected.remove(at: existingIndex)
        } else {
            selected.insert(selectable)
        }
        selectedStr = "";
        var firstTime = true;
        for selectedVal in selected {
            if firstTime {
                selectedStr = optionToString(selectedVal);
            }
            else {
                selectedStr = selectedStr + "," + optionToString(selectedVal)
            }
            firstTime = false;
        }
    }
}
