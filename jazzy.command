#!/bin/sh
set -eu
cd -- "$(dirname -- "$0")"

# Use the active Ruby's Jazzy gem so SourceKitten runs with the matching architecture.
if gem_bin=$(ruby -rrubygems -e 'print Gem.bindir' 2>/dev/null) && [ -x "$gem_bin/jazzy" ]; then
    jazzy_bin="$gem_bin/jazzy"
elif ! jazzy_bin=$(command -v jazzy); then
    printf '%s\n' 'Jazzy is required. Install Ruby, then run: ruby -S gem install jazzy' >&2
    exit 1
fi

# Keep the published docs until the site and its images are ready.
staging_dir=$(mktemp -d "${TMPDIR:-/tmp}/ambiamara-jazzy.XXXXXX")
trap 'rm -rf "$staging_dir"' EXIT
trap 'exit 1' HUP INT TERM
site="$staging_dir/site"
repo_url=https://github.com/RiftValleySoftware/ambiamara
pages_url=https://riftvalleysoftware.github.io/ambiamara

generate_docs() (
    section=$1
    title=$2
    scheme=$3
    module=$4
    platform=$5
    readme=$6
    output_dir="$site/$section"

    printf '\nCreating docs for %s\n' "$title"
    "$jazzy_bin" --source-host-url "$repo_url" \
        --source-host-files-url "$repo_url/blob/master" \
        --root-url "$pages_url/$section/" \
        --readme "$readme" \
        --output "$output_dir" \
        --module "$module" \
        --title "$title" \
        --theme fullwidth \
        --author 'The Great Rift Valley Software Company' \
        --author-url https://riftvalleysoftware.com \
        --min-acl private \
        --exclude '/*/DerivedSources/GeneratedAssetSymbols.swift' \
        --copyright '[©2018-2026 The Great Rift Valley Software Company](https://riftvalleysoftware.com)' \
        --build-tool-arguments "-workspace,AmbiaMara.xcworkspace,-scheme,$scheme,-destination,generic/platform=$platform Simulator,CODE_SIGNING_ALLOWED=NO"

    test -s "$output_dir/index.html"
    test -s "$output_dir/search.json"

    docset="$module.docset"
    documents="$output_dir/docsets/$docset/Contents/Resources/Documents"
    cp icon.png "$output_dir/"
    cp icon.png "$documents/"
    if [ "$section" = mainapp ]; then
        cp img/*.* "$output_dir/img/"
        cp img/*.* "$documents/img/"
    fi
    tar -czf "$output_dir/docsets/$module.tgz" -C "$output_dir/docsets" "$docset"
)

generate_docs mainapp 'RVT Main App Documentation' RVT RVT iOS README.md
generate_docs watch 'RVT Watch App Documentation' WatchApp Watch_App watchOS Sources/WatchApp/README.md
generate_docs complication 'RVT Watch Complication Documentation' WatchComplications Watch_Complications watchOS Sources/WatchComplications/README.md

cp Sources/Meta/JazzyIndex.html "$site/index.html"
cp icon.png "$site/"
touch "$site/.nojekyll"
rsync -a --delay-updates --delete-after --exclude=/.DS_Store "$site/" docs/
printf 'Documentation generated in %s/docs\n' "$PWD"
