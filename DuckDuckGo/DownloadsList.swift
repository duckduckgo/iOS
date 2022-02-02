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
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Today")) {
                        DownloadItem()
                    }
                    
                    Section(header: Text("Yesterday")) {
                        DownloadItem()
                        DownloadItem()
                    }
                    
                    Section(header: Text("Last Week")) {
                        DownloadItem()
                        DownloadItem()
                        DownloadItem()
                    }
                    
                    Section(header: Spacer()) {
                        HStack {
                            Spacer()
                            Text("Delete All")
                                .foregroundColor(Color.red)
                            Spacer()
                        }
                    }
                    
                }
                .listStyle(.grouped)
    //            .navigationTitle("Downloads")
    //            .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("Downloads", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") {
                    print("Done Pressed")
                })
//                .toolbar {
//                    ToolbarItem(placement: .bottomBar) {
//                        Button("Edit") {
//                            print("Edit Pressed")
//                        }
//                    }
//                }
                // toolbar
                HStack {
                    Spacer()
                    Button("Edit") {
                        print("Edit Pressed")
                    }
                }.padding()
            }
        }
    }
}

struct DownloadItem: View {
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("download.pdf")
                Spacer()
                    .frame(height: 4.0)
                Text("45MB")
                    .foregroundColor(.gray)
            }
            Spacer()

            Button {
                print("Share button was tapped")
            } label: {
                Image(systemName: "square.and.arrow.up")
            }.buttonStyle(.plain)
        }
        .frame(height: 72.0)
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
//        .swipeActions {
//            Button("Delete", role: .destructive) {
//                print("Delete")
//            }
//            .tint(.red)
//        }
    }
}

class DownloadsListHostingController: UIHostingController<DownloadsList> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: DownloadsList())
    }
}
