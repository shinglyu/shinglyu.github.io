* I wrote a book https://leanpub.com/learning-to-learn-aws
* I choose to self-publish, because I want to release early and collect feedback, and imporve iteratively
* I want to use Ai but keep the intellectual owernship
* Don't want to generate garbage AI-generated book to fill Amazon
* The past 2 books took me more than one year each
    * This book is not that complex. so it's not a fair comparison, but took me 5 month with maybe 1-2 hours a week (due to childcare duty)
* Motivation
    * I have a child now, making it impossible to work on a book every evening and the whole weekend.
    * Writing a book with a publisher is a very waterfall-style experience, you can't learn incrementally and pivot easily once you signed the contarct up front. 
    * I want to prove that AI can amplify human expertise, rather than completely destroy human intelectual ability like some commentators said 
* The writing process
    * Book level outline > Chapter level outline > Generate chapter > Review and revise
        * Write book level outline, iterative with AI to get feedback
        * Ask AI to turn book level outline into individual chapter outlines
        * Manually edit chapter outlines and add details
        * Iterate with AI on chapter outline until satisfied
        * Ask AI to turn the chatper level outline into full chapter
        * Carefully edit the whole chapter, either rewrite each chapters myself or ask AI to change it.
    * Go through each chapter and change the writing style for consistency
    * Check each chapter with AI for typos, grammar errors, captitalization, wording and logic inconsistencies.
        * Cline + Claude 4.0 sometimes give up after 3 chapters
            * Check grammar, it only do 3 and say "you can continue with 4.5.6...." need to force it again
            * Need to explictly say "do it chapter by chapter
    * Publish on leanpub
        * Generate descriptiosn from the book manuscript using AI
        * Generate book cover with AI
* My setup
    * Cline in VSCode (on Linux)
        * Brief description of what it is
        * Allow you to bring-your-own-model
    * Model: 
        * Gemini 2.0 pro (using 3 month free GCP account)
            * Because it give very generous free tier quota
            * And the 3 month GCP trial give me motiviation to not procrastinate
        * swtich to Gemimini 2.5 Pro and FLash after they released
        * Then realize cline suppots model from GitHub Copilot, so I swtiched to Claude sonnet 3.5
        * Then switch to Claude 4.0 after it's released
        * Finally use Claude 4.0 to rewrite the old chapters with inconsistent style
        * Claude is still my favorite model in terms of writing style
    * IDE is still the best option for collaboration with AI
        * I built the ai-writer, which is similar to Gemini or Claude Canvas
        * IDE allows you to intervene and rewrite whole chapters easily. 
        * Cline's agentic workflow allows it to cross reference chatpers. It can also read the outline and compare that to the chapters. Gives great flexibility
        * Cline allows me to switch to newer, better models as well as model providers

* What I learned
    * AI's role 
        * AI makes it easy to delay style decision
            * E.g. Capitalization
            * Special terms formatting
            * Change the 4 step learning cycle title wording, and update all references
            * Second person vs first person ("You need to use this and that technology" vs " I used this and that technology")
        * AI removed writers block
            * If I'm very tired after work, I can still take 10-15 minutes to generate a chapter and review 1-2 paragraphs. 
            * Reviewing is much easier mentally than writing, especailly because I'm not a native speaker.
        * AI takes away the burden of administrative work
            * administratvie work: writing author bio, writing book description, select category. 
            * These sounds easy, but with the length limit, it's actually harder than writing the book itself. Because you have to summarize a lot of content into concise paragraphs
            * AI speed it up
        * AI is as good, and maybe better than human editor on some areas
            * A little bit cliche when acting as a developmental editor, it always try to use safe, conservative structure and tone
            * Pretty good at fixing typos and grammars
            * Good at formatting code (not in this book, but I tried on something else). Non-technical type-setters usually mess up your example code formatting and you need to spend a lot of time providing proofread feedback
            * With publishers outsourcing these editing tasks to low-skill labours overseas, it's probably easier to work with AI 
    * Workflow
        * Craft your AI writing style prompt for consistency
            * I gave Claude blog posts I wrote by hand
            * Ask it to summarzie my writing style: tone and style and formatting choices
            * Use that summary as the system prompt in Cline so it writes in my style, which results in much less full rewrite needed. 
        * Start with an outline file
            * This give you better control of the flow and key points to highligh
            * It's easier to have a bigger picture over the flow of the story, and can easily adjust
            * You can even ask AI for restructuring advice, and ask it to execute it
            * Need to be very specific about personal experiences, otherwise AI would hallucinate
            * Be very careful about links, always provide every link you want to include
        * Keep all the progress in text files
            * PROGRESS.txt
                * Write something like "I'm currently reviewing chapter 2"
                * Add a "<<<PROGRESS MARKER>>>" at when I call it a day, so I can easily continue. Work as a digital bookmark
            * TODO.txt
                * Write in clear prompts, so AI can work on them one by one
* Future work
    * Audiobook
        * I used Amazon Polly long-form voide to generate one, currently proof-listening
    * Want to add a chapter on learning SageMaker, as it has a very different structure of learning (notebooks, SDKs, MLOps etc. )
    * Maybe have a paperback print-on-demand print using Kindle Direct Publishing

        
