---
name: code-review
description: Guidelines for reviewing new work. Run whenever the user asks to review a PR or give feedback about a piece of code.
---

## Review Guidelines
- ensure that the issue requirement is fulfilled (issue number is in the branch name)
- check for logical issues and bugs
- check for general security vulnerabilities, verify proper user access through Firestore/Storage rules
- ensure there is no unused code
- check for concurrency issues with persisting data
- check for backwards compatibility with older app versions

## Output Format

- rank issues by severity (minor, medium, high)
- print a summary of found issues for each severity in a table
- list issues grouped by category, sorted by severity