<div align="center">
<h1>保后台模块</h1>

![stars](https://img.shields.io/github/stars/HChenX/BGAppRetention?style=flat)
![downloads](https://img.shields.io/github/downloads/HChenX/BGAppRetention/total)
![Github repo size](https://img.shields.io/github/repo-size/HChenX/BGAppRetention)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/HChenX/BGAppRetention)](https://github.com/HChenX/BGAppRetention/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date/HChenX/BGAppRetention)](https://github.com/HChenX/BGAppRetention/releases)
![last commit](https://img.shields.io/github/last-commit/HChenX/BGAppRetention?style=flat)
![language](https://img.shields.io/badge/language-shell-purple)

<p><b><a href="README.md">简体中文</a> | <a href="README-en.md">English</a> </b></p>
<p>本模块通过修改ZRAM和Prop等系统内存管理参数来达到保后台的功能，这是一个Magisk模块。</p>
</div>

# ✨保后台模块简介:

### 💡模块来源:

- 模块基于`@嘟嘟ski`的scene附加模块二改版而来。
- 本模块现在由`@焕晨HChen`进行二改编写和日常维护更新。

### 🌟模块原理:

- 本模块通过修改ZRAM和Prop等系统内存管理参数来达到保后台的功能。
- 但是因此也具有局限性，难以完全触及和更改系统的kill逻辑，所以效果因人而异。

### 💫模块包含内容:

- 主Magisk模块内容。
- 附加Lsp模块`AppRetentionHook`。
- #### 注：附加模块作者：`焕晨HChen`，模块详细内容请查看：[AppRetentionHook](https://github.com/HChenX/AppRetentionHook)。

### 🔥模块效果与风险：

- 正如我上面所说的，纯Magisk模块效果因人而异。
- 但是经过较长时间的测试，也拥有较多的测试人数，反馈效果还是可喜可贺的，较为满足预期。
- 但是如果安装激活了里面的附加Lsp模块，保后台能力将会得到很大提升(请满足附加模块使用要求)。

* 模块采用理念激进的方式进行一些修改和设置，包括但不限于：
    * 1.Zram大小设置为物理内存大小1.5倍，且模块暂不支持自由修改。
    * 2.模块对Prop的设置较为激进，几乎禁止或修改了大部分内存管理逻辑。
    * 3.模块对其他方面也有一些更改，比如:vm参数，lmk参数等。

* 虽然这些更改会提升保后台能力，但是也请注意可能导致一些未知的Bug，包括但不限于：
    * 1.可能存在的内存管理失效的问题，从而引发的爆内存卡死的问题。
    * 2.可能导致耗电量的增加，但是这是不可避免的，鱼与熊掌不可兼得，在合理范围内是可以接受的。
    * 3.最严重可能导致卡开机的问题，所以使用前请确保你有足够的能力挽救。

# 👑模块作者信息：

### ⭐模块作者:

|  模块作者  |  模块作者名  |
|:------:|:-------:|
| 模块原作者  |  嘟嘟ski  |
| 二改模块作者 | 焕晨HChen |
| 附加模块作者 | 焕晨HChen |

### 🌹感谢名单:

##### 对模块提供帮助的名单，排名不分前后

- 全体酷友和群友
- Newbing
- Chatgpt
- 嘟嘟ski

## 🎉结语:

### 💕致谢声明:

- 感谢各位的支持，没有你们的支持模块不可能走到现在，非常感谢！
- 本模块代码可能借鉴了部分其他模块的代码，所有若有侵权请联系我删除。

### 🎵友情链接:

- AppRetentionHook模块Github链接:
- [AppRetentionHook](https://github.com/HChenX/AppRetentionHook)

### 📢焕晨的交流群:

- QQ群:517788148

### 💣免责声明:

> 模块刷入即代表愿意自行承担一切后果。

> 请自行判断是否安装刷入！
