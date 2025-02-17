//
//  AutomationServer.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

extension Logger {
    static var automationServer = { Logger(subsystem: Bundle.main.bundleIdentifier ?? "DuckDuckGo", category: "Automation Server") }()
}


final class AutomationServer {
    let listener: NWListener
    let main: MainViewController

    init(main: MainViewController, port: Int?) {
        var port = port ?? 8786
        self.main = main
        Logger.automationServer.info("Starting automation server on port \(port)")
        do {
            listener = try NWListener(using: .tcp, on: NWEndpoint.Port(integerLiteral: UInt16(port)))
        } catch {
            Logger.automationServer.error("Failed to start listener: \(error)")
            fatalError("Failed to start automation listener: \(error)")
        }
        listener.newConnectionHandler = handleConnection
        listener.start(queue: .main)
        // Output server started
        Logger.automationServer.info("Automation server started on port \(port)")
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
                print("Connection is no longer valid \(connection.state) \(String(describing: error)) \(String(describing: content)).")
                return
            default:
                print("Connection is in state \(connection.state).")
                return
            }
            Logger.automationServer.info("Received request! \(String(describing: content)) \(isComplete) \(String(describing: error))")

            if let error {
                Logger.automationServer.error("Error: \(error)")
                return
            }

            if let content {
                Logger.automationServer.info("Handling content")
                Task {
                    await self.processContentWhenReady(connection: connection, content: content)
                }
            }

            if !isComplete {
                Logger.automationServer.info("Handling not complete")
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
        Logger.automationServer.info("Handling content")
        self.handleConnection(connection, content)
    }
    
    func getQueryStringParameter(url: URLComponents, param: String) -> String? {
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

    @MainActor
    func handleConnection(_ connection: NWConnection, _ content: Data) {
        Logger.automationServer.info("Handling request!")
        let stringContent = String(decoding: content, as: UTF8.self)
        // Log first line of string:
        if let firstLine = stringContent.components(separatedBy: CharacterSet.newlines).first {
            Logger.automationServer.info("First line: \(firstLine)")
        }

        // Ensure support for regex
        guard #available(iOS 16.0, *) else {
            self.respondError(on: connection, error: "Unsupported iOS version")
            return
        }

        // Get url parameter from path
        // GET / HTTP/1.1
        let path = /^(GET|POST) (\/[^ ]*) HTTP/
        guard let match = stringContent.firstMatch(of: path) else {
            self.respondError(on: connection, error: "Unknown method")
            return
        }
        Logger.automationServer.info("Path: \(match.2)")
        // Convert the path into a URL object
        guard let url = URLComponents(string: String(match.2)) else {
            Logger.automationServer.error("Invalid URL: \(match.2)")
            return // Or handle the error appropriately
        }
        switch url.path {
        case "/navigate":
            self.navigate(on: connection, url: url)
        case "/execute":
            self.execute(on: connection, url: url)
        case "/getUrl":
            let currentUrl = self.main.currentTab?.webView.url?.absoluteString
            self.respond(on: connection, response: currentUrl ?? "")
        case "/getWindowHandles":
            self.getWindowHandles(on: connection, url: url)
        case "/closeWindow":
            self.closeWindow(on: connection, url: url)
        case "/switchToWindow":
            self.switchToWindow(on: connection, url: url)
        case "/newWindow":
            self.newWindow(on: connection, url: url)
        case "/getWindowHandle":
            self.getWindowHandle(on: connection, url: url)
        default:
            self.respondError(on: connection, error: "unknown")
        }
    }

    @MainActor
    func navigate(on connection: NWConnection, url: URLComponents) {
        let navigateUrlString = getQueryStringParameter(url: url, param: "url") ?? ""
        let navigateUrl = URL(string: navigateUrlString)!
        self.main.loadUrl(navigateUrl)
        self.respond(on: connection, response: "done")
    }

