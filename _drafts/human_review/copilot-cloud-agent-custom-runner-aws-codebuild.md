---
layout: post
title: "Running GitHub Copilot Cloud Agent on AWS CodeBuild with Self-Hosted Runners"
date: 2026-04-20 00:00:00 +00:00
categories: blog
tags: [GitHub-Copilot, AWS, CodeBuild, self-hosted-runners]
excerpt_separator: <!--more-->
---

I've been experimenting with the [GitHub Copilot Cloud Agent](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent) (also called the Copilot coding agent) as part of my [remote vibe coding setup]({% post_url 2026-01-29-my-remote-vibe-coding-setup %}). The idea is simple: assign a GitHub issue to Copilot, let it implement the code on cloud compute, and have it open a pull request — all without needing a machine running locally. If you haven't read that post, the short version is that this kind of setup is great when you only have a few minutes at a time and want meaningful progress to happen in the background.

The catch is that in some environments you can't just use GitHub-hosted runners. Maybe you need compute that stays inside a specific AWS VPC, or your setup already lives on AWS and you'd rather keep everything there. In October 2025, GitHub [announced support for self-hosted runners](https://github.blog/changelog/2025-10-28-copilot-coding-agent-now-supports-self-hosted-runners/) for the Cloud Agent, which opens the door to running the whole agent pipeline on AWS CodeBuild. Getting it working end-to-end took some trial and error. This post walks through the setup and, more importantly, the pitfalls I hit along the way.

<!--more-->

## Step 1: Configure AWS CodeBuild to run GitHub Actions

AWS CodeBuild supports GitHub Actions runners, which lets it act as a self-hosted runner for GitHub Actions. At a high level, you create a CodeBuild project, set up a webhook connected to your GitHub repository, and configure the project to respond to GitHub Actions runner requests. Once this is done, CodeBuild registers itself as a self-hosted runner and GitHub can dispatch workflow jobs to it.

I won't go into the exact step-by-step here — the [AWS documentation](https://docs.aws.amazon.com/codebuild/latest/userguide/action-runner.html) covers that well. The key idea is that after this setup, your CodeBuild project becomes a drop-in replacement for GitHub-hosted runners. Workflow jobs that specify the right `runs-on` label will execute inside CodeBuild instead of on GitHub's infrastructure.

## Step 2: Configure the GitHub repository to use self-hosted runners for the Cloud Agent

Once CodeBuild is set up as a runner, you need to tell the Copilot Cloud Agent to use it. GitHub has [documentation on customizing the agent environment](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/customize-the-agent-environment#using-self-hosted-github-actions-runners), including how to point it at self-hosted runners.

The short version: you need a `copilot-setup-steps.yml` file in your repository's `.github/workflows/` directory. This file defines a job called `copilot-setup-steps` that Copilot picks up and runs before the main agent work begins. The job's `runs-on` key is where you specify your self-hosted runner label.

Go through the repository settings to enable the Cloud Agent and to point it at your self-hosted runner. The GitHub documentation linked above walks through the relevant settings pages.

## Pitfalls

The two steps above are straightforward in theory, but there are several ways the setup can silently fail or behave unexpectedly. Here's what I ran into.

### Pitfall 1: Network and firewall allowlists

When the Copilot Cloud Agent runs, it needs to reach several external hosts. If your CodeBuild project runs inside a VPC with restrictive outbound rules (which is common in enterprise setups), you need to allowlist all the hosts GitHub requires.

The [GitHub documentation on self-hosted runners](https://docs.github.com/en/actions/reference/runners/self-hosted-runners#accessible-domains-by-function) lists the domains needed for standard GitHub Actions runner operation — things like `github.com` and `api.github.com`. This is easy to overlook because it's the baseline runner requirement, not specific to Copilot. On top of that, the Copilot Cloud Agent also needs:

- `uploads.github.com`
- `user-images.githubusercontent.com`
- `api.individual.githubcopilot.com` (for Copilot Pro and Copilot Pro+ users)
- `api.business.githubcopilot.com` (for Copilot Business users)
- `api.enterprise.githubcopilot.com` (for Copilot Enterprise users)

If you're using the OpenAI Codex third-party agent, there are also additional npm-related domains required — check the GitHub docs for the full list. And if any of the above are blocked, the action run will fail with a lot of timeouts — the kind that look like transient network errors but are actually your firewall doing its job. I spent longer than I'd like to admit debugging timeout errors before realizing the runner domains were missing from the allowlist. In my experience, the missing standard runner domains from the self-hosted runner docs (not the Copilot-specific list) are the easiest to overlook.

### Pitfall 2: Disable the built-in firewall in Copilot settings

Copilot has a "Built-in Firewall" option in the repository settings (under the Copilot section). If you're using a self-hosted runner, you need to disable this.

The good news: there's a dedicated step in the Copilot pipeline that checks for this and gives you a clear error message if the built-in firewall is still enabled. So you will know about it — you just need to know what to do when you see it. Go into the Copilot settings for your repository and turn off the built-in firewall. I think this is one of the easier pitfalls to fix, because at least the error is actionable.

### Pitfall 3: The `runs-on` label format is very specific

This one caught me completely off guard. For the `copilot-setup-steps.yml` workflow, the `runs-on` label for CodeBuild must follow a very specific format:

```yaml
runs-on: codebuild-<project-name>-${{ github.run_id }}-${{ github.run_attempt }}
```

The project name is what links the AWS-related settings of your GitHub Actions job to a specific CodeBuild project. The `run_id` is what allows CodeBuild to map each build to a specific workflow run, and to stop the build when the workflow run is cancelled. According to the [AWS documentation](https://docs.aws.amazon.com/codebuild/latest/userguide/action-runner.html), including both is how CodeBuild knows which project configuration to use and which workflow run to track.

If you omit `run_id` and `run_attempt` and just use the project name, the Copilot action will get stuck waiting for a runner. If you look at the webhook logs on the CodeBuild side, you'll see that CodeBuild receives the request but can't match it to the right build. The job just sits in a pending state indefinitely. I burned a good chunk of time on this before finding the exact label format in the documentation.

### Pitfall 4: The `copilot-setup-steps` job needs `contents: read` permission

This one is listed in the GitHub documentation, but near the top where it reads like boilerplate — not something that seems directly related to self-hosted runners. I started from the example in the [GitHub documentation on customizing the agent environment](https://docs.github.com/en/enterprise-cloud@latest/copilot/how-tos/use-copilot-agents/cloud-agent/customize-the-agent-environment):

```yaml
#===== .github/workflows/copilot-setup-steps.yml =====
jobs:
  copilot-setup-steps:
    runs-on: codebuild-<project-name>-${{ github.run_id }}-${{ github.run_attempt }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install JavaScript dependencies
        run: npm ci
```

The `Checkout code` step kept failing. The error message said the repository did not exist, which sent me down the wrong path — debugging repository visibility and CodeBuild integration permissions. But the actual problem was an inline permission.

What's tricky here is that `contents: read` and the `actions/checkout` step appear in two separate example code blocks in the documentation, and it's easy to copy one without realizing you need the other. The fix is to add `permissions: contents: read` to the same job:

```yaml
#===== .github/workflows/copilot-setup-steps.yml =====
jobs:
  # The job MUST be called `copilot-setup-steps` or it will not be picked up by Copilot.
  copilot-setup-steps:
    runs-on: codebuild-<project-name>-${{ github.run_id }}-${{ github.run_attempt }}

    # Set the permissions to the lowest permissions possible needed for your steps.
    # Copilot will be given its own token for its operations.
    permissions:
      # If you want to clone the repository as part of your setup steps, for example to install dependencies, you'll need the `contents: read` permission.
      # If you don't clone the repository in your setup steps, Copilot will do this for you automatically after the steps complete.
      contents: read

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install JavaScript dependencies
        run: npm ci
```

There's an additional wrinkle that makes this even harder to debug: the error only happens when the Copilot agent triggers the workflow by responding to an issue assignment. If you manually trigger the `copilot-setup-steps` job from the GitHub Actions tab, it runs with different default credentials that already include `contents: read`, and the checkout succeeds. So you'd test it manually, it works fine, then you assign an issue to Copilot and the checkout fails — with a "repository does not exist" error that seems completely unrelated to permissions.

According to the documentation, you can also skip the explicit checkout entirely and let Copilot handle it automatically after the setup steps complete. But I prefer doing it in the setup step so it's deterministic and avoids spending LLM tokens on figuring out how to run `git pull`.

## Conclusion

Getting the Copilot Cloud Agent working on AWS CodeBuild is entirely doable, but the path has a few sharp corners. In my experience, the `contents: read` permission is the trickiest one — not because the fix is complicated, but because the permission and the `actions/checkout` step live in two separate code blocks in the documentation, and you can easily copy one without realizing you need the other. The debugging is also misleading: you test manually and everything works, then it fails when Copilot actually triggers it. The firewall allowlist is conceptually straightforward, but in enterprise setups, managing VPC egress rules often involves a network team and can take time to get right.

I think the overall setup is worth the effort. Being able to assign a GitHub issue to Copilot, have the implementation run entirely on AWS CodeBuild inside your own VPC, and get a pull request back — without any local machine running — fits well into the kind of background async workflow I described in [my remote vibe coding post]({% post_url 2026-01-29-my-remote-vibe-coding-setup %}).
