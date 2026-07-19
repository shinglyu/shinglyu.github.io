My Portfolio Site
====================

Visit [https://shinglyu.com](https://shinglyu.com)

# Dev Container (Recommended)

Run this site in a reproducible container with Jekyll auto-started.

0) Install podman (as docker): `sudo apt install podman podman-docker`
1) Open this folder in VS Code and install the "Dev Containers" extension.
2) Reopen in container; it will install gems and start the server.
3) Your site will be available at:

```
http://localhost:4000/
```

If the server is not running, start it inside the container:

```bash
bundle exec jekyll serve --host 0.0.0.0 --watch --drafts
```

# Local Setup (Optional)

If you prefer running locally without the devcontainer:

```bash
sudo apt-get install ruby-full build-essential
gem install bundler
bundle config set path vendor/bundle
bundle install
bundle exec jekyll serve --drafts
```

# Folder structure
```
.
├── bin
│   ├── create_draft.sh # Create a draft with the correct format and naming
│   └── publish.sh # Publish a draft
├── blog_assets
│   ├── slugify-post-name # put images, mermaid diagrams, long source codes here
├── _drafts
│   ├── slugified-post-title.md
│   ├── outlines
│   │   └── # outlines used for AI to write it, do not commit the file
├── _posts
│   ├── 2016-02-15-Mutation_Testing_in_JavaScript_Using_Grunt_Mutation_Testing.md
...
```

# Publish
```
# Drafts published through GitHub Actions should start with these front matter fields:
---
grammar_checked: false
fact_checked: false
---

# After the editor-led grammar/fact review is complete, set the matching flags
# to true before running the publish workflow.
#
# Add the draft filename to .github/workflows/publish.yml, then run the
# "Publish Blog Post" workflow with publish_only, sync_to_public_only, or both.
# The workflow uses .github/scripts/publish.sh and .github/scripts/sync_to_public.sh.
```

Check https://github.com/shinglyu/shinglyu.github.io/deployments/github-pages to see if the deployment is successful
Then, check https://shinglyu.com to verify if the post is published
