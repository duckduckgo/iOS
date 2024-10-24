//
//  VideoPlayerView.swift
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
import AVFoundation
import AVKit

struct VideoPlayerView: View {

    @StateObject private var model: VideoPlayerViewModel

    private var isPlaying: Binding <Bool>

    init(
        url: URL,
        isPlaying: Binding<Bool> = .constant(true),
        hidePlayerControls: Bool = true,
        loopVideo: Bool = false
    ) {
         let playerModel = VideoPlayerViewModel(
            url: url,
            hidePlayerControls: hidePlayerControls,
            loopVideo: loopVideo
         )
        self.isPlaying = isPlaying
        _model = StateObject(wrappedValue: playerModel)
    }

    var body: some View {
        VideoPlayer(player: model.player)
            .disabled(model.hidePlayerControls) // Disable player controls
            .onChange(of: isPlaying.wrappedValue) { newValue in
                if newValue {
                    model.play()
                } else {
                    model.pause()
                }
            }
    }

}

struct VideoPlayerView_Previews: PreviewProvider {

    struct VideoPlayerPreview: View {
        let videoURL = Bundle.main.url(forResource: "add-to-dock-demo", withExtension: "mp4")!
        @State var isPlaying = false

        var body: some View {
            VideoPlayerView(
                url: videoURL,
                isPlaying: $isPlaying,
                loopVideo: true
            )
            .onAppear(perform: {
                isPlaying = true
            })
            .aspectRatio(contentMode: .fill)
            .frame(maxHeight: 234)
        }
    }

    static var previews: some View {
        VideoPlayerPreview()
            .preferredColorScheme(.light)
   }
}
