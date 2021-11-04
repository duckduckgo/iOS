//
//  compare.js
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

// Utility for comparing the top sites report with our CSV output.

// setup

const fs = require('fs')

// Compares the specified top site report with the specified CSV

try {
    main()
} catch (error) {
    console.log(`Error: ${error.message}`)
    console.log('USAGE: node compare <json file> <csv file>')
}

function main () {
    if (process.argv.length !== 4) {
        throw Error('Not enough arguments')
    }

    const jsonFile = process.argv[2]
    const csvFile = process.argv[3]

    const json = JSON.parse(fs.readFileSync(jsonFile, 'utf8'))
    const csvLines = readSortedCSVFile(csvFile)

    console.log('url, result, site https score, privacy score, site tracker score, site grade score, expected site grade, actual site grade, expected enhanced grade, actual enhanced grade')

    for (let i = 0; i < json.length; i++) {
        const report = json[i]

        if (report.failed) {
            console.log(`${report.url},failed`)
            continue
        }

        const row = csvLines.find(o => o.startsWith(report.url))
        if (!row) {
            console.log(`${report.url},missing`)
            continue
        }

        const record = row.split(',')
        const siteGrade = record[8]
        const enhancedGrade = record[9]

        const flag = (siteGrade !== report.scores.site.grade) ? '👎' : '👍'

        console.log(`${report.url},${flag},${report.scores.site.httpsScore},${report.scores.site.privacyScore},${report.scores.site.trackerScore},${report.scores.site.score},${siteGrade},${report.scores.site.grade},${enhancedGrade},${report.scores.enhanced.grade}`)
    }
}

function readSortedCSVFile (named) {
    return fs.readFileSync(named, 'utf8')
        .split('\n') // create the array
        .slice(1) // drop the first element (the column titles)
        .sort((s1, s2) => { return s1.localeCompare(s2) }) // sort it alpha numerically
}
