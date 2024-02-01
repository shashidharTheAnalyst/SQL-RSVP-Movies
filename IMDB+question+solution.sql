USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT 
    table_name, table_rows
FROM
    information_schema.tables
WHERE
    table_schema = 'imdb';

/*
# TABLE_NAME	TABLE_ROWS
director_mapping	3867
genre	14662
movie	8146
names	21603
ratings	8230
role_mapping	14726
*/








-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT 
    SUM(CASE
        WHEN id IS NULL THEN 1
        ELSE 0
    END) AS ID_NULL,
    SUM(CASE
        WHEN title IS NULL THEN 1
        ELSE 0
    END) AS Title_NULL,
    SUM(CASE
        WHEN year IS NULL THEN 1
        ELSE 0
    END) AS Year_NULL,
    SUM(CASE
        WHEN date_published IS NULL THEN 1
        ELSE 0
    END) AS Date_published_NULL,
    SUM(CASE
        WHEN duration IS NULL THEN 1
        ELSE 0
    END) AS Duration_NULL,
    SUM(CASE
        WHEN country IS NULL THEN 1
        ELSE 0
    END) AS Country_NULL,
    SUM(CASE
        WHEN worlwide_gross_income IS NULL THEN 1
        ELSE 0
    END) AS Worlwide_gross_income_NULL,
    SUM(CASE
        WHEN languages IS NULL THEN 1
        ELSE 0
    END) AS Languages_NULL,
    SUM(CASE
        WHEN production_company IS NULL THEN 1
        ELSE 0
    END) AS Production_company_NULL
FROM
    movie;

/* --
# ID_NULL	Title_NULL	Year_NULL	Date_published_NULL	Duration_NULL	Country_NULL	Worlwide_gross_income_NULL	Languages_NULL	Production_company_NULL
	0			0			0			0					0				20					3724					194					528
*/







-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)


/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT 
    year AS Year, COUNT(title) AS number_of_movies
FROM
    movie
GROUP BY year;

SELECT 
    MONTH(date_published) AS month_num,
    COUNT(title) AS number_of_movies
FROM
    movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);

/* # Year	number_of_movies
	2017	3052
	2018	2944
	2019	2001
*/

/*
# month_num	number_of_movies
		1		804
		2		640
		3		824
		4		680
		5		625
		6		580
		7		493
		8		678
		9		809
		10		801
		11		625
		12		438
*/









/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 
    COUNT(*) AS movie_count
FROM
    movie
WHERE
    (country = 'USA' OR country = 'india')
        AND year = 2019;

/*
# movie_count
		887
*/






/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT DISTINCT
    genre
FROM
    genre;

/*
# genre
Drama
Fantasy
Thriller
Comedy
Horror
Family
Romance
Adventure
Action
Sci-Fi
Crime
Mystery
Others
*/









/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
SELECT 
    genre, COUNT(movie_id) AS number_of_movies
FROM
    genre AS g
        INNER JOIN
    movie AS m ON g.movie_id = m.id
WHERE year = 2019
GROUP BY genre
ORDER BY number_of_movies DESC
LIMIT 1;

/*
# 	genre		number_of_movies
	Drama		4285
*/










/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
WITH one_genre AS
(
	SELECT movie_id, 
			COUNT(genre) AS number_of_movies
	FROM genre
	GROUP BY movie_id
	HAVING number_of_movies=1
)
SELECT COUNT(movie_id) AS number_of_movies
FROM one_genre;

/*
# number_of_movies
3289
*/







/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    genre, ROUND(AVG(duration)) AS avg_duration
FROM
    genre AS g
        INNER JOIN
    movie AS m ON g.movie_id = m.id
GROUP BY genre
ORDER BY avg_duration DESC;

/*
#   genre		avg_duration
	Action		113
	Romance		110
	Drama		107
	Crime		107
	Fantasy		105
	Comedy		103
	Thriller	102
	Adventure	102
	Mystery		102
	Family		101
	Others		100
	Sci-Fi		98
	Horror		93
*/






/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH thriller_rank AS (
    SELECT
        genre,
        COUNT(movie_id) AS movie_count,
        RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
    FROM
        genre AS g
        INNER JOIN movie AS m ON g.movie_id = m.id
    GROUP BY
        genre
    ORDER BY
        movie_count DESC
)
SELECT *
FROM
    thriller_rank
    WHERE genre = 'thriller';








/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

WITH RatingSummary AS (
    SELECT
        MIN(avg_rating) AS min_avg_rating,
        MAX(avg_rating) AS max_avg_rating,
        MIN(total_votes) AS min_total_votes,
        MAX(total_votes) AS max_total_votes,
        MIN(median_rating) AS min_median_rating,
        MAX(median_rating) AS max_median_rating
    FROM ratings
)
SELECT
    min_avg_rating,
    max_avg_rating,
    min_total_votes,
    max_total_votes,
    min_median_rating,
    max_median_rating
FROM RatingSummary;

/*
# min_avg_rating	max_avg_rating	min_total_votes	max_total_votes	min_median_rating	max_median_rating
	1.0				10.0			100				725138			1					10
*/



    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
WITH movie_rating AS (
SELECT
        title,
        avg_rating,
        DENSE_RANK() OVER (ORDER BY avg_rating DESC) AS movie_rank
    FROM
        movie AS m
        INNER JOIN ratings AS r ON m.id = r.movie_id
)
SELECT *
FROM movie_rating
WHERE movie_rank <=10;

/*
		# title						avg_rating	movie_rank
		Kirket						10.0		1
		Love in Kilnerry			10.0		1
		Gini Helida Kathe			9.8			2
		Runam						9.7			3
		Fan							9.6			4
	Android Kunjappan Version 5.25	9.6			4
	Yeh Suhaagraat Impossible		9.5			5
	Safe							9.5			5
	The Brighton Miracle			9.5			5
	Shibu							9.4			6
	Our Little Haven				9.4			6
	Zana							9.4			6
	Family of Thakurganj			9.4			6
	Ananthu V/S Nusrath				9.4			6
	Eghantham						9.3			7
	Wheels							9.3			7
	Turnover						9.2			8
	Digbhayam						9.2			8
	Tõde ja õigus					9.2			8
	Ekvtime: Man of God				9.2			8
	Leera the Soulmate				9.2			8
	AA BB KK						9.2			8
	Peranbu							9.2			8
	Dokyala Shot					9.2			8
	Ardaas Karaan					9.2			8
	Kuasha jakhon					9.1			9
	Oththa Seruppu Size 7			9.1			9
	Adutha Chodyam					9.1			9
	The Colour of Darkness			9.1			9
	Aloko Udapadi					9.1			9
	C/o Kancharapalem				9.1			9
	Nagarkirtan						9.1			9
	Jelita Sejuba: Mencintai Kesatria Negara	9.1	9
	Shindisi						9.0			10
	Officer Arjun Singh IPS			9.0			10
	Oskars Amerika					9.0			10
	Delaware Shore					9.0			10
	Abstruse						9.0			10
	National Theatre Live: Angels in America Part Two - Perestroika	9.0	10
	Innocent						9.0			10
*/


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
    median_rating, COUNT(movie_id) AS movie_count
FROM
    ratings
GROUP BY median_rating
ORDER BY median_rating;

/*
# median_rating	movie_count
1	94
2	119
3	283
4	479
5	985
6	1975
7	2257
8	1030
9	429
10	346
*/






/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT production_company, COUNT(id) AS movie_count,
		DENSE_RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_company_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
WHERE avg_rating > 8 AND production_company IS NOT NULL
GROUP BY production_company
ORDER BY movie_count DESC;

/*
# production_company	movie_count	prod_company_rank
Dream Warrior Pictures	3	1
National Theatre Live	3	1
Lietuvos Kinostudija	2	2
Swadharm Entertainment	2	2
Panorama Studios	2	2
Marvel Studios	2	2
Central Base Productions	2	2
Painted Creek Productions	2	2
National Theatre	2	2
Colour Yellow Productions	2	2
The Archers	1	3
Blaze Film Enterprises	1	3
Bradeway Pictures	1	3
Bert Marcus Productions	1	3
A Studios	1	3
Ronk Film	1	3
Benaras Mediaworks	1	3
Bioscope Film Framers	1	3
Bestwin Production	1	3
Studio Green	1	3
AKS Film Studio	1	3
Kaargo Cinemas	1	3
Animonsta Studios	1	3
O3 Turkey Medya	1	3
StarVision	1	3
Synergy Films	1	3
PVP Cinema	1	3
Plan J Studios	1	3
20 Steps Productions	1	3
Prime Zero Productions	1	3
Shreya Films International	1	3
SLN Cinemas	1	3
Epiphany Entertainments	1	3
3 Ng Film	1	3
Eastpool Films	1	3
A square productions	1	3
Oak Entertainments	1	3
Doha Film Institute	1	3
Fenrir Films	1	3
Fábrica de Cine	1	3
Chernin Entertainment	1	3
Cross Creek Pictures	1	3
Loaded Dice Films	1	3
WM Films	1	3
Walt Disney Pictures	1	3
Excel Entertainment	1	3
Ancine	1	3
Twentieth Century Fox	1	3
Ave Fenix Pictures	1	3
Runaway Productions	1	3
Aletheia Films	1	3
70 MM Entertainments	1	3
Moho Film	1	3
BR Productions and Riding High Pictures	1	3
Cana Vista Films	1	3
Gurbani Media	1	3
Sony Pictures Entertainment (SPE)	1	3
InnoVate Productions	1	3
Saanvi Pictures	1	3
The SPA Studios	1	3
Rotten Productions	1	3
Film Village	1	3
Arka Mediaworks	1	3
Atresmedia Cine	1	3
Goopy Bagha Productions Limited	1	3
Maxmedia	1	3
1234 Cine Creations	1	3
Silent Hills Studio	1	3
Blueprint Pictures	1	3
Archangel Studios	1	3
HI Film Productions	1	3
Tin Drum Beats	1	3
Frío Frío	1	3
Warnuts Entertainment	1	3
Potential Studios	1	3
Adrama	1	3
Dark Steel Entertainment	1	3
Allfilm	1	3
Nokkhottro Cholochitra	1	3
BOB Film Sweden AB	1	3
Smash Entertainment!	1	3
EFilm	1	3
Urvashi Theaters	1	3
Angel Capital Film Group	1	3
Grass Root Film Company	1	3
Art Movies	1	3
Lost Legends	1	3
Ra.Mo.	1	3
Avocado Media	1	3
Tigmanshu Dhulia Films	1	3
Think Music	1	3
Anwar Rasheed Entertainment	1	3
Dwarakish Chitra	1	3
Anto Joseph Film Company	1	3
Dijital Sanatlar Production	1	3
Missart produkcija	1	3
Jayanna Combines	1	3
Jar Pictures	1	3
British Muslim TV	1	3
Crossing Bridges Films	1	3
BrightKnight Entertainment	1	3
Mirror Images LTD.	1	3
Mango Pickle Entertainment	1	3
Detailfilm	1	3
Archway Pictures	1	3
Vehli Janta Films	1	3
Grooters Productions	1	3
Fulwell 73	1	3
Participant	1	3
Madras Enterprises	1	3
Alchemy Vision Workz	1	3
Axess Film Factory	1	3
PRK Productions	1	3
Dashami Studioz	1	3
Fablemaze	1	3
StarFab Production	1	3
RGK Cinema	1	3
Shreyasree Movies	1	3
BRON Studios	1	3
Bhadrakali Pictures	1	3
The Icelandic Filmcompany	1	3
The Church of Almighty God Film Center	1	3
Maha Sithralu	1	3
Mythri Movie Makers	1	3
Orange Médias	1	3
Mumbai Film Company	1	3
Swapna Cinema	1	3
Vivid Films	1	3
HRX Films	1	3
Wonder Head	1	3
Sixteen by Sixty-Four Productions	1	3
Akshar Communications	1	3
Moviee Mill	1	3
Happy Hours Entertainments	1	3
M-Films	1	3
Cineddiction Films	1	3
Heyday Films	1	3
Diamond Works	1	3
Shree Raajalakshmi Films	1	3
Dream Tree Film Productions	1	3
Cine Sarasavi Productions	1	3
Acropolis Entertainment	1	3
RedhanThe Cinema People	1	3
Hombale Films	1	3
Swonderful Pictures	1	3
COMETE Films	1	3
Cinepro Lanka International	1	3
Williams 4 Productions	1	3
Touch Wood Multimedia Creations	1	3
Rocket Beans Entertainment	1	3
Hepifilms	1	3
SRaj Productions	1	3
Kharisma Starvision Plus PT	1	3
MD productions	1	3
Ataraxia Entertainment	1	3
NBW Films	1	3
Kannamthanam Films	1	3
Brainbox Studios	1	3
Matchbox Pictures	1	3
Reliance Entertainment	1	3
Neelam Productions	1	3
Jyot & Aagnya Anusaare Productions	1	3
Clown Town Productions	1	3
Special Treats Production Company	1	3
Mooz Films	1	3
Bulb Chamka	1	3
GreenTouch Entertainment	1	3
Crystal Paark Cinemas	1	3
Kangaroo Broadcasting	1	3
Swami Samartha Creations	1	3
DreamReality Movies	1	3
Fahadh Faasil and Friends	1	3
Narrator	1	3
Kineo Filmproduktion	1	3
Appu Pathu Pappu Production House	1	3
Rishab Shetty Films	1	3
Namah Pictures	1	3
Annai Tamil Cinemas	1	3
Viacom18 Motion Pictures	1	3
MNC Pictures	1	3
Clyde Vision Films	1	3
Adenium Productions	1	3
Trafalgar Releasing	1	3
Lovely World Entertainment	1	3
Hayagriva Movie Adishtana	1	3
OPM Cinemas	1	3
Sithara Entertainments	1	3
French Quarter Film	1	3
Mumba Devi Motion Pictures	1	3
Fox STAR Studios	1	3
Aries Telecasting	1	3
Abis Studio	1	3
Rapi Films	1	3
Ay Yapim	1	3
Aatpaat Production	1	3
Channambika Films	1	3
Cinenic Film	1	3
The United Team of Art	1	3
Grahalakshmi Productions	1	3
Mahesh Manjrekar Movies	1	3
Manikya Productions	1	3
Bombay Walla Films	1	3
Viva Inen Productions	1	3
Banana Film DOOEL	1	3
Toei Animation	1	3
Golden Horse Cinema	1	3
V. Creations	1	3
Moonshot Entertainments	1	3
Humble Motion Pictures	1	3
Coconut Motion Pictures	1	3
Bayview Projects	1	3
Piecewing Productions	1	3
Manyam Productions	1	3
Suresh Productions	1	3
Benzy Productions	1	3
RMCC Productions	1	3

*/








