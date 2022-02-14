//
//  DownloadsList.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

struct DownloadsList: View {
    @ObservedObject var viewModel: DownloadsListViewModel
    @State var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ActiveDownloadRow()
                    ForEach(viewModel.sections) { section in
                        Section(header: Text(section.header)) {
                            ForEach(section.rows) { row in
                                DownloadRow(rowModel: row)
                            }
                            .onDelete { offset in
                                self.delete(at: offset, in: section)
                            }
                        }
                    }
                    if editMode == .active {
                        DeleteAllSection()
                    }
                }
                .listStyle(.grouped)
                .navigationBarTitle("Downloads", displayMode: .inline)
                .environment(\.editMode, $editMode)
                .navigationBarItems(trailing: Button("Done") { print("Done Pressed") }
                                        .opacity(editMode == .inactive ? 1.0 : 0.0))
                
                HStack {
                    Spacer()
                    EditButton().environment(\.editMode, $editMode)
                }.padding()
            }
        }
    }
    
    func delete(at offsets: IndexSet, in section: DownloadsListSection) {
        guard let sectionIndex = viewModel.sections.firstIndex(of: section) else { return }
        print("\(section), \(offsets.first!)")
        viewModel.deleteItem(at: offsets, in: sectionIndex)
    }

}

struct DownloadsList_Previews: PreviewProvider {
    static var previews: some View {
        DownloadsList(viewModel: DownloadsListViewModel())
    }
}

struct DownloadRow: View {
    var rowModel: DownloadsListRow
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(rowModel.filename)
                Spacer()
                    .frame(height: 4.0)
                Text(rowModel.fileSize)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button {
                print("Share button was tapped")
            } label: {
                Image(systemName: "square.and.arrow.up")
            }.buttonStyle(.plain)
                .animation(nil) 
        }
        .frame(height: 72.0)
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

struct ActiveDownloadRow: View {
    @State var progressValue: Float = 0.0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("download.pdf")
                Spacer()
                    .frame(height: 4.0)
                Text("\(Int(100*progressValue)) of 100MB")
                    .foregroundColor(.gray)
            }
            Spacer()
            
            ProgressBar(progress: self.$progressValue)
                .frame(width: 30.0, height: 30.0)
                .padding(10.0)
            
            Button {
                incrementProgress()
            } label: {
                Image(systemName: "square.and.arrow.up")
//                    .tint(.black)
            }.buttonStyle(.plain)
        }
        .frame(height: 72.0)
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    func incrementProgress() {
        let randomValue = Float([0.012, 0.022, 0.034, 0.016, 0.11].randomElement()!)
        self.progressValue += randomValue
    }
}

struct ProgressBar: View {
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(Color.red)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.red)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
//                .font(.largeTitle)
//                .bold()
        }
    }
}

struct DeleteAllSection: View {
    var body: some View {
        Section(header: Spacer()) {
            HStack {
                Spacer()
                Text("Delete All")
                    .foregroundColor(Color.red)
                Spacer()
            }
        }
        .deleteDisabled(true)
    }
}
