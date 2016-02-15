---
layout: post
title:  "Mutation Testing in JavaScript Using Grunt Mutation Testing"
date:   2016-02-15 00:00:00
categories: Testing
---

* Slide show version: [link](https://shinglyu.github.io/my_presentations/QA_Sharing_Session_3_Mutation_Testing_Workshop.html)
* Code example: [github link](https://github.com/shinglyu/JS-mutation-testing-example)

This November I attended the EuroStar Software Testing Conference, and was introduced to a interesting idea called mutation testing. Ask yourself: "How do I ensure my (automated) unit test suite is good enough?". Did you miss any important test? Is your test always passing so it didn't catch anything? Is there anything un-testable in your code such that your test suite can never catch it?

<h1>Introduction to Mutation Testing</h1>

Mutation testing tries to "test your tests" by deliberately inject faults (called "mutants")into your program under test. If we re-run the tests on the crippled program, our test suite should catch it (i.e. some test should fail.) If you missed some test, the error might slip through and the test will pass. Borrowing terms from Genetics, if the test fails, we say the mutant is "killed" by the test suite; on the opposite, if the tests passes, we say the mutant survived.

The goal of mutation testing is to kill all mutants by enhancing the test suite. Although 100% kill is usually impossible for even small programs, any progress on increasing the number can still benefit your test a lot.

The concept of mutation testing has been around for quite a while, but it didn't get very popular because of the following reasons: first, it is slow. The number of possible mutations are just too much, re-compiling (e.g. C++) and re-run the test will take too long. Various methods has been proposed to lower the number of tests we need to run without sacrifice the chance of finding problems. The second is the "equivalent mutation" problem, which we'll discuss in more detail in the examples.

<h1>Mutation Testing from JavaScript</h1>

There are many existing mutation testing framework. But most of them are for languages like Java, C++ or C#. Since my job is mainly about JavaScript (both in browser and Node.js), I wanted to run mutation testing in JavaScript.

I have found a few mutation testing frameworks for JavaScript, but they are either non-open-source or very academic. The only one I can get started without effort is the <a href="https://www.npmjs.com/package/grunt-mutation-testing">grunt-mutatoin-testing</a> on <code>npm</code>. Therefore we will show you some example using it.

This framework supports mutants like changing the math operators, remote elements from arrays or changing comparison operators. You can find a full list of mutations with examples <a href="https://www.npmjs.com/package/grunt-mutation-testing#available-mutations">here</a>.

<h1>Setting up the environment</h1>

You can follow along by cloning this repository -- <a href="https://github.com/shinglyu/JS-mutation-testing-example">JS-mutation-testing-example</a>, you'll also need <code>node</code> and <code>npm</code> installed. (I recommended you to use <a href="https://github.com/creationix/nvm">nvm</a>).

There are a few Node packages you need to install,

<pre>
<code lang="bash">
sudo npm install -g mocha
sudo npm install -g grunt-cli
npm install . #This installs the dependencies in pakcages.json
</code>
</pre>

The <code>npm install .</code> command will install the following packages from <code>packages.json</code>

<pre>
<code lang="javascript">
//===== packages.json =====
{
  ...
  &quot;devDependencies&quot;: {
    &quot;grunt-mutation-testing&quot;: &quot;~1.3.0&quot;,
    &quot;grunt&quot;: &quot;~0.4.5&quot;,
    &quot;karma&quot;: &quot;~0.13.15&quot;
  }
}
</code>
</pre>

The <code>grunt-mutation-testing</code> is self-explanatory. As the name implies, it runs in the <a href="http://gruntjs.com/">Grunt</a> task runner. <code>Grunt</code> requires you to install a global <code>grunt-cli</code> package and a local <code>grunt</code> package. In order for the mutation testing framework to run the test, we need a test runner. <code>grunt-mutation-testing</code>'s default is <a href="http://karma-runner.github.io">karma</a>, but I'll use <code>mocha</code> instead. (You still need to install <code>karma</code> otherwise the <code>grunt-mutation-testing</code> will complain.)

<h1>A simple test suite</h1>

I created a simple program in <code>src/calculator.js</code>, which has two functions:

<pre>
<code lang="javascript">
// ===== calculator.js =====
function substractPositive(num1, num2){
  if (num1 &gt; 0){
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
  else if (num1 &gt; num2){
    return num1 + num2;
  }
  else {
    return num1 + num2;
  }
}

module.exports.substractPositive = substractPositive
module.exports.add = add;
</code>
</pre>

The first is <code>substractPositive</code>, it substract <code>num2</code> from <code>num1</code> if <code>num1</code> is a positive number. If <code>num1</code> is not positive, it will return <code>0</code> instead. It doesn't make much sense, but it's for demostration purpose.

The second is a simple <code>add</code> function that adds two numbers. It has a useless <code>if...else</code> statement, which is also used to demostrate the power of mutation testing.

The two functions are tested using <code>test/test_calculator.js</code>:

<pre>
<code lang="javascript">
var assert = require(&#039;assert&#039;);
var cal = require(&#039;../src/calculator.js&#039;)

describe(&#039;Calculator&#039;, function(){
  it(&#039;substractPositive&#039;, function(){
    assert.equal(&#039;2&#039;, cal.substractPositive(1, -1));
  });

  it(&#039;add&#039;, function(){
    assert.equal(&#039;2&#039;, cal.add(1, 1));
  });
})
</code>
</pre>

This is a test file running using <code>mocha</code>, The first verifies <code>substractPositive(1, -1)</code> returns <code>2</code>. The second tests <code>add(1,1)</code> produces <code>2</code>. If you run <code>mocha</code> in your commandline, you'll see both the test passes.

So this test suite looks pretty good, it exerices both function and verifies its output, but is it good enough? Let's verify this by some mutation testing.

<h1>Running the mutation testing</h1>

To run the mutation testing, we need to setup a <code>grunt</code> task called <code>mutationTest</code> by creating a <code>Gruntfile.js</code>

<pre>
<code lang="javascript">
//===== Gruntfile.js =====

module.exports = function(grunt) {
  grunt.initConfig({
    mutationTest: {
      options: {
        testFramework: &#039;mocha&#039;
      },
      target: {
        options:{
          code: [&#039;src/*.js&#039;],
          specs: &#039;test/test_*.js&#039;,
          mutate: &#039;src/*.js&#039;
        }
      }
    }
  });

  grunt.loadNpmTasks(&#039;grunt-mutation-testing&#039;);

  grunt.registerTask(&#039;default&#039;, [&#039;mutationTest&#039;]);
};
</code>
</pre>

You can see wee choose <code>mocha</code> as the <code>testFramework</code>, and we tell the <code>grunt-mutation-testing</code> framework to run the test files specified in <code>specs</code> on the source files <code>code</code>. The <code>code</code> files may include third-party libraries, which we may not want to mutate, so we need to specify the exact files we want to mutate using <code>mutate</code> field. The three fields can either be a single pattern string or an array of strings.

We register the <code>mutationTest</code> as our default task, so when we run <code>grunt</code> in the commandline, it will run <code>mutationTest</code> directly.

#Finding Missing Tests

Now if we run <code>grunt</code>, you'll see the following test result:

<pre>
<code lang="bash">
% grunt  
Running &quot;mutationTest:target&quot; (mutationTest) task
(17:34:23.955) INFO [mutation-testing]: Mutating file: /tmp/mutation-testing1151016-11404-alnz38/src/calculator.js
(17:34:23.957) INFO [mutation-testing]: Mutating line 1, 1/22 (5%)
(17:34:23.959) INFO [mutation-testing]: Mutating line 10, 2/22 (9%)
(17:34:24.677) INFO [mutation-testing]: Mutating line 23, 3/22 (14%)
(17:34:24.679) INFO [mutation-testing]: Mutating line 24, 4/22 (18%)
(17:34:24.680) INFO [mutation-testing]: Mutating line 2, 5/22 (23%)
(17:34:24.682) INFO [mutation-testing]: Mutating line 2, 6/22 (27%)

/src/calculator.js:2:11 Replaced  &gt;  with &gt;= -&gt; SURVIVED
(17:34:24.684) INFO [mutation-testing]: Mutating line 2, 7/22 (32%)
(17:34:24.686) INFO [mutation-testing]: Mutating line 2, 8/22 (36%)
(17:34:24.688) INFO [mutation-testing]: Mutating line 3, 9/22 (41%)
(17:34:24.689) INFO [mutation-testing]: Mutating line 3, 10/22 (45%)
(17:34:24.690) INFO [mutation-testing]: Mutating line 6, 11/22 (50%)

/src/calculator.js:6:5 Removed return 0 -&gt; SURVIVED
...
12 of 22 unignored mutations are tested (54%).

Done, without errors.
</code>
</pre>

This line is a killed mutant,

<pre>
<code lang="text">
(17:34:23.959) INFO [mutation-testing]: Mutating line 10, 2/22 (9%)
</code>
</pre>

and this is a survived mutant,

<pre>
<code lang="text">
/src/calculator.js:2:11 Replaced  &gt;  with &gt;= -&gt; SURVIVED
</code>
</pre>

It tells us that by replacing the <code>&gt;</code> with <code>&gt;=</code> in line 2, column 11 of our `calculator.js` file, the test will pass. 

If you look the line, the problem is pretty clear

<pre>
<code lang="javascript">
// ===== calculator.js =====
function substractPositive(num1, num2){
  if (num1 &gt; 0){ # This line
    return num1 - num2;
  }
  else {
    return 0
  }
}
</code>
</pre>

We didn't test the boundary values, if `num1 = 0`, then the program should go to the `else` branch and returns `0`. By changing the <code>&gt;</code> to <code>&gt;=</code>, the program will go into the <code>num1 &gt;= 0</code> branch and returns `0 - num2`!

This is one of the power of mutation testing, it tells you which condition you are missing. The solution is very simple, we can add a test like this:

<pre>
<code lang="text">
it('substractPositive', function(){
  assert.equal('0', cal.substractPositive(0, -1));
});
</code>
</pre>

If you run mutation testing again, the problem with the <code>substractPositive</code> function should go away.

<h1>Equivalent Mutation and Dead Code</h1>

Sometimes the mutation will not change the behavior of the program, so no matter what test you write, you can never make it fail. So example, a mutation may disable caching in your program, the program will run slower but the behavior will be exactly the same, so you'll have a mutation you can never kill. This kind of mutation is called "equivalent mutation".

Equivalent mutation will make you overestimate your mutation survival rate. And they take your time to debug, but may not reveal useful information about your test suite. However, some equivalent mutations do reveal issues about your program under test.

Let look at the mutation results again:

<pre>
<code lang="javascript">
/src/calculator.js:11:11 Replaced  ==  with != -&gt; SURVIVED
/src/calculator.js:14:16 Replaced  &gt;  with &gt;= -&gt; SURVIVED
/src/calculator.js:14:16 Replaced  &gt;  with &lt;= -&gt; SURVIVED
/src/calculator.js:15:5 Removed return num1 + num2; -&gt; SURVIVED
/src/calculator.js:15:16 Replaced  +  with - -&gt; SURVIVED
/src/calculator.js:18:5 Removed return num1 + num2; -&gt; SURVIVED
/src/calculator.js:18:16 Replaced  +  with - -&gt; SURVIVED
</code>
</pre>

If you look at the code, you'll find that all the branches of the <code>if...else</code> statement returns the same thing. So no matter how you mutate the <code>if...else</code> conditions, the function will always return the correct result.

<pre>
<code lang="javascript">
10 function add(num1, num2){
11   if (num1 == num2){
12     return num1 + num2;
13   }
14  else if (num1 &gt; num2){
15     return num1 + num2;
16   }
17  else {
18     return num1 + num2;
19   }
20 }
</code>
</pre>

But the <code>if...else</code> is useless, you can simplify the function to only three lines:

<pre>
<code lang="javascript">
function add(num1, num2){
  return num1 + num2;
}
</code>
</pre>

If you run the mutation test again, you can see all the mutations being killed.

This is one of the side benefit of equivalent mutations, although your test suite is fine, it tells you that your program code has dead code or untestable code.

<h1>Next Steps</h1>

By now you should have a rough idea about how mutation testing works, and how to actually apply them in your JavaScript project. If you are interested in mutation testing, there are more interesting question you can dive into, for example, how to use code coverage data to reduce the test you need to run? How to avoid equivalent mutations? I hope you'll find many interesting methods you can apply to your testing work.
