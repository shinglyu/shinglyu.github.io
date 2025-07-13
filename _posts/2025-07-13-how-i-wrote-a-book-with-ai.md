---
layout: post
title: How I Wrote a Book with AI
categories: Writing
date: 2025-07-13 22:10:13 +02:00
excerpt_separator: <!--more-->
---

After spending over a year each on my previous two books, I decided to experiment with AI assistance for my latest project: [Learning to Learn AWS](https://leanpub.com/learning-to-learn-aws). The goal wasn't to generate another AI-filled book flooding Amazon, but to maintain intellectual ownership while dramatically reducing the time investment. Here's how I completed a quality technical book in just 5 months, working only 1-2 hours per week.

<!--more-->

## Why I Chose This Approach

I deliberately chose to self-publish on Leanpub because it allows me to release early, collect feedback, and improve iteratively. This philosophy extended to my AI collaboration approach—I wanted to maintain complete creative control while leveraging AI's capabilities to overcome the practical barriers that had made my previous books such time-consuming endeavors.

My past two books each took over a year to complete. While this book wasn't as complex (making it an imperfect comparison), I managed to finish it in 5 months despite having significantly less time due to childcare responsibilities. The transformation came from treating AI as a strategic writing partner rather than a replacement—one that could help me maintain intellectual ownership while solving the practical barriers that make book writing so time-intensive.

This partnership approach was crucial because I had no interest in contributing to the flood of shallow, AI-generated content already saturating the market. Instead, I wanted to enhance my own expertise and voice while dramatically reducing the friction of translating ideas into polished prose. With only 1-2 hours per week available for writing, this collaboration became the key to making meaningful progress without sacrificing quality or authenticity.

Every idea, structure, and key insight in the book comes from my own experience and knowledge. AI served as an intelligent writing assistant that helped me express these ideas more efficiently, not as a source of content itself. With young children and a full-time job, I could only dedicate 1-2 hours per week to writing. Traditional writing methods would have meant another multi-year project. AI collaboration allowed me to make meaningful progress in these limited time windows by removing the friction of translating thoughts into polished prose.

As a non-native English speaker, I often found myself stuck on phrasing and structure rather than content. AI helped me maintain momentum by providing a foundation I could then refine and personalize. The result isn't an AI book—it's my book, written more efficiently with AI assistance. Every chapter reflects my personal learning journey, my specific insights about AWS services, and my teaching approach developed over years of hands-on experience.

## The Writing Process: A Four-Stage Approach

Here is my process of writing with AI:

### Stage 1: Book-Level Outline
I started by creating a comprehensive book-level outline, iterating with AI to refine the structure and flow. This high-level view proved crucial for maintaining narrative coherence across chapters.

### Stage 2: Chapter-Level Outlines
Next, I asked AI to transform the book outline into detailed chapter outlines. I manually edited these extensively, adding specific personal experiences, technical details, and examples that only I could provide. This step prevented AI hallucination while ensuring each chapter served the book's overall purpose.

### Stage 3: Chapter Generation and Revision
With solid outlines in place, I had AI generate full chapters. Then came the critical human intervention phase, I carefully edited each chapter, either rewriting sections myself or directing AI to make specific changes. This maintained my voice while leveraging AI's ability to transform structured thoughts into flowing prose.

### Stage 4: Consistency and Quality Control
After completing all chapters, I went through two final passes:
- **Style consistency**: Ensuring uniform tone, terminology, and formatting across chapters
- **Quality checking**: Using AI to catch typos, grammar errors, capitalization issues, and logical inconsistencies

This process is of course iterative. If I learned something new or have new ideas while writing some chapters, I go back to the book-level and chapter-level outline to update them and refine them. I only generate one chapter at a time, so if I have to make structural changes across multiple chapters, I only need to go back and edit a few outlines, and don't have to regenerate mutliple chapters. 

## Publication and Marketing

For publication on Leanpub, AI proved invaluable for the often-overlooked administrative tasks:
- **Book description**: Generated compelling copy from the manuscript
- **Book cover**: Created using AI image generation
- **Author bio**: Crafted within platform length limits

These tasks sound simple but are surprisingly challenging due to strict length constraints and the need to distill complex content into concise, compelling summaries. If it's your first time writing a book, the publisher might ask you to write this near the end, when you are already exhausted from the whole writing experience. This further delays the release and is very painful. 

## My Technical Setup
Once you understand my process, let's take a look at the AI tools I used. 

### Cline: The Game-Changing IDE Integration

I used [Cline](https://cline.bot) in Visual Studio Code on Linux as my primary AI writing assistant. Cline is an AI-powered coding assistant with a bring-your-own-model design, but it turned out to be perfect for book writing. Unlike web-based AI interfaces, an IDE-based approach offers crucial advantages:

- **Seamless file management**: Easy editing of entire chapters without copy-pasting
- **Easy human intervention**: Easy rewrite anything AI wrote, with my favorite vim keybinding
- **Cross-referencing capabilities**: Cline can read outlines and compare them against chapters
- **Model flexibility**: Switch between different AI models as better ones become available
- **Agentic workflows**: The AI can work autonomously across multiple files

I also built my own [ai-writer tool](https://github.com/aws-samples/ai-writer) (similar to Gemini or Claude Canvas) in the past. But canvas-style tools are more suitable for single-file articles. Cline's integration into a full-fledge IDE proved superior for book-length projects.

### Model Evolution Journey

My model choices evolved throughout the project, driven by both capability improvements and practical constraints:

1. **Gemini 2.0 Pro**: Started here using the generous free tier with my 3-month GCP trial. The trial deadline created helpful motivation to avoid procrastination.

2. **Gemini 2.5 Pro and Flash**: Upgraded when these newer models were released for better performance.

3. **Claude Sonnet 3.5**: Switched when I discovered Cline supports GitHub Copilot models, giving me access to Claude's superior writing style.

4. **Claude 4.0**: Moved to the latest model upon release and used it to rewrite earlier chapters for style consistency.

Claude remains my favorite for writing style—it produces the most natural, engaging prose that requires minimal editing to match my voice. Gemini models are okay, but their tone and writing style would change dramatically when you change the prompt slightly.


## What I Learned from the process

### AI as a Creative Enabler

One of the most surprising discoveries was how AI enabled me to separate content creation from style decisions. Rather than wrestling with both simultaneously, I could focus entirely on getting my ideas down first, then systematically address formatting choices like capitalization, special term formatting, and voice consistency across all chapters. This delayed decision-making proved invaluable when I later realized inconsistencies in my terminology. For example, I had used "AWS SkillBuilder," "SkillBuilder," and "Skill Builder" interchangeably when the correct stylization is "AWS Skill Builder." AI helped me standardize these details efficiently across the entire manuscript. It also helped me change some chapters written by Gemini in second person tone into first person tone. 

The collaboration also eliminated writer's block entirely. Even on exhausting days after work, I could spend just 10-15 minutes generating a chapter and reviewing a few paragraphs. This shift from writing to editing proved transformative, especially for non-native English speakers like myself who often get stuck on phrasing and structure rather than content. Reviewing and editing demanded far less mental energy than writing from scratch, allowing me to maintain momentum even when my creative reserves were low.

Perhaps most importantly, AI excelled at the tedious but crucial administrative tasks that often make book writing so painful. Writing compelling book descriptions, author bios, and category selections within strict length constraints proved surprisingly challenging—these seemingly simple tasks often feel harder than writing the book itself. The combination of length restrictions and the need for persuasive, concise language makes these tasks particularly difficult when you're already exhausted from the main writing process.

### AI vs. Human Editors

When it comes to technical accuracy, AI consistently matches or exceeds human editors in catching grammar errors, typos, and formatting inconsistencies when there are many technical terms and very specific stylization. This advantage becomes even more pronounced for technical books with code examples (not this one, but I tried on others), where AI significantly outperforms traditional typesetters who frequently introduce errors in code formatting. The precision required for technical documentation makes AI's systematic approach particularly valuable.

However, AI's strengths come with notable limitations in structural feedback. While AI provides reliable suggestions for surface-level improvements, it tends toward safe, conservative recommendations when acting as a developmental editor. Human insight remains crucial for bold structural decisions, creative direction, and understanding of the publishing market.

The practical considerations of cost and speed further tip the balance toward AI collaboration. With many publishers increasingly outsourcing editing to lower-skilled overseas workers to reduce costs, AI offers comparable quality with significantly better availability and consistency. The traditional editing process can introduce delays and variability that AI partnerships eliminate, making the collaboration particularly attractive for self-published authors.

## Workflow Insights That Made the Difference

### Crafting the AI Writing Style Prompt

I fed Claude several blog posts I'd written manually and asked it to summarize my writing style—tone, structure, and formatting preferences. Using this summary as a system prompt in Cline resulted in generated content that required far less rewriting to match my voice.

### File-Based Progress Tracking

As mentioned before, I kept all the outline in text files, this helps the AI maintain the overall structure and flow I have in mind. 

Although not realted to AI directly, I maintained all progress in simple text files:
- **PROGRESS.txt**: Current status ("I'm currently reviewing chapter 2") with digital bookmarks using "PROGRESS MARKER" inserted into the place I left off. This allow me to get back into the flow much faster the next day. 
- **TODO.txt**: Clear prompts written so AI could work through them systematically

### Meticulous Link and Reference Management

One critical caveat: AI cannot be trusted with links or specific references. I learned to provide every URL, citation, and external reference explicitly. AI will hallucinate plausible-sounding but incorrect links.

### Agentic Limitations

Claude 4.0 with Cline occasionally give up when the context window grows larger. For example, when checking grammar across multiple chapters, it would process the first three thoroughly, then suggest "you can continue with chapters 4, 5, 6..." I learned to explicitly request "do it chapter by chapter" to ensure the agent go through each chapter.


## Future Developments

### Audiobook Production
I'm currently using Amazon Polly's long-form speech synthesis to generate an audiobook version. The proof-listening process is ongoing, and I might release it as an extra on Leanpub.

### Content Expansion
I'm considering adding a chapter on learning SageMaker, which presents unique challenges due to its different learning structure (notebooks, SDKs, MLOps workflows) compared to traditional AWS services.

### Print Options
A paperback print-on-demand version through Kindle Direct Publishing is under consideration for readers who prefer physical books.

## The Bottom Line

Writing a book with AI isn't about letting the machine do the work. It's about intelligent collaboration that amplifies your expertise while removing friction from the creative process. The key is maintaining intellectual ownership while leveraging AI's strengths: removing writer's block, handling administrative tasks, and enabling rapid iteration.

For technical authors especially, this approach offers a sustainable way to share knowledge without the crushing time investment that traditionally makes book writing prohibitive. The result isn't an AI-generated book, but a human-authored work that AI helped bring to life efficiently.

The technology is here, the tools are accessible, and the results speak for themselves. The question isn't whether to use AI in your writing process—it's how to use it effectively while maintaining the quality and authenticity your readers deserve.