-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    g.genre, COUNT(g.movie_id) AS movie_count
FROM
    genre AS g
        INNER JOIN
    ratings AS r ON g.movie_id = r.movie_id
        INNER JOIN
    movie AS m ON m.id = g.movie_id
WHERE
    m.country = 'USA'
        AND MONTH(date_published) = 3
        AND year = 2017
        AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC;

/*
# 	genre	 movie_count
	Drama	 16
	Comedy	 8
	Crime	 5
	Horror	 5
	Action	 4
	Sci-Fi	 4
	Thriller 4
	Romance	 3
	Fantasy	 2
	Mystery	 2
	Family	 1
*/






-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
    title, avg_rating, genre
FROM
    genre AS g
        INNER JOIN
    ratings AS r ON g.movie_id = r.movie_id
        INNER JOIN
    movie AS m ON m.id = g.movie_id
WHERE
    title LIKE 'The%' AND avg_rating > 8
ORDER BY avg_rating DESC;

/*
# title										avg_rating	genre
The Brighton Miracle						9.5			Drama
The Colour of Darkness						9.1			Drama
The Blue Elephant 2							8.8			Drama
The Blue Elephant 2							8.8			Horror
The Blue Elephant 2							8.8			Mystery
The Irishman								8.7			Crime
The Irishman								8.7			Drama
The Mystery of Godliness: The Sequel		8.5			Drama
The Gambinos								8.4			Crime
The Gambinos								8.4			Drama
Theeran Adhigaaram Ondru					8.3			Action
Theeran Adhigaaram Ondru					8.3			Crime
Theeran Adhigaaram Ondru					8.3			Thriller
The King and I								8.2			Drama
The King and I								8.2			Romance
*/





-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT 
    title, median_rating, genre
FROM
    genre AS g
        INNER JOIN
    ratings AS r ON g.movie_id = r.movie_id
        INNER JOIN
    movie AS m ON m.id = g.movie_id
WHERE
    median_rating = 8
        AND date_published BETWEEN '2018-04-01' AND '2019-04-01'
ORDER BY avg_rating DESC;

