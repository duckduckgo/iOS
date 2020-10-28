//
//  EmailManager.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import WebKit

public class EmailManager {
    
    public var token: String?
    public var username: String?
    public var alias: String?
    
    var isSignedIn: Bool {
        return token != nil && username != nil
    }

    func storeToken(_ token: String, username: String) {
        //TODO actual storage
        self.token = token
        self.username = username
        
        fetchAlias()
    }
    
    private static let apiAddress = URL(string: "https://quackdev.duckduckgo.com/api/email/addresses")!

    private var headers: HTTPHeaders {
        guard let token = token else {
            return [:]
        }
        return ["Authorization": "Bearer " + token]
    }
    
    struct EmailResponse: Decodable {
        let address: String
    }
        
    func fetchAlias() {
        APIRequest.request(url: EmailManager.apiAddress, method: .post, headers: headers) { response, error in
            guard let data = response?.data, error == nil else {
                print("error fetching alias")
                return
            }
            do {
                let decoder = JSONDecoder()
                self.alias = try decoder.decode(EmailResponse.self, from: data).address
                print(self.alias)
            } catch {
                print("invalid alias response")
                return
            }
        }
    }
}
