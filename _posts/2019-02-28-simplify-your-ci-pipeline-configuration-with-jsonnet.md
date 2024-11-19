---
layout: post
title: Simplify Your CI Pipeline Configuration with Jsonnet
categories: DevOps
date: 2019-02-28 14:45:00 +01:00
excerpt_separator: <!--more-->
---

> This post is also featured on the [DAZN Engineering Blog][dazn_blog].

Most of the CI/CD (Continuous Integration/Continuous Delivery) tools nowadays supports some form of configuration file so you can properly version control them. For example [Travis CI][travis_file], [Gitlab CI][gitlab_file], [Circle CI][circle_file] and [Drone CI][drone_file] uses YAML file. [Jenkins][jenkins_file] uses its own DSL. These YAML-based configuration files are easy to read and edit, but they don't scale very well when the file grows big. This problem can be solved by using a nice data templating language called Jsonnet. In this post we'll be demonstrating Drone CI v1.0 configuration file format, but the idea can be easily applied to other CI tool.

<!--more-->

### The problem with YAML-based CI configuration files

The first problem is that pipelines become hard to reason about when you have more and more conditional builds. Usually when we are using git with CI pipelines, we end up with multiple pipelines for each scenario. For example, imagine we have an imaginary Node.js web service, when I do a feature branch push (i.e. non-master branch push) we would want to trigger the build and unit test steps. When the pull request is approved and we merge the branch to the `master` branch, we want it to build, unit test, deploy to our `dev` environment and then run integration test on it; Once we are done with testing in `dev` environment, we can use Drone CI's CLI to trigger a deployment to `stage`, which will take the build from the previous master branch build and deploy it to the 'stage' environment, then run integration test on it. The same can be applied for deployment to production, but we'll leave it out to keep the example simple. So to summarize, we ant the following pipelines:

```
When push to non-master
  - build
  - unit_test

When merge to master
  - build
  - unit_test
  - deploy_dev
  - integration_test

When manually deploy to stage
  - deploy_stage
  - integration_test
```

Drone and many other CI solution allow you to achieve this with some conditions.  A Drone config file for the above pipelines will look like this:

```yaml
kind: pipeline
name: default

steps:
- name: build
  image: node:8.6.0
  commands:
    - npm install
    - npm run build
  when:
    event:
      - push

- name: unit_test
  image: node:8.6.0
  commands:
    - npm run unit_test
  when:
    event:
      - push

- name: intergration_test
  image: node:8.6.0
  commands:
    - npm run integration_test

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

Now imaging you are new to the project and read this drone pipeline, what would happen when you push a feature branch? First you'll have to read through all the steps. For each step you'll need to check if the `when` conditions matches the scenario you care about. Then you need to write down all the steps that matched. Be careful that a step without any `when` condition will run in every situation. So you'll need to do a lot of processing in your head to see what will be run when. It's also very easy to add a new step with the wrong condition and have it run in an unexpected situation. The pipeline configuration we just created is basically a tree, and we apply conditions onto it to get a branch of it.

![pipeline tree]({{site_url}}/blog_assets/drone_jsonnet/pipeline_tree.svg)

But it will be much simpler if we duplicate the build and test steps and enumerate every combination with `when` blocks. But this way we'll end up with 8 steps, each with different `when` condition, while most of the code is duplicated. We'll solve this with jsonnet after we explain the second problem.

![pipelines]({{site_url}}/blog_assets/drone_jsonnet/pipelines.svg)

The second problem is code duplication. YAML provides [anchor][yaml_anchor] to cut down on repetition. But that only works at key-value granularity. A simple YAML anchor looks like this:

```yaml
anchors:
  - &anchor_job
    job: programmer
    duty: code and debug

employees:
  - name: Alice
    <<: *anchor_job
  - name: Bob
    <<: *anchor_job
```

In this example, we defined an anchor called `&anchor_job`, which contains two keys, `job: programmer` and `duty:  code and debug`. In our `employees` list, we use `<<: *anchor_job` to in-line it into the `name: Alice` object. The keys from `&anchor_job` will be merged into the `name: Alice` object and become 

```yaml
employees:
  - name: Alice
    job: programmer
    duty: code and debug
  - name: Bob
    job: programmer
    duty: code and debug
```

However this mechanism only works at key-value level, you can't parameterize part of a value. Let's assume that we are going to deploy the imaginary service to multiple  AWS regions for resilience, we'll have even more combinations. If we have 3 environments, `dev`, `stage` and `prod` (production), and 2 regions, 'eu-central-1' and 'us-west-1', then we'll have 3 x 2 = 6 deployment combinations. Even if we use YAML anchor to avoid repeating the `when` part, we still repeat a lot of the code:

A YAML anchor

```yaml
aliases-deployment-triggers:
  # The common `when` condition for promoting to stage
  - &when_deploy_stage
    when:
      event:
        - promote
      environment:
        - stage
  # The common `when` condition for promoting to prod
  - &when_deploy_prod
    when:
      event:
        - promote
      environment:
        - prod