/*
# title	median_rating	genre
Tikli and Laxmi Bomb	8	Drama
Ankur	8	Drama
Green Book	8	Comedy
Green Book	8	Drama
An American in Paris: The Musical	8	Others
The King and I	8	Drama
The King and I	8	Romance
Grazuole	8	Drama
Grazuole	8	Family
Chop Chop Chang: Operation C.H.I.M.P	8	Comedy
Shonar Pahar	8	Drama
Bohemian Rhapsody	8	Drama
My Foolish Heart	8	Drama
Rossz versek	8	Comedy
Rossz versek	8	Drama
Wo bu shi yao shen	8	Comedy
Wo bu shi yao shen	8	Drama
Badhaai Ho	8	Comedy
Badhaai Ho	8	Drama
Until Midnight	8	Drama
Until Midnight	8	Thriller
Keluarga Cemara	8	Drama
Keluarga Cemara	8	Family
Manbiki kazoku	8	Crime
Manbiki kazoku	8	Drama
Song Lang	8	Drama
Eia jõulud Tondikakul	8	Family
Mukherjee Dar Bou	8	Drama
Mukherjee Dar Bou	8	Family
37 Seconds	8	Drama
Winaypacha	8	Drama
Canary	8	Drama
La flor	8	Drama
La flor	8	Fantasy
Mahalaya	8	Drama
Metri Shesh Va Nim	8	Crime
Metri Shesh Va Nim	8	Drama
Metri Shesh Va Nim	8	Thriller
Diamond Dust	8	Crime
Diamond Dust	8	Drama
Diamond Dust	8	Mystery
Mission: Impossible - Fallout	8	Action
Mission: Impossible - Fallout	8	Adventure
Mission: Impossible - Fallout	8	Thriller
Is This Now	8	Thriller
Roma	8	Drama
Raazi	8	Action
Raazi	8	Drama
Raazi	8	Thriller
Niet Schieten	8	Drama
Da xiang xi di er zuo	8	Drama
Chi La Sow	8	Comedy
Chi La Sow	8	Romance
Sirdys	8	Drama
Sirdys	8	Romance
A Star Is Born	8	Drama
A Star Is Born	8	Romance
As Worlds Collide	8	Thriller
Incredibles 2	8	Action
Incredibles 2	8	Adventure
Driving While Black	8	Comedy
Driving While Black	8	Drama
The Breadwinner	8	Drama
The Breadwinner	8	Family
Deadpool 2	8	Action
Deadpool 2	8	Adventure
Deadpool 2	8	Comedy
Bille	8	Drama
Live from Dhaka	8	Drama
Irumbu Thirai	8	Action
Irumbu Thirai	8	Thriller
Hamid	8	Drama
Searching	8	Drama
Searching	8	Mystery
Searching	8	Thriller
Kamera wo tomeruna!	8	Comedy
Kamera wo tomeruna!	8	Horror
Fagun Haway	8	Drama
Fagun Haway	8	Family
Stree	8	Comedy
Stree	8	Horror
Bioscopewala	8	Drama
Moromete Family: On the Edge of Time	8	Drama
Saga of Tanya the Evil Movie	8	Action
Saga of Tanya the Evil Movie	8	Adventure
Di jiu tian chang	8	Drama
Ek Hasina Thi	8	Crime
Ek Hasina Thi	8	Drama
Ek Hasina Thi	8	Mystery
The Favourite	8	Drama
Love, Simon	8	Comedy
Love, Simon	8	Drama
Love, Simon	8	Romance
303	8	Comedy
303	8	Drama
303	8	Romance
Digimon Adventure Tri. 6	8	Action
Digimon Adventure Tri. 6	8	Adventure
Dyke pole	8	Adventure
Dyke pole	8	Comedy
Dyke pole	8	Drama
Bhavesh Joshi Superhero	8	Action
Bhavesh Joshi Superhero	8	Drama
Võta või jäta	8	Drama
The Grizzlies	8	Drama
Zimna wojna	8	Drama
La noche de 12 años	8	Crime
La noche de 12 años	8	Drama
Pahuna: The Little Visitors	8	Drama
Pahuna: The Little Visitors	8	Mystery
Beoning	8	Drama
Beoning	8	Mystery
Koode	8	Drama
Koode	8	Fantasy
The Boy Who Harnessed the Wind	8	Drama
Sarvam Thaala Mayam	8	Drama
Boku no Hero Academia the Movie	8	Action
Boku no Hero Academia the Movie	8	Adventure
Maghzhaye Koochake Zang Zadeh	8	Crime
Maghzhaye Koochake Zang Zadeh	8	Drama
Maghzhaye Koochake Zang Zadeh	8	Thriller
Njan Prakashan	8	Comedy
Njan Prakashan	8	Drama
Ne Bom Vec Luzerka	8	Drama
Zoku Owarimonogatari	8	Fantasy
Generation Aami	8	Drama
Le roi de coeur	8	Comedy
Le roi de coeur	8	Drama
The Evil Dead	8	Horror
Chambal	8	Drama
How to Train Your Dragon: The Hidden World	8	Action
How to Train Your Dragon: The Hidden World	8	Adventure
Einstein and Einstein	8	Drama
Marriage: Impossible	8	Comedy
Marriage: Impossible	8	Drama
Der Junge muss an die frische Luft	8	Comedy
Der Junge muss an die frische Luft	8	Drama
Tuntematon mestari	8	Drama
120 battements par minute	8	Drama
Ruben Brandt, Collector	8	Action
Ruben Brandt, Collector	8	Crime
Ricordi?	8	Drama
Ricordi?	8	Romance
Upgrade	8	Action
Upgrade	8	Horror
Upgrade	8	Sci-Fi
102 Not Out	8	Comedy
102 Not Out	8	Drama
A Quiet Place	8	Drama
A Quiet Place	8	Horror
A Quiet Place	8	Sci-Fi
Den skyldige	8	Crime
Den skyldige	8	Drama
Den skyldige	8	Thriller
Seuwingkizeu	8	Drama
THE SECRET of HAPPINESS	8	Comedy
THE SECRET of HAPPINESS	8	Drama
BlacKkKlansman	8	Crime
BlacKkKlansman	8	Drama
Ternet ninja	8	Action
Ternet ninja	8	Adventure
Michelangelo - Infinito	8	Drama
October	8	Drama
October	8	Romance
Karwaan	8	Comedy
Karwaan	8	Drama
Ente Mezhuthiri Athazhangal	8	Drama
Ente Mezhuthiri Athazhangal	8	Romance
Sonchiriya	8	Action
Sonchiriya	8	Crime
Sonchiriya	8	Drama
La Casa Lobo	8	Drama
La Casa Lobo	8	Horror
Varathan	8	Action
Varathan	8	Drama
Varathan	8	Thriller
Mazhayathu	8	Drama
Mazhayathu	8	Family
The Unorthodox	8	Comedy
The Unorthodox	8	Drama
Homestay	8	Drama
Homestay	8	Fantasy
Homestay	8	Thriller
Ir visi ju vyrai	8	Comedy
Ir visi ju vyrai	8	Drama
Ir visi ju vyrai	8	Romance
Blakus	8	Comedy
Blakus	8	Drama
Un rubio	8	Drama
Un rubio	8	Romance
Alita: Battle Angel	8	Action
Alita: Battle Angel	8	Adventure
Alita: Battle Angel	8	Sci-Fi
Sweater	8	Drama
The Guernsey Literary and Potato Peel Pie Society	8	Drama
The Guernsey Literary and Potato Peel Pie Society	8	Romance
The Bromley Boys	8	Comedy
Sueño en otro idioma	8	Drama
Sueño en otro idioma	8	Romance
Love Sonia	8	Drama
Transfert	8	Drama
Transfert	8	Thriller
The Hate U Give	8	Crime
The Hate U Give	8	Drama
Imaikkaa Nodigal	8	Action
Imaikkaa Nodigal	8	Crime
Imaikkaa Nodigal	8	Drama
The Rider	8	Drama
Canastra Suja	8	Drama
Canastra Suja	8	Romance
Kesari	8	Action
Kesari	8	Drama
Ilosia aikoja, Mielensäpahoittaja	8	Comedy
Ilosia aikoja, Mielensäpahoittaja	8	Drama
Foxtrot	8	Drama
Durante la tormenta	8	Drama
Durante la tormenta	8	Mystery
Durante la tormenta	8	Romance
Journal 64	8	Crime
Journal 64	8	Mystery
Journal 64	8	Thriller
Manto	8	Drama
Mario	8	Drama
Mario	8	Romance
Take care good night	8	Crime
Take care good night	8	Drama
Take care good night	8	Family
Edmond	8	Comedy
Edmond	8	Drama
Gundermann	8	Drama
Blindspotting	8	Comedy
Blindspotting	8	Crime
Blindspotting	8	Drama
Savovi	8	Drama
Savovi	8	Thriller
Leto	8	Romance
Parque Mayer	8	Drama
Soorma	8	Drama
Homo Novus	8	Comedy
Homo Novus	8	Romance
Ága	8	Drama
Katheyondu Shuruvagide	8	Comedy
Katheyondu Shuruvagide	8	Romance
Mard Ko Dard Nahin Hota	8	Action
Mard Ko Dard Nahin Hota	8	Comedy
Milly & Mamet: Ini Bukan Cinta & Rangga	8	Comedy
Milly & Mamet: Ini Bukan Cinta & Rangga	8	Romance
Kaatrin Mozhi	8	Comedy
Kaatrin Mozhi	8	Drama
Janelle Monáe: Dirty Computer	8	Others
Dronningen	8	Drama
Dear Ex	8	Comedy
Dear Ex	8	Drama
Dear Ex	8	Romance
Komola Rocket	8	Drama
Jeungin	8	Crime
Jeungin	8	Drama
June	8	Drama
June	8	Romance
My Mr. Wife	8	Comedy
Remélem legközelebb sikerül meghalnod:)	8	Comedy
Remélem legközelebb sikerül meghalnod:)	8	Drama
Remélem legközelebb sikerül meghalnod:)	8	Thriller
Kler	8	Drama
Bizi Hatirla	8	Drama
Aruna & Lidahnya	8	Drama
Friend Zone	8	Comedy
Friend Zone	8	Romance
Aashirwad	8	Drama
Kaminnyy khrest	8	Drama
Shankar Mudi	8	Drama
Another Day of Life	8	Others
Tigers	8	Drama
Unsound	8	Comedy
Unsound	8	Drama
Christopher Robin	8	Adventure
Christopher Robin	8	Comedy
Christopher Robin	8	Drama
Muskarci ne placu	8	Drama
Lucky	8	Comedy
Lucky	8	Drama
The Professor and the Madman	8	Drama
The Professor and the Madman	8	Mystery
Evening Shadows	8	Drama
Ivan	8	Drama
Chasing the Blues	8	Comedy
Gold	8	Drama
Blood 13	8	Crime
Blood 13	8	Drama
Blood 13	8	Horror
Arábia	8	Drama
Mauvaises herbes	8	Comedy
Wiro Sableng 212	8	Action
Wiro Sableng 212	8	Adventure
Wiro Sableng 212	8	Comedy
The Vast of Night	8	Fantasy
The Vast of Night	8	Mystery
The Vast of Night	8	Sci-Fi
Sulla mia pelle	8	Drama
The Reports on Sarah and Saleem	8	Crime
The Reports on Sarah and Saleem	8	Drama
The Reports on Sarah and Saleem	8	Mystery
Iravukku Aayiram Kangal	8	Action
Iravukku Aayiram Kangal	8	Thriller
Instant Family	8	Comedy
Instant Family	8	Drama
Love and Shukla	8	Comedy
Love and Shukla	8	Drama
Love and Shukla	8	Romance
Apró mesék	8	Drama
Apró mesék	8	Romance
Apró mesék	8	Thriller
Hereditary	8	Drama
Hereditary	8	Horror
Hereditary	8	Mystery
Chekka Chivantha Vaanam	8	Action
Chekka Chivantha Vaanam	8	Crime
Chekka Chivantha Vaanam	8	Drama
Utøya 22. juli	8	Drama
Utøya 22. juli	8	Thriller
Kolamavu Kokila	8	Comedy
Kolamavu Kokila	8	Crime
Kolamavu Kokila	8	Drama
Uma	8	Drama
Hou lai de wo men	8	Drama
Hou lai de wo men	8	Romance
Motorcycle Girl	8	Others
Une colonie	8	Drama
Îmi este indiferent daca în istorie vom intra ca barbari	8	Comedy
Îmi este indiferent daca în istorie vom intra ca barbari	8	Drama
Shu Thayu	8	Comedy
Shu Thayu	8	Drama
Petta	8	Action
Petta	8	Drama
Koodasha	8	Action
Koodasha	8	Crime
Koodasha	8	Drama
Silvat	8	Drama
Silvat	8	Romance
Indian Horse	8	Drama
The Tower	8	Drama
Sila Samayangalil	8	Drama
Soni	8	Drama
Kammara Sambhavam	8	Action
Kammara Sambhavam	8	Comedy
Kammara Sambhavam	8	Drama
Five Feet Apart	8	Drama
Five Feet Apart	8	Romance
Campeones	8	Comedy
Campeones	8	Drama
Rizu to aoi tori	8	Drama
Rizu to aoi tori	8	Fantasy
Zlogonje	8	Adventure
Zlogonje	8	Drama
Zlogonje	8	Family
The Steam Engines of Oz	8	Adventure
The Steam Engines of Oz	8	Family
Breaking Barbi	8	Comedy
Üç Harfliler: Beddua	8	Horror
Meri Nimmo	8	Drama
Das schönste Mädchen der Welt	8	Comedy
Das schönste Mädchen der Welt	8	Romance
Vijay Superum Pournamiyum	8	Comedy
Vijay Superum Pournamiyum	8	Drama
Golak Bugni Bank Te Batua	8	Comedy
Golak Bugni Bank Te Batua	8	Drama
Blindsone	8	Drama
Halkaa	8	Drama
Halkaa	8	Family
Brokedown	8	Horror
Brokedown	8	Thriller
Pataakha	8	Action
Pataakha	8	Comedy
Pataakha	8	Drama
Kafir: Bersekutu dengan Setan	8	Horror
Aatagadharaa Siva	8	Action
Aatagadharaa Siva	8	Comedy
Aatagadharaa Siva	8	Drama
Si Doel the Movie	8	Drama
Game Over	8	Drama
Game Over	8	Thriller
Alice	8	Comedy
Alice	8	Drama
Alice	8	Romance
Baishe: Yuanqi	8	Fantasy
Baishe: Yuanqi	8	Romance
Gali Guleiyan	8	Drama
Gali Guleiyan	8	Thriller
Inspiration	8	Horror
Inspiration	8	Thriller
Once Again	8	Drama
Once Again	8	Romance
Bodied	8	Comedy
Bodied	8	Drama
Yonlu	8	Drama
Suburban Coffin	8	Comedy
Suburban Coffin	8	Fantasy
Suburban Coffin	8	Horror
Ek Je Chhilo Raja	8	Drama
Seethakaathi	8	Drama
Taxiwaala	8	Comedy
Taxiwaala	8	Horror
Taxiwaala	8	Thriller
Hello Guru Prema Kosame	8	Comedy
Hello Guru Prema Kosame	8	Romance
Psychobitch	8	Drama
Adanga Maru	8	Action
Adanga Maru	8	Thriller
Kidu	8	Action
Kidu	8	Drama
Kidu	8	Romance
Antony & Cleopatra	8	Drama
Nathicharami	8	Drama
Polis Evo 2	8	Action
Alone/Together	8	Drama
Alone/Together	8	Romance
Terlalu Tampan	8	Comedy
Pestonjee	8	Comedy
Pestonjee	8	Drama
Back Roads	8	Crime
Back Roads	8	Drama
Back Roads	8	Thriller
Gone Kesh	8	Drama
The Big Take	8	Thriller
Beyond the Clouds	8	Drama
Beyond the Clouds	8	Family
Spider-Man 2: Another World	8	Sci-Fi
If Something Happens	8	Mystery
Omerta	8	Action
Omerta	8	Crime
Kayamkulam Kochunni	8	Action
Kayamkulam Kochunni	8	Drama
Aravindante Athidhikal	8	Comedy
Aravindante Athidhikal	8	Drama
Kadaikutty Singam	8	Action
Kadaikutty Singam	8	Drama
9: Nine	8	Fantasy
9: Nine	8	Horror
9: Nine	8	Sci-Fi
Börü	8	Action
Börü	8	Thriller
Carry on Jatta 2	8	Comedy
Nham Mat Thay Mua He	8	Drama
Nham Mat Thay Mua He	8	Romance
Nonsense	8	Drama
Nonsense	8	Romance
Pulang	8	Drama
Nannu Dochukunduvate	8	Romance
Foxtrot Six	8	Action
Foxtrot Six	8	Drama
Foxtrot Six	8	Sci-Fi
Hushaaru	8	Comedy
Ulan	8	Drama
Ulan	8	Fantasy
Ulan	8	Mystery
Dukun	8	Horror
Dukun	8	Thriller
Trädgårdsgatan	8	Drama
Trädgårdsgatan	8	Romance
Hidden Light	8	Drama
Mohalla Assi	8	Comedy
Mohalla Assi	8	Drama
Clown Motel: Spirits Arise	8	Horror
Asagao to Kase-san	8	Romance
Kralj Petar I	8	Drama
Karma	8	Horror
Karma	8	Thriller
Sankashta Kara Ganapathi	8	Comedy
Sankashta Kara Ganapathi	8	Romance
Rx 100	8	Action
Rx 100	8	Drama
Rx 100	8	Romance
Ashke	8	Drama
Ashke	8	Romance
Mr & Mrs 420 Returns	8	Comedy
Mitron	8	Comedy
Dachra	8	Horror
Wish Man	8	Others
Ivan and the Dogs	8	Drama
Beach House	8	Thriller
Entre dos aguas	8	Drama
Antes Que Eu Me Esqueça	8	Comedy
Antes Que Eu Me Esqueça	8	Drama
Kaala	8	Action
Kaala	8	Drama
Aleksi	8	Comedy
Aleksi	8	Drama
Aleksi	8	Romance
According to Mathew	8	Crime
According to Mathew	8	Romance
According to Mathew	8	Thriller
Aami Ashbo Phirey	8	Others
Devadas	8	Action
Devadas	8	Comedy
Devadas	8	Drama
Exes Baggage	8	Drama
Exes Baggage	8	Romance
Notebook	8	Drama
Notebook	8	Romance
Message Man	8	Action
Message Man	8	Crime
Message Man	8	Thriller
Goyo: Ang batang heneral	8	Action
One Two Jaga	8	Crime
One Two Jaga	8	Drama
Mulk	8	Drama
Sultan Agung: Tahta, Perjuangan, Cinta	8	Action
Sultan Agung: Tahta, Perjuangan, Cinta	8	Drama
Boyz in the Wood	8	Action
Boyz in the Wood	8	Comedy
Boyz in the Wood	8	Horror
Guarda in alto	8	Adventure
Bikini Moon	8	Drama
Nisekoi	8	Comedy
Nisekoi	8	Drama
Nisekoi	8	Romance
Paper Boy	8	Romance
118	8	Action
118	8	Thriller
Hantu Kak Limah	8	Comedy
Hantu Kak Limah	8	Horror
The Directive	8	Action
The Directive	8	Adventure
The Directive	8	Sci-Fi
Stray	8	Drama
Manikarnika: The Queen of Jhansi	8	Action
Manikarnika: The Queen of Jhansi	8	Drama
Too Much Info Clouding Over My Head	8	Comedy
Too Much Info Clouding Over My Head	8	Drama
The Challenger Disaster	8	Drama
Oru Kuppai Kathai	8	Drama
Vijetha	8	Drama
Bluff Master	8	Crime
Bluff Master	8	Thriller
Zui Hou De Ri Chu	8	Adventure
Zui Hou De Ri Chu	8	Drama
Zui Hou De Ri Chu	8	Romance
Cliffs of Freedom	8	Drama
Beauty Mark	8	Drama
2.0	8	Action
2.0	8	Sci-Fi
Like Arrows	8	Drama
Les filles du soleil	8	Drama
Qué León	8	Comedy
Qué León	8	Romance
Viral Beauty	8	Comedy
Viral Beauty	8	Romance
Neproshchennyy	8	Drama
Nanu Ki Jaanu	8	Comedy
Nanu Ki Jaanu	8	Drama
Nanu Ki Jaanu	8	Horror
Office Uprising	8	Action
Office Uprising	8	Comedy
Office Uprising	8	Horror
The Accidental Prime Minister	8	Drama
Elephants	8	Drama
Elephants	8	Romance
Tik Tik Tik	8	Action
Tik Tik Tik	8	Sci-Fi
Tik Tik Tik	8	Thriller
Batti Gul Meter Chalu	8	Drama
Sagaa	8	Action
Sagaa	8	Crime
Sagaa	8	Drama
The Joke Thief	8	Drama
A.I. Rising	8	Drama
A.I. Rising	8	Romance
A.I. Rising	8	Sci-Fi
The Super	8	Horror
The Super	8	Mystery
The Super	8	Thriller
Captive State	8	Drama
Captive State	8	Sci-Fi
Captive State	8	Thriller
Will & Liz	8	Drama
Will & Liz	8	Romance
The Demonologist	8	Crime
The Demonologist	8	Fantasy
The Demonologist	8	Horror
Hürkus	8	Others
Time Jumpers	8	Sci-Fi
Last American Horror Show	8	Horror
High End Yaariyaan	8	Comedy
High End Yaariyaan	8	Drama
High End Yaariyaan	8	Family
Aabhaasam	8	Comedy
Jane and Emma	8	Drama
Yes, God, Yes	8	Drama
Mistrust	8	Drama
Mistrust	8	Romance
Beautifully Broken	8	Drama
Clyde Cooper	8	Mystery
Mehbooba	8	Action
Mehbooba	8	Drama
Mehbooba	8	Romance
Bizli: Origin	8	Action
Bizli: Origin	8	Fantasy
Bizli: Origin	8	Sci-Fi
Silly Fellows	8	Comedy
Mar Gaye Oye Loko	8	Comedy
Mar Gaye Oye Loko	8	Drama
Mar Gaye Oye Loko	8	Fantasy
The Untold Story	8	Comedy
The Untold Story	8	Drama
Matriarch	8	Horror
Matriarch	8	Thriller
One Less God	8	Drama
One Less God	8	Thriller
Astral	8	Drama
Astral	8	Horror
Astral	8	Sci-Fi
Penance	8	Action
Robin Hood: The Rebellion	8	Action
Robin Hood: The Rebellion	8	Adventure
Kizim ve Ben	8	Drama
Occupation	8	Action
Occupation	8	Drama
Occupation	8	Sci-Fi
Quality Problems	8	Comedy
Quality Problems	8	Drama
Pickings	8	Action
Pickings	8	Crime
Pickings	8	Drama
72 Hours: Martyr Who Never Died	8	Action
72 Hours: Martyr Who Never Died	8	Drama
Two Tails	8	Adventure
Two Tails	8	Comedy
Nesokrushimyy	8	Action
Nesokrushimyy	8	Drama
Nightshooters	8	Action
Lancaster Skies	8	Action
Lancaster Skies	8	Drama
Night Pulse	8	Thriller
Shine	8	Drama
Body of Sin	8	Adventure
Body of Sin	8	Crime
Body of Sin	8	Thriller
Fantastica	8	Comedy
Fantastica	8	Fantasy
The Dawnseeker	8	Sci-Fi
Whispers	8	Drama
Whispers	8	Horror
Whispers	8	Thriller
Banjara: The truck driver	8	Drama
Banjara: The truck driver	8	Romance
President Evil	8	Comedy
President Evil	8	Horror
Night	8	Horror
Night	8	Thriller
Three Worlds	8	Drama
Three Worlds	8	Sci-Fi
The Trump Prophecy	8	Drama

*/





-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT 
    SUM(total_votes) AS total_votes, 
    country
FROM 
    movie AS m
    INNER JOIN ratings AS r ON m.id = r.movie_id
WHERE 
    country LIKE 'Germany' OR country LIKE 'Italy'
GROUP BY 
    country
