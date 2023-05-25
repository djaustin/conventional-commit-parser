#!/usr/bin/env bats
WORKDIR=$(pwd)

setup() {
    # Set up a temporary directory to initialize a git repository
    TESTDIR=$(mktemp -d)
    cd $TESTDIR
    git init
}

teardown() {
    # Clean up the temporary directory
    cd ..
    rm -rf "$TESTDIR"
}

@test "Latest tag v1.2.3, multiple feature commits after tag, should return v1.3.0" {
    git commit --allow-empty -m "Initial commit"
    git tag v1.2.3
    git commit --allow-empty -m "feat: new feature"
    git commit --allow-empty -m "feat: another new feature"
    output=$("$WORKDIR/parse.sh")
    [ $? -eq 0 ]
    [ "$output" = "v1.3.0" ]
}

@test "Latest tag v1.2.3, multiple fix commits after tag, should return v1.2.4" {
    git commit --allow-empty -m "Initial commit"
    git tag v1.2.3
    git commit --allow-empty -m "fix: bug fix"
    git commit --allow-empty -m "fix: another bug fix"
    output=$("$WORKDIR/parse.sh")
    [ $? -eq 0 ]
    [ "$output" = "v1.2.4" ]
}

@test "Latest tag v1.2.3, multiple breaking change commits after tag, should return v2.0.0" {
    git commit --allow-empty -m "Initial commit"
    git tag v1.2.3
    git commit --allow-empty -m "fix: bug fix

BREAKING CHANGE: breaks things"
    git commit --allow-empty -m "feat: new feature

BREAKING CHANGE: breaks more things"
    output=$("$WORKDIR/parse.sh")
    [ $? -eq 0 ]
    [ "$output" = "v2.0.0" ]
}

@test "Incorrect tag format, should return v0.0.0" {
    git commit --allow-empty -m "Initial commit"
    git tag incorrect_tag
    output=$("$WORKDIR/parse.sh")
    [ $? -eq 0 ]
    [ "$output" = "v0.0.0" ]
}

@test "Incorrect commit message format, should print warning" {
    git commit --allow-empty -m "Initial commit"
    git tag v1.2.3
    git commit --allow-empty -m "incorrect commit message format"
    output=$("$WORKDIR/parse.sh")
    [ $? -eq 0 ]
    [[ "$output" =~ "WARNING:" ]]
}

@test "Feat and fix after latest tag v1.2.3, should return v1.3.0" {
    git commit --allow-empty -m "Initial commit"
    git tag v1.2.3
    git commit --allow-empty -m "fix: bug fix"
    git commit --allow-empty -m "feat: new feature"
    output=$("$WORKDIR/parse.sh")
    [ $? -eq 0 ]
    [ "$output" = "v1.3.0" ]
}

@test "Breaking change and feat after latest tag v1.2.3, should return v2.0.0" {
    git commit --allow-empty -m "Initial commit"
    git tag v1.2.3
    git commit --allow-empty -m "feat: new feature"
    git commit --allow-empty -m "fix: bug fix

BREAKING CHANGE: breaks things"
    output=$("$WORKDIR/parse.sh")
    [ $? -eq 0 ]
    [ "$output" = "v2.0.0" ]
}

@test "Breaking change and fix after latest tag v1.2.3, should return v2.0.0" {
    git commit --allow-empty -m "Initial commit"
    git tag v1.2.3
    git commit --allow-empty -m "fix: bug fix"
    git commit --allow-empty -m "fix: another bug fix

BREAKING CHANGE: breaks things"
    output=$("$WORKDIR/parse.sh")
    [ $? -eq 0 ]
    [ "$output" = "v2.0.0" ]
}

@test "Breaking change, feat, and fix commit types after latest tag v1.2.3, should return v2.0.0" {
    git commit --allow-empty -m "Initial commit"
    git tag v1.2.3
    git commit --allow-empty -m "fix: bug fix"
    git commit --allow-empty -m "feat: new feature"
    git commit --allow-empty -m "fix: another bug fix

BREAKING CHANGE: breaks things"
    output=$("$WORKDIR/parse.sh")
    [ $? -eq 0 ]
    [ "$output" = "v2.0.0" ]
}