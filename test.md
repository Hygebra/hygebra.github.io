<div class="container">

<!-- 左侧栏导航 -->
<div class="sidebar">
  <h2>导航</h2>
  <a href="#home">主页</a>
  <a href="#blog">博客</a>
  <a href="#papers">论文</a>
  <a href="#about">关于我</a>
</div>

<!-- 主体内容 -->
<div class="main">

<a id="home"></a>


# 欢迎

这里是我的个人主页，展示我的研究、博客和论文。

行内公式示例：$E=mc^2$  

行间公式示例：

$$
\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
$$

---

<a id="blog"></a>
# 博客

下面是博客文章示例：

## 博客文章 1

`include:blog/post1.md`  （可用 `cat blog/post1.md >> index.md` 拼接 Pandoc）

## 博客文章 2

`include:blog/post2.md`

### 图片示例

![实验示意图](images/example.png)

---

<a id="papers"></a>
# 论文展示

<button onclick="showPDF('paper1.pdf')">Paper 1</button>
<button onclick="showPDF('paper2.pdf')">Paper 2</button>

<iframe id="pdf-frame" src="papers/paper1.pdf" width="100%" height="600px"></iframe>

---

<a id="about"></a>
# 关于我

- 姓名: 你的名字  
- 邮箱: yourname@example.com  
- GitHub: [yourusername](https://github.com/yourusername)  
- 简介: 博士生 / 研究方向 / 技术博客

</div>
</div>