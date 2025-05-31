My Portfolio Site
====================

Visit [https://shinglyu.com](https://shinglyu.com)

# Installation

```
sudo apt-get install ruby ruby-dev nodejs
sudo gem install jekyll jekyll-paginate
```

# Preview
```
jekyll serve --drafts
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
# Check if the post has any grammar, spelling error.
# Check if the post contains any credentials, confidential data, PII etc. 
./bin/publish.sh _drafts/draft_file_name.md
# Verify if the draft file has been moved to the _post folder and added a timesteamp.
# Verify if the post publish time is in the past. Future post will not be visible
git commit
git push
```

Check https://github.com/shinglyu/shinglyu.github.io/deployments/github-pages to see if the deployment is successful
Then, check https://shinglyu.com to verify if the post is published


