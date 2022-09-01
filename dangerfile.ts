import {warn, danger} from "danger";

export default async () => {  
    // Warn when there is a big PR
    if (danger.github.pr.additions + danger.github.pr.deletions > 500) {
        warn("PR has more than 500 lines of code changing. Consider splitting into smaller PRs if possible.");
    }
};
