---
layout: post
title: 如何貢獻開源專案？
categories: Web
date: 2018-05-12 17:55:42 +02:00
tags: mozilla
excerpt_separator: <!--more-->
---
貢獻開源專案是一個提高自己技能的好機會，同時也能提昇自己在軟體界的能見度與溝通技巧。以下是我貢獻 Mozilla 的 [Servo][servo] 瀏覽器引擎的一些心得，提供想要一探開源的新手一些方向。

<!--more-->
# 心理準備
首先你要問自己為什麼你想要貢獻開源？是為了提高軟體技術？為了充實履歷表？畢竟能做的專案太多，更別說自己開新專案，所以必須先想清楚自己的初衷，然後找到一個適合自己的需求又能有所貢獻的專案。 要找到適合的專案，可以優先從以下方向開始看：

1. 自己正在使用的開源工具/框架/程式語言
2. 自己想學習的新開源技術
3. 自己非常需要的工具，自己開新專案

專案首先一定要對自己有用，否則很難有動力繼續做下去。寫軟體的很大一個動力來自於巧妙的利用程式解決了自己的問題的成就感。如果這個成果又能被其他人使用的話，就是一個更強烈的正向循環。

另外一個常見的錯誤是因為覺得自己技術底子不夠，所以把所有時間花在讀書而沒有動手實做。任何一個程式語言的書絕對都夠你讀個三年五年，更別說每個專案有其背景知識，例如 Web 技術、瀏覽器技術、編譯器、作業系統，即使是大學本科花四年也只能學到皮毛，所以所謂「我先把該學的學完就可以開始貢獻了」絕對是一個癡人說夢的想法。最好的方法是開始從簡單的 bug 下手，例如修一些 typo 或是非常簡單的錯誤，一方面可以練習整個專案的開發流程，也可以開始與專案的其他貢獻者互動。假設程式本身真的太難，也有一些比較簡單的開始方式，例如幫忙撰寫或翻譯技術文件、主辦讀書會、寫部落格分享自己的學習心得、回報軟體的錯誤等等。這些方法可以一邊學習專案本身的技術，同時又開始在社群中培養一些能見度。

最後，開源專案是由人組成的，因此溝通（以及誤解）是逃避不了的。很多時候活躍的專案因為開發速度太快，很少會有完整的文件，很多時候一些架構設計、know-how 可能都在幾個核心成員的腦中。因此當你盡了自己所能讀完了文件與原始碼，還是無法獲得解答的時候，最快的方法就是去專案的聊天室或討論區裡面發問。很多時候你花了幾天讀不懂的原始碼可能只是因為某些歷史原因而這麼複雜，只要簡單一問就能夠馬上進步。不同社群之間的溝通模式差異很大，有些社群內可能核心成員真的很忙，或是比較精英主義，對於新手就會比較冷漠。這時候也只能盡量保持客氣，一般來說只要你的貢獻對社群真的有用，隨著時間過去總是會慢慢被接納。若是社群成員真的太惡意，你大可以找其他的專案貢獻。

以下將以我 2014 年開始貢獻的 Servo 專案作為例子，跟大家介紹一下如何一步一步的開始貢獻。

# 基礎知識 
以下有些基礎技能你最好先學會（或是先掃過一下教學文件然後邊做邊學）：

* git: 幾乎所有開源專案都有某種版本控制系統，而 git 是最常見的一種。
  * 感謝 [Denny][denny] 的 [教學投影片][git-slides]
  * 感謝 [葉闆][yodalee] 的[教學影片][git-video]以及[Pull request 介紹][pr-intro]

* GitHub: GitHub 是一個 git 的託管服務，同時他也提供一些協作的功能例如 pull request， issues。熟悉 GitHub 可以幫助你找到數以千計的開源專案，並且快速的加入開發。
  * [基本觀念（中文）][github-zh]
  * [基本流程（英文）][github-en]
  * [Fork（英文）][github-fork-en]

# 找尋可以貢獻的 bug
Servo 的 bug (程式缺陷) 或是新功能請求都在 GitHub 上管理，可以至 Servo 的 [Issues 頁面][issues]瀏覽。 適合新手的 bug 都蒐集在 [Servo Starters][starters] 頁面上，也可以至 Servo Issues 直接查詢[有 E-easy 標籤的 bug][easy]。 

