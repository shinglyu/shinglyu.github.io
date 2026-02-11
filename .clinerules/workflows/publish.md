## Steps to Publish a Blog Draft

* User should provide you with a draft file, if not, ask the user.
* Use the git command to confim this draft is commited and has no uncomitted changes
* Check for grammar error and typo in the draft. Correct them.
* Use the git command to check if the images used in the file are commited
* Check for factual error in the draft. If so, stop
* Check if the post contains senstivity information like PII, or API keys or credential. If so, stop.
* Use `mv` to move the draft file to `_posts/` with date prefix (`YYYY-MM-DD-filename.md`)
* Update the frontmatter with the publishing date time.
* Use git to commit (remember to also add the deleted draft) the new post and push to create a PR.
* After the PR is created, Cloudflare will automatically deploy a preview. Guide the user to review the Cloudflare auto-deployed link provided in the PR to verify the post renders correctly and has no layout issues.
* Write a short and concise social media post promoting this post and output it directly in chat (do NOT create a file)
* Use your browser tool to open https://shinglyu.com after a 3 minutes to check if the post is published. Retry 3 times. 