ORDER BY 
    total_votes DESC;

/* 
# total_votes	country
	106710		Germany
	77965		Italy

*/





-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT 
    SUM(CASE
        WHEN name IS NULL THEN 1
        ELSE 0
    END) AS name_nulls,
    SUM(CASE
        WHEN height IS NULL THEN 1
        ELSE 0
    END) AS height_nulls,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS date_of_birth_nulls,
    SUM(CASE
        WHEN known_for_movies IS NULL THEN 1
        ELSE 0
    END) AS known_for_movies_nulls
FROM
    names;

/*
# name_nulls	height_nulls	date_of_birth_nulls	known_for_movies_nulls
	0			17335			13431				15226
*/






/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


WITH top_genre AS
(
	SELECT g.genre, COUNT(g.movie_id) AS movie_count
	FROM genre AS g
	INNER JOIN ratings AS r
	ON g.movie_id = r.movie_id
	WHERE avg_rating > 8
    GROUP BY genre
    ORDER BY movie_count DESC
    LIMIT 3
),

top_director AS
(
SELECT n.name AS director_name,
		COUNT(g.movie_id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY COUNT(g.movie_id) DESC) AS director_row_rank
FROM names AS n 
INNER JOIN director_mapping AS dm 
ON n.id = dm.name_id 
INNER JOIN genre AS g 
ON dm.movie_id = g.movie_id 
INNER JOIN ratings AS r 
ON r.movie_id = g.movie_id,
top_genre
WHERE g.genre in (top_genre.genre) AND avg_rating>8
GROUP BY director_name
ORDER BY movie_count DESC
)
SELECT director_name, movie_count
FROM top_director
WHERE director_row_rank <= 3;

/*
# director_name		movie_count
	James Mangold	4
	Soubin Shahir	3
	Joe Russo		3
*/







/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT DISTINCT
    name AS actor_name, COUNT(r.movie_id) AS movie_count
FROM
    ratings AS r
        INNER JOIN
    role_mapping AS rm ON rm.movie_id = r.movie_id
        INNER JOIN
    names AS n ON rm.name_id = n.id
WHERE
    median_rating >= 8
        AND category = 'actor'
GROUP BY name
ORDER BY movie_count DESC
LIMIT 2;

/*
# actor_name	movie_count
Mammootty	8
Mohanlal	5
*/




/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT production_company, 
	SUM(total_votes) as vote_count, 
    ROW_NUMBER() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
    FROM movie as m
    INNER JOIN ratings as r
    ON m.id = r.movie_id
    GROUP BY production_company
    LIMIT 3;
	
/*
# production_company		vote_count	prod_comp_rank
	Marvel Studios			2656967		1
	Twentieth Century Fox	2411163		2
	Warner Bros.			2396057		3
*/








/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH actor_summary AS
(
SELECT
    N.NAME AS actor_name,
    SUM(total_votes) AS total_votes,
    COUNT(R.movie_id) AS movie_count,
    ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actor_avg_rating
FROM
    movie AS M
    INNER JOIN ratings AS R ON M.id = R.movie_id
    INNER JOIN role_mapping AS RM ON M.id = RM.movie_id
    INNER JOIN names AS N ON RM.name_id = N.id
WHERE
    category = 'ACTOR' AND country = 'india'
GROUP BY NAME
HAVING movie_count >= 5
)
SELECT *,
       Rank() OVER(ORDER BY actor_avg_rating DESC) AS actor_rank
FROM   actor_summary; 

/*
# actor_name	total_votes	movie_count	actor_avg_rating	actor_rank
Vijay Sethupathi	23114	5	8.42	1
Fahadh Faasil	13557	5	7.99	2
Yogi Babu	8500	11	7.83	3
Joju George	3926	5	7.58	4
Ammy Virk	2504	6	7.55	5
Dileesh Pothan	6235	5	7.52	6
Kunchacko Boban	5628	6	7.48	7
Pankaj Tripathi	40728	5	7.44	8
Rajkummar Rao	42560	6	7.37	9
Dulquer Salmaan	17666	5	7.30	10
Amit Sadh	13355	5	7.21	11
Tovino Thomas	11596	8	7.15	12
Mammootty	12613	8	7.04	13
Nassar	4016	5	7.03	14
Karamjit Anmol	1970	6	6.91	15
Hareesh Kanaran	3196	5	6.58	16
Naseeruddin Shah	12604	5	6.54	17
Anandraj	2750	6	6.54	17
Mohanlal	17244	6	6.51	19
Siddique	5953	7	6.43	20
Aju Varghese	2237	5	6.43	20
Prakash Raj	8548	6	6.37	22
Jimmy Sheirgill	3826	6	6.29	23
Mahesh Achanta	2716	6	6.21	24
Biju Menon	1916	5	6.21	24
Suraj Venjaramoodu	4284	6	6.19	26
Abir Chatterjee	1413	5	5.80	27
Sunny Deol	4594	5	5.71	28
Radha Ravi	1483	5	5.70	29
Prabhu Deva	2044	5	5.68	30
*/








-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actress_summary AS
(
    SELECT
        n.NAME AS actress_name,
        SUM(total_votes) AS total_votes,
        COUNT(r.movie_id) AS movie_count,
        ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actress_avg_rating
    FROM
        movie AS m
        INNER JOIN ratings AS r ON m.id = r.movie_id
        INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
        INNER JOIN names AS n ON rm.name_id = n.id
    WHERE
        category = 'ACTRESS' AND country = 'india'  AND languages LIKE '%HINDI%'
    GROUP BY NAME
    HAVING movie_count >= 3
)
SELECT *,
    RANK() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
FROM
    actress_summary
ORDER BY actress_rank;

/*
# actress_name				total_votes	movie_count	actress_avg_rating	actress_rank
Taapsee Pannu				18061		3			7.74				1
Kriti Sanon					21967		3			7.05				2
Divya Dutta					8579		3			6.88				3
Shraddha Kapoor				26779		3			6.63				4
Kriti Kharbanda				2549		3			4.80				5
Sonakshi Sinha				4025		4			4.18				6
*/






/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

WITH thriller_movies AS
(
SELECT title, avg_rating
FROM movie as m
INNER JOIN genre AS g
ON m.id = g.movie_id
INNER JOIN ratings AS r
ON g.movie_id = r.movie_id
WHERE genre = 'thriller'
ORDER BY avg_rating desc
)
SELECT title,
CASE
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         ELSE 'Flop movies'
       END AS avg_rating_category
FROM   thriller_movies;

