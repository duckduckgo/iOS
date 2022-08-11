//
//  DownloadSession.swift
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

import Foundation

protocol DownloadSessionDelegate: AnyObject {

    func downloadSession(_ session: DownloadSession,
                         didWriteData bytesWritten: Int64,
                         totalBytesWritten: Int64,
                         totalBytesExpectedToWrite: Int64)

    func downloadSession(_ session: DownloadSession, didFinishWith result: Result<URL, Error>)

}

protocol DownloadSession: AnyObject {

    var isRunning: Bool { get }
    var delegate: DownloadSessionDelegate? { get set }

    func start()
    func cancel()

}
