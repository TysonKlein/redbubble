Harvard Data Science Capstone
================
Tyson Klein
October 22, 2018

Analysis of RedBubble.com sales by TysonK
=========================================

An Overview
-----------

RedBubble is one of the longest running and diverse Print-On-Demand (POD) art websites in the world, offering artists everywhere the opportunity to make money by selling their works on a range of products without having to get involved with any of the logistics.

Redbubble, like many of its contemporaries, has a 'passive' approach for the artist. You upload your designs as images and they do everything else. This means that all sales made are pure profit on the artists side.

About a year and a half ago I opened [my Redbubble store](https://www.redbubble.com/people/tysonk?ref=account-nav-dropdown&asc=u). The specifics of my store aren't entirely important to this report, but there are some important details that will emerge again later. Most designs I uploaded had something to do with National Parks from English speaking countries around the world, and the remainder of the designs are an eclectic mix of outdoors-themed and quirky pruducts meant to appeal to a general audience.

My store began to gain traction and some interesting patterns began to emerge. For example, although Redbubble offers designs to be printed on products ranging from coffee mugs to T shirts to throw pillows, by far my most sucessfull item was the sticker.

To date, stickers account for 98.5% of all items sold and 96.2% of all profit.

Daily Users and Profit
----------------------

Below is the profit per day of my store since May 1st, 2017, measured in Canadian Dollars(red), and the same graph instead measuring unique daily users (turquoise). <img src="Readme_files/figure-markdown_github/daily sales and user plot-1.png" style="display: block; margin: auto;" /><img src="Readme_files/figure-markdown_github/daily sales and user plot-2.png" style="display: block; margin: auto;" />

Clearly a trend exists with both of these datasets. First, there are some noticable peaks and valleys that seem to line up with both. These represent busy and slow periods for the store, but before we can better quantify *how* busy or slow, this data has to be better understood and manipulated.

Rolling average and distribution fitting
----------------------------------------

To begin, a useful tool to analyze the overall trend of an extended period of time for such a random dataset is a **rolling average**. This is an alpha adjusted average where *average.today = actual.yesterday \* A + average.yesterday \* (1 - A)*. Calculating the average for day **N** uses only data from day **N - 1** and earlier. This is done to prevent the average from being over-informed when constructing confidence intervals.

A has to be appropriately small so that the rolling average isn't completly changed for every outlier day, yet large enough to respond quickly to the profit trend. All proceeding A's are set at 0.07.

Now that we have an average to compare every day to, another valuable statistic to learn is the day-to-day variation in both datasets. For brevity, this analysis will only be done on the daily users, but the process is identical.

A great way to do this is to fit our varied data to a series of plausible distributions and observe which distribution best represents the varience. Unfortunately these data sets exhibit trends which prevent us from simply measuring the varience between *all* data points. This is a perfect use for our computed rolling average, and instead of simply measuring the varience between daily users, we can account for the trend by dividing each daily user data point by its corresponding user rolling average. This can be thought of as **Adjusting** our dataset to account for time-dependant trends, preserving the varience and yielding the following:

<img src="Readme_files/figure-markdown_github/adjusted daily users plot-1.png" style="display: block; margin: auto;" />

These points represent how each day relates to the rolling average. Five distributions were used to fit this data; Normal, Gamma, Weibull, Dagum, and GEV (Generalized Extreme Value). These five were chosen specifically because they are some of the most common distributions for inter-arrival times (With exception to the Normal distribution, which is included for comparison purposes), and random variables like daily profit and unique users can be thought of the same way, since there is a hard minimum (0), which is very unlikely, and practically infinite maximum.

<img src="Readme_files/figure-markdown_github/User distribution fits-1.png" style="display: block; margin: auto;" /><img src="Readme_files/figure-markdown_github/User distribution fits-2.png" style="display: block; margin: auto;" />

As you can see from these plots, these functionns all look very similar, although the Q-Q plot points to the Dagum function being the best fit. A better way to cut through the subjectivity of selecting a distribution is summarizing with the Kolmogorov-Smirnov fitness test. Below is a table with results for all five distributions.

| Distribution |  Test.Statistic|  P.value|
|:-------------|---------------:|--------:|
| Normal       |          0.0511|   0.0980|
| Gamma        |          0.0347|   0.4905|
| Weibull      |          0.0633|   0.0198|
| Dagum        |          0.0151|   0.9994|
| GEV          |          0.0254|   0.8518|

While the KS test only eliminated the Weibull distribution on a p &lt; 0.05 threshold, we can see that the KS test also supports our theory that the data fits a Dagum distribution very well.

Naive Trend Analysis
--------------------

Below are the original sales and user charts, now with the rolling average (dark line) and 90% confidence intervals (light lines) constructed from the Dagum distribution. This confidence interval is represents where 90% of all datapoints will exist between. This is the first opportunity we have to see the story being told by the data. First, if you pay close attention to the dates of some of the peaks and valleys, there are four clear trends.

1.  Both tend to be higher during the late summer months.
2.  Both tend to be higher during mid-November to mid-December.
3.  Both, in general, increase over time.
4.  There is less variance in daily users than daily sales.

<img src="Readme_files/figure-markdown_github/daily sales and user plot with rolling average and CI-1.png" style="display: block; margin: auto;" /><img src="Readme_files/figure-markdown_github/daily sales and user plot with rolling average and CI-2.png" style="display: block; margin: auto;" />

Factors to Consider
-------------------

A very important thing to understand about a RedBubble store is that unique users have a direct relationship with daily sales. There are a few steps invloved to get from one to the other, and the easiest way to illustrate this path is to consider an average customer.

Let's say Jim has decided he wants to buy a sticker for [Banff National Park](https://www.redbubble.com/people/tysonk/works/33710123-banff-national-park-basic?asc=u&p=sticker) after a recent holiday. Jim finds the RedBubble storefront for my sticker, and the first stop on the path occurs. **Jim decides if he wants to buy this product**. This interaction, which I call the *should I?* factor, is a random variable with possible outcomes of *yes* or *no*.

Assuming Jim loves the design and chooses to buy it, he adds it to his cart. Jim now has another important decision to make; **Jim decides if he wants to buy another product**. Almost always the answer to this is no, but again this interaction introduces another factor I call *how many?*. This is also a random variable with possible outcomes *1* to *infinite*, heavily weighted towards 1.

Now that Jim has, say, a sticker and a T-shirt in his cart, he checks out to complete his order. There is one more important random variable to consider, and that is summarized by **How much profit does each product produce?**. This is a very important factor, and one of the variables that the artist has the most control over, called *what cost?*. It completly depends on the product, sale, and set margin for the artist but can range from *0* to *infinite*, weighted towards an average value dictated by the most commonly sold item.

The sale is now complete. Jim, the **user**, has completed an **order** with the sticker and T-shirt representing multiple **units**, for some **profit**. This directional flow of actions results in much more varience on the profit end compared to the user end, and explains \#4 on our list of noticed trends.

Analysis of Factors
-------------------

### Exposure

The success of this store, or really any merchandise business, resides in how and what we change to influence these factors. To start, we can look at the implied fisrt factor: *exposure*. This is where I would have an absolute hay-day if I were privy to the data RedBubble collects internally. Before we can influence a customer interaction, they have to see the webpage.

Unfortunately for the artists, there is very little that can be done to increase exposure. RedBubble is a wild-west implementation of the POD model: everyone uploads whatever they want and the cream rises to the top. One could argue that this is the best possible implementation, where the best designs get rewarded the most, but that doesn't necessarily happen.

Redbubble designs get more ad-targets and raise higher in internal search rankings based on their sales record. What does this mean? A mediocre design that has been on the store for a while with modest sales numbers can be on the first page of search results whereas a great design that was recently uploaded with hardly any sales will be buried in the later pages of a search result.

If I was a betting man (a great stance for an aspiring analyst), I would say that search rank has a hell of a lot more to do with the success of a single design than the quality of that design. What ends up happenning with this meritocratic approach is that page 1 designs stay on page 1 entirely due to the fact that they sell better than page 2+ designs. Many times, I have uploaded a design only to sell a grand total of 0 products within the fist several months of its existance. Then, if a I get lucky and a **single** person buys this design, it shoots up in the search rankings past all the other unbought designs. Suddenly, that design turns into a hit.

So to gain some autonomy over this seemingly unfair beginning of a design life-cycle, I batch uploaded a series of designs, **bought them all** with my second account, and spent the next few months making sales of all of these designs having been kick started higher in the search rankings.

For the average design in my store, the sales have slowly improved over time as each individual ranking creeps closer and closer to its rightful place in the search results. Often that happens to be on page 1, but after some time the search ranking stabilizes. I believe this is one of the main influences of \#3 of the noticed trends: Both users and Sales, in general, increase over time.

### Should I?

Assuming the exposure of our design leads a user to click on it, the next factor to consider is *should I?*. As mentioned before, this is a random variable with possible outcomes *yes* or *no*. These can instead be thought of as *1* or *0*, with an expected value somewhere in between. This value represents the **probability of a user making a purchase**. This value can actually be plotted over time, as it is fairly easily represented as the *average daily orders / average daily users*. This graph ranges from 0 - 1, representing the probability of each user buying a product.

<img src="Readme_files/figure-markdown_github/daily Order per user plot-1.png" style="display: block; margin: auto;" />

This graph seems to be failry stable, and doesn't change in response to developments in my store and added designs. Instead, there are two possible theories I have for the trend.

1.  The value is higher based on the quality of the design. This is approximately constant for my store becuase my set of designs are all very similar and most have existed since the start date of May 1st, 2017. I would imaging talented designers would have this value higher than the ~20% purchase rate that I am showing.

2.  The values fluctuate based on buyer desparation. I think it is no coincidence that the highest peak on this graph occurs in the month leading up to Christmas. Buyers are looking for gifts for loved ones, and are more likely to make a purchase because they either just want to buy anything for them, aren't as scrutinous becuase they aren't buying for themselves, or feel pressured from the in-site sales advertisements all over the webpage at that time of year. The dip in desparation after the holidays may also point to a lack of available spending money for customers.

### How Many?

As mentioned before, the overwhelming majority of orders contain only a single unit. Below is a histogram of Units per Order.

<img src="Readme_files/figure-markdown_github/units per order hist-1.png" style="display: block; margin: auto;" />

This isn't necessarily because users usually only buy a single item; in fact it is usually the opposite. RedBubble has cleverly made their products available at scaleable deals, discounting your whole order of stickers based on how many you decide to purchase.

Barring differences in the exchange rate between USD and CAD, an average full price sticker sold in the United States nets about $4.05 in profit. This is quantified in a histogram of US sticker sales by profit per sticker.

<img src="Readme_files/figure-markdown_github/unit profit hist-1.png" style="display: block; margin: auto;" />

The small bump on the right side of this graph at just over $4.00 represents these full price purchases, but you may have noticed that it is by no means the largest bump on this graph. The two other bumps are both very closely packed together, and clearly show that something else is going on. Below is the same graph with lines representing various levels of discount from full price.

<img src="Readme_files/figure-markdown_github/unit profit hist with discount-1.png" style="display: block; margin: auto;" />

This illustrates the discount strategy RedBubble is using. When you have one sticker in your cart, a popup will notify you before checking out that you can save 25% if you buy 5 or more stickers and 50% if you buy 10 or more stickers. Since there is no other way to buy a sticker from my store at less than the full profit margin of ~$4.05 (other than short seasonal discounts of 15%, 20% and 30% shown with the tiny bumps on the graph), these two bumps represent people taking advantage of these discounts. 76.8% of all stickers are bought with the 10+ stickers for 50% off discount, 19.5% are bought with the 5+ stickers for 25% off discount, and only 3.7% of stickers are purchased at full price.

Why then are the majority of my orders just single stickers? The benefit of having such a huge open marketplace is that users have a ton of designs to choose from. This means that orders of 10+ stickers will very rarely have 2 designs by the same designer. The only reason people buy more than one of my designs in a single order is because most of my designs are in related series (for example, someone buys a Jasper and Banff sticker because they have been to both).

Unfortunately, just like exposure, there is very little that can be done to influence this factor. The only possible thing I have control over for this *how many?* factor is to make various series of related designs on my store, and making related designs navigable to each other via RedBubble's Collection feature.

Coming Soon
-----------
