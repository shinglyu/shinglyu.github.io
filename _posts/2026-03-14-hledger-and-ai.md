---
layout: post
title: "hledger and AI: Managing Your Finances in Plain Text"
categories: blog
date: 2026-03-14 12:00:00 +0100
excerpt_separator: <!--more-->
tags: [hledger, personal-finance, AI, plain-text-accounting, dutch-box3]
---

I was scrolling through YouTube late one evening when a video on [plain text accounting](https://plaintextaccounting.org/) caught my eye. It immediately clicked.

I've been managing my finances with a patchwork of Excel spreadsheets for years — one quarterly balance sheet, one income statement, and a few ad hoc sheets for tax calculations. They work, until they don't. Formulas drift. Unbalanced accounts go unnoticed. And importing CSVs downloaded from my bank apps involves a tedious amount of manual cleanup every time.

<!--more-->

Then there's the Dutch tax system. If you live in the Netherlands, you're probably familiar with Box 3 — the wealth tax on savings and investments. In the past it was based on fictional flat returns, calculated from your balance on January 1st. The new system asks for your actual return, which requires a lot more detailed numbers — especially if you hold foreign currency accounts (say, a savings account in Taiwan while living in Amsterdam). You need the EUR-equivalent balance on January 1st for the declaration, and you need to track currency gains and losses for the actual-return calculation. In Excel, this is painful. I needed something better.

That's where [hledger](https://hledger.org/) came in.

## What is plain text accounting?

Plain text accounting applies the [double-entry bookkeeping](https://en.wikipedia.org/wiki/Double-entry_bookkeeping) idea to a simple, human-readable text file. The format is open, version-controllable, and doesn't require any proprietary software to read.

The core idea is the same as traditional accounting: every transaction affects at least two accounts, and debits always equal credits. But instead of a spreadsheet or dedicated accounting software, you write it like this:

```journal
2024-01-25 Employer
    assets:checking              3000.00 EUR
    income:salary               -3000.00 EUR  ; you can omit this line — hledger infers it
```

That's it. hledger reads these journal files and can generate balance sheets, income statements, and all sorts of reports. The text file is the source of truth. You can read it in any text editor, diff it with `git`, and process it with any tool you want.

hledger always checks that every transaction is balanced — debits must equal credits. This catches mistakes before they compound. You can also declare an expected balance at any point in time (a "balance assertion") to cross-check against a real bank statement. For example, if your January statement says the account ended at 7,549.20 EUR, you write `= 7549.20 EUR` after the posting amount:

```journal
2024-01-25 Employer
    assets:checking              3000.00 EUR = 7549.20 EUR  ; balance assertion
    income:salary               -3000.00 EUR
```

hledger verifies the running total matches that number when it processes the transaction. If anything is off, it tells you immediately.

There's also the `--strict` flag, which goes further: it checks that every account name you've used has been explicitly declared. If you mistype an account name — `expneses:food` instead of `expenses:food` — hledger will catch it instead of silently creating a phantom account.

## Example 1: the basics

Let me show you what a month of personal finances looks like. Here's a simple journal file:

```journal
; Opening balance
2024-01-01 Opening balance
    assets:checking              5000.00 EUR
    equity:opening-balances

; Salary income
2024-01-25 Employer
    assets:checking              3000.00 EUR
    income:salary               -3000.00 EUR  ; you can omit this line — hledger infers it

; Groceries
2024-01-10 Albert Heijn
    expenses:food:groceries       120.50 EUR
    assets:checking

2024-01-17 Albert Heijn
    expenses:food:groceries        95.30 EUR
    assets:checking

2024-01-24 Albert Heijn
    expenses:food:groceries       110.00 EUR
    assets:checking

; Utilities
2024-01-15 Power Company
    expenses:utilities:electricity  80.00 EUR
    assets:checking

; Dining out
2024-01-20 Local restaurant
    expenses:food:dining-out       45.00 EUR
    assets:checking
```

From this, I can generate a balance sheet:

```bash
$ hledger -f example1.journal bs
Balance Sheet 2024-01-25

                 ||  2024-01-25
=================++=============
 Assets          ||
-----------------++-------------
 assets:checking || 7549.20 EUR
-----------------++-------------
                 || 7549.20 EUR
=================++=============
 Liabilities     ||
-----------------++-------------
-----------------++-------------
                 ||
=================++=============
 Net:            || 7549.20 EUR
```

And an income statement:

```bash
$ hledger -f example1.journal is
Income Statement 2024-01-01..2024-01-25

                                || 2024-01-01..2024-01-25
================================++========================
 Revenues                       ||
--------------------------------++------------------------
 income:salary                  ||            3000.00 EUR
--------------------------------++------------------------
                                ||            3000.00 EUR
================================++========================
 Expenses                       ||
--------------------------------++------------------------
 expenses:food:dining-out       ||              45.00 EUR
 expenses:food:groceries        ||             325.80 EUR
 expenses:utilities:electricity ||              80.00 EUR
--------------------------------++------------------------
                                ||             450.80 EUR
================================++========================
 Net:                           ||            2549.20 EUR
```

The numbers balance — always. Not because I checked them manually, but because every transaction is double-entry. The math is structural.

## Example 2: tracking investments with market prices

hledger has a `P` directive — a way to record market prices over time. This lets you track your investments not just by cost basis, but by current market value.

```journal
; Opening balance
2024-01-01 Opening balance
    assets:checking              10000.00 EUR
    equity:opening-balances

; Buy 10 shares of VWRL ETF at 100 EUR each
2024-01-15 Buy VWRL
    assets:investments:VWRL        10 VWRL @ 100.00 EUR
    assets:checking              -1000.00 EUR

; Buy 5 more shares in February
2024-02-15 Buy VWRL
    assets:investments:VWRL         5 VWRL @ 105.00 EUR
    assets:checking               -525.00 EUR

; Market prices throughout the year
P 2024-01-31 VWRL 100.00 EUR
P 2024-02-29 VWRL 105.00 EUR
P 2024-03-31 VWRL 108.00 EUR
P 2024-06-30 VWRL 115.00 EUR
P 2024-09-30 VWRL 118.00 EUR
P 2024-12-31 VWRL 120.00 EUR
```

What did I pay (cost basis)?

```bash
$ hledger -f example2.journal bal assets:investments --cost
         1525.00 EUR  assets:investments:VWRL
```

What is it worth at the end of the year?

```bash
$ hledger -f example2.journal bal assets:investments -V --end 2025-01-01
         1800.00 EUR  assets:investments:VWRL
```

I can also see how the portfolio value and full balance sheet change each quarter using the `--quarterly` flag:

```bash
$ hledger -f example2.journal bs --quarterly -V
Balance Sheet 2024-03-31..2024-12-31, valued at period ends

                         ||   2024-03-31    2024-06-30    2024-09-30    2024-12-31
=========================++========================================================
 Assets                  ||
-------------------------++--------------------------------------------------------
 assets:checking         ||  8475.00 EUR   8475.00 EUR   8475.00 EUR   8475.00 EUR
 assets:investments:VWRL ||  1620.00 EUR   1725.00 EUR   1770.00 EUR   1800.00 EUR
-------------------------++--------------------------------------------------------
                         || 10095.00 EUR  10200.00 EUR  10245.00 EUR  10275.00 EUR
=========================++========================================================
 Liabilities             ||
-------------------------++--------------------------------------------------------
-------------------------++--------------------------------------------------------
                         ||
=========================++========================================================
 Net:                    || 10095.00 EUR  10200.00 EUR  10245.00 EUR  10275.00 EUR
```

15 VWRL shares × 120 EUR = 1800 EUR. My cost was 1525 EUR, so I'm up 275 EUR. That took a handful of commands. In Excel, I would have needed a running price table and careful VLOOKUP formulas — and a mistake in any cell would silently corrupt the result.

## Example 3: Dutch Box 3 — foreign currency savings account

This is the example that made me fully commit to hledger. For Box 3, I need to report the EUR-equivalent balance of my foreign currency savings account on January 1st each year, and also track currency gains and losses for the actual-return calculation.

*(Disclaimer: I'm not an accountant and this is not professional financial or tax advice. Always consult a qualified professional for your specific situation.)*

I have a savings account in Taiwan (TWD). Here's how I model it — I record exchange rates with `P` directives and then track all deposits and withdrawals:

```journal
; Exchange rate P directives (TWD to EUR, approximate rates for illustration)
P 2023-01-01 TWD 0.030 EUR
P 2023-06-01 TWD 0.028 EUR
P 2023-12-31 TWD 0.029 EUR
P 2024-01-01 TWD 0.029 EUR
P 2024-06-01 TWD 0.027 EUR
P 2024-12-31 TWD 0.026 EUR

; Opening balance
2023-01-01 Opening balance - Taiwan savings
    assets:savings:taiwan-bank      100000 TWD
    equity:opening-balances

; Savings deposit
2023-06-01 Savings deposit
    assets:savings:taiwan-bank       50000 TWD
    income:other

; Cash withdrawal for expenses
2023-09-01 Cash withdrawal
    expenses:other                   30000 TWD
    assets:savings:taiwan-bank

; Balance at 2024-01-01 is 120,000 TWD

; Close the account at end of 2024
2024-12-31 Close Taiwan savings account
    assets:savings:taiwan-bank      -120000 TWD
    equity:opening-balances
```

**Balance on January 1st** (for the Box 3 declaration):

```bash
$ hledger -f example3.journal bal assets:savings --end 2024-01-02 --value=then,EUR
        3560.000 EUR  assets:savings:taiwan-bank
```

The `--value=then,EUR` flag converts each TWD amount to EUR at the exchange rate in effect at the time of that transaction. So the 100,000 TWD opening at rate 0.030 = 3,000 EUR, plus the 50,000 TWD deposit at 0.028 = 1,400 EUR, minus the 30,000 TWD withdrawal at 0.028 = 840 EUR. Total: 3,560 EUR.

**EUR value of the account at the end of the year** (after closing):

To see the full picture of what each transaction was worth in EUR at the time, I use the account register:

```bash
$ hledger -f example3.journal areg assets:savings --value=then,EUR
Transactions in assets:savings and subaccounts:
2023-01-01 Opening balance - Taiwan savings  eq:opening-balances  3000.000 EUR  3000.000 EUR
2023-06-01 Savings deposit                   in:other             1400.000 EUR  4400.000 EUR
2023-09-01 Cash withdrawal                   ex:other             -840.000 EUR  3560.000 EUR
2024-12-31 Close Taiwan savings account      eq:opening-balances -3120.000 EUR   440.000 EUR
```

The account started with 3,000 EUR worth of TWD, received another 1,400 EUR worth, then withdrew 840 EUR worth. At the end of 2024, I closed it by withdrawing 120,000 TWD at the then-current rate of 0.026, which was worth 3,120 EUR. The "440 EUR" final balance in the register is the currency loss — we put in more EUR-equivalent than we got back because TWD depreciated against EUR. To make the sign intuitive (negative = loss), add `--invert`:

```bash
$ hledger -f example3.journal bal assets:savings --value=then,EUR --invert
        -440.000 EUR  assets:savings:taiwan-bank
```

The −440 EUR is the net currency loss over the account's lifetime.

**Inflows and outflows for the year:**

You can also break down total deposits and withdrawals by filtering on the amount sign:

```bash
$ hledger -f example3.journal bal assets:savings --value=then,EUR 'amt:>0'
        4400.000 EUR  assets:savings:taiwan-bank

$ hledger -f example3.journal bal assets:savings --value=then,EUR 'amt:<0'
       -3960.000 EUR  assets:savings:taiwan-bank
```

4,400 EUR went in (in EUR terms at the time of each deposit), 3,960 EUR came out. The 440 EUR difference is exactly the currency loss.

This would be excruciating to track correctly in Excel. With hledger, it's a few flags.

## Why plain text accounting works well with AI

**AI writes the import rules once; you run them forever.** Most banks let you export transactions as CSV. hledger has a rule-based CSV import system. You show the AI a sample CSV from your bank, and it generates a rules file like this (this is an example, not an actual rules file):

```text
# bank_export.csv.rules

source bank_export.csv

skip 1

fields date, description, amount, balance

date-format %Y-%m-%d
currency EUR
account1 assets:checking

if albert heijn
  account2 expenses:food:groceries

if power co
  account2 expenses:utilities:electricity

if restaurant
  account2 expenses:food:dining-out

if salary
  account2 income:salary
```

From then on, you run `hledger import bank_export.csv` and everything gets categorized automatically — no AI involved, no tokens spent, fully deterministic. The AI writes the pattern-matching rules once; you benefit from them forever.

**Privacy-friendly AI use.** If you care about your financial data going to cloud AI providers, you have options. You can run a local LLM (like Llama via [Ollama](https://ollama.com/)). Or, since the AI only needs to understand the *structure* of your CSV to write import rules, you can replace real account names and numbers with dummy ones before sharing. The rules will work exactly the same on your real data.

**Future-proof by design.** hledger is open source. The file format is a documented plain text standard. If hledger disappeared tomorrow, the data is still just text — you can read it, write a parser, convert it, or ask an AI to migrate it to any other tool.

**A caveat on AI and hledger.** Most AI models haven't seen much hledger in their training data, so they do hallucinate commands and flags. I've found that providing the relevant section of the [hledger documentation](https://hledger.org/hledger.html) in the prompt helps a lot. The [hledger Matrix chat room](https://matrix.to/#/#hledger:matrix.org) is also friendly and helpful when you get stuck — the community there is small but active.

**Ask AI questions, run hledger answers.** The plain text journal is something any LLM can read and reason about directly. A nice workflow is to ask the AI a question about your finances, and instead of having it answer based on the journal directly (which risks hallucinating numbers), ask it to generate the hledger command that answers the question. Then you run the command yourself and get a deterministic, trustworthy result.

For a simple question like *"How much did I spend on food in January?"* the AI would respond with:

> Run: `hledger -f example1.journal bal expenses:food -p 2024-01`

```bash
$ hledger -f example1.journal bal expenses:food -p 2024-01
           45.00 EUR  expenses:food:dining-out
          325.80 EUR  expenses:food:groceries
--------------------
          370.80 EUR
```

But the AI really shines on multi-step questions that require reasoning across the data. For example: *"My total expenses last month were 450.80 EUR. Which category is taking the biggest share, and where could I realistically cut spending?"*

A good AI response would first ask for a category breakdown:

> Run: `hledger -f example1.journal bal expenses --depth 2 -p 2024-01`

```bash
$ hledger -f example1.journal bal expenses --depth 2 -p 2024-01
          370.80 EUR  expenses:food
           80.00 EUR  expenses:utilities
--------------------
          450.80 EUR
```

Then, seeing that food is 370.80 out of 450.80 total (about 82%), and groceries dominate within that, it might suggest drilling into groceries:

> Run: `hledger -f example1.journal bal expenses:food:groceries -p 2024-01`

```bash
$ hledger -f example1.journal bal expenses:food:groceries -p 2024-01
          325.80 EUR  expenses:food:groceries
```

325.80 EUR on groceries, across three trips. The AI now has enough data to say: "Groceries are 72% of total spending. If you want to cut 20% overall, reducing your grocery runs from 3 to 2 per month would get you most of the way there." All numbers came from deterministic hledger commands, not AI guesswork.

## Getting started

If you want to try this, the [hledger website](https://hledger.org/) has good documentation and [a quick start guide](https://hledger.org/5-minute-quick-start.html).

Start small. Create a journal file, record a week of transactions, and run `hledger is` to see your income statement. Once you see how clean the numbers are — and how easy it is to verify them — going back to spreadsheets feels like going back to a flip phone.

There's a lot I haven't touched on here: setting up budgets and tracking actual vs. planned spending, handling multiple currencies simultaneously, calculating investment ROI over time. hledger has features for all of these — worth exploring once you're comfortable with the basics.

Plain text tools and AI are a natural fit. hledger is a way to move your finances into the AI age.

