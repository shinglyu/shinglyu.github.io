---
layout: post
title: 驚爆！報稅軟體的低級錯誤
categories: Testing
date: 2016-05-21 22:20:00 +08:00
excerpt_separator: <!--more-->
---

__更新__：經過我向客服中心反映，並透過朋友的幫助轉給了廠商，今天（5/23）早上國稅局客服中心打電話來確認說修復完成了，我實際檢查也確認修復了。辛苦了週末加班的工程師！

別誤會，我不是要教你什麼逃漏稅的方法，只是分享一下政府的報稅軟體是怎麼樣的低品質又缺乏測試。
過去幾年都我一直用 Windows VM 安裝桌面版的報稅軟體，今年發現網頁版功能也完善了（主要是可以成功的匯入所得資料），於是想改用網頁版直接在 Linux Mint 上面用 Firefox 報稅，沒想到竟然是悲劇的開始。


![online_tax_screenshot]({{site_url}}/blog_assets/tax_bug/online_tax.png)

<!--more-->

我選擇使用金融憑證來登入，經過一連串很惱人的彈跳式警告訊息跟一大堆 JVM 警告之後，順利的選擇用「群益金鼎證券」金融憑證登入。

![login_screenshot]({{site_url}}/blog_assets/tax_bug/login.png)

中間的步驟就省略不說了，雖然介面很醜但是基本上沒有什麼大問題。

![submit_stage_screenshot]({{site_url}}/blog_assets/tax_bug/submit_stage.png)

最後來到了上傳資料與繳費的頁面，因為我選擇用信用卡繳費，流程是先跳到信用卡刷卡頁面，刷卡成功以後再回到報稅系統上傳申報資料。必須要兩個步驟都完成才算繳稅成功。刷卡倒是輕鬆愉快，但是當我最後上傳申報資料的時候，跳出了一個再次確認金融憑證的頁面。

![confirm_screenshot]({{site_url}}/blog_assets/tax_bug/confirm.png)

我再次選了群益金鼎證券，沒想到這次竟然跳出了「錯誤的參加單位代碼」！

![confirm_error_screenshot]({{site_url}}/blog_assets/tax_bug/confirm_error.png)

參加單位代碼又不是我填的，既然都做成選單了應該要自動帶出正確的代碼。而且我在一開始登入時候也用了群益金鼎證券，兩邊的程式碼應該是共用的吧？沒想到我太高估了政府外包商的程式能力......。（就是在說你！關貿網路跟中華電信！）


於是我先隨便嘗試了另外一家券商，其他的券商可以成功的跳出選擇憑證的 JVM 畫面，當然送出以後會告訴我說憑證的發證單位不正確，但是這樣表示只有群益群益金鼎證券的代碼填寫錯誤。於是我退出系統重新登入，在登入的時候打開了 Firefox 的開發者工具簡單地看了一下券商選單頁面的 HTML。

![login_code_screenshot]({{site_url}}/blog_assets/tax_bug/login_code.png)

你可以看到群益金鼎證券的這個選項其中的 value 是0D011，顯然就是所謂的參加單位代碼。 還可以注意到有些券商並不是一個代碼，而是直接寫出了英文名字。而且在群益證券的 `<option/>` 上一行還有一個神秘的註解 `<!-- <option value="The Capital Group"></option> -->`，看起來像是開發時測試用的「遺跡」，顯然沒有清乾淨，不知道 code review 是怎麼通過的？（八成是沒有 code review 吧？）

![login_code_zoom_screenshot]({{site_url}}/blog_assets/tax_bug/login_code_zoom.png)

於是我再登入系統重新走完一次流程。在繳費的時候我直接把信用卡刷卡的畫面關掉，因為我怕重複扣款，然後上傳資料的按鈕就自動被啟用了（繳費之前是被停用的），我心想這樣的防護也太弱了吧。最後終於到了讓我卡住的確認頁面，再次打開Firefox的開發者工具一看，群益金鼎證券的值竟然變成了 `The Capital Group`！跟前一份選單比對裡面的值竟然有很多不同！

![confirm_code_zoom_screenshot]({{site_url}}/blog_assets/tax_bug/confirm_code_zoom.png)

![confirm_code_screenshot]({{site_url}}/blog_assets/tax_bug/confirm_code.png)

於是我手動把群益金鼎證券的值換成了在第一個畫面看到的 `0D011` 再次送出就成功了。但是因為刷卡繳費跟這次送出是在不同的工作階段，系統非常愚蠢的無法找到我的繳費紀錄，於是我還是無法順利地報完我的稅。

我最後聯絡上了國稅局的客服中心，也把這些截圖與說明寄給了他們所謂「工程師的信箱」，但是我很懷疑他們會不會真正的處理。這麼基本的流程，竟然在測試跟 code review 的過程中都沒有發現，要他們的工程師能夠理解我在說什麼，可能也是太苛求了吧。至於我的稅，還是乖乖的灌個 Windows 用桌面版軟體報稅吧！