kind: pipeline
name: default

steps:
# ... omitting some build and test steps for simplicity
- name: deploy_stage_eu
  image: node:8.6.0
  commands:
    # Assume our deploy script takse the parameter env and region
    - npm run deploy -- --env=stage --region=eu-central-1
  <<: *when_deploy_stage # Using the anchor here

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

- name: deploy_prod_us
  image: node:8.6.0
  commands:
    - npm run deploy -- --env=prod --region=us-west-1
  <<: *when_deploy_prod
```

Notice that even if we reduce the repetition by  `when_deploy_stage` for both the stage part, we can't abstract out the `npm run deploy -- --env=<environment> --region=<region>` line and the name, because we can't parameterize the environment and region bit within the line. The good news is that Jsonnet can solve both problem we discussed. We'll give a short introduction about Jsonnet and explain how we can solve the problems with Jsonnet.

### Jsonnet 
Jsonnet is an open source templating language based on JSON. The backbone of it is still native json, but it adds variables, conditionals, functions, arithmetics and more to it. It also has nice linter, formatter, and IDE integrations. It has a nicely designed standard library that provides you utilities for string manipulation, math, and functional tools like map and fold.

A jsonnet source code pass through the compiler, which emits JSON. On MacOS you can easily install it with `brew install jsonnet`. Although Drone now [natively supports jsonnet][drone_jsonnet_post], but since my team still runs the old version of Drone, we decided to compile jsonnet to JSON, then use the [json2yaml][json2yaml] tool to convert it to YAML. We then commit both the jsonnet source and the generated YAML file into our git repository.

#### Avoiding repetition with functions

So let's try to solve the repetition problem by using jsonnet functions. The moving parts in our deploy step is the environment and region. So we can define a function that takes the two parameters and do string interpolation in there:

```jsonnet
// demo1.jsonnet

local deploy(env, region) =
  {
    name: 'deploy_%(env)s_%(region)s' % { env: env, region: region },
    image: 'node:8.6.0',
    commands: [
      'npm run deploy -- --env=%(env)s --region=%(region)s' % { env: env, region: region },
    ],
    when: {
      event: ['promote'],
      environment: [env],
    },
  };

// Calling the function
{
  steps: [
    deploy('stage', 'eu-central-1'),
    deploy('stage', 'us-west-1'),
    deploy('prod', 'eu-central-1'),
    deploy('prod', 'us-west-1'),
  ],
}
```

Let's take a closer look to the `name` field. Jsonnet supports old Python-like string formatting (the `%` operator). In the template string, the `%(env)s` will search for the `env` key in the object following the `%` operator. The `s` at the end of the `%(...)` means we want to format it as a string.

If we run `jsonnet demo1.jsonnet`, this will be printed to the STDOUT:

```javascript
{
   "steps": [
      {
         "commands": [
            "npm run deploy -- --env=stage --region=eu-central-1"
         ],
         "image": "node:8.6.0",
         "name": "deploy_stage_eu-central-1",
         "when": {
            "environment": [
               "stage"
            ],
            "event": [
               "promote"
            ]
         }
      },
      {
         "commands": [
            "npm run deploy -- --env=stage --region=us-west-1"
         ],
         "image": "node:8.6.0",
         "name": "deploy_stage_us-west-1",
         "when": {
            "environment": [
               "stage"
            ],
            "event": [
               "promote"
            ]
         }
      },
      {
         "commands": [
            "npm run deploy -- --env=prod --region=eu-central-1"
         ],
         "image": "node:8.6.0",
         "name": "deploy_prod_eu-central-1",
         "when": {
            "environment": [
               "prod"
            ],
            "event": [
               "promote"
            ]
         }
      },
      {
         "commands": [
            "npm run deploy -- --env=prod --region=us-west-1"
         ],
         "image": "node:8.6.0",
         "name": "deploy_prod_us-west-1",
         "when": {
            "environment": [
               "prod"
            ],
            "event": [
               "promote"
            ]
         }
      }
   ]
}
```

We generated 64 lines of json from just 23 lines of jsonnet, and it's much easier to read!

#### Define separate pipelines for each scenario

The next question is how can we structure our jsonnet code such that we can easily understand what steps are included in each scenario (e.g. push to non-master, merge to master etc.). We can first define the building blocks, the steps:

```jsonnet
local build = {
  name: 'build',
  image: 'node:8.6.0',
  commands: [
    'npm install',
    'npm run build',
  ],
};

local unitTest = {
  name: 'unit_test',
  image: 'node:8.6.0',
  commands: [
    'npm run unit_test',
  ],
};

local integrationTest = {
  name: 'integration_test',
  image: 'node:8.6.0',
  commands: [
    'npm run integration_test',
  ],
};

