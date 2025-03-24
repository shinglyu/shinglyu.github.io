---
layout: post
title: Make AI Draw Architecture Diagrams with AWS Icons
categories: Web
date: 2025-03-24 22:23:56 +08:00
excerpt_separator: <!--more-->
---

## Taking AWS Architecture Diagrams to the Next Level

Last year, I wrote about [turning hand-drawn architecture diagrams into digital diagrams using generative AI]({{site_url}}/ai/2024/07/12/turning-hand-drawn-architecture-diagrams-into-digital-diagrams-with-generative-ai.html). While that approach worked well for creating editable digital diagrams, the result was quite basic—mostly rectangles and text. But if you've ever seen presentations by AWS solution architects, you'll know that colorful AWS service icons can make architecture diagrams much more visually appealing and easier to understand at a glance.

I've since figured out how to leverage AI to not only create the basic diagram structure but also incorporate those recognizable AWS service icons. In this post, I'll walk you through the process step by step.

<!--more-->

## My Setup

Before diving into the process, let me quickly outline my setup:

- **AI Tool**: I'm using Cline in VSCode with Claude 3.7 Sonnet provided through GitHub Copilot
- **Diagramming Tool**: draw.io desktop application
- **Alternative**: If you don't use Cline, you can achieve the same results with GPT-4o or another advanced AI through a chatbot interface—you'll just need to manually copy-paste the code

## Step 1: Generate a Basic Architecture Diagram in Mermaid

The first step is to ask the AI to generate an architecture diagram using Mermaid syntax. If you already have a specific architecture in mind, you can also follow the technique from my previous post to convert a hand-drawn diagram.

I asked Claude (through Cline) to:

> Draw a 3 tier web application, with an email sending component to customers using managed email services. Use AWS services, Write in Mermaid syntax to a file name `three-tier.mermaid`.

The AI then generated a Mermaid diagram file for me:

![Claude generating Mermaid diagram]({{site_url}}/blog_assets/ai-diagram-aws/cline.png)

## Step 2: Import the Mermaid Diagram into draw.io

Once you have your Mermaid diagram, the next step is to import it into draw.io:

1. Open draw.io desktop application
2. Go to **Arrange** > **Insert** > **Advanced** > **Mermaid**
3. Paste your Mermaid code or select the file

After importing, you'll get a basic diagram with generic shapes representing AWS services:

![Raw imported diagram]({{site_url}}/blog_assets/ai-diagram-aws/raw_diagram.drawio.svg)

For an example of the mermaid syntax, and screenshots on how to import the mermaid syntax into Draw.io, check the [old post]({{site_url}}/ai/2024/07/12/turning-hand-drawn-architecture-diagrams-into-digital-diagrams-with-generative-ai.html).

## Step 3: Create an AWS Icon Reference File

Now for the interesting part. Draw.io saves diagrams as XML files, and we need to teach the AI how to use AWS icons. To do this:

1. Create a new empty draw.io diagram
2. Add all the AWS service icons you might need
3. Save it in the .drawio XML format

Mine looks like this: 

![AWS Icon diagram]({{site_url}}/blog_assets/ai-diagram-aws/aws_icons.drawio.svg)

When you examine the file, you'll find snippets like this:

```xml
<mxCell id="qUjVfe4VSX1uA_H3d-F2-1" value="" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#8C4FFF;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.cloudfront;" vertex="1" parent="1">
  <mxGeometry x="150" y="130" width="78" height="78" as="geometry" />
</mxCell>
```

The most important part is at the end: `resIcon=mxgraph.aws4.cloudfront`. This defines the specific AWS icon to use (in this case, CloudFront).

## Step 4: Replace Generic Shapes with AWS Icons

With our reference file ready, we can ask the AI to replace the generic boxes in our diagram with the appropriate AWS icons:

> Please replace the boxes representing AWS services in @/raw_diagram.drawio with AWS service icons. You can find the syntax of AWS service icons in @/aws_icons.drawio. Generate the output into a new file `diagram_with_aws_icon.drawio`.

The AI will analyze both files—the basic diagram and the AWS icon reference—and create a new file with the proper AWS icons in place:

![Diagram with AWS icons]({{site_url}}/blog_assets/ai-diagram-aws/diagram_with_aws_icon.drawio.svg)

## Step 5: Polish the Diagram with Right-Angle Lines

As an electrical engineer by training, I have a strong preference for right-angle lines in my diagrams (they're cleaner and more professional-looking). Fortunately, that's an easy fix to request from the AI:

> Take @/diagram_with_aws_icon.drawio, and make all the lines and arrows use right-angle lines. Write the output to `diagram_with_aws_icon_right_angles.drawio`

And voilà! We now have a polished AWS architecture diagram with proper service icons and right-angle connections:

![Diagram with right-angle lines]({{site_url}}/blog_assets/ai-diagram-aws/diagram_with_aws_icon_right_angles.drawio.svg)

## Conclusion: AI as a Diagram Assistant

This experiment demonstrates how AI can significantly speed up the creation of professional-looking architecture diagrams. Claude 3.7 Sonnet handled the draw.io XML format flawlessly, which is impressive considering the complexity of the format.

While the generated diagram may still need some manual tweaking—adjusting line positions to prevent overlaps or clarifying the overall layout—it provides a solid foundation that saves considerable time compared to starting from scratch.

For architects and engineers who regularly create AWS architecture diagrams, this approach offers a happy middle ground: you get the efficiency of AI generation combined with the precision and visual appeal of professional AWS service icons.

What other diagramming tasks do you think AI could help with? Let me know if you've found other creative ways to leverage AI for technical documentation!
