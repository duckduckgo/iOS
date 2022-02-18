//
//  DirectoryMonitor.swift
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

protocol DirectoryMonitorDelegate: AnyObject {
    func didChange(directoryMonitor: DirectoryMonitor, added: Set<URL>, removed: Set<URL>)
}

class DirectoryMonitor {
    fileprivate enum State {
        case stopped
        case started(dirSource: DispatchSourceFileSystemObject)
        case debounce(dirSource: DispatchSourceFileSystemObject, timer: Timer)
    }

    private var state: State = .stopped
    weak var delegate: DirectoryMonitorDelegate?
    
    let directory: URL
    private var directoryContents: Set<URL>

    init(directory: URL) {
        print("DirectoryMonitor init for \(directory)")
        self.directory = directory
        self.directoryContents = []
    }
    
    deinit {
        print("DirectoryMonitor deinit")
    }

    private static func source(for directory: URL) throws -> DispatchSourceFileSystemObject {
        let dirFD = open(directory.path, O_EVTONLY)
        guard dirFD >= 0 else {
            let err = errno
            throw NSError(domain: POSIXError.errorDomain, code: Int(err), userInfo: nil)
        }
        return DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: dirFD,
            eventMask: [.write],
            queue: DispatchQueue.main
        )
    }
    
    private static func contents(of directory: URL) -> Set<URL> {
        let contents = (try? FileManager.default.contentsOfDirectory(at: directory,
                                                                    includingPropertiesForKeys: nil,
                                                                    options: [.skipsHiddenFiles])) ?? []
        return Set(contents)
    }

    func start() throws {
        print("- start()")
        guard case .stopped = state else { fatalError() }
        
        directoryContents = DirectoryMonitor.contents(of: directory)
        
        let dirSource = try DirectoryMonitor.source(for: directory)
        dirSource.setEventHandler {
            self.kqueueDidFire()
        }
        dirSource.resume()

        let nowTimer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false) { _ in
            self.debounceTimerDidFire()
        }
        
        state = .debounce(dirSource: dirSource, timer: nowTimer)
    }
    
    private func kqueueDidFire() {
        print("- kqueueDidFire()")
        switch state {
        case .started(let dirSource):
            let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                self.debounceTimerDidFire()
            }
            state = .debounce(dirSource: dirSource, timer: timer)
        case .debounce(_, let timer):
            timer.fireDate = Date(timeIntervalSinceNow: 0.2)
            // Stay in the `.debounce` state.
        case .stopped:
            // This can happen if the read source fired and enqueued a block on the
            // main queue but, before the main queue got to service that block, someone
            // called `stop()`.  The correct response is to just do nothing.
            break
        }
    }

    private func debounceTimerDidFire() {
        print("- debounceTimerDidFire()")
        guard case .debounce(let dirSource, let timer) = state else { fatalError() }
        
        timer.invalidate()
        state = .started(dirSource: dirSource)

        let newContents = DirectoryMonitor.contents(of: directory)
        
        let itemsAdded = newContents.subtracting(directoryContents)
        let itemsRemoved = directoryContents.subtracting(newContents)
        
        directoryContents = newContents

        if !itemsAdded.isEmpty || !itemsRemoved.isEmpty {
            delegate?.didChange(directoryMonitor: self, added: itemsAdded, removed: itemsRemoved)
        }
    }

    func stop() {
        print("- stop()")
        if !state.isRunning { fatalError() }
        // I don't need an implementation for this in the current project so
        // I'm just leaving it out for the moment.
//        fatalError()
        state = .stopped
    }
}

fileprivate extension DirectoryMonitor.State {
    var isRunning: Bool {
        switch self {
        case .stopped:  return false
        case .started:  return true
        case .debounce: return true
        }
    }
}