/*
# title	avg_rating_category
Safe	Superhit movies
Digbhayam	Superhit movies
Dokyala Shot	Superhit movies
Abstruse	Superhit movies
Kaithi	Superhit movies
Raju Gari Gadhi 3	Superhit movies
Lost Angelas	Superhit movies
Enigma	Superhit movies
Joker	Superhit movies
Birbal Trilogy	Superhit movies
Vikram Vedha	Superhit movies
Ratsasan	Superhit movies
Ghost	Superhit movies
Bell Bottom	Superhit movies
Rakshasudu	Superhit movies
Adios Vaya Con Dios	Superhit movies
Andhadhun	Superhit movies
Kavacha	Superhit movies
Nerkonda Paarvai	Superhit movies
Evaru	Superhit movies
Juzni vetar	Superhit movies
What Death Leaves Behind	Superhit movies
Take Off	Superhit movies
Theeran Adhigaaram Ondru	Superhit movies
Yazh	Superhit movies
Thondimuthalum Dhriksakshiyum	Superhit movies
Thadam	Superhit movies
Deception: Oo Pel Dan Myin	Superhit movies
Joseph	Superhit movies
Magamuni	Superhit movies
Ah-ga-ssi	Superhit movies
Shuddhi	Superhit movies
Contratiempo	Superhit movies
Maanagaram	Superhit movies
Kavaludaari	Superhit movies
Operation Alamelamma	Superhit movies
Kurangu Bommai	Superhit movies
Unda	Superhit movies
Virus	Superhit movies
Dhaka Attack	Hit movies
Angamaly Diaries	Hit movies
Manu	Hit movies
Dharmayuddhaya	Hit movies
Until Midnight	Hit movies
Jiivi	Hit movies
Alien Domicile 2: Lot 24	Hit movies
Awe!	Hit movies
The Tashkent Files	Hit movies
Laal Kabootar	Hit movies
Metri Shesh Va Nim	Hit movies
Mission: Impossible - Fallout	Hit movies
Forushande	Hit movies
Despair	Hit movies
Is This Now	Hit movies
Blood Child	Hit movies
The Transcendents	Hit movies
Beautiful Manasugalu	Hit movies
Raazi	Hit movies
Goodachari	Hit movies
Der müde Tod	Hit movies
Ne Zha zhi mo tong jiang shi	Hit movies
Shapludu	Hit movies
As Worlds Collide	Hit movies
Mientras el Lobo No Está	Hit movies
Get Out	Hit movies
Mersal	Hit movies
Nabab	Hit movies
Kataka	Hit movies
Irumbu Thirai	Hit movies
Abrahaminte Santhathikal	Hit movies
Searching	Hit movies
Lupt	Hit movies
Fanxiao	Hit movies
Arise from Darkness	Hit movies
The Butler	Hit movies
Hotel Mumbai	Hit movies
American Criminal	Hit movies
John Wick: Chapter 3 - Parabellum	Hit movies
The Ghazi Attack	Hit movies
8 Thottakkal	Hit movies
Ballon	Hit movies
Maghzhaye Koochake Zang Zadeh	Hit movies
Ishq	Hit movies
Incitement	Hit movies
Caretakers	Hit movies
John Wick: Chapter 2	Hit movies
Miss Sloane	Hit movies
Breakdown Forest - Reise in den Abgrund	Hit movies
Eshtebak	Hit movies
A Death in the Gunj	Hit movies
Monos	Hit movies
Trapped	Hit movies
Den skyldige	Hit movies
Thupparivaalan	Hit movies
Aapla Manus	Hit movies
Varathan	Hit movies
Homestay	Hit movies
Ratu Ilmu Hitam	Hit movies
Den 12. mann	Hit movies
Transfert	Hit movies
Ramaleela	Hit movies
Feedback	Hit movies
Strategy and Pursuit	Hit movies
El crack cero	Hit movies
Journal 64	Hit movies
Gi-eok-ui bam	Hit movies
Savovi	Hit movies
The Farm: En Veettu Thottathil	Hit movies
Xue guan yin	Hit movies
Swathanthryam Ardharathriyil	Hit movies
Remélem legközelebb sikerül meghalnod:)	Hit movies
Valhalla	Hit movies
Vera	Hit movies
Vellaipookal	Hit movies
Uriyadi 2	Hit movies
Kalki	Hit movies
Truth	Hit movies
A Life Not to Follow	Hit movies
The Tale	Hit movies
Shot Caller	Hit movies
Good Time	Hit movies
Split	Hit movies
Mom	Hit movies
Adhe Kangal	Hit movies
End Trip	Hit movies
Kuttram 23	Hit movies
Dogman	Hit movies
Velaikkaran	Hit movies
El reino	Hit movies
Iravukku Aayiram Kangal	Hit movies
Apró mesék	Hit movies
Profile	Hit movies
Utøya 22. juli	Hit movies
El Hoyo	Hit movies
Batla House	Hit movies
Excursion	Hit movies
Quick	Hit movies
Vinci Da	Hit movies
Sivappu Manjal Pachai	Hit movies
Barot House	Hit movies
Two Down	Hit movies
Glass Jaw	Hit movies
Hebbuli	Hit movies
The Nightingale	Hit movies
No Date, No Signature	Hit movies
Last Ferry	Hit movies
Night Bus	Hit movies
Ittefaq	Hit movies
Saab Bahadar	Hit movies
Verna	Hit movies
Illusions	Hit movies
Chase	Hit movies
Brokedown	Hit movies
Ventajas de viajar en tren	Hit movies
The Collini Case	Hit movies
Game Over	Hit movies
Pozivniy «Banderas»	Hit movies
Jessie	Hit movies
Baaji	Hit movies
La llorona	Hit movies
59 Seconds	Hit movies
Brimstone	Hit movies
Gali Guleiyan	Hit movies
Inspiration	Hit movies
Elle	Hit movies
Kaabil	Hit movies
Mu ji zhe	Hit movies
Aus dem Nichts	Hit movies
Salinjaui gieokbeob	Hit movies
First Reformed	Hit movies
Solo	Hit movies
Kavan	Hit movies
The Place	Hit movies
Inori no maku ga oriru toki	Hit movies
Nematoma	Hit movies
122	Hit movies
Taxiwaala	Hit movies
The Report	Hit movies
Adanga Maru	Hit movies
Shéhérazade	Hit movies
Trezor	Hit movies
Back Roads	Hit movies
The Foreigner	Hit movies
The Big Take	Hit movies
Lens	Hit movies
A martfüi rém	Hit movies
The Killing of a Sacred Deer	Hit movies
Marlina si Pembunuh dalam Empat Babak	Hit movies
Zavod	Hit movies
The Night Comes for Us	Hit movies
Urvi	Hit movies
Bhaagamathie	Hit movies
Aala Kaf Ifrit	Hit movies
Al Asleyeen	Hit movies
Blackmail	Hit movies
Direnis Karatay	Hit movies
Le chant du loup	Hit movies
Okka Kshanam	Hit movies
The Mule	Hit movies
Quien a hierro mata	Hit movies
Börü	Hit movies
U-Turn	Hit movies
Madre	Hit movies
Üç Harfliler: Adak	Hit movies
Gaddalakonda Ganesh	Hit movies
Dukun	One-time-watch movies
Widows	One-time-watch movies
Never Hike Alone	One-time-watch movies
In This Gray Place	One-time-watch movies
Carbon	One-time-watch movies
Babumoshai Bandookbaaz	One-time-watch movies
Us	One-time-watch movies
Ira	One-time-watch movies
Naachiyar	One-time-watch movies
Swallow	One-time-watch movies
Karma	One-time-watch movies
Freaks	One-time-watch movies
Tekst	One-time-watch movies
The Autopsy of Jane Doe	One-time-watch movies
Viktorville	One-time-watch movies
Beach House	One-time-watch movies
Gatta Cenerentola	One-time-watch movies
Boyne Falls	One-time-watch movies
22-nenme no kokuhaku: Watashi ga satsujinhan desu	One-time-watch movies
Khoj	One-time-watch movies
The Line	One-time-watch movies
Polícia Federal: A Lei é para Todos	One-time-watch movies
Armomurhaaja	One-time-watch movies
Siew Lup	One-time-watch movies
Ha-roo	One-time-watch movies
La ragazza nella nebbia	One-time-watch movies
Real Cases of Shadow People The Sarah McCormick Story	One-time-watch movies
War	One-time-watch movies
Papa, sdokhni	One-time-watch movies
According to Mathew	One-time-watch movies
Amityville: Mt. Misery Rd.	One-time-watch movies
Athiran	One-time-watch movies
Kasablanka	One-time-watch movies
Rambo: Last Blood	One-time-watch movies
Venom	One-time-watch movies
Nobel Chor	One-time-watch movies
Atomic Blonde	One-time-watch movies
Message Man	One-time-watch movies
Jungle	One-time-watch movies
The Equalizer 2	One-time-watch movies
The Fate of the Furious	One-time-watch movies
Fixeur	One-time-watch movies
Thoroughbreds	One-time-watch movies
Charmøren	One-time-watch movies
Tiyaan	One-time-watch movies
Ezra	One-time-watch movies
Aadhi	One-time-watch movies
Araña	One-time-watch movies
Nur Gott kann mich richten	One-time-watch movies
Calibre	One-time-watch movies
Inuyashiki	One-time-watch movies
Patser	One-time-watch movies
Tiere	One-time-watch movies
Spyder	One-time-watch movies
Glass	One-time-watch movies
Mr. Jones	One-time-watch movies
Hong hai xing dong	One-time-watch movies
The Lodge	One-time-watch movies
Yol kenari	One-time-watch movies
Thiruttu Payale 2	One-time-watch movies
Il testimone invisibile	One-time-watch movies
One Day: Justice Delivered	One-time-watch movies
Kaappaan	One-time-watch movies
Pihu	One-time-watch movies
Come to Daddy	One-time-watch movies
Trois jours et une vie	One-time-watch movies
Halloween	One-time-watch movies
Hunter Killer	One-time-watch movies
Red Sparrow	One-time-watch movies
Money	One-time-watch movies
Puriyaadha Pudhir	One-time-watch movies
The Book of Henry	One-time-watch movies
Gurgaon	One-time-watch movies
The Village in the Woods	One-time-watch movies
Jasper Jones	One-time-watch movies
Nibunan	One-time-watch movies
Kaygi	One-time-watch movies
Callback	One-time-watch movies
Life	One-time-watch movies
Small Town Crime	One-time-watch movies
The Angel	One-time-watch movies
Carbone	One-time-watch movies
Zero 3	One-time-watch movies
Baazaar	One-time-watch movies
Death Game	One-time-watch movies
Tamaroz	One-time-watch movies
Street Lights	One-time-watch movies
Sarajin bam	One-time-watch movies
Angel of Mine	One-time-watch movies
Sathya	One-time-watch movies
Pandigai	One-time-watch movies
Cómprame un revolver	One-time-watch movies
Anna	One-time-watch movies
Veera Bhoga Vasantha Rayalu	One-time-watch movies
118	One-time-watch movies
O Paciente: O Caso Tancredo Neves	One-time-watch movies
Danmarks sønner	One-time-watch movies
A Patch of Fog	One-time-watch movies
Land of the Little People	One-time-watch movies
Hounds of Love	One-time-watch movies
Legionario	One-time-watch movies
Zombies Have Fallen	One-time-watch movies
Operation Brothers	One-time-watch movies
O Animal Cordial	One-time-watch movies
Annabelle: Creation	One-time-watch movies
Chappaquiddick	One-time-watch movies
Happy Death Day	One-time-watch movies
The Good Liar	One-time-watch movies
Die Hölle	One-time-watch movies
Bad Day for the Cut	One-time-watch movies
Angel Has Fallen	One-time-watch movies
X.	One-time-watch movies
El otro hermano	One-time-watch movies
Adam Joan	One-time-watch movies
Peppermint	One-time-watch movies
Hyeob-sang	One-time-watch movies
Tam jeong 2	One-time-watch movies
El-Khaliyyah	One-time-watch movies
Maradona	One-time-watch movies
Ban-deu-si jab-neun-da	One-time-watch movies
Soul Hunters	One-time-watch movies
The Huntress: Rune of the Dead	One-time-watch movies
Romeo Akbar Walter	One-time-watch movies
Bluff Master	One-time-watch movies
Nguoi Bât Tu	One-time-watch movies
Avengement	One-time-watch movies
Rojo	One-time-watch movies
Majaray Nimrooz: Radde Khoon	One-time-watch movies
Ai-naki Mori de Sakebe	One-time-watch movies
Message from the King	One-time-watch movies
Alien: Covenant	One-time-watch movies
Bad Samaritan	One-time-watch movies
HHhH	One-time-watch movies
Creep 2	One-time-watch movies
Dark Beacon	One-time-watch movies
Lycan	One-time-watch movies
Blood Vow	One-time-watch movies
Beirut	One-time-watch movies
Strip Club Massacre	One-time-watch movies
Parallel	One-time-watch movies
Life in the Hole	One-time-watch movies
Corporate	One-time-watch movies
Freddy/Eddy	One-time-watch movies
Roman J. Israel, Esq.	One-time-watch movies
Die Vierhändige	One-time-watch movies
Hitsuji no ki	One-time-watch movies
Bogan	One-time-watch movies
Keshava	One-time-watch movies
Haebing	One-time-watch movies
Villain	One-time-watch movies
Fuga	One-time-watch movies
Removed	One-time-watch movies
The Tooth and the Nail	One-time-watch movies
Varikkuzhiyile Kolapathakam	One-time-watch movies
Instinct	One-time-watch movies
Aadai	One-time-watch movies
Storozh	One-time-watch movies
The Commuter	One-time-watch movies
The Outsider	One-time-watch movies
Be My Cat: A Film for Anne	One-time-watch movies
Painless	One-time-watch movies
Madtown	One-time-watch movies
Deadly Crush	One-time-watch movies
The Evangelist	One-time-watch movies
Fractured	One-time-watch movies
My Pure Land	One-time-watch movies
The Limehouse Golem	One-time-watch movies
El guardián invisible	One-time-watch movies
El bar	One-time-watch movies
Mean Dreams	One-time-watch movies
Singam 3	One-time-watch movies
Zona hostil	One-time-watch movies
The Beguiled	One-time-watch movies
The Ritual	One-time-watch movies
Chai dan zhuan jia	One-time-watch movies
Hongo	One-time-watch movies
Naam Shabana	One-time-watch movies
Una especie de familia	One-time-watch movies
V.I.P.	One-time-watch movies
Frères ennemis	One-time-watch movies
Haunt	One-time-watch movies
Yaman	One-time-watch movies
Maracaibo	One-time-watch movies
Revenge	One-time-watch movies
Si-gan-wi-ui jib	One-time-watch movies
Betrayed	One-time-watch movies
La sombra de la ley	One-time-watch movies
Bonehill Road	One-time-watch movies
Svaha: The Sixth Finger	One-time-watch movies
The Burial Of Kojo	One-time-watch movies
Thuppaki Munai	One-time-watch movies
Cuck	One-time-watch movies
Il signor Diavolo	One-time-watch movies
Byomkesh Gotro	One-time-watch movies
Mok-gyeok-ja	One-time-watch movies
Bumperkleef	One-time-watch movies
Falaknuma Das	One-time-watch movies
Saja	One-time-watch movies
American Assassin	One-time-watch movies
Five Fingers for Marseilles	One-time-watch movies
Sweet Virginia	One-time-watch movies
Bad Kids of Crestview Academy	One-time-watch movies
Scary Stories to Tell in the Dark	One-time-watch movies
Xian yi ren X de xian shen	One-time-watch movies
Infinity Chamber	One-time-watch movies
The Wall	One-time-watch movies
Detour	One-time-watch movies
Los Angeles Overnight	One-time-watch movies
Maze Runner: The Death Cure	One-time-watch movies
I Kill Giants	One-time-watch movies
American Fable	One-time-watch movies
Ravenswood	One-time-watch movies
Berlin Falling	One-time-watch movies
The Standoff at Sparrow Creek	One-time-watch movies
Lucid	One-time-watch movies
Extracurricular	One-time-watch movies
Driven	One-time-watch movies
Laissez bronzer les cadavres	One-time-watch movies
Look Away	One-time-watch movies
A Crooked Somebody	One-time-watch movies
Radius	One-time-watch movies
Kaalakaandi	One-time-watch movies
Öteki Taraf	One-time-watch movies
Accident Man	One-time-watch movies
Spell	One-time-watch movies
The Coldest Game	One-time-watch movies
Irada	One-time-watch movies
Skjelvet	One-time-watch movies
Fantasten	One-time-watch movies
Das Ende der Wahrheit	One-time-watch movies
The Hummingbird Project	One-time-watch movies
Nommer 37	One-time-watch movies
Duelles	One-time-watch movies
B. Tech	One-time-watch movies
The Dig	One-time-watch movies
Animal	One-time-watch movies
18am Padi	One-time-watch movies
Mercury	One-time-watch movies
Prospect	One-time-watch movies
Aschhe Abar Shabor	One-time-watch movies
Alpha: The Right to Kill	One-time-watch movies
Do-eo-lak	One-time-watch movies
The Belko Experiment	One-time-watch movies
The Entitled	One-time-watch movies
Black Butterfly	One-time-watch movies
Blood Stripe	One-time-watch movies
Norman: The Moderate Rise and Tragic Fall of a New York Fixer	One-time-watch movies
Mirror Game	One-time-watch movies
Mile 22	One-time-watch movies
Prodigy	One-time-watch movies
The Isle	One-time-watch movies
M.F.A.	One-time-watch movies
Vargur	One-time-watch movies
Dead on Arrival	One-time-watch movies
Steel Country	One-time-watch movies
Extracurricular Activities	One-time-watch movies
Paradise Hills	One-time-watch movies
The Journey	One-time-watch movies
Love Me Not	One-time-watch movies
Burn Out	One-time-watch movies
Kääntöpiste	One-time-watch movies
Cutterhead	One-time-watch movies
Mai mee Samui samrab ter	One-time-watch movies
A Good Woman Is Hard to Find	One-time-watch movies
Loosideu deurim	One-time-watch movies
#Captured	One-time-watch movies
Absurd Accident	One-time-watch movies
Tueurs	One-time-watch movies
Clickbait	One-time-watch movies
Tik Tik Tik	One-time-watch movies
La hora final	One-time-watch movies
Low Tide	One-time-watch movies
La quietud	One-time-watch movies
The Perfection	One-time-watch movies
Acusada	One-time-watch movies
Morto Não Fala	One-time-watch movies
Shohrat the Trap	One-time-watch movies
The Refuge	One-time-watch movies
Witnesses	One-time-watch movies
O Banquete	One-time-watch movies
Sathru	One-time-watch movies
Greta	One-time-watch movies
Circus of the Dead	One-time-watch movies
Neckan	One-time-watch movies
Anabolic Life	One-time-watch movies
Retribution	One-time-watch movies
La nuit a dévoré le monde	One-time-watch movies
Haze	One-time-watch movies
1 Buck	One-time-watch movies
Hush Money	One-time-watch movies
Le serpent aux mille coupures	One-time-watch movies
The Job	One-time-watch movies
La Misma Sangre	One-time-watch movies
Il permesso - 48 ore fuori	One-time-watch movies
The Super	One-time-watch movies
Tiger Zinda Hai	One-time-watch movies
Captive State	One-time-watch movies
Oru Mexican Aparatha	One-time-watch movies
La Cordillera	One-time-watch movies
The Russian Bride	One-time-watch movies
Aake	One-time-watch movies
Puthan Panam	One-time-watch movies
Indu Sarkar	One-time-watch movies
Yuddham Sharanam	One-time-watch movies
Numéro une	One-time-watch movies
Une vie violente	One-time-watch movies
One	One-time-watch movies
Zhan lang II	One-time-watch movies
Puen Tee Raluek	One-time-watch movies
Party Hard Die Young	One-time-watch movies
Vikadakumaran	One-time-watch movies
Judgementall Hai Kya	One-time-watch movies
5 è il numero perfetto	One-time-watch movies
Savita Damodar Paranjpe	One-time-watch movies
Bloodline	One-time-watch movies
Blank	One-time-watch movies
Kidnap	One-time-watch movies
The Forgiven	One-time-watch movies
Skybound	One-time-watch movies
Vishwaroopam 2	One-time-watch movies
Beacon Point	One-time-watch movies
Call of the Wolf	One-time-watch movies
Bank Chor	One-time-watch movies
Savageland	One-time-watch movies
Level 16	One-time-watch movies
The Man in the Wall	One-time-watch movies
The Prodigy	One-time-watch movies
Razbudi menya	One-time-watch movies
Unfriended: Dark Web	One-time-watch movies
Tomato Red	One-time-watch movies
Ryde	One-time-watch movies
Den enda vägen	One-time-watch movies
Voidfinder	One-time-watch movies
The Kill Team	One-time-watch movies
Bairavaa	One-time-watch movies
Sarvann	One-time-watch movies
Yeo-gyo-sa	One-time-watch movies
Game of Death	One-time-watch movies
Konwój	One-time-watch movies
Jagveld	One-time-watch movies
A Tale of Shadows	One-time-watch movies
Perception	One-time-watch movies
Uru	One-time-watch movies
LIE	One-time-watch movies
Orayiram Kinakkalal	One-time-watch movies
Yin bao zhe	One-time-watch movies
Somewhere Beyond the Mist	One-time-watch movies
Lukas	One-time-watch movies
Manyak	One-time-watch movies
7 Nyeon-eui bam	One-time-watch movies
Hattrick	One-time-watch movies
Non sono un assassino	One-time-watch movies
Annabelle Comes Home	One-time-watch movies
Cam	One-time-watch movies
Gogol. Strashnaya mest	One-time-watch movies
American Hangman	One-time-watch movies
Xue bao	One-time-watch movies
Pet Sematary	One-time-watch movies
Hometown Killer	One-time-watch movies
Zuo jia de huang yan: Bi zhong you zui	One-time-watch movies
2:22	One-time-watch movies
Teenage Cocktail	One-time-watch movies
Found	One-time-watch movies
I Still See You	One-time-watch movies
Division 19	One-time-watch movies
Voyoucratie	One-time-watch movies
Verónica	One-time-watch movies
Jigsaw	One-time-watch movies
Beyond the Sky	One-time-watch movies
We Go On	One-time-watch movies
O Rastro	One-time-watch movies
Alterscape	One-time-watch movies
Bloodlands	One-time-watch movies
Bonded by Blood 2	One-time-watch movies
Tau	One-time-watch movies
Desolation	One-time-watch movies
Darc	One-time-watch movies
Killing Ground	One-time-watch movies
Together For Ever	One-time-watch movies
Kings Bay	One-time-watch movies
Kundschafter des Friedens	One-time-watch movies
Ghost Note	One-time-watch movies
In Darkness	One-time-watch movies
The Hatton Garden Job	One-time-watch movies
The Music Box	One-time-watch movies
The Mad Whale	One-time-watch movies
Dark River	One-time-watch movies
Thumper	One-time-watch movies
Small Crimes	One-time-watch movies
Skyscraper	One-time-watch movies
Project Ghazi	One-time-watch movies
BuyBust	One-time-watch movies
Acrimony	One-time-watch movies
A Violent Man	One-time-watch movies
The Villain	One-time-watch movies
Loverboy	One-time-watch movies
Mon garçon	One-time-watch movies
Fast Color	One-time-watch movies
Gol-deun seul-leom-beo	One-time-watch movies
Nomis	One-time-watch movies
Rust Creek	One-time-watch movies
Amok	One-time-watch movies
Room for Rent	One-time-watch movies
Gemini Ganeshanum Suruli Raajanum	One-time-watch movies
Woosang	One-time-watch movies
Rocky Mental	One-time-watch movies
Nene Raju Nene Mantri	One-time-watch movies
Hell Is Where the Home Is	One-time-watch movies
Lottery	One-time-watch movies
Gogol. Viy	One-time-watch movies
Kargar sadeh niazmandim	One-time-watch movies
70 Binladens	One-time-watch movies
Kabir	One-time-watch movies
Rabbia furiosa	One-time-watch movies
The Villagers	One-time-watch movies
Kadaram Kondan	One-time-watch movies
Jasmine	One-time-watch movies
Would You Rather	One-time-watch movies
Delirium	One-time-watch movies
Arizona	One-time-watch movies
The Ascent	One-time-watch movies
Strange But True	One-time-watch movies
Security	One-time-watch movies
Aftermath	One-time-watch movies
El Complot Mongol	One-time-watch movies
Most Beautiful Island	One-time-watch movies
Las tinieblas	One-time-watch movies
Dismissed	One-time-watch movies
Lover	One-time-watch movies
Assimilate	One-time-watch movies
Final Score	One-time-watch movies
Videomannen	One-time-watch movies
Pirmdzimtais	One-time-watch movies
24 Hours to Live	One-time-watch movies
Webcast	One-time-watch movies
Kaleidoscope	One-time-watch movies
The Corrupted	One-time-watch movies
Insidious: The Last Key	One-time-watch movies
Knuckleball	One-time-watch movies
Acts of Vengeance	One-time-watch movies
Matriarch	One-time-watch movies
Las grietas de Jara	One-time-watch movies
Elizabeth Harvest	One-time-watch movies
Vivegam	One-time-watch movies
Paul Sanchez est revenu!	One-time-watch movies
Russkiy Bes	One-time-watch movies
Velvet Buzzsaw	One-time-watch movies
What Keeps You Alive	One-time-watch movies
Heesaeng boohwalja	One-time-watch movies
En affære	One-time-watch movies
The Lake Vampire	One-time-watch movies
Missing	One-time-watch movies
7 Hosil	One-time-watch movies
Bez menya	One-time-watch movies
Daughter of the Wolf	One-time-watch movies
Monsters and Men	One-time-watch movies
Diya	One-time-watch movies
To thávma tis thálassas ton Sargassón	One-time-watch movies
Dressage	One-time-watch movies
Lilli	One-time-watch movies
Abrakadabra	One-time-watch movies
The Pool	One-time-watch movies
Jûni-nin no shinitai kodomo-tachi	One-time-watch movies
Kavacham	One-time-watch movies
Revenger	One-time-watch movies
Misteri Dilaila	One-time-watch movies
Retina	One-time-watch movies
Trafficked	One-time-watch movies
Sleepless	One-time-watch movies
This Is Your Death	One-time-watch movies
Dark Cove	One-time-watch movies
Point Blank	One-time-watch movies
One Less God	One-time-watch movies
Bad Girl	One-time-watch movies
Terrifier	One-time-watch movies
Bloody Crayons	One-time-watch movies
Hollow in the Land	One-time-watch movies
Ira	One-time-watch movies
12 Feet Deep	One-time-watch movies
Billionaire Boys Club	One-time-watch movies
The Mason Brothers	One-time-watch movies
Close	One-time-watch movies
A Young Man with High Potential	One-time-watch movies
Spinning Man	One-time-watch movies
Madre	One-time-watch movies
Ana de día	One-time-watch movies
We Have Always Lived in the Castle	One-time-watch movies
Sawoleuiggeut	One-time-watch movies
Jahr des Tigers	One-time-watch movies
Vodka Diaries	One-time-watch movies
Sniper: Ultimate Kill	One-time-watch movies
Piercing	One-time-watch movies
The Wicked Gift	One-time-watch movies
Lakshyam	One-time-watch movies
Steig. Nicht. Aus!	One-time-watch movies
American Dreamer	One-time-watch movies
Kaaviyyan	One-time-watch movies
Karuppan	One-time-watch movies
Kaashi in Search of Ganga	One-time-watch movies
Rewind: Die zweite Chance	One-time-watch movies
The Wedding Guest	One-time-watch movies
Chanakyatanthram	One-time-watch movies
Luz	One-time-watch movies
Ma	One-time-watch movies
The Operative	One-time-watch movies
Burn	One-time-watch movies
Boomerang	One-time-watch movies
The Watcher	One-time-watch movies
Satyameva Jayate	One-time-watch movies
Fractured	One-time-watch movies
The Burnt Orange Heresy	One-time-watch movies
Crypto	One-time-watch movies
Subrahmanyapuram	One-time-watch movies
The Dead Center	One-time-watch movies
Trhlina	One-time-watch movies
Insomnium	One-time-watch movies
City of Tiny Lights	One-time-watch movies
A Violent Separation	One-time-watch movies
No Way to Live	One-time-watch movies
The Ghoul	One-time-watch movies
Vincent N Roxxy	One-time-watch movies
The Last Witness	One-time-watch movies
Darling	One-time-watch movies
Replicas	One-time-watch movies
My Birthday Song	One-time-watch movies
Innuendo	One-time-watch movies
The Marker	One-time-watch movies
Josie	One-time-watch movies
In the Tall Grass	One-time-watch movies
Money	One-time-watch movies
Demonios tus ojos	One-time-watch movies
Luna	One-time-watch movies
3 ting	One-time-watch movies
American Satan	One-time-watch movies
The Men	One-time-watch movies
Trendy	One-time-watch movies
Mom and Dad	One-time-watch movies
Cardinals	One-time-watch movies
BNB Hell	One-time-watch movies
Barracuda	One-time-watch movies
Fashionista	One-time-watch movies
Coffin 2	One-time-watch movies
Darkness Visible	One-time-watch movies
Heartthrob	One-time-watch movies
The Nursery	One-time-watch movies
Bad Match	One-time-watch movies
First Light	One-time-watch movies
The Wrong Mother	One-time-watch movies
Possum	One-time-watch movies
Best F(r)iends: Volume 1	One-time-watch movies
Ride	One-time-watch movies
Konvert	One-time-watch movies
Witch-Hunt	One-time-watch movies
Hong yi xiao nu hai 2	One-time-watch movies
Brothers in Arms	One-time-watch movies
Sweetheart	One-time-watch movies
Triple Threat	One-time-watch movies
Oxygen	One-time-watch movies
Saaho	One-time-watch movies
The Cleaning Lady	One-time-watch movies
Jang-san-beom	One-time-watch movies
Duverný neprítel	One-time-watch movies
Ach spij kochanie	One-time-watch movies
Kuang shou	One-time-watch movies
Eter	One-time-watch movies
Loon Lake	One-time-watch movies
4 Rah Istanbul	One-time-watch movies
Be Vaghte Sham	One-time-watch movies
Bbaengban	One-time-watch movies
Sultan: The Saviour	One-time-watch movies
Female Human Animal	One-time-watch movies
Sumaho o otoshita dake na no ni	One-time-watch movies
Mata Batin 2	One-time-watch movies
Rattlesnakes	One-time-watch movies
Killer Under the Bed	One-time-watch movies
Nightmare Tenant	One-time-watch movies
Countdown	One-time-watch movies
Chanakya	One-time-watch movies
Mute	One-time-watch movies
Seberg	One-time-watch movies
An Ordinary Man	One-time-watch movies
Overdrive	One-time-watch movies
Sanctuary; Quite a Conundrum	One-time-watch movies
Bent	One-time-watch movies
Bottom of the World	One-time-watch movies
Higher Power	One-time-watch movies
Welcome to Curiosity	One-time-watch movies
Submergence	One-time-watch movies
Cuando los ángeles duermen	One-time-watch movies
Chimera Strain	One-time-watch movies
Braid	One-time-watch movies
The Curse of La Llorona	One-time-watch movies
Residue	One-time-watch movies
Muse	One-time-watch movies
Shattered	One-time-watch movies
Two Pigeons	One-time-watch movies
Kung Fu Traveler	One-time-watch movies
Running with the Devil	One-time-watch movies
La niebla y la doncella	One-time-watch movies
Mal Nosso	One-time-watch movies
Still/Born	One-time-watch movies
Jackals	One-time-watch movies
Asher	One-time-watch movies
Downrange	One-time-watch movies
K.O.	One-time-watch movies
Bullet Head	One-time-watch movies
Pledge	One-time-watch movies
Occidental	One-time-watch movies
Shelter	One-time-watch movies
Life Like	One-time-watch movies
Monster Party	One-time-watch movies
Vault	One-time-watch movies
In un giorno la fine	One-time-watch movies
Twin Betrayal	One-time-watch movies
A Lover Betrayed	One-time-watch movies
Notes on an Appearance	One-time-watch movies
Seung joi nei jor yau	One-time-watch movies
Cola de Mono	One-time-watch movies
Feedback	One-time-watch movies
El Hijo	One-time-watch movies
Mu hou wan jia	One-time-watch movies
El silencio de la ciudad blanca	One-time-watch movies
Byeonshin	One-time-watch movies
Demonic	One-time-watch movies
Geostorm	One-time-watch movies
The Circle	One-time-watch movies
Cruel Summer	One-time-watch movies
Benzin	One-time-watch movies
The Neighbor	One-time-watch movies
The Circle	One-time-watch movies
Terminal	One-time-watch movies
Robin Hood	One-time-watch movies
Lavender	One-time-watch movies
The Parts You Lose	One-time-watch movies
Die, My Dear	One-time-watch movies
Trench 11	One-time-watch movies
El ataúd de cristal	One-time-watch movies
Khaneye dokhtar	One-time-watch movies
Liebmann	One-time-watch movies
B&B	One-time-watch movies
Drone	One-time-watch movies
Apotheosis	One-time-watch movies
Lazarat	One-time-watch movies
Harmony	One-time-watch movies
The Changeover	One-time-watch movies
Midnighters	One-time-watch movies
The Nun	One-time-watch movies
Distorted	One-time-watch movies
Funôhan	One-time-watch movies
Raju Gari Gadhi 2	One-time-watch movies
The Guardian Angel	One-time-watch movies
Simran	One-time-watch movies
The Doll 2	One-time-watch movies
Anonymous 616	One-time-watch movies
Serenity	One-time-watch movies
Rapurasu no majo	One-time-watch movies
The Wrong Son	One-time-watch movies
Donnybrook	One-time-watch movies
Lifechanger	One-time-watch movies
Nothing Really Happens	One-time-watch movies
Head Count	One-time-watch movies
The Oath	One-time-watch movies
The Boat	One-time-watch movies
El pacto	One-time-watch movies
Çocuklar Sana Emanet	One-time-watch movies
Muere, monstruo, muere	One-time-watch movies
Purity Falls	One-time-watch movies
The Ex Next Door	One-time-watch movies
Watchman	One-time-watch movies
706	One-time-watch movies
xXx: Return of Xander Cage	One-time-watch movies
Voice from the Stone	One-time-watch movies
Corbin Nash	One-time-watch movies
Inconceivable	One-time-watch movies
Demon House	One-time-watch movies
Zhui bu	One-time-watch movies
Rough Night	One-time-watch movies
Ruin Me	One-time-watch movies
The Worthy	One-time-watch movies
The Possession of Hannah Grace	One-time-watch movies
Ji qi zhi xue	One-time-watch movies
Avenge the Crows	One-time-watch movies
Beyond the Night	One-time-watch movies
Commando 2	One-time-watch movies
Mona_Darling	One-time-watch movies
The Black String	One-time-watch movies
Rideshare	One-time-watch movies
Aiyaary	One-time-watch movies
The 15:17 to Paris	One-time-watch movies
Welcome Home	One-time-watch movies
Carnivores	One-time-watch movies
Them That Follow	One-time-watch movies
Askin Gören Gözlere Ihtiyaci yok	One-time-watch movies
Kee	One-time-watch movies
A Night to Regret	One-time-watch movies
His Perfect Obsession	One-time-watch movies
The Furies	One-time-watch movies
Tutsak	One-time-watch movies
Jai mat ze moon	One-time-watch movies
Kill Chain	One-time-watch movies
Seven	One-time-watch movies
Setters	One-time-watch movies
Sindhubaadh	One-time-watch movies
Killer in Law	One-time-watch movies
Gunned Down	One-time-watch movies
Bornoporichoy: A Grammar Of Death	One-time-watch movies
Mara	One-time-watch movies
True Crimes	One-time-watch movies
White Orchid	One-time-watch movies
Rabbit	One-time-watch movies
Damascus Cover	One-time-watch movies
Unforgettable	One-time-watch movies
The Lighthouse	One-time-watch movies
Us and Them	One-time-watch movies
Boar	One-time-watch movies
The Crucifixion	One-time-watch movies
Sleepwalker	One-time-watch movies
Bang jia zhe	One-time-watch movies
The Holly Kane Experiment	One-time-watch movies
Daas Dev	One-time-watch movies
Goodland	One-time-watch movies
Last Seen in Idaho	One-time-watch movies
O lyubvi	One-time-watch movies
Beneath Us	One-time-watch movies
Warning Shot	One-time-watch movies
Inside	One-time-watch movies
Volt	One-time-watch movies
Pray for Rain	One-time-watch movies
Magellan	One-time-watch movies
Clinical	One-time-watch movies
Polaroid	One-time-watch movies
Frazier Park Recut	One-time-watch movies
The Archer	One-time-watch movies
The Capture	One-time-watch movies
Created Equal	One-time-watch movies
Stay	One-time-watch movies
St. Agatha	One-time-watch movies
#Selfi	One-time-watch movies
Perfect Skin	One-time-watch movies
Mata Batin	One-time-watch movies
Truth or Dare	One-time-watch movies
Doe	One-time-watch movies
Nigerian Prince	One-time-watch movies
Stillwater	One-time-watch movies
No dormirás	One-time-watch movies
The Wrong Daughter	One-time-watch movies
Like.Share.Follow.	One-time-watch movies
Killers Within	One-time-watch movies
F20	One-time-watch movies
Superfly	One-time-watch movies
Best F(r)iends: Volume 2	One-time-watch movies
Solum	One-time-watch movies
Plagi Breslau	One-time-watch movies
The Husband	One-time-watch movies
ECCO	One-time-watch movies
Leatherface	One-time-watch movies
Alcoholist	One-time-watch movies
The Man Who Was Thursday	One-time-watch movies
Bad Frank	One-time-watch movies
Monochrome	One-time-watch movies
Sugar Daddies	One-time-watch movies
Cyber Case	One-time-watch movies
Gehenna: Where Death Lives	One-time-watch movies
Curvature	One-time-watch movies
From a House on Willow Street	One-time-watch movies
Presumed	One-time-watch movies
Tilt	One-time-watch movies
Close Calls	One-time-watch movies
Tout nous sépare	One-time-watch movies
First Kill	One-time-watch movies
The Strange Ones	One-time-watch movies
Bitch	One-time-watch movies
Malicious	One-time-watch movies
10x10	One-time-watch movies
Broken Ghost	One-time-watch movies
Baaghi 2	One-time-watch movies
The Pages	One-time-watch movies
Lucky Day	One-time-watch movies
Long Lost	One-time-watch movies
Vals	One-time-watch movies
Semma Botha Aagatha	One-time-watch movies
Wake Up	One-time-watch movies
Cradle Robber	One-time-watch movies
Lie Low	One-time-watch movies
Les fauves	One-time-watch movies
Mikhael	One-time-watch movies
Fahrenheit 451	Flop movies
Angelica	Flop movies
Stockholm	Flop movies
Paralytic	Flop movies
Night Pulse	Flop movies
Baadshaho	Flop movies
Perfect sãnãtos	Flop movies
The Child Remains	Flop movies
M/M	Flop movies
Girl Followed	Flop movies
Bullitt County	Flop movies
Hex	Flop movies
Allure	Flop movies
Off the Rails	Flop movies
Deadly Exchange	Flop movies
Against the Night	Flop movies
Hex	Flop movies
El desentierro	Flop movies
Depraved	Flop movies
Mercy Black	Flop movies
Amityville: The Awakening	Flop movies
Havenhurst	Flop movies
Abduct	Flop movies
Stratton	Flop movies
Rupture	Flop movies
Easy Living	Flop movies
Coyote Lake	Flop movies
Shortwave	Flop movies
The Wolf Hour	Flop movies
Kill Switch	Flop movies
Deadman Standing	Flop movies
The Second	Flop movies
Sam Was Here	Flop movies
River Runs Red	Flop movies
Perdidos	Flop movies
Housewife	Flop movies
The Wrong Nanny	Flop movies
Diwanji Moola Grand Prix	Flop movies
Die in One Day	Flop movies
Sequestro Relâmpago	Flop movies
Benzersiz	Flop movies
Silencio	Flop movies
The Surrogate	Flop movies
Tone-Deaf	Flop movies
Killer in a Red Dress	Flop movies
Kidnapping Stella	Flop movies
Boi	Flop movies
Where the Devil Dwells	Flop movies
The Birdcatcher	Flop movies
Be Afraid	Flop movies
She Who Must Burn	Flop movies
Dangerous Company	Flop movies
Ánimas	Flop movies
Cut to the Chase	Flop movies
Ghost House	Flop movies
The Playground	Flop movies
Monolith	Flop movies
The Spearhead Effect	Flop movies
Body of Sin	Flop movies
Altered Hours	Flop movies
Illicit	Flop movies
Rosy	Flop movies
5 Frauen	Flop movies
Killing Gunther	Flop movies
The Stranger Inside	Flop movies
Devil in the Dark	Flop movies
Dark Meridian	Flop movies
Motorrad	Flop movies
Every Time I Die	Flop movies
The Fox	Flop movies
Balloon	Flop movies
The Perception	Flop movies
Jawaan	Flop movies
Kala Viplavam Pranayam	Flop movies
Bottle Girl	Flop movies
Eyewitness	Flop movies
The Fanatic	Flop movies
The Wrong Friend	Flop movies
Instakiller	Flop movies
Mr. & Ms. Rowdy	Flop movies
Scare BNB	Flop movies
The Garlock Incident	Flop movies
The Elevator: Three Minutes Can Change Your Life	Flop movies
Investigation 13	Flop movies
Relentless	Flop movies
Haunted	Flop movies
Eloise	Flop movies
Dead Awake	Flop movies
Hank Boyd Is Dead	Flop movies
Live Cargo	Flop movies
Tangent Room	Flop movies
2036 Origin Unknown	Flop movies
The Assignment	Flop movies
Replace	Flop movies
Black Water	Flop movies
Camera Obscura	Flop movies
Lasso	Flop movies
The Poison Rose	Flop movies
What Still Remains	Flop movies
Obsession	Flop movies
Ten	Flop movies
The Appearance	Flop movies
Nowhere Mind	Flop movies
The Chain	Flop movies
Between Worlds	Flop movies
The Gallows Act II	Flop movies
Silent Panic	Flop movies
Genius	Flop movies
Body at Brighton Rock	Flop movies
Memorias de lo que no fue	Flop movies
Cucuy: The Boogeyman	Flop movies
We Belong Together	Flop movies
An Affair to Die For	Flop movies
Home Is Where the Killer Is	Flop movies
Only Mine	Flop movies
Bagh bandi khela	Flop movies
Beyond White Space	Flop movies
Displacement	Flop movies
The Dinner	Flop movies
Diverge	Flop movies
Land of Smiles	Flop movies
The Ballerina	Flop movies
Blood Money	Flop movies
Fifty Shades Freed	Flop movies
Beneath the Leaves	Flop movies
Wolves at the Door	Flop movies
Cold November	Flop movies
Desolation	Flop movies
Break-Up Nightmare	Flop movies
Maatr	Flop movies
The Recall	Flop movies
American Violence	Flop movies
Serpent	Flop movies
Lost Fare	Flop movies
S.W.A.T.: Under Siege	Flop movies
Looking Glass	Flop movies
Cereyan	Flop movies
American Pets	Flop movies
Totem	Flop movies
Til Death Do Us Part	Flop movies
The Follower	Flop movies
Hospitality	Flop movies
Spider in the Web	Flop movies
Deadly Switch	Flop movies
Cold Blood Legacy	Flop movies
Whispers	Flop movies
Ascent to Hell	Flop movies
Domino	Flop movies
Quarries	Flop movies
Blackmark	Flop movies
The Witch Files	Flop movies
200 Degrees	Flop movies
Negative	Flop movies
Nightworld	Flop movies
The Chamber	Flop movies
Cut Shoot Kill	Flop movies
Let Her Out	Flop movies
The Student	Flop movies
Ghatel-e ahli	Flop movies
The Pale Man	Flop movies
The Riot Act	Flop movies
Escape Plan: The Extractors	Flop movies
Edge of Fear	Flop movies
Red Letter Day	Flop movies
Paradise Beach	Flop movies
Rassvet	Flop movies
London Fields	Flop movies
The Ghost and The Whale	Flop movies
Keep Watching	Flop movies
Convergence	Flop movies
Capps Crossing	Flop movies
Billy Boy	Flop movies
Among Us	Flop movies
Candiland	Flop movies
The Inherited	Flop movies
In Extremis	Flop movies
Dark Sense	Flop movies
Awaken the Shadowman	Flop movies
Soul to Keep	Flop movies
Fare	Flop movies
Red Christmas	Flop movies
Wetlands	Flop movies
Bad Blood	Flop movies
The Cutlass	Flop movies
Dementia 13	Flop movies
Christmas Crime Story	Flop movies
All Light Will End	Flop movies
Isabelle	Flop movies
Skin in the Game	Flop movies
Empathy, Inc.	Flop movies
Naa Panta Kano	Flop movies
Siberia	Flop movies
Joel	Flop movies
#Followme	Flop movies
Pimped	Flop movies
Family Vanished	Flop movies
Aurora	Flop movies
Secret Obsession	Flop movies
Redcon-1	Flop movies
Never Here	Flop movies
The Unseen	Flop movies
Blowtorch	Flop movies
The Perfect Host: A Southern Gothic Tale	Flop movies
Jekyll Island	Flop movies
The Dark Below	Flop movies
Body of Deceit	Flop movies
Ultimate Justice	Flop movies
Blood Bound	Flop movies
The Redeeming	Flop movies
Broken Star	Flop movies
Rock, Paper, Scissors	Flop movies
Aux	Flop movies
Woodshock	Flop movies
Discarnate	Flop movies
Fantasma	Flop movies
Rapid Eye Movement	Flop movies
They Remain	Flop movies
Incontrol	Flop movies
Noctem	Flop movies
Escape Room	Flop movies
3	Flop movies
Welcome to Acapulco	Flop movies
Haseena Parkar	Flop movies
Reprisal	Flop movies
Two Graves	Flop movies
30 Miles from Nowhere	Flop movies
Koxa	Flop movies
Family Blood	Flop movies
Sabrina	Flop movies
Creep Nation	Flop movies
Fear Bay	Flop movies
Room 37: The Mysterious Death of Johnny Thunders	Flop movies
Along Came the Devil 2	Flop movies
Caller ID	Flop movies
Gas Light	Flop movies
Deep Burial	Flop movies
The Answer	Flop movies
The Harrowing	Flop movies
Wild for the Night	Flop movies
The Drownsman	Flop movies
Furthest Witness	Flop movies
The Grinn	Flop movies
Lost Solace	Flop movies
Valley of Bones	Flop movies
Enclosure	Flop movies
The Wasting	Flop movies
Dark Iris	Flop movies
Unhinged	Flop movies
9/11	Flop movies
The Samaritans	Flop movies
ExPatriot	Flop movies
The Institute	Flop movies
The Atoning	Flop movies
A Thought of Ecstasy	Flop movies
The Nanny	Flop movies
Paint It Red	Flop movies
Hesperia	Flop movies
Heilstätten	Flop movies
Downward Twin	Flop movies
Witches in the Woods	Flop movies
The Car: Road to Revenge	Flop movies
Otryv	Flop movies
Art of Deception	Flop movies
Above Ground	Flop movies
Grinder	Flop movies
The Tank	Flop movies
Strangers Within	Flop movies
Sum1	Flop movies
Lies We Tell	Flop movies
Altitude	Flop movies
Parasites	Flop movies
Buckout Road	Flop movies
Rondo	Flop movies
Axis	Flop movies
Arsenal	Flop movies
8 Remains	Flop movies
Point of no Return	Flop movies
Where the Skin Lies	Flop movies
#SquadGoals	Flop movies
The Field	Flop movies
Artik	Flop movies
Running Out Of Time	Flop movies
Target	Flop movies
Simple Creature	Flop movies
100 Ghost Street: The Return of Richard Speck	Flop movies
Tell Me Your Name	Flop movies
Restraint	Flop movies
The Summoning	Flop movies
Ridge Runners	Flop movies
Lyst	Flop movies
The Martyr Maker	Flop movies
Havana Darkness	Flop movies
Raasta	Flop movies
Agent	Flop movies
Canal Street	Flop movies
Project Ithaca	Flop movies
Odds Are	Flop movies
Operation Ragnarök	Flop movies
Dassehra	Flop movies
The Hollow One	Flop movies
Your Move	Flop movies
MindGamers	Flop movies
The Body Tree	Flop movies
Intensive Care	Flop movies
Silencer	Flop movies
The School	Flop movies
The Executioners	Flop movies
Gremlin	Flop movies
Candy Corn	Flop movies
Tempus Tormentum	Flop movies
Playing with Dolls: Havoc	Flop movies
The Nightmare Gallery	Flop movies
Net I Die	Flop movies
Scars of Xavier	Flop movies
Thriller	Flop movies
Nirdosh	Flop movies
Bundy and the Green River Killer	Flop movies
Night	Flop movies
Catskill Park	Flop movies
The Guest House	Flop movies
Deadly Sanctuary	Flop movies
The Harvesting	Flop movies
Del Playa	Flop movies
Hide in the Light	Flop movies
Armed Response	Flop movies
Central Park	Flop movies
American Gothic	Flop movies
The Toybox	Flop movies
Halt: The Motion Picture	Flop movies
Followers	Flop movies
The Midnight Matinee	Flop movies
Botoks	Flop movies
Trickster	Flop movies
The Farm	Flop movies
Khamoshi	Flop movies
Portal	Flop movies
Muse	Flop movies
Paranormal Investigation	Flop movies
Primrose Lane	Flop movies
Valley of the Sasquatch	Flop movies
Burning Kiss	Flop movies
The Wicked One	Flop movies
Seeds	Flop movies
House by the Lake	Flop movies
Braxton	Flop movies
The Honor Farm	Flop movies
The Haunted	Flop movies
Drifter	Flop movies
The Sound	Flop movies
Cage	Flop movies
Nereus	Flop movies
The Midnight Man	Flop movies
Involution	Flop movies
The Young Cannibals	Flop movies
Berserk	Flop movies
High Heel Homicide	Flop movies
Pussy Kills	Flop movies
Killer Kate!	Flop movies
In the Cloud	Flop movies
Live	Flop movies
Deviant Love	Flop movies
Needlestick	Flop movies
Mississippi Murder	Flop movies
The Snare	Flop movies
I Before Thee	Flop movies
Besetment	Flop movies
The Evil Inside Her	Flop movies
The Nth Ward	Flop movies
7 Witches	Flop movies
Defective	Flop movies
Mountain Fever	Flop movies
Out of the Shadows	Flop movies
The Rake	Flop movies
Cabaret	Flop movies
Everfall	Flop movies
Cain Hill	Flop movies
Prescience	Flop movies
Blood Craft	Flop movies
Shadow Wolves	Flop movies
Identical	Flop movies
Asylum of Fear	Flop movies
A Room to Die For	Flop movies
We Are Monsters	Flop movies
Wrecker	Flop movies
Larceny	Flop movies
Contract to Kill	Flop movies
Wraith	Flop movies
What Lies Ahead	Flop movies
Door in the Woods	Flop movies
Edge of Isolation	Flop movies
Prodigy	Flop movies
Linhas de Sangue	Flop movies
Somnium	Flop movies
Staged Killer	Flop movies
7 Splinters in Time	Flop movies
Accident	Flop movies
Slasher.com	Flop movies
Hell of a Night	Flop movies
The Man in the Shadows	Flop movies
Armed	Flop movies
Immigration Game	Flop movies
Hate Story IV	Flop movies
Carnivore: Werewolf of London	Flop movies
Red Room	Flop movies
Deadly Expose	Flop movies
Nighthawks	Flop movies
Doll Cemetery	Flop movies
E-Demon	Flop movies
Garbage	Flop movies
The Row	Flop movies
Zoo-Head	Flop movies
Delirium	Flop movies
Ladyworld	Flop movies
The Tracker	Flop movies
3 Lives	Flop movies
Check Point	Flop movies
Project Eden: Vol. I	Flop movies
Slender Man	Flop movies
The Hurt	Flop movies
The House of Violent Desire	Flop movies
Incoming	Flop movies
Dead Water	Flop movies
A Deadly View	Flop movies
Night Zero	Flop movies
The Open House	Flop movies
The Manson Family Massacre	Flop movies
Prowler	Flop movies
5th Passenger	Flop movies
Slender	Flop movies
Bodysnatch	Flop movies
Unwritten	Flop movies
Ambition	Flop movies
The Legend of Halloween Jack	Flop movies
Alpha Wolf	Flop movies
Foto na pamyat	Flop movies
Nightmare Box	Flop movies
A Place in Hell	Flop movies
CTRL	Flop movies
Fighting the Sky	Flop movies
Mind and Machine	Flop movies
Death Pool	Flop movies
Dagenham	Flop movies
The Cabin	Flop movies
The 13th Friday	Flop movies
Ouija House	Flop movies
Annabellum: The Curse of Salem	Flop movies
Clowntergeist	Flop movies
Inhumane	Flop movies
The System	Flop movies
Survival Box	Flop movies
The Haunting of Sharon Tate	Flop movies
Cleavers: Killer Clowns	Flop movies
Scary Story Slumber Party	Flop movies
The Church	Flop movies
Face of Evil	Flop movies
Recall	Flop movies
Body Keepers	Flop movies
Virus of the Dead	Flop movies
Curse of the Nun	Flop movies
Schoolhouse	Flop movies
Amavas	Flop movies
Milliard	Flop movies
But Deliver Us from Evil	Flop movies
Breaking Point	Flop movies
Kolaiyuthir Kaalam	Flop movies
I See You	Flop movies
Against the Clock	Flop movies
Antisocial.app	Flop movies
Blood Prism	Flop movies
Sathya	Flop movies
House of Afflictions	Flop movies
[Cargo]	Flop movies
I Spit on Your Grave: Deja Vu	Flop movies
It Kills	Flop movies
Infection: The Invasion Begins	Flop movies
The Terrible Two	Flop movies
The Crossbreed	Flop movies
The Fast and the Fierce	Flop movies
Drive	Flop movies
The Broken Key	Flop movies
Romina	Flop movies
Black Wake	Flop movies
Astro	Flop movies
Countrycide	Flop movies
Another Soul	Flop movies
Race 3	Flop movies
This Old Machine	Flop movies
Halloween Horror Tales	Flop movies
Tera Intezaar	Flop movies
The Forbidden Dimensions	Flop movies
Krampus: The Christmas Devil	Flop movies
Bordo Bereliler Afrin	Flop movies
Roofied	Flop movies
*/




