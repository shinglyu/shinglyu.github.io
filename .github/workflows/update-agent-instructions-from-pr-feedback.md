---
on:
  pull_request:
    types: [closed]
    paths:
      - "_posts/**"
      - "_drafts/**"
      - "ideas/**"
      - "human_review/**"
  workflow_dispatch:

permissions:
  contents: read
  pull-requests: read

tools:
  github:
    toolsets: [context, repos, pull_requests]
  edit:

safe-outputs:
  create-pull-request:
    title-prefix: "[ai] "
    labels: [agent-instructions, automated]
    draft: true
    if-no-changes: ignore
    allowed-files:
      - ".github/instructions/**"
      - ".github/agents/**"
      - ".github/aw/**"
    protected-files:
      policy: fallback-to-issue  # same values as string form (default: blocked)
      exclude:
        - .github/agents/writer.agent.md  # allow the agent to update writer instructions
        - .github/agents/                 # allow updates to the .agents/ directory
---

# Update Agent Instructions from PR Feedback

A blog-related pull request was just closed. The closed PR number is `${{ github.event.pull_request.number }}` in repository `${{ github.repository }}`.

Follow the instructions in `.github/agents/pr-feedback-analyzer.agent.md` to analyze the feedback on this PR and update the agent instructions accordingly.