local deploy(env, region) =
  {
    name: 'deploy_%(env)s_%(region)s' % { env: env, region: region },
    image: 'node:8.6.0',
    commands: [
      'npm run deploy -- --env=%(env)s --region=%(region)s' % { env: env, region: region },
    ],
  };
```

Then we can start composing our pipelines with these steps. First we define a list of steps we want when pushing to a non-master branch:

```jsonnet
local commitToNonMasterSteps = [
  build,
  unitTest
];
```

We want to restrict these steps to only run on a push to non-master, we can use a `std.map` to add the conditional block (i.e. `when` block) to each step of it.

```jsonnet
local whenCommitToNonMaster(step) = step {
  when: {
    event: ['push'],
    branch: {
      exclude: ['master'],
    },
  },
};

local commitToNonMasterSteps = std.map(whenCommitToNonMaster, [
  build,
  unitTest,
]);
```

The `whenCommitToNonMaster` function will append the `when` block to the step you pass in. The syntax `step { when: ... }` actually means "merging the `step` object with the `{ when: ... }` object". This function is then applied to each and every step using the `std.map` function. This pattern can then be applied to other scenarios, for example when we merge to master:

```jsonnet
local whenMergeToMaster(step) = step {
  when: {
    event: ['push'],
    branch: ['master'],
  },
};

local mergeToMasterSteps = std.map(whenMergeToMaster, [
  build,
  unitTest,
  deploy('dev', 'eu-central-1'),
  deploy('dev', 'us-west-1'),
  integrationTest,
]);
```

We choose to repeat the `build` and `unitTest` step here, so we can clearly see what is included in the "merge to master" pipeline. In the generated code there will be two copies of the `build` step, one with a `when` block of pushing to non master and another with a `when` block of merging to master; same for the `unitTest` step. We can carry on with defining other scenarios and their list of steps. In the end we'll have a list of scenarios, each contains a list of steps. We can then flatten all the lists into one giant list of all possible steps using the `std.flattenArrays()` function.

```jsonnet
local pipelines = std.flattenArrays([
  commitToNonMasterSteps, // build, unitTest
  mergeToMasterSteps      // build, unitTest, deploy_dev_eu,   deploy_dev_us,   integrationTest
  deployToStageSteps,     //                  deploy_stage_eu, deploy_stage_us, integrationTest
  deployToProdSteps,      //                  deploy_prod_eu,  deploy_prod_us,  integrationTest
]);

// Below is the actual JSON object that will be emitted by the jsonnet compiler.
{
  kind: 'pipeline',
  name: 'default',
  steps: pipelines,
}
```

Using this architecture, anyone who reads the Drone configuration can clearly see the list of scenarios (the `pipelines` list). To see what steps are executed in each scenario, we can simply go to the definition of the scenario variable (e.g. `commitToNonMasterSteps`).

### A side note about Jsonnet vs. JavaScript

You might wonder why we choose to use Jsonnet instead of JavaScript. You can easily achieve the same effect by forming the config object in JavaScript and print it out with `JSON.stringify()`. One reason is that Jsonnet is natively supported by Drone CI since v1.0, so it make sense to use it directly. Another reason is that Jsonnet's syntax is built around native JSON, with a relatively limited set of function and operators. So it will force you to focus on the data rather then the algorithm. By using JavaScript you might be tempted to use all sorts of NPM libraries and write complex algorithms that makes it hard to trace and debug. The design of it also leads you to write very functional code instead of procedural code, so if you are into functional programming it will be a natural fit. But technically Jsonnet is no better then using plain JavaScript, so feel free to choose whichever fits into your existing pipeline and team's expertise.

### Conclusions
We discussed the problems for writing the CI pipeline in plain YAML. The first problem is that if we use complex conditionals to control which step to run in which scenario, the pipeline will quickly become hard to reason about. The second problem is that even if we use YAML anchors we still can't eliminate all the repetitions. By using jsonnet, we can solve the two problems. We can eliminate the repetition using jsonnet functions and string interpolation. To address the complex conditionals problem, we structure our jsonnet code in a way that we enumerate all the steps under each scenario. Thanks to the jsonnet templating, we can be explicit but keep our code concise and clean. 

[circle_file]: https://circleci.com/docs/2.0/config-intro/
[drone_file]: https://docs.drone.io/user-guide/pipeline/steps/
[drone_jsonnet_post]: https://blog.drone.io/drone-1-release-candidate-1/#jsonnet-configuration
[gitlab_file]: https://docs.gitlab.com/ee/ci/yaml/
[jenkins_file]: https://jenkins.io/doc/pipeline/tour/hello-world/
[json2yaml]: https://www.npmjs.com/package/json2yaml
[travis_file]: https://docs.travis-ci.com/user/tutorial/
[yaml_anchor]: https://blog.daemonl.com/2016/02/yaml.html
[dazn_blog]: https://medium.com/dazn-tech/simplify-your-ci-pipeline-configuration-with-jsonnet-5a96cd9ccc51
