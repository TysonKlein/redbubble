Redbubble ecommerce data analysis
================
Tyson Klein
November 15th, 2020

## Analysis of RedBubble.com sales by Tyson Klein

### Running this Analysis

To recreate this analysis at home, you can clone this repo and open this
project in Rstudio, then run the R scripts in the following order:
package-installer.r -\> wrangle-data.r -\> distribution-analysis.r -\>
generate-plots.r -\> then Knit Readme.Rmd

### An Introdution

RedBubble is one of the longest running and diverse Print-On-Demand
(POD) art websites in the world, offering artists everywhere the
opportunity to make money by selling their works on a range of products
without having to get involved with any of the logistics.

RedBubble, like many of its contemporaries, has a ‘passive’ approach for
the artist. You upload your designs as images and they do everything
else. This means that all sales made are pure profit on the artists
side.

In March of 2017 I opened [my Redbubble
store](https://www.redbubble.com/people/tysonk?ref=account-nav-dropdown&asc=u).
The specifics of my store aren’t entirely important to this report, but
there are some important details that will emerge again later. Most
designs in my store have something to do with National Parks from
English speaking countries around the world, and the remainder of the
designs are an eclectic mix of outdoors-themed and quirky products meant
to appeal to a general audience.

My store began to gain traction and some interesting patterns began to
emerge. For example, although RedBubble offers designs to be printed on
products ranging from coffee mugs to T shirts to throw pillows, by far
my most successful item was the sticker.

To date, stickers account for 98.5% of all items sold and 96.2% of all
profit.

### Daily Users and Profit

Below is the profit per day of my store since May 1st, 2017, measured in
Canadian Dollars(red), and the same graph instead measuring unique daily
users (turquoise).
<img src="Readme_files/figure-gfm/daily sales and user plot-1.png" style="display: block; margin: auto;" /><img src="Readme_files/figure-gfm/daily sales and user plot-2.png" style="display: block; margin: auto;" />

Clearly a trend exists with both data sets. First, there are some
noticeable peaks and valleys that seem to line up with both. These
represent busy and slow periods for the store, but before we can better
quantify *how* busy or slow, this data must be better understood and
manipulated.

### Rolling average and distribution fitting

To begin, a useful tool to analyze the overall trend of an extended
period for such a random data set is a **rolling average**. This is an
alpha adjusted average where *average.today = actual.yesterday\*A +
average.yesterday\*(1 - A)*. Calculating the average for day **N** uses
only data from day **N - 1** and earlier. This is done to prevent the
average from being over-informed when constructing confidence intervals.

A has to be appropriately small so that the rolling average isn’t
completely changed for every outlier day, yet large enough to respond
quickly to the profit trend. All proceeding A’s are set at 0.07.

Now that we have an average to compare every day to, another valuable
statistic to learn is the day-to-day variation in both data sets. For
brevity, this analysis will only be done on the daily users, but the
process is identical.

A great way to do this is to fit our varied data to a series of
plausible distributions and observe which distribution best represents
the variance. Unfortunately, these data sets exhibit trends which
prevent us from simply measuring the variance between *all* data points.
This is a perfect use for our computed rolling average, and instead of
simply measuring the variance between daily users, we can account for
the trend by dividing each daily user data point by its corresponding
user rolling average. This can be thought of as **Adjusting** our data
set to account for time-dependent trends, preserving the variance and
yielding the following:

<img src="Readme_files/figure-gfm/adjusted daily users plot-1.png" style="display: block; margin: auto;" />

These points represent how each day relates to the rolling average. Five
distributions were used to fit this data; Normal, Gamma, Weibull, Dagum,
and GEV (Generalized Extreme Value). These five were chosen specifically
because they are some of the most common distributions for inter-arrival
times (With exception to the Normal distribution, which is included for
comparison purposes), and random variables like daily profit and unique
users can be thought of the same way, since there is a hard minimum (0),
which is very unlikely, and practically infinite maximum.

<img src="Readme_files/figure-gfm/User distribution fits-1.png" style="display: block; margin: auto;" />

As you can see from these plots, these functions all look very similar,
although the Q-Q plot points to the Dagum function being the best fit. A
better way to cut through the subjectivity of selecting a distribution
is summarizing with the Kolmogorov-Smirnov fitness test. Below is a
table with results for all five distributions.

| Distribution | Test.Statistic | P.value |
| :----------- | -------------: | ------: |
| Normal       |         0.0329 |  0.1222 |
| Gamma        |         0.0158 |  0.9044 |
| Weibull      |         0.0452 |  0.0100 |
| Dagum        |         0.0154 |  0.9181 |
| GEV          |         0.0190 |  0.7385 |

While the KS test only eliminated the Weibull distribution on a p \<
0.05 threshold, we can see that the KS test also supports our theory
that the data fits a Dagum distribution very well.

\#\#E Naive Trend Analysis

Below are the original sales and user charts, now with the rolling
average (dark line) and 90% confidence intervals (light lines)
constructed from the Dagum distribution. This confidence interval
represents where 90% of all data points will exist between. This is the
first opportunity to see the story being told by the data. If you pay
close attention to the dates of some of the peaks and valleys, there are
four clear trends.

**1. Both tend to be higher during the late summer months.** **2. Both
tend to be higher during mid-November to mid-December.** **3. Both, in
general, increase over time.** **4. There is less variance in daily
users than daily sales.**

<img src="Readme_files/figure-gfm/daily sales and user plot with rolling average and CI-1.png" style="display: block; margin: auto;" /><img src="Readme_files/figure-gfm/daily sales and user plot with rolling average and CI-2.png" style="display: block; margin: auto;" />

### Factors to Consider

A very important thing to understand about a RedBubble store is that
unique users have a direct relationship with daily sales. There are a
few steps involved to get from one to the other, and the easiest way to
illustrate this path is to consider an average customer.

Let’s say Jim has decided he wants to buy a sticker for [Banff National
Park](https://www.redbubble.com/people/tysonk/works/33710123-banff-national-park-basic?asc=u&p=sticker)
after a recent holiday. Jim finds the RedBubble storefront for my
sticker, and the first stop on the path occurs. **Jim decides if he
wants to buy this product**. This interaction, which I call the *should
I?* factor, is a random variable with possible outcomes of *yes* or
*no*.

Assuming Jim loves the design and chooses to buy it, he adds it to his
cart. Jim now has another important decision to make; **Jim decides if
he wants to buy another product**. Almost always the answer to this is
no, but again this interaction introduces another factor I call *how
many?*. This is also a random variable with possible outcomes *1* to
*infinite*, heavily weighted towards 1.

Now that Jim has, say, a sticker and a T-shirt in his cart, he checks
out to complete his order. There is one more important random variable
to consider, and that is summarized by **How much profit does each
product produce?**. This is a very important factor, and one of the
variables that the artist has the most control over, called *what
cost?*. It completely depends on the product, sale, and set margin for
the artist but can range from *0* to *infinite*, weighted towards an
average value dictated by the most commonly sold item.

The sale is now complete. Jim, the **user**, has completed an **order**
with the sticker and T-shirt representing multiple **units**, for some
**profit**. This directional flow of actions results in much more
variance on the profit end compared to the user end and explains \#4 on
our list of noticed trends.

## Analysis of Factors

### Exposure

The success of this store, or really any merchandise business, resides
in how and what we change to influence these factors. To start, we can
look at the implied first factor: *exposure*. This is where I would have
an absolute hay-day if I were privy to the data RedBubble collects
internally. Before we can influence a customer interaction, they must
see the webpage.

Unfortunately for the artists, there is very little that can be done to
increase exposure. RedBubble is a wild-west implementation of the POD
model: everyone uploads whatever they want, and the cream rises to the
top. One could argue that this is the best possible implementation,
where the best designs get rewarded the most, but that doesn’t
necessarily happen.

RedBubble designs get more ad-targets and raise higher in internal
search rankings based on their sales record. What does this mean? A
mediocre design that has been on the store for a while with modest sales
numbers can be on the first page of search results whereas a great
design that was recently uploaded with hardly any sales will be buried
in the later pages of a search result.

If I was a betting man (a great stance for an aspiring analyst), I would
say that search rank has a hell of a lot more to do with the success of
a single design than the quality of that design. What ends up happening
with this meritocratic approach is that page 1 designs stay on page 1
entirely because they sell better than page 2+ designs. Many times, I
have uploaded a design only to sell a grand total of 0 products within
the fist several months of its existence. Then, if a I get lucky and a
**single** person buys this design, it shoots up in the search rankings
past all the other un-bought designs. Suddenly, that design turns into a
hit.

To gain some autonomy over this seemingly unfair beginning of a design
life-cycle, I batch uploaded a series of designs, **bought them all**
with my second account, and spent the next few months making sales of
all of these designs having been kick started higher in the search
rankings.

For the average design in my store, the sales have slowly improved over
time as each individual ranking creeps closer and closer to its rightful
place in the search results. Often that happens to be on page 1, but
after some time the search ranking stabilizes. I believe this is one of
the main influences of \#3 of the noticed trends: Both users and Sales,
in general, increase over time.

### Should I?

Assuming the exposure of our design leads a user to click on it, the
next factor to consider is *should I?*. As mentioned before, this is a
random variable with possible outcomes *yes* or *no*. These can instead
be thought of as *1* or *0*, with an expected value somewhere in
between. This value represents the **probability of a user making a
purchase** and is easily represented as the *average daily orders /
average daily users*.

<img src="Readme_files/figure-gfm/daily Order per user plot-1.png" style="display: block; margin: auto;" />

This graph seems to be fairly stable and doesn’t change in response to
developments in my store and added designs. Instead, there are two
possible theories I have for the trend.

1.  The value is higher based on the quality of the design. This is
    approximately constant for my store because my set of designs are
    all very similar and most have existed since the start date of May
    1st, 2017. I would imaging talented designers would have this value
    higher than the \~20% purchase rate that I am showing.

2.  The values fluctuate based on buyer desperation. I think it is no
    coincidence that the highest peak on this graph occurs in the month
    leading up to Christmas. Buyers are looking for gifts for loved ones
    and are more likely to make a purchase because they either aren’t as
    scrutinous when they aren’t buying for themselves or feel pressured
    from the in-site sales advertisements all over the webpage at that
    time of year. The dip in desperation after the holidays may also
    point to a lack of available spending money for customers.

### How Many?

As mentioned before, most orders contain only a single unit. Below is a
histogram of Units per Order.

<img src="Readme_files/figure-gfm/units per order hist-1.png" style="display: block; margin: auto;" />

This isn’t necessarily because users usually only buy a single item; in
fact, it is usually the opposite. RedBubble has cleverly made their
products available at scale-able deals, discounting your whole order of
stickers based on how many you decide to purchase.

Barring differences in the exchange rate between USD and CAD, an average
full price sticker sold in the United States nets about $4.05 in profit.
This is quantified in a histogram of US sticker sales by profit per
sticker.

<img src="Readme_files/figure-gfm/unit profit hist-1.png" style="display: block; margin: auto;" />

The small bump on the right side of this graph at just over $4.00
represents these full price purchases, but you may have noticed that it
is by no means the largest bump on this graph. The two other bumps are
both very closely packed together, and clearly show that something else
is going on. Below is the same graph with lines representing various
levels of discount from full price.

<img src="Readme_files/figure-gfm/unit profit hist with discount-1.png" style="display: block; margin: auto;" />

This illustrates the discount strategy RedBubble is using. When you have
one sticker in your cart, a popup will notify you before checking out
that you can save 25% if you buy 5 or more stickers and 50% if you buy
10 or more stickers. Since there is no other way to buy a sticker from
my store at less than the full profit margin of \~$4.05 (other than
short seasonal discounts of 15%, 20% and 30% shown with the tiny bumps
on the graph), these two bumps represent people taking advantage of
these discounts. 76.8% of all stickers are bought with the 10+ stickers
for 50% off discount, 19.5% are bought with the 5+ stickers for 25% off
discount, and only 3.7% of stickers are purchased at full price.

Why then are most of my orders just single stickers? The benefit of
having such a huge open marketplace is that users have a ton of designs
to choose from. This means that orders of 10+ stickers will very rarely
have 2 designs by the same designer. The only reason people buy more
than one of my designs in a single order is because most of my designs
are in related series (for example, someone buys a Jasper and Banff
sticker because they have been to both).

Unfortunately, just like exposure, there is very little that can be done
to influence this factor. The only possible thing I have control over
for this *how many?* factor is to make various series of related designs
on my store, and making related designs navigable to each other via
RedBubble’s Collection feature.

## Modelling Daily Sales

To quickly revisit our 4 noticed trends:  
**1. Both tend to be higher during the late summer months.**  
**2. Both tend to be higher during mid-November to mid-December.**  
**3. Both, in general, increase over time.**  
**4. There is less variance in daily users than daily sales.**

We now have a reasonable explanation for 3 and 4, but to better
understand 1 and 2 we have to analyze seasonal trends in the data. The
theory I have about both of these trends is that Redbubble is a popular
online retailer that benefits from a black friday-Chritmas boost in
sales, and that the content of my store (National Parks) is more popular
during the summer. Lucky for us, Google Trends data enables us to
directly compare the relative popularity of each of these ideas and more
over the lifetime of my store.

For example, here is the Google trends data for the relative search
popularity of National Parks over the past 5 years: ![google trends
National Parks](png/googleTrendsNationalParks.PNG) It may be a little
hard to tell, but this is showing a similar rise in the mid to late
summer months as both our sales and user trends. Similarly, here is the
same chart for relative popularity of the search category ‘Redbubble’:
![google trends Redbubble](png/googleTrendsRedbubble.PNG) This is also
showing a similar bump to the sales and user data during mid
November-December.

Using this data (and other data that may help explain trends 1 and 2),
we can construct a model to predict the sales figures one year in the
future. The one year prediction is especially apt in this scenario
because seasonal peaks and valleys are apparent in most of the google
trends data related to my Redbubble store, and hidden non seasonal
trends may help explain more of trend \#3.

The following search trends were used to help construct this model:

**Redbubble (company** **National Park (topic)**  
**Weekend**  
**Sticker**  
**Shopping (topic)**  
**Road trip**

These were all assigned a daily value between 0 and 100 that represents
the relative popularity of that term on that given day. Then, these
terms were fed into a linear model with some other data (day of week,
day of month, days since May 1st, 2017) and were all fitted to the input
daily sales. Since we are attempting to create a year forecast, the
sales data used a linear combination of factors from 365 days prior to
fit the model.

Below is the resulting linear model:

|                  |  Estimate | Standard Error |   t value | p value |
| :--------------- | --------: | -------------: | --------: | ------: |
| (Intercept)      | \-28.7108 |         3.1021 |  \-9.2552 |  0.0000 |
| trend.Redbubble  |    0.3285 |         0.0165 |   19.8837 |  0.0000 |
| trend.NatPark    |    0.2654 |         0.0176 |   15.0384 |  0.0000 |
| trend.RoadTrip   |  \-0.1725 |         0.0155 | \-11.1475 |  0.0000 |
| trend.Sticker    |    0.0232 |         0.0353 |    0.6589 |  0.5101 |
| trend.Shopping   |    0.2822 |         0.0200 |   14.0907 |  0.0000 |
| trend.Weekend    |  \-0.0050 |         0.0127 |  \-0.3905 |  0.6962 |
| trend.Linear     |    0.0099 |         0.0006 |   16.7749 |  0.0000 |
| trend.dayofweek  |  \-1.0688 |         1.6529 |  \-0.6466 |  0.5180 |
| trend.dayofmonth |  \-0.6336 |         1.6097 |  \-0.3936 |  0.6939 |

The P values eliminate some trends, but in general the analysis seems
sound. Applying this model to our real data to create a forecast based
on data from 1 year prior is very useful for doing A/B testing, as long
as this model is reliable. Here is the forecast (blue) compared to the
actual sales data (green) for the entire duration of the Redbubble
store. The line in red is simply the difference between actual and
forecast:

<img src="Readme_files/figure-gfm/Modelled data vs real data-1.png" style="display: block; margin: auto;" />

Our model matches the real sales data pretty close here, but you may
notice that in recent times the forecast is actually a bit off. Let’s
take a closer look at just the error:

<img src="Readme_files/figure-gfm/Modelled data error-1.png" style="display: block; margin: auto;" />

Aside from some spikes in the graph around black friday/cyber monday in
November, the model is well within $10 of the real sales data. However,
some extreme circumstances in 2020 have made this model less accurate
especially during the spring and late summer months. It appears as
though sales were quite a bit lower than forecasted in the March - May
timespan in 2020. This makes a lot of sense, since people were more
concerned with rent and food than buying stickers on the internet.
However there is also a reverse trend recently: notice the positive
error in the late summer and fall months of 2020. This means that real
sales have actually been out-performing the forecast.

My theory for this is that people are actually more willing to travel to
a National park during a pandemic, since so many other competing travel
options are now off the table. Also, maybe they are less willing to
brave the National Park gift shop on their way out and instead opt to
search on the internet for souvenirs. Either way, this is one hell of a
way to throw off a model like this.
