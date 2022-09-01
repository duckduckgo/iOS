import {warn, danger} from "danger";

export default async () => {  
    // Warn when there is a big PR
    if (danger.github.pr.additions + danger.github.pr.deletions > 500) {
        warn("PR has more than 500 lines of code changing. Consider splitting into smaller PRs if possible.");
    }

    // Warn when link to internal task is missing
    for (let bodyLine of danger.github.pr.body.toLowerCase().split(/\n/)) {
        if (bodyLine.includes("task/issue url:") && (!bodyLine.includes("app.asana.com"))) {
            warn("Please, don't forget to add a link to the internal task");
        }
    }
};
