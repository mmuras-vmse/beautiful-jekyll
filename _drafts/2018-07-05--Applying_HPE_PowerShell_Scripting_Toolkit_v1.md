## New-DraftTemplate

---
layout: post
title:  Applying HP / HPE PowerShell Scripting Toolkit
---

2018-07-05


### Applying the HP / HPE PowerShell Scripting Toolkit

Let’s start off with a thought experiment...

1.	Think about the servers you have in your Data Center.

Maybe they are HP, maybe they are Dell, or IBM, or Cisco or something else.

2.	Do you have 1 or 2 common server models?  

Focus on the model that you think you have more of than any other.

3.	How many servers do you have of that model?

4.	Have you ever configured the BIOS of that server before?

5.	Have you ever configured the Boot Order of that server before?

6.	Have you ever handed off this task to another worker?  Focus on the outcome.  Was the outcome of the worker setting the BIOS and Boot Order what you needed?


(Discuss the thought experiment, if fully flushed out with a member of the audience.)

So for me, my Server of choice is an HP (or HPE) Proliant DL360 G9, which happens to use the “out of band” management tool called HP iLO4.

In my case, either someone on my team or someone else in my organization was (or sad to say still is) running through this configuration of the HP Proliant DL360 G9 manually.  

While some of you may have 10 or 20 servers.  What would you do if you had 50 servers or 100 or as in my case more than 200 servers (and climbing).  I am not saying I had to do them all at one time, but over the course of the next few years, we will probably be going through a hardware refresh cycle.  And that hardware refresh cycle will require we touch more than 200 physical servers.  



    test code
    splatblog

![alt text](test.png)

test this
