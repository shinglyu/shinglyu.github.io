---
layout: post
title:  "Manage Your Development Environment Setup in GitHub"
date:   2016-03-15 00:00:00
categories: Testing
---

Linux is my major development platform. Most of the tool I use (Vim, zsh, i3) use configuration files located in your home directory . it is pretty hard to keep them in sync between your machines . And sometimes if you mess up with the configuration file it's pretty hard to revert your changes.


one day I was looking for vim configuration examples on GitHub, I stumbled upon a repository called " dotfiles " ( I forgot who's repository it is) , which contains many configuration files in one repository . [ ( In case you don't know, It's called dotfiles Because most often the next configuration files Has the file name started with the dot , which means hidden files in lyrics ) 


 This is actually a brilliant idea , Is safe for your configuration files in the get repository and use soft links To make them appear in the correct path. This way you can enjoy a lot of benefits of git. 
First, you can easily set up new machines by simply clone the repository. secondly , you have a full version control history of your configuration files . You can go back to known good configurations when you break them . you can also use its branches to manage machine specific settings . For example , you might want to have some special configurations in your office computers , which makes no sense in your home computer . You can create two branches , one for your office and one for your home . Then you can manage to differences between the two configuration files , you also get the flexibility of cherry picking changes between branches .last but not least , receive your configuration files published on GitHub, you can easily shared them with your friends .


here is the exact steps you can implement this method.


1. create a folder called dot files in your home directory 
2. copy for you configuration files into the folder. (here are use my as an example )
3. remove the original configuration files , and replace them with soft links to your files in the dotfiles folder . 
 4. Add,  commit and push your configuration files to GitHub . ( remember to remove any sensitive data like passwords , API tokens , personal information before you push ) 
 5. you can automate the software link creation process in  a shell script .this way you can easily run the shell script on to new computer if you need to set up.


 tips 


* you can use your master Brange as the template branch. when you have some changes that can be universally applied,you put them in the master branch.All your other machine specific branches can then pool that change from the master branch
* I like to write little utility functions in shell script . For example I have a shell script that can let me run unit test commands when I pressed a hotkey .I also put those utility scrips in the repository . 
* You may also consider saving your Linux package lists in the repository . or even make a shell script that can install all of them in one click . You can use the following command to see what package you have installed on your current computer . ( I use Devian based linux , But you can definitely find similar command on other is and Package manager ) 
