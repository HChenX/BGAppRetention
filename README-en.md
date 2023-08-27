<div align="center">
<h1>BGAppRetention</h1>

![stars](https://img.shields.io/github/stars/HChenX/BGAppRetention?style=flat)
![downloads](https://img.shields.io/github/downloads/HChenX/BGAppRetention/total)
![Github repo size](https://img.shields.io/github/repo-size/HChenX/BGAppRetention)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/HChenX/BGAppRetention)](https://github.com/HChenX/BGAppRetention/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date/HChenX/BGAppRetention)](https://github.com/HChenX/BGAppRetention/releases)
![last commit](https://img.shields.io/github/last-commit/HChenX/BGAppRetention?style=flat)
![language](https://img.shields.io/badge/language-shell-purple)

<p><b><a href="README.md">简体中文</a> | <a href="README-en.md">English</a> </b></p>
<p>This module achieves the function of app retention by modifying system memory management parameters such as ZRAM and Prop. It is a Magisk module.</p>
</div>

# ✨Module Introduction:

### 💡Module Source:

- The module is based on the  `@嘟嘟ski` module.
- This module is now updated by `@焕晨HChen`.

### 🌟Module Principle:

- This module achieves the function of app retention by modifying system memory management parameters such
  as ZRAM and Prop.
- So, it also has limitations and is difficult to fully touch and change the kill logic of the system, so the
  effect varies from person to person.

### 💫Module Have:

- Main Magisk module content.
- Additional Lsp module: `AppRetentionHook`.
- #### Note: Additional module author: `焕晨HChen`, For detailed module content, please refer to: [AppRetentionHook](https://github.com/HChenX/AppRetentionHook)。

### 🔥Module Effects & Risks:

- As I mentioned above, the effects of pure Magisk modules vary from person to person.
- But, after a long period of testing and with a large number of testers, the feedback effect is still commendable
  and meets expectations.
- However, if the additional Lsp module inside is installed and activated, the app retention capability will be
  greatly improved (please meet the requirements for using the additional module).

* The module adopts a radical approach to make some modifications and settings, including but not limited to:
    * 1.The Zram size is set to 1.5 times the physical memory size, and the module currently does not support free
      modification.
    * 2.The module has a more aggressive setting for Prop, almost prohibiting or modifying most of the memory management
      logic.
    * 3.The module also has some changes to other aspects, such as vm parameters, lmk parameters, etc.

* Although these changes will improve the app retention capabilities, please note that they may lead to some unknown
  bugs,
  including but not limited to:
    * 1.Possible issues with memory management failure, resulting in the problem of memory explosion and stuck memory.
    * 2.It may lead to an increase in power consumption, but this is inevitable. Within a reasonable range, it is
      acceptable.
    * 3.The most serious issue may cause card startup, Please pay attention in advance.

# 👑Module Author Information:

### ⭐Module Author:

|      Module Author:      | Module Author Name |
|:------------------------:|:------------------:|
|  Module Original Author  |       嘟嘟ski        |
|  Author of this module   |      焕晨HChen       |
| Additional Module Author |      焕晨HChen       |

### 🌹Acknowledgments List:

- 全体酷友和群友
- Newbing
- Chatgpt
- 嘟嘟ski

## 🎉Conclusion:

### 💕Acknowledgement Statement:

- Thank you all for your support. Without your support, it would not have been possible to go this far. Thank you
  very much!
- This module code may have borrowed some code from other modules. If there is any infringement, please contact me to
  delete it.

### 🎵Friendly Link:

- AppRetentionHook Module GitHub Link:
- [AppRetentionHook](https://github.com/HChenX/AppRetentionHook)

### 📢Communication Group:

- QQ group:517788148

### 💣Disclaimer:

> If you use this module, you are agreeing to accept all consequences.
> This project holds no responsibility for any projects derived from it.