/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT genre,
    ROUND(AVG(duration), 2) AS avg_duration,
    SUM(ROUND(AVG(duration), 2)) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
    AVG(ROUND(AVG(duration), 2)) OVER (ORDER BY genre ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS moving_avg_duration
FROM movie AS m
INNER JOIN genre AS g ON m.id = g.movie_id
GROUP BY genre
ORDER BY genre;

	   
/*
# genre	avg_duration	running_total_duration	moving_avg_duration
Action	112.88	112.88	112.880000
Adventure	101.87	214.75	107.375000
Comedy	102.62	317.37	105.790000
Crime	107.05	424.42	106.105000
Drama	106.77	531.19	106.238000
Family	100.97	632.16	105.360000
Fantasy	105.14	737.30	105.328571
Horror	92.72	830.02	103.752500
Mystery	101.80	931.82	103.535556
Others	100.16	1031.98	103.198000
Romance	109.53	1141.51	102.863000
Sci-Fi	97.94	1239.45	102.470000
Thriller	101.58	1341.03	102.366000

*/






-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH top_genre AS
(
	SELECT g.genre, COUNT(g.movie_id) AS movie_count
	FROM genre AS g
	INNER JOIN ratings AS r
	ON g.movie_id = r.movie_id
	WHERE avg_rating > 8
    GROUP BY genre
    ORDER BY movie_count DESC
    LIMIT 3
),
top_5 AS
(
	SELECT 	g.genre,
			year,
			title AS movie_name,
			worlwide_gross_income,
			DENSE_RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
        
	FROM movie AS m 
    INNER JOIN genre AS g 
    ON m.id= g.movie_id,
    top_genre
	WHERE g.genre IN (top_genre.genre)
)
SELECT *
FROM top_5
WHERE movie_rank<=5
ORDER BY movie_rank;

-- income currency conversion is ignored.

/*
# genre	year	movie_name	worlwide_gross_income	movie_rank
Drama	2017	Shatamanam Bhavati	INR 530500000	1
Action	2018	The Villain	INR 1300000000	1
Action	2019	Code Geass: Fukkatsu No Lelouch	$ 9975704	1
Drama	2017	Winner	INR 250000000	2
Action	2017	Winner	INR 250000000	2
Drama	2018	Antony & Cleopatra	$ 998079	2
Drama	2019	Joker	$ 995064593	2
Drama	2017	Thank You for Your Service	$ 9995692	3
Comedy	2018	La fuitina sbagliata	$ 992070	3
Action	2019	Shi tu xing zhe 2: Die ying xing dong	$ 99482027	3
Drama	2017	The Healer	$ 9979800	4
Comedy	2017	The Healer	$ 9979800	4
Drama	2018	Zaba	$ 991	4
Comedy	2019	Eaten by Lions	$ 99276	4
Drama	2017	Shan guang shao nu	$ 9949926	5
Comedy	2018	Gung-hab	$ 9899017	5
Comedy	2019	Friend Zone	$ 9894885	5
*/





-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT production_company,
		count(title) AS movie_count,
        RANK() OVER (ORDER BY count(title) desc) AS prod_comp_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
WHERE median_rating>=8 AND production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY production_company
LIMIT 2;

/*
# production_company	movie_count	prod_comp_rank
Star Cinema	7	1
Twentieth Century Fox	4	2

*/






-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actress_summary AS
(
    SELECT
        n.NAME AS actress_name,
        SUM(total_votes) AS total_votes,
        COUNT(r.movie_id) AS movie_count,
        ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actress_avg_rating
    FROM
        movie AS m
        INNER JOIN ratings AS r ON m.id = r.movie_id
        INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
        INNER JOIN names AS n ON rm.name_id = n.id
        INNER JOIN genre AS g ON m.id = g.movie_id
     WHERE
        category = 'ACTRESS' AND g.genre = 'drama'
    GROUP BY NAME
    HAVING ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) > 8
)
SELECT *,
    DENSE_RANK() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
