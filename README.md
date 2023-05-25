# Conventional Commit Version Parser

This project provides a script for parsing the latest version of a git repository based on its tags and commits.

## Installation

To use this script, you must have `bash` and `git` installed on your system.

Once you have `bash` and `git` installed, you can download the `parse.sh` script from this repository and place it in a directory on your system.

## Usage

To use the `parse.sh` script, navigate to a git repository on your system and run the script. The script will output the latest version of the repository based on its tags and commits.

For example:

```bash
$ cd /path/to/git/repository
$ /path/to/parse.sh
v1.3.0
```
## Testing
This project includes tests written in Bats, a Bash testing framework. To run the tests, you must have Bats installed on your system.

Once you have Bats installed, you can run the tests for this project by navigating to the project directory and running the bats command:

```bash
$ cd /path/to/project
$ bats parse.bats
```
