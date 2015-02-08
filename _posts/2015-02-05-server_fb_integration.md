---
layout: post
title: Integrating the Server and Client with Facebook as the Glue
---

*Author: John Chou* 

In this blog post I'll discuss how I went about building the serverside component in Node.js, integrating swift with Facebook, and making requests with AlamoFire

-----

For the past 2 weeks I was working on the server side component of our application, and it required many different components to get it working.  I'll divide up the work that I did in 3 parts, though I transitioned from each of them quite frequently:

* The Facebook Integration
* The Client requests
* The Serverside

### The Facebook Integration

So Facebook has a nice IOS SDK in Objective-C, but it doesn't have very good Swift support.  Therefore, we had to use a bridging header where I found a tutorial to do [here](www.brianjcoleman.com/tutorial-facebook-login-in-swift/)

From there, I was able to get facebook login to work correctly, the next task 

Poole is a streamlined Jekyll site designed and built as a foundation for building more meaningful themes. Poole, and every theme built on it, includes the following:

* Complete Jekyll setup included (layouts, config, [404](/404.html), [RSS feed](/atom.xml), posts, and [example page](/about))
* Mobile friendly design and development
* Easily scalable text and component sizing with `rem` units in the CSS
* Support for a wide gamut of HTML elements
* Related posts (time-based, because Jekyll) below each post
* Syntax highlighting, courtesy Pygments (the Python-based code snippet highlighter)

Additional features are available in individual themes.

### Browser support

Poole and it's themes are by preference a forward-thinking project. In addition to the latest versions of Chrome, Safari (mobile and desktop), and Firefox, it is only compatible with Internet Explorer 9 and above.

### Download

Poole is developed on and hosted with GitHub. Head to the <a href="https://github.com/poole/poole">GitHub repository</a> for downloads, bug reports, and features requests.

Thanks!