FROM
    actress_summary
ORDER BY actress_rank
LIMIT 3;

/*
# actress_name	total_votes	movie_count	actress_avg_rating	actress_rank
Sangeetha Bhat	1010	1	9.60	1
Fatmire Sahiti	3932	1	9.40	2
Pranati Rai Prakash	897	1	9.40	2
*/





/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH movie_date AS (
    SELECT 
        d.name_id, 
        n.name, 
        d.movie_id,
        m.date_published, 
        LEAD(date_published, 1) OVER (PARTITION BY d.name_id ORDER BY date_published, d.movie_id) AS next_movie_date
    FROM 
        director_mapping AS d
        JOIN names AS n ON d.name_id = n.id 
        JOIN movie AS m ON d.movie_id = m.id
),
avg_days_gap AS (
    SELECT name_id, AVG(DATEDIFF(next_movie_date, date_published)) AS avg_inter_movie_days
    FROM movie_date
    GROUP BY name_id
),
final_result AS (
    SELECT 
        d.name_id AS director_id,
        n.name AS director_name,
        COUNT(d.movie_id) AS number_of_movies,
        ROUND(AVG(avg_inter_movie_days)) AS inter_movie_days, 
        ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS avg_rating,
        SUM(total_votes) AS total_votes,
        MIN(avg_rating) AS min_rating,
        MAX(avg_rating) AS max_rating,
        SUM(duration) AS total_duration,
        ROW_NUMBER() OVER (ORDER BY COUNT(d.movie_id) DESC) AS director_row_rank
    FROM
        names AS n 
        JOIN director_mapping AS d ON n.id = d.name_id
        JOIN ratings AS r ON d.movie_id = r.movie_id
        JOIN movie AS m ON m.id = r.movie_id
        JOIN avg_days_gap AS a ON a.name_id = d.name_id
    GROUP BY 
        director_id
)
SELECT *	
FROM 
    final_result
WHERE director_row_rank <=9;

/*
# director_id	director_name	number_of_movies	inter_movie_days	avg_rating	total_votes	min_rating	max_rating	total_duration	director_row_rank
nm1777967	A.L. Vijay	5	177	5.65	1754	3.7	6.9	613	1
nm2096009	Andrew Jones	5	191	3.04	1989	2.7	3.2	432	2
nm6356309	Özgür Bakar	4	112	3.96	1092	3.1	4.9	374	3
nm2691863	Justin Price	4	315	4.93	5343	3.0	5.8	346	4
nm0814469	Sion Sono	4	331	6.31	2972	5.4	6.4	502	5
nm0831321	Chris Stokes	4	198	4.32	3664	4.0	4.6	352	6
nm0425364	Jesse V. Johnson	4	299	6.10	14778	4.2	6.5	383	7
nm0001752	Steven Soderbergh	4	254	6.77	171684	6.2	7.0	401	8
nm0515005	Sam Liu	4	260	6.32	28557	5.8	6.7	312	9

*/






