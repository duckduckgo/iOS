//
//  ReorderableForEach.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
import UniformTypeIdentifiers

protocol Reorderable: Hashable {
    var dropItemProvider: NSItemProvider { get }
    var dropType: UTType { get }
}

struct ReorderableForEach<Data: Reorderable, ID: Hashable, Content: View, Preview: View>: View {

    typealias ContentBuilder = (Data) -> Content
    typealias PreviewBuilder = (Data) -> Preview

    private let data: [Data]
    private let isReorderingEnabled: Bool
    private let id: KeyPath<Data, ID>

    private let content: ContentBuilder
    private let preview: PreviewBuilder?
    private let onMove: (_ from: IndexSet, _ to: Int) -> Void

    @State private var movedItem: Data?

    init(_ data: [Data],
         id: KeyPath<Data, ID>,
         isReorderingEnabled: Bool = true,
         @ViewBuilder content: @escaping ContentBuilder,
         onMove: @escaping (_ from: IndexSet, _ to: Int) -> Void) where Preview == EmptyView {
        self.data = data
        self.id = id
        self.isReorderingEnabled = isReorderingEnabled
        self.content = content
        self.preview = nil
        self.onMove = onMove
    }

    init(_ data: [Data],
         id: KeyPath<Data, ID>,
         isReorderingEnabled: Bool = true,
         @ViewBuilder content: @escaping ContentBuilder,
         @ViewBuilder preview: @escaping (Data) -> Preview,
         onMove: @escaping (_ from: IndexSet, _ to: Int) -> Void) {
        self.data = data
        self.id = id
        self.isReorderingEnabled = isReorderingEnabled
        self.content = content
        self.preview = preview
        self.onMove = onMove
    }

    var body: some View {
        ForEach(data, id: id) { item in
            if isReorderingEnabled {
                if let preview {
                    droppableContent(for: item)
                        .onDrag {
                            movedItem = item
                            return item.dropItemProvider
                        } preview: {
                            preview(item)
                        }
                } else {
                    droppableContent(for: item)
                        .onDrag {
                            movedItem = item
                            return item.dropItemProvider
                        }
                }
            } else {
                content(item)
            }
        }
    }

    private func droppableContent(for item: Data) -> some View {
        content(item)
            .onDrop(of: [item.dropType], delegate: ReorderDropDelegate(
                data: data,
                item: item,
                onMove: onMove,
                movedItem: $movedItem))
    }
}

private struct ReorderDropDelegate<Data: Reorderable>: DropDelegate {

    let data: [Data]
    let item: Data
    let onMove: (_ from: IndexSet, _ to: Int) -> Void

    @Binding var movedItem: Data?

    func dropEntered(info: DropInfo) {
        guard item != movedItem,
              let current = movedItem,
              let from = data.firstIndex(of: current),
              let to = data.firstIndex(of: item)
        else { return }

        if data[to] != current {
            let fromIndices = IndexSet(integer: from)
            let toIndex = to > from ? to + 1 : to
            onMove(fromIndices, toIndex)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        movedItem = nil
        return info.hasItemsConforming(to: [item.dropType])
    }
}

extension ReorderableForEach where Data: Identifiable, ID == Data.ID {
    init(_ data: [Data],
         isReorderingEnabled: Bool = true,
         @ViewBuilder content: @escaping ContentBuilder,
         onMove: @escaping (_ from: IndexSet, _ to: Int) -> Void) where Preview == EmptyView {
        self.data = data
        self.id = \Data.id
        self.isReorderingEnabled = isReorderingEnabled
        self.content = content
        self.preview = nil
        self.onMove = onMove
    }

    init(_ data: [Data],
         isReorderingEnabled: Bool = true,
         @ViewBuilder content: @escaping ContentBuilder,
         @ViewBuilder preview: @escaping PreviewBuilder,
         onMove: @escaping (_ from: IndexSet, _ to: Int) -> Void) {
        self.data = data
        self.id = \Data.id
        self.isReorderingEnabled = isReorderingEnabled
        self.content = content
        self.preview = preview
        self.onMove = onMove
    }
}
