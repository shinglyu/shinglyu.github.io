---
layout: post
title:  "Mutation Testing in JavaScript Using Stryker"
categories: Testing
date: 2016-10-11 09:00:00 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---


Earlier this year, I wrote a [blog post](http://shinglyu.github.io/testing/2016/02/15/Mutation_Testing_in_JavaScript_Using_Grunt_Mutation_Testing.html) introducing Mutation Testing in JavaScript using the [Grunt Mutation Testing framework](https://www.npmjs.com/package/grunt-mutation-testing). But as their NPM README said,

> We will be working on (gradually) migrating the majority of the code base to the [Stryker](https://www.npmjs.com/package/stryker).

So I'll update my post to use the latest Stryker framework. The following will be the updated post with all the code example migrated to the Stryker framework:

<!--more-->
<hr>

* Code example: [github link](https://github.com/shinglyu/JS-mutation-testing-example-stryker)

Last November (2015) I attended the EuroStar Software Testing Conference, and was introduced to a interesting idea called mutation testing. Ask yourself: "How do I ensure my (automated) unit test suite is good enough?". Did you miss any important test? Is your test always passing so it didn't catch anything? Is there anything un-testable in your code such that your test suite can never catch it?

<h1>Introduction to Mutation Testing</h1>

Mutation testing tries to "test your tests" by deliberately inject faults (called "mutants") into your program under test. If we re-run the tests on the crippled program, our test suite should catch it (i.e. some test should fail.) If you missed some test, the error might slip through and the test will pass. Borrowing terms from Genetics, if the test fails, we say the mutant is "killed" by the test suite; on the opposite, if the tests passes, we say the mutant survived.

The goal of mutation testing is to kill all mutants by enhancing the test suite. Although 100% kill is usually impossible for even small programs, any progress on increasing the number can still benefit your test a lot.

The concept of mutation testing has been around for quite a while, but it didn't get very popular because of the following reasons: first, it is slow. The number of possible mutations are just too much, re-compiling (e.g. C++) and re-run the test will take too long. Various methods has been proposed to lower the number of tests we need to run without sacrifice the chance of finding problems. The second is the "equivalent mutation" problem, which we'll discuss in more detail in the examples.

<h1>Mutation Testing from JavaScript</h1>

There are many existing mutation testing framework. But most of them are for languages like Java, C++ or C#. Since my job is mainly about JavaScript (both in browser and Node.js), I wanted to run mutation testing in JavaScript.

I have found a few mutation testing frameworks for JavaScript, but they are either non-open-source or very academic. The most mature one I can find so far is the [Stryker](https://stryker-mutator.github.io/) framework, which is released under Apache 2.0 license.

This framework supports mutants like changing the math operators, changing logic operators or even removing conditionals and block statements. You can find a full list of mutations with examples <a href="https://stryker-mutator.github.io/mutators.html">here</a>.

<h1>Setting up the environment</h1>

You can follow the [quickstart](https://stryker-mutator.github.io/quickstart.html) guide to install everything you need. The guide has a nice interactive menu so you can choose your favorite build system, test runner, test framework and reporting format. In this blog post I'll demonstrate with my favorite combination: Vanilla NPM + Mocha + Mocha + clear-text.

You'll need <code>node</code> and <code>npm</code> installed. (I recommended using <a href="https://github.com/creationix/nvm">nvm</a>).

There are a few Node packages you need to install,

{% highlight bash%}
sudo npm install -g --save-dev mocha
npm install --save-dev stryker styker-api stryker-mocha-runner
{% endhighlight%}

Here are the list of packaged that I've installed:

{% highlight js %}
"devDependencies": {
	"mocha": "^2.5.3",
	"stryker": "^0.4.3",
	"stryker-api": "^0.2.0",
	"stryker-mocha-runner": "^0.1.0"
}
{% endhighlight%}

<h1>A simple test suite</h1>

I created a simple program in <code>src/calculator.js</code>, which has two functions:

{% highlight js %}
// ===== calculator.js =====
function substractPositive(num1, num2){
  if (num1 > 0){
    return num1 - num2;
  }
  else {
    return 0
  }
}

function add(num1, num2){
  if (num1 == num2){
    return num1 + num2;
  }
  else if (num1  num2){
    return num1 + num2;
  }
  else {
    return num1 + num2;
  }
}

module.exports.substractPositive = substractPositive
module.exports.add = add;
{% endhighlight %}

The first function is called <code>substractPositive</code>, it substract <code>num2</code> from <code>num1</code> if <code>num1</code> is a positive number. If <code>num1</code> is not positive, it will return <code>0</code> instead. It doesn't make much sense, but it's just for demonstrative purpose.

The second is a simple <code>add</code> function that adds two numbers. It has a unnecessary <code>if...else...</code> statement, which is also used to demonstrate the power of mutation testing.

The two functions are tested using <code>test/test_calculator.js</code>:

{% highlight js %}
var assert = require("assert");
var cal = require("../src/calculator.js")

describe("Calculator", function(){
  it("substractPositive", function(){
    assert.equal("2", cal.substractPositive(1, -1));
  });

  it("add", function(){
    assert.equal("2", cal.add(1, 1));
  });
})
{% endhighlight %}

This is a test file running using <code>mocha</code>, The first verifies <code>substractPositive(1, -1)</code> returns <code>2</code>. The second tests <code>add(1,1)</code> produces <code>2</code>. If you run <code>mocha</code> in your commandline, you'll see both the test passes. If you run `mocha` in the commandline you'll see the output:

{% highlight bash%}
% mocha

  Calculator
    ✓ substractPositive
    ✓ add

  2 passing (6ms)
{% endhighlight %}

So this test suite looks OK, it exercises both function and verifies its output, but is it good enough? Let's verify this by some mutation testing.

<h1>Running the mutation testing</h1>

To run the mutation testing, we first need to create a config file for the stryker mutator. Create a file called `stryker.conf.js` in the project's root directory and paste the following input into it:

{% highlight js %}
// stryker.conf.js
module.exports = function(config){
  config.set({
    files: [
        // Add your files here, this is just an example:
        { pattern: 'src/**/*.js', mutated: true, included: false},
        'test/**/*.js'
    ],
    testRunner: 'mocha',
    testFramework: 'mocha',
    testSelector: null,
    reporter: ['clear-text', 'progress']
  });
}
{% endhighlight %}

You can see we choose <code>mocha</code> as the `testRunner` and <code>testFramework</code>, and we tell the Stryker framework to run the test files in `test/**/*.js`, and the source files are in `src/**/*.js`.

Then we need to tell `npm` how to run Stryker in the `package.json` file. Simply add the following code in your `package.json` configuration:

{% highlight js%}
"scripts": {
  "stryker": "stryker -c stryker.conf.js"
},
{% endhighlight%}

This will add a `npm run stryker` command to `npm run` and execute the `stryker -c stryker.conf.js` script.

# Finding Missing Tests

Now if we run `npm run stryker`, you'll see the following test result:

{% highlight js%}
% npm run stryker

> @ stryker /home/shinglyu/workspace/mutation-testing-demo/stryker
> stryker -c stryker.conf.js

[2016-10-07 15:14:51.997] [INFO] InputFileResolver - Found 1 file(s) to be mutated.
[2016-10-07 15:14:52.129] [INFO] Stryker - Initial test run succeeded. Ran 2 tests.
[2016-10-07 15:14:52.151] [INFO] Stryker - 22 Mutant(s) generated
[2016-10-07 15:14:52.153] [INFO] TestRunnerOrchestrator - Creating 8 test runners (based on cpu count)
SSSSSSSSSSSSS..S......
Mutant survived!
/home/shinglyu/workspace/mutation-testing-demo/stryker/src/calculator.js: line 17:7
Mutator: BlockStatement
-     else {
-       return num1 + num2;
-     }
+     else {
+   }

Tests ran:
    Calculator substractPositive
    Calculator add

Mutant survived!
/home/shinglyu/workspace/mutation-testing-demo/stryker/src/calculator.js: line 18:11
Mutator: Math
-       return num1 + num2;
+       return num1 - num2;

Tests ran:
    Calculator substractPositive
    Calculator add

Mutant survived!
/home/shinglyu/workspace/mutation-testing-demo/stryker/src/calculator.js: line 14:11
Mutator: RemoveConditionals
-     else if (num1 > num2){
+     else if (false){

Tests ran:
    Calculator substractPositive
    Calculator add

Mutant survived!
/home/shinglyu/workspace/mutation-testing-demo/stryker/src/calculator.js: line 14:23
Mutator: BlockStatement
-     else if (num1 > num2){
-       return num1 + num2;
-     }
+     else if (num1 > num2){
+   }

Tests ran:
    Calculator substractPositive
    Calculator add

//(omitted for brevity)

22 mutants tested.
0 mutants untested.
0 mutants timed out.
8 mutants killed.
Mutation score based on covered code: 36.36%
Mutation score based on all code: 36.36%
[2016-10-07 15:14:52.468] [INFO] fileUtils - Cleaning stryker temp folder /home/shinglyu/workspace/mutation-testing-demo/stryker/.stryker-tmp
{% endhighlight %}


As you can see, it tested 22 kinds of mutations, but 14 (22-8=14) of them survived!

Let's look at a survived mutant:

{% highlight js %}
Mutant survived!
/home/shinglyu/workspace/mutation-testing-demo/stryker/src/calculator.js: line 2:6
Mutator: ConditionalBoundary
-     if (num1 > 0){
+     if (num1 >= 0){
{% endhighlight%}

It tells us that by replacing the `>` with `>=` in line 2 of our `calculator.js` file, the test will pass.

If you look the line, the problem is pretty clear

{% highlight js %}
// ===== calculator.js =====
function substractPositive(num1, num2){
  if (num1 > 0){ // <== This line
    return num1 - num2;
  }
  else {
    return 0
  }
}
{% endhighlight%}

We didn't test the boundary values, if `num1 == 0`, then the program should go to the `else` branch and returns `0`. By changing the `>` to `>=`, the program will go into the `return num1 - num2` branch instead and returns `0 - num2`!

This is one of the problem mutation testing can solve, it tells you which test case you missed. The solution is very simple, we can add a test like this:

{% highlight js %}
it('substractPositive', function(){
  assert.equal('0', cal.substractPositive(0, -1));
});

{% endhighlight %}

If you run mutation testing again, the problem with the <code>substractPositive</code> function should go away.

<h1>Equivalent Mutation and Dead Code</h1>

Sometimes a mutation will not change the behavior of the program, so no matter what test you write, you can never make it fail. For example, a mutation may disable caching in your program, the program will run slower but the behavior will be exactly the same, so you'll have a mutation you can never kill. This kind of mutation is called "equivalent mutation".

Equivalent mutation will make you overestimate your mutation survival rate. And they time to debug, but may not reveal useful information about your test suite. However, some equivalent mutations do reveal issues about your program under test.

Let look at the mutation results again:

{% highlight js%}
Mutant survived!
/home/shinglyu/workspace/mutation-testing-demo/stryker/src/calculator.js: line 11:6
Mutator: ReverseConditional
-     if (num1 == num2){
+     if (num1 != num2){

Mutant survived!
/home/shinglyu/workspace/mutation-testing-demo/stryker/src/calculator.js: line 14:11
Mutator: RemoveConditionals
-     else if (num1 > num2){
+     else if (false){

Mutant survived!
/home/shinglyu/workspace/mutation-testing-demo/stryker/src/calculator.js: line 14:23
Mutator: BlockStatement
-     else if (num1 > num2){
-       return num1 + num2;
-     }
+     else if (num1 > num2){
+   }

Mutant survived!
/home/shinglyu/workspace/mutation-testing-demo/stryker/src/calculator.js: line 15:11
Mutator: Math
-       return num1 + num2;
+       return num1 - num2;

{% endhighlight %}


If you look at the code, you'll find that all the branches of the <code>if...else...</code> statement returns the same thing. So no matter how you mutate the <code>if...else...</code> conditions, or even remove one branch that was not reached, the function will always return the correct result.

{% highlight js%}
10 function add(num1, num2){
11   if (num1 == num2){
12     return num1 + num2;
13   }
14  else if (num1 > num2){
15     return num1 + num2;
16   }
17  else {
18     return num1 + num2;
19   }
20 }
{% endhighlight %}

Because we found that the <code>if...else...</code> is useless, we can simplify the function to only three lines:

{% highlight js%}
function add(num1, num2){
  return num1 + num2;
}
{% endhighlight %}

If you run the mutation test again, you can see all the mutations being killed.

This is one of the side benefit of equivalent mutations, although your test suite is fine, it tells you that your program code has dead code or untestable code.

<h1>Next Steps</h1>

By now you should have a rough idea about how mutation testing works, and how to actually apply them in your JavaScript project. If you are interested in mutation testing, there are more interesting questions you can dive into, for example, how to use code coverage data to reduce the test you need to run? How to avoid equivalent mutations? I hope you'll find many interesting methods you can apply to your testing work. You can submit issues and suggestions to the Stryker [GitHub repository](https://github.com/stryker-mutator/stryker), or even contribute code to them. The team is very responsive and friendly. Happy Mutation Testing!
