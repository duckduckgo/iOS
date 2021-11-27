//
//  navigatorsharepatch.js
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

(function () {
    function isSensitiveFile (filename) {
        let uriObj = null
        try {
            uriObj = new URL(filename)
        } catch (e) {
            return true
        }

        return uriObj.protocol === 'file:'
    }

    const oldShare = Navigator.prototype.share
    Navigator.prototype.share = function (data) {
        if (data.url && isSensitiveFile(data.url)) {
            return Promise.reject(new Error('System file sharing is not supported in this browser'))
        } else if (data.files) {
            for (const i in data.files) {
                if (isSensitiveFile(data.files[i])) {
                    return Promise.reject(new Error('System file sharing is not supported in this browser'))
                }
            }
        }

        return oldShare.call(this, data)
    }
})()
