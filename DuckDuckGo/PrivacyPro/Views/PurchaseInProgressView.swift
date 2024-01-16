//
//  PurchaseInProgressView.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import DesignResourcesKit

struct PurchaseInProgressView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var status: String
        
    var body: some View {
        ZStack {
            Color(designSystemColor: .background)
                .opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .disabled(true)
                        
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(designSystemColor: .background))
                    .frame(width: 220, height: 120)
                    .shadow(color: colorScheme == .dark ? .black : .gray50, radius: 10)
                
                VStack {
                    SwiftUI.ProgressView()
                        .scaleEffect(2)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(designSystemColor: DesignSystemColor.icons)))
                        .padding(.bottom, 18)
                        .padding(.top, 10)
                    Text(status).daxSubheadRegular().foregroundColor(Color(designSystemColor: .textPrimary))
                        .frame(width: 200, height: 20)
                }
            }
                
        }
    }
}

struct PurchaseInProgressView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseInProgressView(status: "Completing Purchase...")
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
