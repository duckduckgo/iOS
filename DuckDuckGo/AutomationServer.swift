//
//  AppDelegate.swift
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
import Foundation
import Network

/*
// WebDriver BiDi automation server
class AutomationServerBidi {
    let listener: NWListener
    let main: MainViewController
    
    init(main: MainViewController, port: Int?) {
        self.main = main
        listener = try! NWListener(using: .tcp, on: NWEndpoint.Port(integerLiteral: UInt16(port ?? 8786)))
        listener.newConnectionHandler = handleConnection
        // listener.start(queue: .global())
        listener.start(queue: .main)
    }
}
*/


struct Log: TextOutputStream {

    func write(_ string: String) {
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.txt")
        if let handle = try? FileHandle(forWritingTo: log) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
    }
}

class AutomationServer {
    let listener: NWListener
    let main: MainViewController
    var logger: Log

    init(main: MainViewController, port: Int?) {
        self.logger = Log()

        self.main = main
        listener = try! NWListener(using: .tcp, on: NWEndpoint.Port(integerLiteral: UInt16(port ?? 8786)))
        listener.newConnectionHandler = handleConnection
        // listener.start(queue: .global())
        listener.start(queue: .main)
    }
    
    @MainActor
    func receive(from connection: NWConnection) {
        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: connection.maximumDatagramSize
        ) { content, _, isComplete, error in
            switch connection.state {
            case .ready:
                break // Connection is valid, continue
            case .cancelled, .failed:
                print("Connection is no longer valid \(connection.state) \(error) \(content).", to: &self.logger)
                return
            default:
                print("Connection is in state \(connection.state).", to: &self.logger)
                return
            }
            print("Received request! \(content) \(isComplete) \(error)", to: &self.logger)
            
            if let error {
                print("Error: \(error)", to: &self.logger)
                return
            }
            
            if let content {
                print("Handling content", to: &self.logger)
                Task {
                    await self.processContentWhenReady(connection: connection, content: content)
                }
            }

            if !isComplete {
                print("Handling not complete", to: &self.logger)
                self.receive(from: connection)
            }
        }
    }
    
    @MainActor
    func processContentWhenReady(connection: NWConnection, content: Data) async {
        // Check if loading
        while self.main.currentTab?.isLoading ?? false {
            print("Still loading, waiting...")
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        }

        // Proceed when loading is complete
        print("Handling content", to: &self.logger)
        self.handleConnection(connection, content)
    }
    
    @MainActor
    func handleConnection(_ connection: NWConnection, _ content: Data) {
        print("Handling request!", to: &self.logger)
        let stringContent = String(decoding: content, as: UTF8.self)
        // Log first line of string:
        if let firstLine = stringContent.components(separatedBy: CharacterSet.newlines).first {
            print(firstLine, to: &self.logger)
        }
        
        func getQueryStringParameter(url: String, param: String) -> String? {
          guard let url = URLComponents(string: url) else { return nil }
          return url.queryItems?.first(where: { $0.name == param })?.value
        }
        // Get url parameter from path
        // GET / HTTP/1.1
        if #available(iOS 16.0, *) {
            let path = /^(GET|POST) (\/[^ ]*) HTTP/
            if let match = stringContent.firstMatch(of: path) {
                print("Path: \(match.2)", to: &logger)
                // Convert the path into a URL object
                guard let url = URL(string: String(match.2)) else {
                    print("Invalid URL: \(match.2)")
                    return // Or handle the error appropriately
                }
                if url.path == "/navigate" {
                    let navigateUrlString = getQueryStringParameter(url: String(match.2), param: "url") ?? ""
                    let navigateUrl = URL(string: navigateUrlString)!
                    self.main.navigateTo(url: navigateUrl)
                    self.respond(on: connection, response: "done")
                } else if url.path == "/execute" {
                    let script = getQueryStringParameter(url: String(match.2), param: "script") ?? ""
                    var args: [String: String] = [:]
                    print("Script: \(script)", to: &self.logger)
                    // json decode args
                    if let argsString = getQueryStringParameter(url: String(match.2), param: "args") {
                        if let argsData = argsString.data(using: .utf8) {
                            do {
                                let jsonDecoder = JSONDecoder()
                                args = try jsonDecoder.decode([String: String].self, from: argsData)
                            } catch {
                                self.respond(on: connection, response: "{\"error\": \"\(error.localizedDescription)\", \"args\": \"\(argsString)\"}")
                            }
                        } else {
                            self.respond(on: connection, response: "{\"error\": \"Unable to decode args\"}")
                        }
                    }
                    Task {
                        await self.executeScript(script, args: args, on: connection)
                    }
                } else if url.path == "/getUrl" {
                    self.respond(on: connection, response: self.main.currentUrl() ?? "")
                } else if url.path == "/getWindowHandles" {
                    // TODO get all tabs
                    let handle = self.main.tabManager.current(createIfNeeded: true)
                    guard let handle else {
                        self.respond(on: connection, response: "no window")
                        return
                    }
                    
                    let handles = self.main.tabManager.model.tabs.map({ tab in
                        let tabView = self.main.tabManager.controller(for: tab)!
                        return String(UInt(bitPattern: ObjectIdentifier(tabView)))
                    })
                    
                    if let jsonData = try? JSONEncoder().encode(handles),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        self.respond(on: connection, response: jsonString)
                    } else {
                        // Handle JSON encoding failure
                        self.respond(on: connection, response: "{\"error\":\"Failed to encode response\"}")
                    }
                } else if url.path == "/closeWindow" {
                    self.main.closeTab(self.main.currentTab!.tabModel)
                    self.respond(on: connection, response: "{\"success\":true}")
                } else if url.path == "/switchToWindow" {
                    if let handleString = getQueryStringParameter(url: String(match.2), param: "handle") {
                        print("Switch to window \(handleString)", to: &logger)
                        let tabToSelect: TabViewController? = nil
                        if let tabIndex = self.main.tabManager.model.tabs.firstIndex(where: { tab in
                            guard let tabView = self.main.tabManager.controller(for: tab) else {
                                return false
                            }
                            return String(UInt(bitPattern: ObjectIdentifier(tabView))) == handleString
                        }) {
                            print("found tab \(tabIndex)", to: &logger)
                            self.main.tabManager.select(tabAt: tabIndex)
                            self.respond(on: connection, response: "{\"success\":true}")
                        } else {
                            self.respond(on: connection, response: "{\"error\":\"Invalid window handle\"}")
                        }
                    } else {
                        self.respond(on: connection, response: "{\"error\":\"Invalid window handle\"}")
                    }
                } else if url.path == "/newWindow" {
                    self.main.newTab()
                    let handle = self.main.tabManager.current(createIfNeeded: true)
                    guard let handle else {
                        self.respond(on: connection, response: "no window")
                        return
                    }
                    // Response {handle: "", type: "tab"}
                    let response: [String: String] = ["handle": String(UInt(bitPattern: ObjectIdentifier(handle))), "type": "tab"]
                    if let jsonData = try? JSONEncoder().encode(response),
                    let jsonString = String(data: jsonData, encoding: .utf8) {
                        self.respond(on: connection, response: jsonString)
                    } else {
                        self.respond(on: connection, response: "{\"error\":\"Failed to encode response\"}")
                    }
                } else if url.path == "/getWindowHandle" {
                    let handle = self.main.currentTab
                    guard let handle else {
                        self.respond(on: connection, response: "no window")
                        return
                    }
                    self.respond(on: connection, response: String(UInt(bitPattern: ObjectIdentifier(handle))))
                } else {
                    self.respond(on: connection, response: "unknown")
                }
            } else {
                self.respond(on: connection, response: "unknown method")
            }
        } else {
            self.respond(on: connection, response: "unhandled")
        }
    }

    func executeScript(_ script: String, args: [String: Any], on connection: NWConnection) async {
        print("Going to execute script: \(script)", to: &self.logger)
        var result = await main.executeScript(script, args: args)
        print("Have result to execute script: \(result)", to: &self.logger)
        guard var result else {
            return
        }
        do {
            switch result {
            case .failure(let error):
                self.respond(on: connection, response: "{\"error\": \"\(error)\"}")
            case .success(let value):
                var jsonString: String = ""
                
                // Try to encode the value to JSON
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                // Serialize the value to JSON if possible
                if JSONSerialization.isValidJSONObject(value) {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted])
                        jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
                    } catch {
                        jsonString = "{\"error\": \"Failed to serialize value: \(error.localizedDescription)\"}"
                    }
                } else {
                    jsonString = "{\"error\": \"Value is not a valid JSON object\"}"
                }
                
                // Send the response back with the JSON string
                self.respond(on: connection, response: jsonString)
            }
        } catch {
            self.respond(on: connection, response: "{\"error\": \"\(error)\"}")
        }
    }
    
    func respond(on connection: NWConnection, response: String? = nil) {
        do {
            if let response {
                struct Response: Codable {
                    var message: String
                }
                let responseHeader = """
                HTTP/1.1 200 OK
                Content-Type: application/json
                Connection: close
                
                """
                var valueString = ""
                if let stringValue = response as? String {
                    valueString = stringValue
                }
                let responseObject = Response(message: valueString)
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(responseObject)
                let responseString = String(data: data, encoding: .utf8) ?? ""
                let response = responseHeader + "\r\n" + responseString
                connection.send(
                    content: response.data(using: .utf8),
                    completion: .contentProcessed({ error in
                        if let error = error {
                            print("Error sending response: \(error)", to: &self.logger)
                        }
                        connection.cancel()
                    })
                )
            }
        } catch {
            print("Got error encoding JSON: \(error)", to: &logger)
        }
    }
    
    @MainActor
    func handleConnection(_ connection: NWConnection) {
        // connection.start(queue: .global())
        connection.start(queue: .main)
        self.receive(from: connection)
    }
}
