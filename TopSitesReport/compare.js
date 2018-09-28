
// setup

let fs = require('fs');

// Compares the specified top site report with the specified CSV

try {
    main();
} catch (error) {
    console.log(`Error: ${error.message}`);
    console.log("USAGE: node compare <json file> <csv file>");
}

function main() {

    if (process.argv.length != 4) {
        throw Error("Not enough arguments");
    }

    let jsonFile = process.argv[2];
    let csvFile = process.argv[3];

    let json = JSON.parse(fs.readFileSync(jsonFile, 'utf8'));
    let csvLines = readSortedCSVFile(csvFile);

    console.log("url, result, site https score, privacy score, site tracker score, site grade score, expected site grade, actual site grade, expected enhanced grade, actual enhanced grade");

    for (var i = 0; i < json.length; i++) {
        let report = json[i];

        if (report.failed) {
            console.log(`${report.url},failed`);
            continue;
        }

        let row = csvLines.find(o => o.startsWith(report.url));
        if (!row) {
            console.log(`${report.url},missing`);
            continue;
        }

        let record = row.split(",");
        let siteGrade = record[8];
        let enhancedGrade = record[9];

        let flag = (siteGrade != report.scores.site.grade) ? "👎" : "👍";

        console.log(`${report.url},${flag},${report.scores.site.httpsScore},${report.scores.site.privacyScore},${report.scores.site.trackerScore},${report.scores.site.score},${siteGrade},${report.scores.site.grade},${enhancedGrade},${report.scores.enhanced.grade}`);
    }

}

function readSortedCSVFile(named) {
    return fs.readFileSync(named, 'utf8')
        .split("\n") // create the array
        .slice(1) // drop the first element (the column titles)
        .sort((s1, s2) => { return s1.localeCompare(s2); }) // sort it alpha numerically
}