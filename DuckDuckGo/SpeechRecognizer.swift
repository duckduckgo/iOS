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

protocol SpeechRecognizerDelegate: AnyObject {
    func speechRecognizer(_ speechRecognizer: SpeechRecognizer, availabilityDidChange available: Bool)
}

final class SpeechRecognizer: NSObject, SpeechRecognizerProtocol {
    weak var delegate: SpeechRecognizerDelegate?
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer?
    private let operationQueue: OperationQueue
    
    private(set) var isAvailable = false {
        didSet {
            delegate?.speechRecognizer(self, availabilityDidChange: isAvailable)
        }
    }
    
    override init() {
        operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInteractive
        
        speechRecognizer = SFSpeechRecognizer()
        speechRecognizer?.queue = operationQueue
        
        super.init()
        
        speechRecognizer?.delegate = self
        updateAvailabilityFlag()
    }
    
    private func updateAvailabilityFlag() {
        // https://app.asana.com/0/0/1201701558793614/1201934552312834
        
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            self.isAvailable = self.supportsOnDeviceRecognition && (self.speechRecognizer?.isAvailable ?? false)
        }
    }
    
    private var supportsOnDeviceRecognition: Bool {
        return speechRecognizer?.supportsOnDeviceRecognition ?? false
    }
    
    static var recordPermission: AVAudioSession.RecordPermission {
        return AVAudioSession.sharedInstance().recordPermission
    }
    
    static func requestMicAccess(withHandler handler: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { authorized in
            DispatchQueue.main.async {
                handler(authorized)
            }
        }
    }
    
    private func convertArr<T>(count: Int, data: UnsafePointer<T>) -> [T] {
        let buffer = UnsafeBufferPointer(start: data, count: count)
        return Array(buffer)
    }
    
    func getVolumeLevel(from channelData: UnsafeMutablePointer<Float>) -> Float {
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: 1024))
        guard channelDataArray.count != 0 else { return 0 }
        
        let silenceThreshold: Float = 0.0030
        let loudThreshold: Float = 0.07
        
        let sumChannelData = channelDataArray.reduce(0) { $0 + abs($1) }
        var channelAverage = sumChannelData / Float(channelDataArray.count)
        channelAverage = min(channelAverage, loudThreshold)
        channelAverage = max(channelAverage, silenceThreshold)

        let normalized = (channelAverage - silenceThreshold) / (loudThreshold - silenceThreshold)
        return normalized
    }
    
    func startRecording(resultHandler: @escaping (_ text: String?,
                                                  _ error: Error?,
                                                  _ speechDidFinish: Bool) -> Void,
                        volumeCallback: @escaping (_ volume: Float) -> Void) {
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        audioEngine = AVAudioEngine()

        guard let recognitionRequest = self.recognitionRequest,
        let audioEngine = audioEngine else {
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
                guard let recognitionTask = self?.recognitionTask, !recognitionTask.isCancelled else {
                    return
                }
                
                var isFinal = false
                var transcription: String?
                
                if let result = result {
                    // speechRecognitionMetadata is always returned when the system assumes the user stopped speaking
                    // https://app.asana.com/0/0/1201278924898595
                    isFinal = result.isFinal || result.speechRecognitionMetadata != nil
                    transcription = result.bestTranscription.formattedString
                }
                
                resultHandler(transcription, error, isFinal)

                if error != nil || isFinal {
                    inputNode.removeTap(onBus: 0)
                    self?.stopRecording()
                }
            }
        } catch {
            self.reset()
            resultHandler(nil, error, true)
        }
    }
    
    func stopRecording() {
        reset()
    }
    
    private func reset() {
        try? AVAudioSession.sharedInstance().setActive(false)
        recognitionTask?.cancel()
        audioEngine?.stop()
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    deinit {
        reset()
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        isAvailable = supportsOnDeviceRecognition && available
    }
}
