pwd=$(pwd)
source "$pwd/.maestro/run_ui_tests.sh" .maestro/browser_features/shared_web_tests.yaml
app_dir=$(xcrun simctl get_app_container booted $app_bundle data)

echo "ℹ️ Running shared web tests"

echo "Ensure runner results were collected"
runner_results_path="$app_dir/Documents/Downloads/runner-results.json"
if [ ! -f "$runner_results_path" ]; then
    echo "‼️ No runner results found at $runner_results_path"
    exit 1
fi
echo "✅ Found runner results at $runner_results_path"
tail -n 1 "$runner_results_path"

echo "ℹ️ Parsing runner results"
runner_results=$(cat "$runner_results_path")
if [ -z "$runner_results" ]; then
    echo "‼️ No runner results found"
    exit 1
fi
