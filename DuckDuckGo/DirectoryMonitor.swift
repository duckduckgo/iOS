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
    typealias FileDescriptor = Int32
    
    fileprivate enum State {
        case stopped
        case started(source: DispatchSourceFileSystemObject)
        case debounce(source: DispatchSourceFileSystemObject, timer: Timer)
    }
    
    private var state: State = .stopped
    weak var delegate: DirectoryMonitorDelegate?
    
    private let directory: URL
    private var directoryContents: Set<URL>
    
    init(directory: URL) {
        self.directory = directory
        self.directoryContents = []
    }
    
    private static func makeFileDescriptor(for directory: URL) throws -> FileDescriptor {
        let dirFD = open(directory.path, O_EVTONLY)
        guard dirFD >= 0 else {
            let err = errno
            throw NSError(domain: POSIXError.errorDomain, code: Int(err), userInfo: nil)
        }
        return dirFD
    }
    
    private static func makeSource(with fileDescriptor: FileDescriptor) -> DispatchSourceFileSystemObject {
        DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor,
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
        guard case .stopped = state else { fatalError("Should only start stopped state") }
        
        directoryContents = DirectoryMonitor.contents(of: directory)
        
        let fileDescriptor = try DirectoryMonitor.makeFileDescriptor(for: directory)
        let directorySource = DirectoryMonitor.makeSource(with: fileDescriptor)
        
        directorySource.setEventHandler {
            self.onDirectorySourceChangeEvent()
        }
        
        directorySource.setCancelHandler {
            close(fileDescriptor)
        }
        
        directorySource.resume()
        
        let nowTimer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false) { _ in
            self.debounceTimerDidFire()
        }
        
        state = .debounce(source: directorySource, timer: nowTimer)
    }
    
    private func onDirectorySourceChangeEvent() {
        switch state {
        case .started(let source):
            let delayedTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                self.debounceTimerDidFire()
            }
            state = .debounce(source: source, timer: delayedTimer)
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
        guard case .debounce(let source, let timer) = state else { fatalError("state should be .debounce") }
        
        timer.invalidate()
        state = .started(source: source)
        
        let newContents = DirectoryMonitor.contents(of: directory)
        
        let itemsAdded = newContents.subtracting(directoryContents)
        let itemsRemoved = directoryContents.subtracting(newContents)
        
        directoryContents = newContents
        
        if !itemsAdded.isEmpty || !itemsRemoved.isEmpty {
            delegate?.didChange(directoryMonitor: self, added: itemsAdded, removed: itemsRemoved)
        }
    }
    
    func stop() {
        switch state {
        case .started(let source):
            source.cancel()
        case .debounce(let source, let timer):
            timer.invalidate()
            source.cancel()
        case .stopped:
            break
        }
        
        state = .stopped
    }
}

private extension DirectoryMonitor.State {
    var isRunning: Bool {
        switch self {
        case .stopped:  return false
        case .started:  return true
        case .debounce: return true
        }
    }
}
