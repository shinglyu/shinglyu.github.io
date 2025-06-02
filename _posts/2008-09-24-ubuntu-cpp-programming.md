---
layout: post
title: "[Ubuntu教學] 用Ubuntu 寫C++"
date: 2008-09-24
tags: [ubuntu, linux, cpp, programming, tutorial, gedit, g++]
categories: tech
---

> This was an early technical blog I've written on another blogging platform. The content is probably outdated and my writing style was cringey. But I copied it here anyway for archival purposes.

最近因為學校課程需要開始在摸C++  
Windows上的話我用的是Dev C++  
可是在Ubuntu上我還沒找到很順手的IDE(Integrated Development Environment，[集成開發環境](http://zh.wikipedia.org/w/index.php?title=%E9%9B%86%E6%88%90%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83&variant=zh-tw "集成开发环境"))  
用KDevelop狀況連連，編譯一直有問題；Eclipse 灌了可是也還沒摸熟；Anjuta的工具列好像少了什麼......囧  
  
最後我找到一個方法  
某個英文討論串上有個前輩也推荐先用這個方法  
他說初學者應該先搞懂Linux 上編譯的技術，而不是一開始就讓IDE幫你處理的好好的。  
就像讀數學應該先把觀念弄懂，而不是一開始就套速解公式。  
  
==========以下正文開始==========  
  
1.首先要先確定該有的套件都有了  
我們需要安裝build-essential，以及編譯器g++  
在終端機輸入以下這個指令安裝吧  

> sudo apt-get install g++ build-essential

2.接下來其實就可以開始寫程式了，當然你可以用Ubuntu內建的「文字編輯器」（gedit）  
記得要選　顯示>>標示模式>>原始碼>>C++　這樣他會自動幫你套色，看起來比較清楚  
  
![gedit設定](/blog_assets/ubuntu-cpp/gedit.jpg)
  
3.或者你可以用台灣人寫的文字編輯器MadEdit，很好用喔，會自動退格之類的很貼心  
安裝請用指令  

> sudo apt-get install madedit

記得也要 檢視>>語法類型 選C++  
  
![MadEdit設定](/blog_assets/ubuntu-cpp/madedit.jpg)
  
4.記得用g++的時候請在程式的最後按Enter多留一行空白行，不然會編譯時會顯示錯誤訊息：「檔案未以空白列結束(no newline at end of file)」  
  
5.程式寫好存成.cpp檔，接著就可以開始編譯了，例如我們把檔案存在  

> /home/a108210/cpp/

檔名叫  

> hello.cpp

那我們打開終端機，輸入  

> g++ /home/a108210/cpp/hello.cpp -o /home/a108210/cpp/hello.out -Wall

這個指令可以拆開來看  

> g++ /home/a108210/cpp/hello.cpp -o /home/a108210/cpp/hello.out -Wall

*   g++：這是編譯器compiler
*   /home/a108210/cpp/hello.cpp：這是cpp檔案所在位置
*   -o /home/a108210/cpp/hello.out：-o參數後面接的就是要輸出的檔案的位置+名稱，如你所見這邊是/home/a108210/cpp/hello.out
*   -Wall：加這個的目的是讓他把所有的警告訊息都顯示出來，免得他覺得不重要的訊息就自動隱藏了

接下來你就會看到檔案hello.out已經編譯好熱騰騰的躺在/home/a108210/cpp/裏面了  
  
6.接下來我們切換到檔案所在的位置，在終端機輸入：  

> cd /home/a108210/cpp/

7.執行程式吧，輸入：  

> ./hello.out

理論上你照著5.6.7.做的話會看到像這樣  
  
![編譯執行結果](/blog_assets/ubuntu-cpp/out.jpg)
  
那個hello world是因為示範用的程式碼是像這樣的：  

```cpp
#include <iostream>
using namespace std;

int main()
{
cout << "hello world\n"; 
return 0; 
}
```

同場加映：如何用滑鼠取代cd指令  
如果你有用[lazybuntu懶人包](http://lazybuntu.openfoundry.org/)，裏面有個很讚的東西，就是這個：  
  
![終端機右鍵選單](/blog_assets/ubuntu-cpp/opentrm.jpg)
  
這有什麼用呢，請看：  
1.例如我們剛剛操作的位置是/home/a108210/cpp/，那我們打開檔案管理員，直接開到這個位置按右鍵：  
  
![檔案管理員右鍵](/blog_assets/ubuntu-cpp/right.jpg)
  
接著就會出現終端機  
  
![自動開啟終端機](/blog_assets/ubuntu-cpp/Screenshot-6.jpg)
  
注意喔，終端機的位置直接就是/home/a108210/cpp/了。  
  
2.既然位置都已經好了，那我們使用g++的時候就可以省去位置啦，因此我們簡化指令成為：  

> g++ hello.cpp -o hello.out -Wall  

很清爽吧XD  
  
3.而且如此一來上面的步驟6也可以直接跳過了，很棒吧！  
  
如果你常常用終端機的話，這個東西可是妙用無窮呢XDD

---

*原文發表於 2008年9月24日*
