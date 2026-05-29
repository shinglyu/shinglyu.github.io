## Steps to Create a New Blog Draft

1. The user should give you an idea, you should ask for the idea if it's not given

2. Generate 5 descriptive, SEO-optimized title idea, and ask the user to choose

3. Run `./bin/create_draft.sh "<chosen title>"` to create the draft file. This script
   deterministically sets the creation date to the current time in Amsterdam timezone,
   so the post always has a valid (non-future, non-distant-past) date.
   The script outputs the path of the created file — use that path in subsequent steps.

4. Open the generated file and update the `categories` frontmatter field to one of:
   Web, AI, Productivity, Writing
