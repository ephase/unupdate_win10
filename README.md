Remove-kb
---------

 A little powershell script to uninstall and hide some updates. I use it to
 remove unwanted Windows 10 upgrade. this is a really simple script just for 
 my need, but I propably improve it. This script need Adminitrator right

 There are two part
  
  * **lancher.cmd** : a winbatch script to launch powershell one.
  * **remove-kb.ps1** : the powershell script itself.
  
  To add or remove uninstalled / hidden KB you nedd to modify $kbIDs 
  variable.

  Because I'm a Linux fan and this is my first try with powershell
  this script is really simple and could not work properly, burn your cat
  and cut your Little Pony head.  

#TODO

 * Add privilege elevation error when not launch scrip with Administrator right
 * Add possibility of arguments for remove KB (then ps script could be call from
 another script)
 * Write a function for removing like hide_update
 * Update the windows update list to hidde kb than aren't yet listed
 * Speed up hide_update 
 * **Tell me**

#Licence

Do what you're whant and fell free to offer me a beer :D
