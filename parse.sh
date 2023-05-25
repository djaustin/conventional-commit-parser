#!/bin/bash

# Get latest version tag. If there is no version tag, start from v0.0.0
latest_version=$(git describe --tags --abbrev=0 --match='v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || echo "v0.0.0")

# Split the version string into an array using '.' as delimiter
IFS='.' read -ra VERSION <<< "${latest_version#v}"

# Assign major, minor, and patch variables from the VERSION array
major=${VERSION[0]}
minor=${VERSION[1]}
patch=${VERSION[2]}

# Initialize variables to keep track of the presence of feature, fix, or breaking changes
feat=0
fix=0
breaking=0

# Iterate over all commits since the latest version tag
for commit in $(git rev-list ${latest_version}..HEAD); do
    # Get the commit message of the current commit
    msg=$(git log --format=%B -n 1 $commit)

    # Check if the commit message adheres to the conventional commit format
    if [[ $msg =~ ^(feat|fix|chore|docs|style|refactor|perf|test)(\(.*\))?:.* ]]; then
        # If the commit is a new feature, mark feature presence
        if [[ $msg =~ ^feat && $feat -eq 0 ]]; then
            feat=1
        # If the commit is a fix, mark fix presence
        elif [[ $msg =~ ^fix && $fix -eq 0 ]]; then
            fix=1
        fi
        # If the commit is a breaking change, mark breaking change presence
        if [[ $msg =~ BREAKING\ CHANGE && $breaking -eq 0 ]]; then
            breaking=1
        fi
    else
        # If the commit message does not match the conventional commit format, log a warning with the commit hash and the commit message
        echo "WARNING: Commit $commit does not adhere to the conventional commit format: $msg"
    fi
done

# Increment version based on the presence of feature, fix, or breaking changes
# Check for breaking changes first, then new features, then fixes
if [[ $breaking -eq 1 ]]; then
    major=$((major + 1))
    minor=0
    patch=0
elif [[ $feat -eq 1 ]]; then
    minor=$((minor + 1))
    patch=0
elif [[ $fix -eq 1 ]]; then
    patch=$((patch + 1))
fi

# Output the next version tag in the form "vX.Y.Z"
echo "v${major}.${minor}.${patch}"