    @MainActor
    func execute(on connection: NWConnection, url: URLComponents) {
        let script = getQueryStringParameter(url: url, param: "script") ?? ""
        var args: [String: String] = [:]
        // json decode args if present
        if let argsString = getQueryStringParameter(url: url, param: "args") {
            guard let argsData = argsString.data(using: .utf8) else {
                self.respondError(on: connection, error: "Unable to decode args")
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                args = try jsonDecoder.decode([String: String].self, from: argsData)
            } catch {
                self.respondError(on: connection, error: error.localizedDescription)
                return
            }
        }
        Task {
            await self.executeScript(script, args: args, on: connection)
        }
    }

    @MainActor
    func getWindowHandle(on connection: NWConnection, url: URLComponents) {
        let handle = self.main.currentTab
        guard let handle else {
            self.respondError(on: connection, error: "no window")
            return
        }
        self.respond(on: connection, response: handle.tabModel.uid)
    }

    @MainActor
    func getWindowHandles(on connection: NWConnection, url: URLComponents) {
        let handles = self.main.tabManager.model.tabs.map({ tab in
            let tabView = self.main.tabManager.controller(for: tab)!
            return tabView.tabModel.uid
        })

        if let jsonData = try? JSONEncoder().encode(handles),
           let jsonString = String(data: jsonData, encoding: .utf8) {
           self.respond(on: connection, response: jsonString)
        } else {
            // Handle JSON encoding failure
            self.respondError(on: connection, error: "Failed to encode response")
        }
    }

    @MainActor
    func closeWindow(on connection: NWConnection, url: URLComponents) {
        self.main.closeTab(self.main.currentTab!.tabModel)
        self.respond(on: connection, response: "{\"success\":true}")
    }

    @MainActor
    func switchToWindow(on connection: NWConnection, url: URLComponents) {
        if let handleString = getQueryStringParameter(url: url, param: "handle") {
            Logger.automationServer.info("Switch to window \(handleString)")
            let tabToSelect: TabViewController? = nil
            if let tabIndex = self.main.tabManager.model.tabs.firstIndex(where: { tab in
                guard let tabView = self.main.tabManager.controller(for: tab) else {
                    return false
                }
                return tabView.tabModel.uid == handleString
            }) {
                Logger.automationServer.info("found tab \(tabIndex)")
                self.main.tabManager.select(tabAt: tabIndex)
                self.respond(on: connection, response: "{\"success\":true}")
            } else {
                self.respondError(on: connection, error: "Invalid window handle")
            }
        } else {
            self.respondError(on: connection, error: "Invalid window handle")
        }
    }

    @MainActor
    func newWindow(on connection: NWConnection, url: URLComponents) {
        self.main.newTab()
        let handle = self.main.tabManager.current(createIfNeeded: true)
        guard let handle else {
            self.respondError(on: connection, error: "no window")
            return
        }
        // Response {handle: "", type: "tab"}
        let response: [String: String] = ["handle": handle.tabModel.uid, "type": "tab"]
        if let jsonData = try? JSONEncoder().encode(response),
        let jsonString = String(data: jsonData, encoding: .utf8) {
            self.respond(on: connection, response: jsonString)
        } else {
            self.respondError(on: connection, error: "Failed to encode response")
        }
    }

    func respondError(on connection: NWConnection, error: String) {
        self.respond(on: connection, response: "{\"error\": \"\(error)\"}")
    }

    func executeScript(_ script: String, args: [String: Any], on connection: NWConnection) async {
        Logger.automationServer.info("Going to execute script: \(script)")
        let result = await main.executeScript(script, args: args)
        Logger.automationServer.info("Have result to execute script: \(String(describing: result))")
        guard let result else {
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
                Logger.automationServer.info("Have success value to execute script: \(String(describing: value))")
                
                // Serialize the value to JSON if possible
                if value == nil {
                    jsonString = "{}"
                } else if JSONSerialization.isValidJSONObject(value) {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted])
                        jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
                    } catch {
                        jsonString = "{\"error\": \"Failed to serialize value: \(error.localizedDescription)\"}"
                    }
                } else {
                    Logger.automationServer.info("Have value that can't be encoded: \(String(describing: value))")
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
                            Logger.automationServer.error("Error sending response: \(error)")
                        }
                        connection.cancel()
                    })
                )
            }
        } catch {
            Logger.automationServer.error("Got error encoding JSON: \(error)")
        }
    }
    
    @MainActor
    func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .main)
        self.receive(from: connection)
    }
}
