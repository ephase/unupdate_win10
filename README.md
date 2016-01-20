Remove-kb
---------

A little powershell script to uninstall and hide some updates. I use it to
remove unwanted Windows 10 upgrade. This is a really simple script just for 
my need, but I will propably improve it. This script needs Adminitrator's rights.

There are two parts
  
  * **launcher.cmd** : a winbatch script to launch powershell one.
  * **remove-kb.ps1** : the powershell script itself.
  
To add or remove uninstalled / hidden KB you nedd to modify $kbIDs 
variable.

Because I'm a Linux fan and this is my first try with powershell
this script is really simple and could not work properly, burn your cat
and cut your Little Pony head.

#TODO

 * Add privilege elevation error when the script is not launched with Administrator's rights
 * Add the possibility to use arguments when calling the script (then ps script could be call from
 another script)
 * ~~Update the windows update list to hide kb that aren't yet listed~~ *check rewrite_hide_update branch*
 * ~~Speed up hide_update~~ *check rewrite_hide_update branch*
 * **Tell me**

#License

Do what you want and feel free to offer me a beer :D
