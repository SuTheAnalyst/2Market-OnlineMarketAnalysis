-- Create ad_data table
CREATE TABLE public.ad_data
(
    "ID" INTEGER NOT NULL,
    "Bulkmail_ad" INTEGER,
    "Twitter_ad" INTEGER,
    "Instagram_ad" INTEGER,
    "Facebook_ad" INTEGER,
    "Brochure_ad" INTEGER,
    CONSTRAINT "PM_ad_data" PRIMARY KEY ("ID")
);
-- Create marketing_data table
CREATE TABLE public.marketing_data
(
    "ID" INTEGER NOT NULL,
    "Year_Birth" INTEGER,
    "Education" VARCHAR(50),
    "Marital_Status" VARCHAR(50),
    "Income" INTEGER,
    "Kidhome" INTEGER,
	"Teenhome" INTEGER,
	"Dt_Regis_Customer" DATE,
	"Recency" INTEGER,
	"AmtLiq" INTEGER,
	"AmtVege" INTEGER,
	"AmtNonVeg" INTEGER,
	"AmtFish" INTEGER,
	"AmtChocolates" INTEGER,
	"AmtComm" INTEGER,
	"NumDeals" INTEGER,
	"NumWebPur" INTEGER,
	"NumWalkinPur" INTEGER,
	"NumVisits" INTEGER,
	"Campaing_offer_accept" INTEGER,
	"Complain" INTEGER,
	"Country" VARCHAR(50),
	"Ttl_Success_LeadConv" INTEGER,
    CONSTRAINT "PM_marketing_data" PRIMARY KEY ("ID")
);
-- Checking if there is any ID duplication in the table
SELECT
    "ID",
    COUNT(*) AS count_of_duplicates
FROM
    public.marketing_data
GROUP BY
    "ID"
HAVING
    COUNT(*) > 1;
	
-- Income vs Customer spending habits
/*The correlation coefficient ranges from -1 to 1, where -1 indicates a perfect 
negative correlation, 1 indicates a perfect positive correlation, and 0 indicates 
no correlation. The closer the value is to 1 or -1, the stronger the correlation.*/
SELECT
    corr("Income", "AmtLiq") AS age_vs_liquor_correlation,
    corr("Income", "AmtVege") AS income_vs_vegetable_correlation,
    corr("Income", "AmtNonVeg") AS income_vs_non_veg_correlation,
	corr("Income", "AmtFish") AS income_vs_fish_correlation,
	corr("Income", "AmtChocolates") AS income_vs_chocolates_correlation,
	corr("Income", "AmtComm") AS income_vs_comm_correlation
FROM
    public.marketing_data;

-- Income vs Total spending correlation
SELECT 
	corr("Income", "AmtLiq" + "AmtVege" + "AmtNonVeg" + "AmtFish" + "AmtChocolates" + "AmtComm") AS income_vs_total_spending_correlation
FROM 
	public.marketing_data;

-- Minimum and Maximun year birth
SELECT 
	MIN("Year_Birth"), MAX("Year_Birth")
FROM 
	public.marketing_data;

-- What is the relationship between the number of website visits and the number of purchases made? 
SELECT 
	corr("NumVisits", "NumWebPur") AS web_visit_vs_purchase_made_correlation
FROM
    public.marketing_data;
	
-- Ans: -0.051226263075050335

-- What is the overall success rate of lead conversions (Count_success)?
/*This query counts the total number of successful lead conversions and divides it by 
the total number of rows in the "marketing_data" table.*/
SELECT
    COUNT("Ttl_Success_LeadConv") * 100.0 / COUNT(*) AS success_rate
FROM
    public.marketing_data;
-- Ans: 100%

-- Which advertising channels seem to be the most effective?
WITH ChannelSuccess AS (
    SELECT
        Channel,
        SUM(TotalSuccess) AS TotalSuccessLeads
    FROM (
        SELECT
            'Bulkmail_ad' AS Channel,
            SUM("Bulkmail_ad") AS TotalSuccess
        FROM
            public.ad_data
        UNION ALL
        SELECT
            'Twitter_ad' AS Channel,
            SUM("Twitter_ad") AS TotalSuccess
        FROM
            public.ad_data
        UNION ALL
        SELECT
            'Instagram_ad' AS Channel,
            SUM("Instagram_ad") AS TotalSuccess
        FROM
            public.ad_data
        UNION ALL
        SELECT
            'Facebook_ad' AS Channel,
            SUM("Facebook_ad") AS TotalSuccess
        FROM
            public.ad_data
        UNION ALL
        SELECT
            'Brochure_ad' AS Channel,
            SUM("Brochure_ad") AS TotalSuccess
        FROM
            public.ad_data
    ) AS channels
    GROUP BY
        Channel
)

SELECT
    Channel,
    TotalSuccessLeads,
    ROUND(TotalSuccessLeads * 100.0 / SUM(TotalSuccessLeads) OVER (), 2) AS SuccessPercentage
FROM
    ChannelSuccess
ORDER BY
    SuccessPercentage DESC;

-- Which products seem to sell the best?
SELECT
    category,
    ROUND(total_spending * 100.0 / SUM(total_spending) OVER (), 2) AS spending_percentage
