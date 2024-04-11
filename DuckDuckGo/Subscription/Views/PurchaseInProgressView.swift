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
    enum DesignConstants {
        static let coverOpacity = 0.6
        static let cornerRadius = 12.0
        static let shadowRadius = 10.0
        static let lightShadowColor = Color.gray50
        static let darkShadowColor = Color.gray95
        static let spinnerScale = 2.0
        static let internalZStackWidth = 220.0
        static let horizontalPadding = 20.0
        static let verticalPadding = 100.0
    }
    
    @State private var viewHeight: CGFloat = 0 // State to store the height of the VStack

    var body: some View {
        ZStack {
            Color(designSystemColor: .background)
                .opacity(Self.DesignConstants.coverOpacity)
                .edgesIgnoringSafeArea(.all)
                .disabled(true)
                        
            ZStack {
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color(designSystemColor: .background))
                    .frame(width: DesignConstants.internalZStackWidth, height: viewHeight) // Use the dynamic height
                    .shadow(color: colorScheme == .dark ? DesignConstants.darkShadowColor : DesignConstants.lightShadowColor,
                            radius: DesignConstants.shadowRadius)
                
                VStack {
                    SwiftUI.ProgressView()
                        .scaleEffect(DesignConstants.spinnerScale)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(designSystemColor: DesignSystemColor.icons)))
                        .padding(.bottom, 18)
                        .padding(.top, 10)
                    
                    Text(status)
                        .daxSubheadRegular()
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                        .frame(width: DesignConstants.internalZStackWidth - 2 * DesignConstants.horizontalPadding)
                        .multilineTextAlignment(.center)
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear {
                                viewHeight = geometry.size.height + DesignConstants.verticalPadding
                            }
                        })
                }
                .frame(width: DesignConstants.internalZStackWidth)
            }
        }
    }
}

// Preference key to store the height of the content
struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// Commented out because CI fails if a SwiftUI preview is enabled https://app.asana.com/0/414709148257752/1206774081310425/f
// struct PurchaseInProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        PurchaseInProgressView(status: "Completing Purchase... ")
//            .previewLayout(.sizeThatFits)
//            .padding()
//    }
// }