![servo starters][servo starters]

找到 issue 以後，試著理解問題是什麼，如果下面留言中沒有人表示想要做，就可以立刻留言表示興趣，並且向開 bug 的人請求進一步的指示或協助。以下是一個範例的回應：

> Hi @<username>, I'm interested in this issue.

* 想要知道相關原始碼在哪裡 => Could you point me to the relevant code/file?
* 想要知道如何重現出這個問題 => Could you tell me the exact step to reproduce this issue?
* 想要知道相關的標準規範 (W3C, WHATWG, etc. ) => Could point me to the relevant spec?
* 看不太懂也不知道要問什麼，希望對方進一步說明 => Could you give me more information on how this thing works and how I should proceed?

# 如何下載、修改並測試 Servo 的原始碼
要取得 Servo 的程式碼開始修改，首先要從 Servo 官方的 repository "fork" 出一版，按下右上方的 "Fork" 按鈕，你的帳號下就會出現一個 `servo` repository。(詳見[Forking][forking])。需要這麼做的原因是因為一般使用者沒有權限直接修改 servo/servo 的原始碼，所以你必須複製("fork")一份自己的版本，修改完以後在把改動提交給官方審核 (也就是所謂的 Pull Request，也可以參考這篇[文章][pr-intro])。一旦官方對你的 pull request 滿意的話，就會被 merge 到 master，你修改的部份就正式進到 servo 裡面了。

![fork button][fork]

接下來你就可以從你剛剛 fork 出來的 servo repository 按下 "Clone or download"，取得 clone 用的網址。接下來開啟一個終端機，輸入 `git clone git@github.com/<你的帳號>/servo.git` (把<你的帳號>代換成你的 clone 網址)。這個下載需要耗費不少時間，記得確保你的網路暢通，就可以去泡杯咖啡慢慢等候了。

![forked][forked]

等下載完畢，首先要做的就是確保你的環境能夠正確的編譯並執行 servo。Servo 的文件中有寫出各個平台所需要事先安裝的一些套件(看[這裡][prerequsite]) ， 例如 Ubuntu 就需要安裝

```
sudo apt install git curl freeglut3-dev autoconf libx11-dev \
       libfreetype6-dev libgl1-mesa-dri libglib2.0-dev xorg-dev \
       gperf g++ build-essential cmake virtualenv python-pip \
       libssl-dev libbz2-dev libosmesa6-dev libxmu6 libxmu-dev \
       libglu1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libdbus-1-dev
```

然後執行 `./mach build --dev` 來試著編譯。注意除了 OSX 與 Linux 外，其他平台的狀況都不是很穩定，所以如果無法順利編譯也不要氣餒，記得到 [issues][issues] 看看有沒有其他人也遇到一樣的問題，或是開個新 issue 尋求協助 （記得附上你遇到的錯誤訊息）。

一但編譯順利，你就可以跑 `./mach run` 來測試 servo 是否正常運作，你應該會看到 servo 開啟一個視窗，並且載入 servo 的官方網站。你也執行 `./mach run -b` 試試看一個用 HTML 打造的簡易瀏覽器界面 [browser.html][browser.html]。

![browserhtml][browserhtml]

如果你編譯一切順利，恭喜！你可以開始動工了。通常我們會為每一個 issue 或是功能開一個新的 branch，以方便切換。當你完成更改以後，記得 commit 並且寫上清楚的 commit 訊息。一般來說好的 commit message 可以寫成：
* Implemented <a JavaScript API, CSS property or other feature> (實作了<一個 JavaScript API、CSS 屬性或其他功能>)，例如 Implemented window.open(), 或是 Implemented CSS grid
* Modified/Fixed/Changed <some part of the code> to <provide some benefit> (修改/修正/改動了<某個部份>來<提供某些好處>)， 例如 Change the internal implementation of class Foo to enhance readabiltiy。

舉例來說，假設我們要實作 `window.open()` 這個 JavaScript API， 我們可以

```
git branch -b window-open # 開啟一個叫 window-open 的 branch
git checkout window-open
# 實作 window open
./mach build -d  # 確定編譯會過
git commit -m "Implemented window.open()"
git push -u origin window-open # 把 window-open branch 上的東西推到你的 servo repo
```

