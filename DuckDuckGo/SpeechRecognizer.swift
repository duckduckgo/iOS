//
//  SpeechRecognizer.swift
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
import Speech
import Accelerate

class SpeechRecognizer: SpeechRecognizerProtocol {
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer()
    
    var isAvailable: Bool {
        //https://app.asana.com/0/1201011656765697/1201271104639596
        if #available(iOS 15.0, *) {
            return speechRecognizer?.isAvailable ?? false
        } else {
            return false
        }
    }
    
    var supportsOnDeviceRecognition: Bool {
        return speechRecognizer?.supportsOnDeviceRecognition ?? false
    }
    
    var isRunning: Bool {
        return audioEngine.isRunning
    }
    
    func requestMicAccess(withHandler handler: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { authorized in
            handler(authorized)
        }
    }
    
    private func convertArr<T>(count: Int, data: UnsafePointer<T>) -> [T] {

        let buffer = UnsafeBufferPointer(start: data, count: count)
        return Array(buffer)
    }
    
    func getVolumeLevel(from channelData: UnsafeMutablePointer<Float>) -> Float {
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: 1024))
        guard channelDataArray.count != 0 else { return 0 }
        
        let silenceThreshold: Float = 0.0010
        let shoutingThreshold: Float = 0.06
        
        let sumChannelData = channelDataArray.reduce(0) {$0 + abs($1)}
        var channelAverage = sumChannelData / Float(channelDataArray.count)
        channelAverage = min(channelAverage, shoutingThreshold)
        channelAverage = max(channelAverage, silenceThreshold)

        let normalized = (channelAverage - silenceThreshold) / (shoutingThreshold - silenceThreshold)
        return normalized
    }
    
    @available(iOS 15, *)
    func startRecording(resultHandler: @escaping (_ text: String?,
                                                  _ error: Error?,
                                                  _ speechDidFinished: Bool) -> Void,
                        volumeCallback: @escaping(_ volume: Float) -> Void) {
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = self.recognitionRequest else {
            resultHandler(nil, nil, true)
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = true

        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, _) in
                recognitionRequest.append(buffer)
                
                guard let channelData = buffer.floatChannelData?[0] else {
                    return
                }
                
                let volume = self.getVolumeLevel(from: channelData)
                volumeCallback(volume)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
                var isFinal = false
                if let result = result {
                    // speechRecognitionMetadata is always returned when the system assumes the user stopped speaking
                    isFinal = result.isFinal || result.speechRecognitionMetadata != nil
                    resultHandler(result.bestTranscription.formattedString, error, isFinal)
                }
                
                if error != nil || isFinal {
                    inputNode.removeTap(onBus: 0)
                    self?.stopRecording()
                    resultHandler(nil, error, isFinal)
                }
            }
        } catch {
            print("Error transcibing audio: " + error.localizedDescription)
            self.reset()
            resultHandler(nil, error, true)
        }
    }
    
    func stopRecording() {
        reset()
    }
    
    private func reset() {
        recognitionTask?.cancel()
        audioEngine.stop()
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    deinit {
        reset()
        print("\(SpeechRecognizer.self) deinit")
    }
}

protocol SpeechRecognizerProtocol {
    var isAvailable: Bool { get }
    var supportsOnDeviceRecognition: Bool { get }
    var isRunning: Bool { get }
    func requestMicAccess(withHandler handler: @escaping (Bool) -> Void)
    func getVolumeLevel(from channelData: UnsafeMutablePointer<Float>) -> Float
    func stopRecording()

    @available(iOS 15, *)
    func startRecording(resultHandler: @escaping (_ text: String?,
                                                  _ error: Error?, _
                                                  speechDidFinished: Bool) -> Void,
                        volumeCallback: @escaping (_ volume: Float) -> Void)
}
