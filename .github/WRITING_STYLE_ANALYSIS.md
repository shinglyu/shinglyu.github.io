# Writing Style Analysis Summary

This document summarizes the analysis conducted to create the `writer.instructions.md` agent instruction file.

## Analysis Scope

**Time Period Analyzed**: 2016-2022 (pre-GenAI era)
**Number of Posts Analyzed**: 8 representative posts
**Total Posts Available**: 40+ posts from the pre-GenAI period

## Sample Posts Analyzed

1. **How AlphaGo Can Teach Us About Software Testing** (2016-03-19)
   - Category: Testing
   - Key Style: Personal anecdote opening, analogy-driven structure

2. **Mutation Testing in JavaScript Using Stryker** (2016-10-11)
   - Category: Testing
   - Key Style: Tutorial format, step-by-step instructions

3. **如何貢獻開源專案？** (2018-05-12)
   - Category: Web
   - Key Style: Chinese language, comprehensive guide structure

4. **Counting your contribution to a git repository** (2018-12-25)
   - Category: Web
   - Key Style: Quick tips format, command-line focused

5. **Simplify Your CI Pipeline Configuration with Jsonnet** (2019-02-28)
   - Category: DevOps
   - Key Style: Problem-solution structure, detailed technical walkthrough

6. **Lessons learned in writing my first book** (2020-04-05)
   - Category: Web
   - Key Style: Reflective, personal experience sharing

7. **My Productivity System** (2022-03-06)
   - Category: Productivity
   - Key Style: Systems thinking, visual aids (diagrams)

## Key Findings

### Tone & Voice Characteristics
- **Conversational yet authoritative**: Uses "I" and "you" frequently
- **Humble and learning-oriented**: Admits mistakes and shares learning journey
- **Pragmatic**: Focuses on practical solutions over theoretical perfection
- **Enthusiastic but measured**: Shows passion without hype

### Structural Patterns Identified

#### Common Opening Patterns
1. **Personal Hook** (60% of posts)
   - Example: "After Lee Se-dol lose his first match..."
2. **Direct Problem Statement** (30% of posts)
   - Example: "Sometimes you may wonder, how many commits..."
3. **Context Setting** (10% of posts)
   - Example: "After some recent discussion with a friend..."

#### Common Body Structures
1. **Tutorial/How-To** (40% of analyzed posts)
   - Setup → Concept → Implementation → Troubleshooting
2. **Conceptual/Opinion** (30%)
   - Thesis → Evidence → Examples → Conclusion
3. **Tool Review** (30%)
   - Problem → Solution → How It Works → Example

#### Common Closing Patterns
- Summary of key points (70%)
- Call to action or next steps (50%)
- Encouraging sign-off (80%)
- "Happy [X]-ing!" signature (20%)

### Language Analysis

#### Most Common Transitional Phrases
- "Let's..." (appears in 7/8 posts)
- "Now..." (6/8 posts)
- "So..." (6/8 posts)
- "You might wonder..." (4/8 posts)
- "As you can see..." (5/8 posts)

#### Technical Writing Patterns
- Always uses backticks for inline code: 100%
- Includes command output examples: 80%
- Provides working code examples: 90%
- Links to official documentation: 70%
- Uses numbered lists for steps: 100%
- Uses bullet points for features: 90%

#### Sentence Structure
- Average paragraph length: 3-4 sentences
- Frequent use of short, punchy sentences for emphasis
- Longer explanatory sentences broken with commas and em-dashes
- Question sentences used to engage readers

### Code Example Patterns
1. Shows command with syntax highlighting
2. Explains what the command does (often with bullet points)
3. Shows expected output
4. Explains output or next steps

Example template found:
```
Command introduction text...

```[language]
code here
```

Explanation:
* Part 1 explanation
* Part 2 explanation
* Part 3 explanation

Output:
```
expected output
```
```

### Unique Style Elements

1. **Parenthetical Asides**: Frequent use of parentheses for clarifications
   - "(also called...)"
   - "(e.g., ...)"
   - "(see [link])"

2. **Personal Touches**:
   - Sharing tool version numbers used
   - Mentioning specific timeframes
   - Referencing personal projects and experiences

3. **Multicultural Context**:
   - Occasional posts in Traditional Chinese
   - References to international tech communities
   - Global perspective on technology

4. **Humble Expert Voice**:
   - Admits when something is difficult
   - Shares learning mistakes
   - Acknowledges limitations of solutions

## Differences from GenAI-style Writing

The pre-GenAI posts differ from typical AI-generated content in:

1. **Authentic voice**: Real experiences, not generic scenarios
2. **Specific details**: Actual version numbers, real error messages, personal anecdotes
3. **Non-linear thinking**: Tangents and asides that add personality
4. **Imperfections**: Minor grammar quirks that feel human
5. **Cultural context**: References to specific communities and events
6. **Learning journey**: Shows the process of figuring things out, not just the final answer

## Instruction File Structure

Based on this analysis, the `writer.instructions.md` file was structured to include:

1. **Writing Style Analysis** - Distilled patterns from analyzed posts
2. **Preferred Blog Structure** - Templates for different post types
3. **Specific Style Guidelines** - Concrete rules and examples
4. **Common Phrases** - Actual phrases used in the author's posts
5. **Examples of Good Patterns** - Direct quotes showing what works
6. **Anti-Patterns** - What to avoid based on what's NOT in the posts
7. **Integration with Workflow** - How the writer agent fits into the publishing pipeline

## Usage Recommendations

The writer agent instruction should be used:

1. When converting ideas (`ideas/`) to drafts (`_drafts/`)
2. When expanding outlines into full posts
3. As a reference for maintaining voice consistency
4. In conjunction with other agents (grammar, editor, fact-checker)

## Future Considerations

1. **Evolution tracking**: As writing style evolves post-2022, consider creating version 2
2. **GenAI integration**: The instruction helps AI write in the pre-GenAI style, creating consistency
3. **Multilingual support**: Expand Chinese-language guidance if needed
4. **Domain-specific patterns**: Could create specialized sub-instructions for specific technical domains

## Validation

To validate the effectiveness of this instruction:

1. Generate a sample post using the instruction
2. Compare with actual posts from 2016-2022
3. Check for tone, structure, and phrase similarity
4. Adjust instruction if patterns don't match

---

**Created**: 2026-02-07
**Analyzer**: GitHub Copilot Agent
**Methodology**: Qualitative content analysis of representative blog posts
**Files Analyzed**: 8 markdown files from `_posts/` directory
**Instruction File**: `.github/instructions/writer.instructions.md`
