use publications;

select * from titles;
select * from titleauthor;
-- CHALLENGE 1
/* STEP 1. Write a SELECT query to obtain the following output: Title ID, Author ID, Advance of each title and author, royalty of each sale
advance = titles.advance * titleauthor.royaltyper / 100
 sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100   */
 -- advance has only one value for author and title
select t.title_id, ta.au_id, t.advance*ta.royaltyper/100 as advance
from titleauthor ta
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN sales s ON t.title_id =  s.title_id
ORDER BY title_id DESC;

-- there is a royalty for each sale of a book by a given author, so there can be more than one value of sales_royalty for each title and author combination
-- this ill be super important in steps two and three
select t.title_id, ta.au_id, t.price*s.qty*t.royalty/100*ta.royaltyper/100 as sales_royalty
from titleauthor ta
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN sales s ON t.title_id =  s.title_id
ORDER BY title_id DESC;

/* STEP 2.  Aggregate the total royalties for each title and author. Write a query, containing a subquery, 
to obtain the following output: Title ID, Author ID, Aggregated royalties of each title for each author
Hint: use the SUM subquery and group by both au_id and title_id
In the output of this step, each title should appear only once for each author */
-- by sum and grouping by author and title, I am adding all the sales of the same book and author  in one value
select t.title_id, ta.au_id, sum(t.price*s.qty*t.royalty/100*ta.royaltyper/100) as sales_royalty
from titleauthor ta
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN sales s ON t.title_id =  s.title_id
GROUP BY t.title_id, ta.au_id
ORDER BY au_id DESC;

/*Step 3: Calculate the total profits of each author. Now that each title has exactly one row for each author 
where the advance and royalties are available, we are ready to obtain the eventual output. 
Using the output from Step 2, write a query, containing two subqueries, to obtain the following output:
Author ID, Profits of each author by aggregating the advance and total royalties of each title
Sort the output based on a total profits from high to low, and limit the number of rows to 3 */

-- first, let's join both tables of royalties and advance. We'll get a royalty and an advance for each author and each title. that means authors can be in more than one row
select t.title_id, ta.au_id, sum(t.price*s.qty*t.royalty/100*ta.royaltyper/100) as sales_royalty, ad.advance
from titleauthor ta
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN sales s ON t.title_id =  s.title_id
INNER JOIN
(select t.title_id, ta.au_id, t.advance*ta.royaltyper/100 as advance
from titleauthor ta
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN sales s ON t.title_id =  s.title_id) ad
ON t.title_id = ad.title_id and ta.au_id=ad.au_id
GROUP BY t.title_id, ta.au_id
ORDER BY au_id DESC;

/* now we'll sum royalties and advance for each author. in the first subquery I'll add advance and royalty to get total_royalty,
then in the first select i will sum this total royalty for each author, and that's it!
*/
select almost_there.au_id, sum(almost_there.Total_royalty) as author_royalty
from
(select t.title_id, ta.au_id, sum(t.price*s.qty*t.royalty/100*ta.royaltyper/100) + ad.advance as Total_royalty
from titleauthor ta
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN sales s ON t.title_id =  s.title_id
INNER JOIN
(select t.title_id, ta.au_id, t.advance*ta.royaltyper/100 as advance
from titleauthor ta
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN sales s ON t.title_id =  s.title_id) ad
ON t.title_id = ad.title_id and ta.au_id=ad.au_id
GROUP BY t.title_id, ta.au_id) almost_there
GROUP BY almost_there.au_id
ORDER BY author_royalty desc
LIMIT 3;

-- CHALLENGE 2: same but with temporary tables
-- step 1
DROP TABLE IF EXISTS royalty_per_author;
CREATE TEMPORARY TABLE royalty_per_author
select t.title_id, ta.au_id, sum(t.price*s.qty*t.royalty/100*ta.royaltyper/100) as sales_royalty
from titleauthor ta
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN sales s ON t.title_id =  s.title_id
GROUP BY title_id, au_id;

select * from royalty_per_sale;

DROP TABLE IF EXISTS advance_per_author;
CREATE TEMPORARY TABLE advance_per_author
select ta.title_id, ta.au_id, t.advance*ta.royaltyper/100 as advance
from titleauthor ta
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN sales s ON t.title_id =  s.title_id;

select * from advance_per_author
order by au_id;

select r.au_id, sum(a.advance + r.sales_royalty) as total_royalty
from royalty_per_author r
LEFT JOIN advance_per_author a
ON a.au_id = r.au_id
group by au_id
order by total_royalty desc;

-- final answer... can't make it work :(
select r.au_id, sum(a.advance + r.sales_royalty) as total_royalty
from royalty_per_author r
INNER JOIN advance_per_author a
ON a.au_id = r.au_id and a.title_id = r.title_id
group by au_id
order by total_royalty desc;


