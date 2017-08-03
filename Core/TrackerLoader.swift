//
//  ContentBlocker.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

public class TrackerLoader {
    
    private struct FileConstants {
        static let name = "disconnectmetrackers"
        static let ext = "json"
    }
    
    private let parser = DisconnectMeTrackersParser()
    public private(set) var trackers = [Tracker]()
    
    public init() {
        do {
            trackers = try loadTrackers()
        } catch {
            Logger.log(text: "Could not load tracker entries \(error)")
        }
    }
    
    private func loadTrackers() throws -> [Tracker] {
        let fileLoader = FileLoader()
        let data = try fileLoader.load(name: FileConstants.name, ext: FileConstants.ext)
        return try parser.convert(fromJsonData: data)
    }
}