# 如何提交 Pull Request
當你的更改完成，記得先檢查以下幾點，以免浪費其他人的時間：
* `./mach build -d` 可以順利編譯。
* `./mach test-tidy` 會檢查程式風格的問題，例如多餘的空格、錯誤的括號位置、行長度過長之類的問題。
* 相關的測試有通過（不知道要跑什麼測試的話，請到原始的 issue 中問）:
  * `./mach test-unit` 單元測試
  * `./mach test-wpt` web platform test， 主要測試 JS/CSS 相關功能是否符合標準規範

如果都通過就可以到 servo/servo，選 Pull requests 然後按 New pull request。接下來按 compare across forks，然後head fork 選擇 <你的帳號>/servo， compare 選擇你要提交的 branch。簡單檢查一下下面出現的程式碼，如果沒有問題就可以按 Create pull request。

![open pr][openpr]

當你一開 pull request，servo 的 highfive 聊天機器人就會自動跳出來跟你打招呼，並且幫你指定一個 reviewer。所有提交到 servo 的程式碼都需要通過他人審核，這也是一般 open source 專案的慣例，不過 servo 的 reviewer 都相當友善，所以不用太擔心。

![highfive][highfive]

接下來 reviewer 通常會提供你一些修改的建議，這對很多人來說很難為情，因為要把自己寫的程式攤在日光下給人家批評。不過記得 reviewer 都是對事不對人，所以不要把這些評論當作對自己的人身攻擊。這也是一些非常好的學習機會，通常都可以從 reviewer 那邊學到相當 多 servo 內部的知識以及程式風格的建議。

如果要根據 reviewer 的意見修正，只要繼續在自己的那份 servo 上修改、commit、並且 git push 到你自己原來的那個 branch 即可，過給秒鐘後再去重新整理 pull request 的頁面就可以發現已經更新到你新推的程式碼了。經過這樣幾次來回修改直到 reviewer 滿意以後，他可能會做幾件事情：
* 請你 rebase 或 squash，這些操作比較進階，也超出本篇的篇幅，詳細可以參考[這篇手把手教學][squash]。
* 他向另外一隻聊天機器人 @bors-servo 說 "@bors-servo try"，這表示他請 bors-servo 啟動一系列自動測試，但是並不直接 merge 你的 pull request。最後如果測試都通過通常就會進到下一條。
* 他向 bors-servo 說 "@bors-servo r+"，這時候 bors-servo 一樣會先執行一系列測試，如果測試都通過就會直接 merge 你的 pull request。

![r+][r+]

假設有任何測試沒通過，請不要驚慌，根據測試失敗的原因繼續修改你的程式即可。如果看不懂為何會錯也可以直接在 pull request 裡面發問。

以上流程可以看一個例子：[style: Simplify border-image-repeat serialization][pr-example]，從中你可以看到各種機器人如何與 reviewer 合作進行審查與測試。 以上就是完整的從找到問題到成功 merge 一個 pull request 的流程，但是在這過程中有許許多多的小環節都有可能出錯，這時千萬記得隨時發問。

# 哪裡查資料與問問題

Servo 是一個非常複雜而且龐大的專案，而且瀏覽器引擎相關的資料在網路上相當稀少。所以以下我蒐集了一些資源可以幫助你更了解相關的背景知識：

* [How browsers work][how-browsers-work]: 這是目前網路上最完整最全面的瀏覽器引擎介紹，雖然沒有直接介紹 Servo，但是可以幫助你了解瀏覽器引擎大致是如何運作的。
* Matt's [Let's build a browser engine][matt]: Matt Brubeck (也是 Servo 的核心成員) 用實際的 code 介紹如何寫出真正可以運作的瀏覽器引擎。
* [Servo Wiki][wiki]: Servo 官方的 wiki，有一些設計的筆記與投影片，不過似乎有一陣子沒更新，記得要檢查一下是不是太舊。
* Servo code 裡面的註解與文件: Servo 的程式碼中夾雜了不少註解與文件， 假設你在修改某個檔案，記得在同一個資料夾或上下一兩層資料夾找找文件。 
* [WHATWG Spec][whatwg] & [W3C Spec][w3c]: 假設你處理的是 HTML， JavaScript 或是 CSS 的功能，免不了需要查詢一下官方的規範。
![whatwg][whatwg-screenshot]
![w3c][w3c-screenshot]
* [MDN][mdn]: 官方規範太硬太難唸，想要看一下實際上如何使用可以去 MDN 上搜尋。
![mdn][mdn-screenshot]