FROM (
    SELECT
        'AmtLiq' AS category,
        SUM("AmtLiq") AS total_spending
    FROM
        public.marketing_data
    UNION ALL
    SELECT
        'AmtVege' AS category,
        SUM("AmtVege") AS total_spending
    FROM
        public.marketing_data
    UNION ALL
    SELECT
        'AmtNonVeg' AS category,
        SUM("AmtNonVeg") AS total_spending
    FROM
        public.marketing_data
    UNION ALL
    SELECT
        'AmtFish' AS category,
        SUM("AmtFish") AS total_spending
    FROM
        public.marketing_data
    UNION ALL
    SELECT
        'AmtChocolates' AS category,
        SUM("AmtChocolates") AS total_spending
    FROM
        public.marketing_data
    UNION ALL
    SELECT
        'AmtComm' AS category,
        SUM("AmtComm") AS total_spending
    FROM
        public.marketing_data
) AS spending_categories
ORDER BY
    spending_percentage DESC;
-- Ans:Liquore with 50.26%

-- Percentage of purchasing pattern by country
WITH product_spending AS (
    SELECT
        "Country",
        SUM("AmtLiq") AS total_liq,
        SUM("AmtVege") AS total_vege,
        SUM("AmtNonVeg") AS total_nonveg,
        SUM("AmtFish") AS total_fish,
        SUM("AmtChocolates") AS total_chocolates,
        SUM("AmtComm") AS total_comm
    FROM
        public.marketing_data
    GROUP BY
        "Country"
)

SELECT
    "Country",
    ROUND(total_liq * 100.0 / (total_liq + total_vege + total_nonveg + total_fish + total_chocolates + total_comm), 2) AS liq_percentage,
    ROUND(total_vege * 100.0 / (total_liq + total_vege + total_nonveg + total_fish + total_chocolates + total_comm), 2) AS vege_percentage,
    ROUND(total_nonveg * 100.0 / (total_liq + total_vege + total_nonveg + total_fish + total_chocolates + total_comm), 2) AS nonveg_percentage,
    ROUND(total_fish * 100.0 / (total_liq + total_vege + total_nonveg + total_fish + total_chocolates + total_comm), 2) AS fish_percentage,
    ROUND(total_chocolates * 100.0 / (total_liq + total_vege + total_nonveg + total_fish + total_chocolates + total_comm), 2) AS chocolates_percentage,
    ROUND(total_comm * 100.0 / (total_liq + total_vege + total_nonveg + total_fish + total_chocolates + total_comm), 2) AS comm_percentage
FROM
    product_spending;
/* Ans: The purchase of alcoholic beverages is the highest in Montenegro and the lowest in India. 
		The purchase of vegetables is the highest in India and the lowest in Montenegro. 
		The purchase of meat items is the highest in India and the lowest in Australia. 
		The purchase of fish products is the highest in Montenegro and the lowest in Canada. 
		The purchase of chocolate is the highest in Australia and the lowest in Germany. 
		The purchase of commodities is the highest in Australia and the lowest in Spain. 
		In summary, even though Spain and SouthAfrica representing the hightest rate the population,
		the spending power is behind the rest of the low population countries such as Montenegro,
		Germany, Australia, India and Canada (ascending order of population)*/



-- Categorise customer into age group 
-- Define Common Table Expression CTE
/* CTE named age_groups is defined. It categorizes 
each customer into an age group based on their birth year.*/
WITH age_groups AS (
    SELECT
        CASE
            WHEN "Year_Birth" <= 1963 THEN '60 or older'
            WHEN "Year_Birth" BETWEEN 1964 AND 1983 THEN '40-59'
            WHEN "Year_Birth" BETWEEN 1984 AND 2003 THEN '20-39'
            WHEN "Year_Birth" BETWEEN 2004 AND 2023 THEN '19 or younger'
            ELSE 'Unknown'
        END AS age_group
    FROM
        public.marketing_data
)

/* Why CTE? Using a CTE allows you to break down a complex query into more readable and 
manageable parts. In this specific case, the CTE defines the logic for categorizing customers 
into age groups. If the logic for categorizing customers into age groups is needed in multiple places
within the query or in subsequent queries, a CTE allows us to define that logic once and 
reference it as needed.*/

-- Main Query
/* ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 0) AS percentage: It calculates 
the percentage of customers in each age group, rounded to the nearest whole number. */
SELECT
    age_group,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),0) AS percentage
FROM
    age_groups
GROUP BY
    age_group
ORDER BY
	percentage DESC;

--Ans: 55% 40- 59, 31% 60>, 13% 20-39

-- Percentage of customer country profile
WITH customer_counts AS (
    SELECT
        "Country",
        COUNT(*) AS customer_count
    FROM
        public.marketing_data
    GROUP BY
        "Country"
)

SELECT
    "Country",
    customer_count,
    ROUND(customer_count * 100.0 / SUM(customer_count) OVER (), 2) AS percentage
FROM
    customer_counts
ORDER BY
    customer_count DESC;

-- Percenetage of complain made by customers from different country 
WITH customer_complaints AS (
    SELECT
        "Country",
        COUNT("ID") AS total_customers,
        SUM("Complain") AS total_complaints
    FROM
        public.marketing_data
    GROUP BY
        "Country"
)

SELECT
    cc."Country",
    cc.total_customers,
    cc.total_complaints,
    ROUND(cc.total_complaints * 100.0 / cc.total_customers, 2) AS complaint_percentage
FROM
    customer_complaints cc;

/* Ans: Spain being the country with the least purchase of our products obtained more complaint than
	the countries that has higher purchase rate.*/
