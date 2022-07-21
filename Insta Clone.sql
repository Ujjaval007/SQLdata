/* MySQL project which is a cloned version of Instagram database.we will  use it to perform data analysis for real world business related questions and scenarios such as

- find out the rewarding system for the loyal users
- launching campaign to target the weekdays with the most user registerations
- encouraging inactive users to log in back to the system
- who has got the most likes on a single photo?
- How many times does the average user post?
- What are the top 5 most commonly used hashtags?
- users who have liked every single photo on the site
- users who have never commented on a photo
*/

Use ig_clone
/*We want to reward our users who have been around the longest.  
We will reward top 5 oldest users */

Select * from users
ORDER BY created_at
Limit 5;

/* Now we can formulate reward system around these oldest users */

/* Now to launch a campaign to target the weekdays with most user registration we will perform following query */

Select dayname(created_at) as Day , count(*) as totalregistration
from users
group by Day
order by totalregistration desc;

/* Alternate Way */
Select date_format(created_at,'%W') AS 'dayoftheweek', COUNT(*) AS 'total_registration'
FROM users
GROUP BY 1
ORDER BY 2 DESC;


/*We want to target our inactive users with an email campaign.
Find the users who have never posted a photo*/
SELECT username
FROM users
LEFT JOIN photos ON users.id = photos.user_id
WHERE photos.id IS NULL;

/*We're have a new contest to see who can get the most likes on a single photo*/

SELECT users.username,photos.id,photos.image_url,COUNT(*) AS Total_Likes
FROM likes
JOIN photos ON photos.id = likes.photo_id
JOIN users ON users.id = likes.user_id
GROUP BY photos.id
ORDER BY Total_Likes DESC
LIMIT 1;

/*
How many times does the average user post?*/
/*total number of photos/total number of users*/
SELECT ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),2)as avguserpost;


/*user ranking by postings higher to lower*/
Select users.username,count(photos.image_url) as no_of_posts
From users
Join photos on users.id = photos.user_id
group by user_id
order by  no_of_posts desc; 

/*A brand wants to know which hashtags to use in a post
What are the top 5 most commonly used hashtags?*/
SELECT tag_name, COUNT(tag_name) AS total
FROM tags
JOIN photo_tags ON tags.id = photo_tags.tag_id
GROUP BY tags.id
ORDER BY total DESC;

/*They have a small problem with bots on our site...
Find users who have liked every single photo on the site*/
SELECT users.id,username, COUNT(users.id) As total_likes_by_user
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id
Having total_likes_by_user = (SELECT COUNT(*) FROM photos);

/*We also have a problem with celebrities
Find users who have never commented on a photo*/
SELECT username,comment_text
FROM users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY users.id
HAVING comment_text IS NULL;

/* Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on every photo*/

SELECT wo_co.total_A AS 'Number Of Users who never commented',
		(wo_co.total_A/(SELECT COUNT(*) FROM users))*100 AS '%',
		likephoto.total_B AS 'Number of Users who likes every photos',
		(likephoto.total_B/(SELECT COUNT(*) FROM users))*100 AS '%'
FROM
	(
		SELECT COUNT(*) AS total_A FROM
			(SELECT username,comment_text
				FROM users
				LEFT JOIN comments ON users.id = comments.user_id
				GROUP BY users.id
				HAVING comment_text IS NULL) AS total_number_of_users_without_comments
	) AS wo_co
	JOIN
	(
		SELECT COUNT(*) AS total_B FROM
			(SELECT users.id,username, COUNT(users.id) As total_likes_by_user
				FROM users
				JOIN likes ON users.id = likes.user_id
				GROUP BY users.id
				HAVING total_likes_by_user = (SELECT COUNT(*) FROM photos)) AS total_number_users_likes_every_photos
	)AS likephoto;