Servo 的主要成員會定期的巡視 GitHub 上的 issue 與 pull request，所以有 issue 相關的問題可以直接在 GitHub 上發問。另外也可以到 [#servo IRC][irc] 上直接問問題，通常可以更快得到答案。

# 其他人的貢獻經驗
網路上也有不少人分享他們貢獻 Servo 的經驗，例如來自台灣的劉安齊在 Medium 上分享過「[踏入 Mozilla Servo 兩個月的心得][tigercosmos]」。也可以看看 Fausto NA 的 "[My experience contributing to Servo][fausto]"。 開源是一趟冒險，每個人的體驗都會不同，這裡只能介紹一些比較技術性的面向。希望各位都能在這個過程中學到自己想學的，同時又能對社群有所貢獻。


[servo]: https://servo.org/
[issues]: https://github.com/servo/servo/issues
[easy]: https://github.com/servo/servo/issues?utf8=✓&q=is%3Aopen%20is%3Aissue%20label%3AE-easy%20-label%3AC-assigned
[github-zh]: http://www.ithome.com.tw/news/95283
[prerequsite]: https://github.com/servo/servo#setting-up-your-environment
[paulgraham]: http://paulgraham.com/startupideas.html
[denny]: http://denny.one
[git-slides]: http://denny.one/git-slide
[github-en]: https://guides.github.com/activities/hello-world/
[github-fork-en]: https://guides.github.com/activities/forking/
[starters]:https://starters.servo.org 
[forking]: https://git-scm.com/book/zh-tw/v2/GitHub-%E5%8F%83%E8%88%87%E4%B8%80%E5%80%8B%E5%B0%88%E6%A1%88
[pr-example]: https://github.com/servo/servo/pull/20610
[how-browsers-work]: https://www.html5rocks.com/zh/tutorials/internals/howbrowserswork/
[matt]:https://limpet.net/mbrubeck/2014/08/08/toy-layout-engine-1.html 
[wiki]: https://github.com/servo/servo/wiki
[whatwg]: https://html.spec.whatwg.org/ 
[w3c]:https://www.w3.org/Style/CSS/current-work 
[mdn]: https://developer.mozilla.org/zh-TW/
[tigercosmos]: https://medium.com/@tigercosmos/%E8%B8%8F%E5%85%A5-mozilla-servo-%E5%85%A9%E5%80%8B%E6%9C%88%E7%9A%84%E5%BF%83%E5%BE%97-9eaf41e021f9
[fausto]: https://brainlessdeveloper.com/2017/08/12/my-experience-contributing-to-servo/
[irc]: http://chat.mibbit.com/?server=irc.mozilla.org&channel=%23servo
[squash]: https://shinglyu.github.io/web/2016/11/08/servo-rebase-and-squash-guide.html
[servo starters]: {{site_url}}/blog_assets/open_source/servo_starters.png
[fork]: {{site_url}}/blog_assets/open_source/fork.png
[forked]: {{site_url}}/blog_assets/open_source/forked.png
[build]: {{site_url}}/blog_assets/open_source/
[browserhtml]: {{site_url}}/blog_assets/open_source/browserhtml.gif
[browser.html]: https://github.com/browserhtml/browserhtml
[openpr]: {{site_url}}/blog_assets/open_source/openpr.png
[highfive]: {{site_url}}/blog_assets/open_source/highfive.png
[r+]: {{site_url}}/blog_assets/open_source/r+.png
[whatwg-screenshot]: {{site_url}}/blog_assets/open_source/whatwg.png
[w3c-screenshot]: {{site_url}}/blog_assets/open_source/w3c.png
[mdn-screenshot]: {{site_url}}/blog_assets/open_source/mdn.png
[pr-intro]: https://yodalee.blogspot.tw/2014/05/pull-requestgithub.html?m=1
[git-video]: https://yodalee.blogspot.tw/2017/12/git-video.html?m=1
[yodalee]:https://yodalee.blogspot.tw/?m=1
