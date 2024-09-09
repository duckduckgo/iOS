//
//  mobile_segments_test_cases.js
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

/*
This is a debugging tool.  If a test case fails then you can use this to dump the specific 
test case and compare it with the reference implementation's output.

usage: node mobile_segments_test_cases.js <test-case-index>
*/

const fs = require('fs');
const path = './mobile_segments_test_cases.json';

try {
    const data = fs.readFileSync(path, 'utf8');
    const jsonData = JSON.parse(data);

    const args = process.argv.slice(2); 
    const test = +args[0];

    console.log(JSON.stringify(jsonData[test]));
} catch (err) {
    console.error('Error reading the file:', err);
}
