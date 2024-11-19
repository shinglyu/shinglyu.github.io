---
layout: post
title:  "How AlphaGo Can Teach Us About Software Testing"
date:   2016-03-19 23:00:00 +08:00
categories: Testing
excerpt_separator: <!--more-->
---

After Lee Se-dol lose his first match against AlphaGo, some memes appeared on the Internet calling Lee the "Senior QA engineer at Google". I am both happy and sad about this meme. I'm sad because people still think QA is a less descent job than a Go champion. But I'm happy to see that Lee Se-dol demonstrated many good characteristics of a good software tester, and we can learn a lot from him. Here I will show you how this epic Go match can be related to software QA.

![lee_qa_meme]({{site_url}}/blog_assets/lee_qa.jpeg)

(The Chinese line translates to "Google Senior Softare QA Engineer, Lee Se-dol")
<!--more-->

## There is no such thing as 100% coverage 


Many people still believe that you can "test everything". They believe that by writing (or ask a outsource team to write) test cases that covers "everything", you can guarantee quality by hiring some cheap labor to execute these test cases over and over again. But can you really "test everything"? Just think of AlphaGo as the program under test, and treat the 19 x 19 checkerboard as the input interface, there is more than 10^117 possible game positions. It is impossible to test every possible moves in reasonable time. If this simple program (the Go game), which has a simple rule and simple interface, can not be throughly tested, how can you believe that a complex software can be throughly tested?

## Software never follows the human rule 

One of the reason that AlphaGo is intimidating is that is don't always follow the human rule. It makes unexpected moves that it thinks will raise its odds. Its hard for its human competitor to read its mind because he don't know how AlphaGo's "brain" is thinking. When testers do blackbox testing, they face the same challenge. Even if we are lucky enough to have a formal functional and UX specification, we still don't know how the software will behave for areas that are now specified in the specification. Worse still , software may have the correct behavior, but it does it too slow, or the visual output is now clear enough for the user. Those kind of issue may confuse the automated tests and slip through. This all adds up to the complexity and makes the software hard to test. 

## You only have very limited time for testing

Lee Se-dol did get a chance to test AlphaGo's skill before the official challenge, and the track record of AlphaGo is also very scarce. Software testers often find themselves in that kind of situation too. When a project is delayed, developers start to land last-minutes patches. But stackholders still want to release it in time, so QA's time will get squeezed. You'll need to deliver you test result in extremely short period of time and got no material to prepare beforehand. The solution here is to apply good testing techniques and be risk-driven and. Textbook on software testing can teach you about boundary value testing, equivalent groups, flow testing, etc. But you have to prioritize your testing based on what is risky (to the customer, to your corporation, to your stackholders). 

## Testing is intrinsically exploratory 

If you watch Lee plays Go, he doesn't have a test case in hand and try to test AlphaGo systematically. He starts playing in the traditional way, he then observes AlphaGo's behavior and plan his strategy as he goes. This is a better approach that separating the learning, planning, and execution into different phases. Is hard to learn how a piece of software works only by reading the specification, you need to actually run it and play around with it for a while. The pre-written test cases also don't work every time. When you execute them, you might find unexpected behavior that is totally out of the agenda. Sometimes is worth taking a detour to investigate them. This is a alternative paradigm of testing called Exploratory Testing, as oppose to the traditional Scripted Testing. In Exploratory Testing, the focus is on doing test-related learning, test desing and test execution and test verification in parallel. 

Exploratory Testing may sound too unorganized to manage, but its not just for Go world champion or very senior tester. You can implement Exploratory Testing in your organization by following James Bach's [Session-Based Test Management (SBTM)](http://www.satisfice.com/articles/sbtm.pdf) approach. SBTM put emphasis on time-framed, well-documented exploratory testing. You can also check out James Bach's Rapid Software Testing slides.

## QA engineers are domain experts 

Exploration requires deep knowledge about the domain. This is why AlphaGo challenged Lee instead of some random guy. You need to understand not only the rules of Go, but also tactics, strategies and how find weak points. This applies to software testing too, testers are not clicking monkeys, they have deep knowledge about how software is built and how they are supposed to work, both functionally and user-experience-wise. A good software tester understands coding, so she know what kind of mistakes developers often make. A good tester should also know a little bit about performance tuning, software security, and even user experience and visual design, so they can find non-functional problems that can't be found by automation alone.

## Don't just test, tell the testing story 

After his epic victory in the fourth round, Lee Se-dol tell the press how he found the two weakness of AlphaGo, and people are more interested in how he won it instead of the fact that he won.  If you take a look at the [Wikipedia page](https://en.wikipedia.org/wiki/AlphaGo_versus_Lee_Sedol) for these games, you can see there are detailed analysis of how the game progress. As you can see, people are wired to stories rather than numerical report. However, the deliverable of a software testing session is usually a dull report (which nobody really care) about fail rates or bugs counts. Instead, as James Bach stressed in his [Rapid Software Testing](http://www.satisfice.com/rst.pdf) methodology, we should try to tell our "testing stories": what have you tried; how did you spot the weird behavior; how are you use your kill to force the bug to reveal itself; and most importantly, how does your testing work mean to the project and the organization. These kind of stories reveals way more knowledge about the software and the value of QA then dry numbers.  

Although the our daily test work may not attract as much attention as the AlphaGo versus Lee Se-dol match, if we focus on learning and exploration, every test session can still be an epic adventure.
