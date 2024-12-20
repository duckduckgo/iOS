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

class AutomationServer {
    let listener: NWListener
    let main: MainViewController

    init(main: MainViewController) {
        self.main = main
        listener = try! NWListener(using: .tcp, on: 8786)
        listener.newConnectionHandler = handleConnection
        // listener.start(queue: .global())
        listener.start(queue: .main)
    }
    
    func receive(from connection: NWConnection) {
        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: connection.maximumDatagramSize
        ) { content, _, isComplete, error in
            
            // if isLoading delay
            if (self.main.currentTab?.isLoading ?? false) {
                // wait for 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.receive(from: connection)
                }
            }

            func getQueryStringParameter(url: String, param: String) -> String? {
              guard let url = URLComponents(string: url) else { return nil }
              return url.queryItems?.first(where: { $0.name == param })?.value
            }
            
            if let error {
                print("Error: \(error)")
            } else if let content {
                print("Received request!")
                let stringContent = String(decoding: content, as: UTF8.self)
                print(String(data: content, encoding: .utf8)!)
                // Get url parameter from path
                // GET / HTTP/1.1
                if #available(iOS 16.0, *) {
                    let path = /^(GET|POST) (\/[^ ]*) HTTP/
                    if let match = stringContent.firstMatch(of: path) {
                        print("Path: \(match.2)")
                        // Convert the path into a URL object
                        let url = URL(string: String(match.2))!
                        if url.path == "/navigate" {
                            let navigateUrlString = getQueryStringParameter(url: String(match.2), param: "url") ?? ""
                            let navigateUrl = URL(string: navigateUrlString)!
                            self.main.navigateTo(url: navigateUrl)
                            self.respond(on: connection, response: "done")
                        } else if url.path == "/execute" {
                            let script = getQueryStringParameter(url: String(match.2), param: "script") ?? ""
                            var args: [String: String] = [:]
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
                            self.executeScript(script, args: args, on: connection)
                        } else if url.path == "/getUrl" {
                            self.respond(on: connection, response: self.main.currentUrl() ?? "")
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

            if !isComplete {
                self.receive(from: connection)
            }
        }
    }

    func executeScript(_ script: String,  args: [String: Any], on connection: NWConnection) {
        main.executeScript(script, args: args) { result in
            do {
                switch result {
                case .failure(let error):
                    self.respond(on: connection, response: "{\"error\": \"\(error)\"}");
                    return
                case .success(let value):
                    var valueString: String = ""
                    if let stringValue = value as? String {
                        valueString = stringValue
                    }
                    self.respond(on: connection, response: valueString)
                    break
                }
            } catch {
                self.respond(on: connection, response: "{\"error\": \"\(error)\"}")
            }
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
                            print("Error sending response: \(error)")
                        }
                        connection.cancel()
                    })
                )
            }
        } catch {
            Swift.print("Got error encoding JSON: \(error)")
        }
    }
    
    func handleConnection(_ connection: NWConnection) {
        //connection.start(queue: .global())
        connection.start(queue: .main)
        self.receive(from: connection)
    }
}
