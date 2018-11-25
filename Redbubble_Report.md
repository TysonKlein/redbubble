Harvard Data Science Capstone
================
Tyson Klein
October 22, 2018

Analysis of RedBubble.com sales by TysonK
=========================================

An Overview
-----------

RedBubble is one of the longest running and diverse Print-On-Demand (POD) art websites in the world, offering artists everywhere a chance to make money by selling their works on a range of products without having to get involved with any of the logistics. As a homebody with a penchant for Photoshop, I was naturally drawn to it.

Redbubble, like many of its contemporaries, has a 'passive' approach for the artist. You upload your designs as images and they do everything else. This means that all sales made are pure profit on the artists side.

About a year and a half ago I opened [my Redbubble store](https://www.redbubble.com/people/tysonk?ref=account-nav-dropdown&asc=u). The specifics of my store aren't entirely important to this report, but there are some important details that will emerge again later. Most designs I uploaded had something to do with National Parks from English speaking countries around the world, and the remainder of the designs are an eclectic mix of outdoors-themed and quirky pruducts meant to appeal to a general audience.

The money started to come in, and as I tweaked some designs and parameters within my store, I realized that this could be a legitimate income stream. Beyond that, some interesting patterns began to emerge. For example, although Redbubble offers designs to be printed on products ranging from coffee mugs to T shirts to throw pillows, by far my most sucessfull item was the sticker.

To date, stickers account for 98.5% of all items sold and 96.2% of all revenue.

Daily Users and Profits
-----------------------

Below is the profit per day of my store since May 1st, 2017, measured in Canadian Dollars(red), and the same graph instead measuring unique daily users (turquoise). <img src="Redbubble_Report_files/figure-markdown_github/daily sales and user plot-1.png" style="display: block; margin: auto;" /><img src="Redbubble_Report_files/figure-markdown_github/daily sales and user plot-2.png" style="display: block; margin: auto;" />

Clearly a trend exists with both of these datasets. First, there are some noticable peaks and valleys that seem to line up with both. These represent busy and slow periods for the store, but before we can better quantify *how* busy or slow, this data has to be better understood and manipulated.

Rolling average and distribution fitting
----------------------------------------

To begin, a useful tool to analyze the overall trend of an extended period of time for such a random dataset is a **rolling average**. This is an alpha adjusted average where *average.today = actual.today \* A + average.yesterday \* (1 - A)*

A has to be appropriately small so that the rolling average isn't completly changed for every outlier day. All proceeding A's are set at 0.07.

Now that we have an average to compare every day to, another valuable statistic to learn is the day-to-day variation in both datasets. For brevity, this analysis will only be done on the daily users, but the process is identical.

A great way to do this is to fit our varied data to a series of plausible distributions and observe which distribution best represents the varience. Unfortunately these data sets exhibit trends which prevent us from simply measuring the varience between *all* data points. This is a perfect use for our computed rolling average, and instead of simply measuring the varience between daily users, we can account for the trend by dividing each daily user data point by its corresponding user rolling average. This can be thought of as **Normalizing** our dataset, preserving the varience and yielding the following:

<img src="Redbubble_Report_files/figure-markdown_github/normalized daily users plot-1.png" style="display: block; margin: auto;" />

These points represent how each day relates to the rolling average. Five distributions were used to fit this data; Normal, Gamma, Weibull, Dagum, and GEV (Generalized Extreme Value). These five were chosen specifically because they are some of the most common distributions for inter-arrival times, and random variables like daily profit and unique users can be thought of the same way, since there is a hard minimum (0), which is very unlikely, and practically infinite maximum.

<img src="Redbubble_Report_files/figure-markdown_github/User distribution fits-1.png" style="display: block; margin: auto;" /><img src="Redbubble_Report_files/figure-markdown_github/User distribution fits-2.png" style="display: block; margin: auto;" />

As you can see from these plots, these functionns all look very similar. Although the Q-Q plot points to the Dagum function being the best fit, a better way to cut through the ambiguity of selecting a distribution is summarizing with the Kolmogorov-Smirnov fitness test. Below is a table with results for all five distributions.

| Distribution |  Test.Statistic|  P.value|
|:-------------|---------------:|--------:|
| Normal       |          0.0467|   0.1718|
| Gamma        |          0.0309|   0.6537|
| Weibull      |          0.0583|   0.0437|
| Dagum        |          0.0165|   0.9980|
| GEV          |          0.0233|   0.9202|

Clearly Dagum is the way to go! These results are nearly identical for sales as well, and now that we have a bona-fide distribution, we can construct a confidence interval for our data.

Naive Trend Analysis
--------------------

Below are the original sales and user charts, now with the rolling average (dark line) and 90% confidence intervals (light lines). This is the first opportunity we have to see the story being told by the data. First, if you pay close attention to the dates of some of the peaks and valleys, there are four clear trends.

1.  Both tend to be higher during the late summer months.
2.  Both tend to be higher during mid-November to mid-December.
3.  Both, in general, increase over time.
4.  There is less variance in daily users than daily sales.

<img src="Redbubble_Report_files/figure-markdown_github/daily sales and user plot with rolling average and CI-1.png" style="display: block; margin: auto;" /><img src="Redbubble_Report_files/figure-markdown_github/daily sales and user plot with rolling average and CI-2.png" style="display: block; margin: auto;" />

More Factors to Consider
------------------------

A very important thing to understand about this redbubble store is that unique users have a direct relationship with daily sales. There are a few steps invloved to get from one to the other, and the easiest way to illustrate this path is to consider an average customer.

Let's say Jim has decided he wants to buy a sticker for [Banff National Park](https://www.redbubble.com/people/tysonk?ref=account-nav-dropdown&asc=u) after a recent holiday. Jim finds the RedBubble storefront for my sticker, and the first stop on the path occurs. **Jim decides if he wants to buy this product**. This interaction, which I call the *should I?* factor, is a random variable with possible outcomes of *yes* or *no*.

Assuming Jim loves the design and chooses to buy it, he adds it to his cart. Jim now has another important decision to make; **Jim decides if he wants to buy another product**. Almost always the answer to this is no, but again this interaction introduces another factor I call *how many?*. This is also a random variable with possible outcomes *1* to *infinite*, heavily weighted towards 1.

Now that Jim has, say, a sticker and a T-shirt in his cart, he checks out to complete his order. There is one more important random variable to consider, and that is summarized by **How much profit does each product produce?**. This is a very important factor, and one of the variables that the artist has the most control over, called *what cost?*. It completly depends on the product, sale, and set margin for the artist but can range from *0* to *infinite*, weighted towards an average values dictated by the most commonly sold item.

The sale is now complete. Jim, the **user**, has completed an **order** with the sticker and T-shirt representing multiple **units**, for some **profit**. This directional flow of actions results in much more varience on the profit end compared to the user end, and explains \#4 on our list of noticed trends.

<img src="Redbubble_Report_files/figure-markdown_github/daily units plot-1.png" style="display: block; margin: auto;" />

<img src="Redbubble_Report_files/figure-markdown_github/daily orders plot-1.png" style="display: block; margin: auto;" />

Combining some of these graphs can give insight as to how changing these interim random variables (*should I?*, *how many?*, *what cost?*) either intentionally or from outside forces changes the profitability of the store.

<img src="Redbubble_Report_files/figure-markdown_github/daily $ per Order plot-1.png" style="display: block; margin: auto;" />

<img src="Redbubble_Report_files/figure-markdown_github/daily Order per user plot-1.png" style="display: block; margin: auto;" />

<img src="Redbubble_Report_files/figure-markdown_github/daily Units per order plot-1.png" style="display: block; margin: auto;" />

|             |  Estimate|  Std. Error|  t value|  Pr(&gt;|t|)|
|-------------|---------:|-----------:|--------:|------------:|
| (Intercept) |     -0.01|         0.1|    -0.11|         0.91|
| x           |      2.09|         0.1|    20.92|         0.00|

hi
