---
layout: post
title: Simplify Your CI Pipeline Configuration with Jsonnet
categories: DevOps
date: 2019-02-25 00:00:00 +08:00
excerpt_separator: <!--more-->
---


## The problem with YAML-based CI configuration files
Most of the CI/CD (Continuous Integration/Continuous Delivery) tools nowadays supports some form of configuration file. For example [Travis CI][travis_file], [Gitlab CI][gitlab_file], [Circle CI][circle_file] and [Drone CI][drone_file] uses YAML file. [Jenkins][jenkins_file] uses its own DSL. These YAML-based configuration file is easy to read and edit, but they doesn't scale very well. In this post we'll demonstrate the problem with Drone CI v1.0, but the idea can be easily applied to other CI tool.

The first problem is that pipelines become hard to reason about when you have more and more conditional builds. Usually when we are using git with CI pipelines, we end up with multiple pipelines for each scenario. For example, imagine we have a imaginary Node.js web service, when I do a feature branch push (i.e. non-master branch push) we would probably want to trigger the `build` and `test` step. But when we merge a request to `master` branch, we want it to `build`, `test` and then deploy to our `dev` environment. Also Drone CI gives you the ability to trigger a deployment from the CLI, so we also want to also add a `build`-`test`-deploy to stage pipeline for that. So to summarize, we ant the following pipelines:

```
When push to non-master
  - build
  - test

When merge to master
  - build
  - test
  - deploy_dev

When manually deploy to stage
  - build
  - test
  - deploy_stage
```

Drone and many other CI solution allow you to achieve this with some conditions.  A Drone config file for the above pipelines will look like this:

```
kind: pipeline
name: default

steps:
- name: build
  image: node:8.6.0
  commands:
    - npm install
    - npm run build

- name: test
  image: node:8.6.0
  commands:
    - npm test

- name: deploy_dev
  image: node:8.6.0
  commands:
    - npm run deploy -- --env=dev
  when:
    event:
      - push
    branch:
      - master

- name: deploy_stage
  image: node:8.6.0
  commands:
    - npm run deploy -- --env=stage
  when:
    event:
      - promote
    environment:
      - stage
```

The `event: promote` in the `deploy_stage` is triggered by a CLI call `drone promote <repo/name> <build> <environment>`. This is how manual deployment is triggered in Drone. Don't worry if you don't understand how this works, it's not critical to our discussion.

Now imaging you are new to the project and read this drone pipeline, what would happend when you push a feature branch? You have to do all the condition matching in your head to come up with a list of steps that fits the condition. The pipeline configuration we just created is basically a tree, and we apply conditions onto it to get a branch of it. 

![pipeline tree]({{site_url}}/blog_assets/drone_jsonnet/pipeline_tree.svg)

But it will be much simpler if we duplicate the build and test steps and enumerate every combinations with `when` blocks. But this way we'll end up with 8 steps, each with different `when` condition, while most of the code is duplicated. We'll solve this with jsonnet after we explain the second problem.

The second problem is code duplication. YAML provides [anchor][yaml_anchor] to cut down on repetition. But that only works at key-value granularity. Let's assume that we are going to deploy the imaginary service to multiple  AWS regions for resilience, we'll have even more combinations. If we have 3 environments, `dev`, `stage` and `prod` (production), and 2 regions, 'eu-central-1' and 'us-west-1', then we'll have 3 x 2 = 6 deployment combinations. Even if we use YAML anchor to avoid repeating the `when` part, we still repeat a lot of the code:
p

```
aliases-deployment-triggers:
  - &when_deploy_stage
    when:
      event:
        - promote
      environment:
        - stage
  - &when_deploy_prod
    when:
      event:
        - promote
      environment:
        - prod

kind: pipeline
name: default

steps:
# ... omitting some steps
- name: deploy_stage_eu
  image: node:8.6.0
  commands:
    - npm run deploy -- --env=stage --region=eu-central-1
  <<: *when_deploy_stage

- name: deploy_stage_us
  image: node:8.6.0
  commands:
    - npm run deploy -- --env=stage --region=us-west-1
  <<: *when_deploy_stage

- name: deploy_prod_eu
  image: node:8.6.0
  commands:
    - npm run deploy -- --env=prod --region=eu-central-1
  <<: *when_deploy_prod

- name: deploy_stage_us
  image: node:8.6.0
  commands:
    - npm run deploy -- --env=prod --region=us-west-1
  <<: *when_deploy_prod
```

Notice that even if we reduce the repetition by  `when_deploy_stage` for both the stage part, but we can't abstract out the `npm run ...` line and the name, because we can't parameterize the environment and region bit within the line. The good news is that Jsonnet can solve both problem we discussed. We'll give a short introduction about Jsonnet and explain how we can solve the problems with Jsonnet.

## Jsonnet 



JSONNET intro
simple JSONNET hello world
use jsonnet function for templating
use jsonnet to generate the lists pipeline
conclusion, recap what are the problems and how jsonnet solve it
<!--more-->
