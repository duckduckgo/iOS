//
//  SpeechRecognizerProtocol.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import Foundation

protocol SpeechRecognizerProtocol {
    var isAvailable: Bool { get }
    static func requestMicAccess(withHandler handler: @escaping (Bool) -> Void)
    func getVolumeLevel(from channelData: UnsafeMutablePointer<Float>) -> Float
    func stopRecording()

    func startRecording(resultHandler: @escaping (_ text: String?,
                                                  _ error: Error?, _
                                                  speechDidFinish: Bool) -> Void,
                        volumeCallback: @escaping (_ volume: Float) -> Void)
}
