---
layout: post
title: Disable pycodestyle Check in SageMaker Notebooks
categories: AI
date: 2024-08-19 11:34:41 +0200
excerpt_separator: <!--more-->
---
_The solution in this post is originally proposed by [MattC](https://stackoverflow.com/a/77932753) and [krassowski](https://stackoverflow.com/a/67671347) in this [StakeOverflow thread](https://stackoverflow.com/questions/67669843/jupyterlab-3-0-14-how-to-disable-code-style-highlights-pycodestyle). I just added some screenshots. Thanks to [Nadhya Polanco](https://www.linkedin.com/in/nadhya-polanco/) for pointing me to this solution._

_(To view a larger version of a screenshot, right-click on the image and select **Open Image in New Tab**.)_

By default, when you use JupyterLab in Amazon SageMaker Studio, you'll see some Python code being highlighted with pycodestyle syntax check error. This can get distracting if you don't care about them or have the checks in the CI/CD pipeline already.

![Problem]({{site_url}}/blog_assets/sagemaker-disable-pycodestyle/1.problem.png)

Here is how you can disable it:
<!--more-->

## Disable the pycodestyle check completely
First, click the **Settings** menu >  **Settings Editor**.
![Settings]({{site_url}}/blog_assets/sagemaker-disable-pycodestyle/2.settings.png)
There are a lot of items in the Settings Editor. Search for **Langauge Servers**.
![Language Servers]({{site_url}}/blog_assets/sagemaker-disable-pycodestyle/3.languages-servers.png)
Uncheck the `pylsp.plugins.pycodestyle.enabled`.
![Deselect PyLSP]({{site_url}}/blog_assets/sagemaker-disable-pycodestyle/4.diselect-pylsp.png)
Now you have a clean notebook.
![Disabled]({{site_url}}/blog_assets/sagemaker-disable-pycodestyle/5.disabled.png)
## Disable certain checks
If you only need to disable some rules, here is how you can do it.

Right-click on the line with highlighted code > **Show diagnostics panel**
![Show Diagnostics]({{site_url}}/blog_assets/sagemaker-disable-pycodestyle/6.show-diagnostics.png)
The diagnostics panel will show up. Right click on the rule you want to ignore > **Ignore diagnostics like this** > **Ignore diagnostics with "EXXX" code**.
![Ignore Diagnostics]({{site_url}}/blog_assets/sagemaker-disable-pycodestyle/7.ignore-diagnostics.png)
