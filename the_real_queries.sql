select * from comments
select * from comment_likes
select * from bookmarks
select * from follows
select * from hashtag_follow
select * from hashtags
select * from login
select * from photos
select * from post
select * from post_likes
select * from post_tags
select * from videos
select * from users

-- Query 1: Find the user with the most followers.
select TOP 1 u.user_id, u.username, f.follower_id, count(f.followee_id)as No_of_Followers
from users as u
join follows as f
on u.user_id = f.follower_id
group by u.user_id, u.username, f.follower_id
order by count(f.followee_id) DESC

-- Query 2: Calculate the average post size by post type (photo or video).
WITH PostTypes AS (
    SELECT
        'Photos' AS post_type,
        ph.size AS size
    FROM post p
    LEFT JOIN photos ph ON p.photo_id = ph.photo_id
    UNION ALL
    SELECT
        'Videos' AS post_type,
        vi.size AS size
    FROM post p
    LEFT JOIN videos vi ON p.video_id = vi.video_id
)
SELECT
    post_type,
    AVG(size) AS avg_size
FROM PostTypes
GROUP BY post_type;

-- Query 3: List the top 5 posts with the most comments and their user owners.

WITH RankedPosts AS (
  SELECT u.user_id,
    u.username,
    p.post_id,
    COUNT(c.comment_id) AS comments_count,
    DENSE_RANK() OVER (ORDER BY COUNT(c.comment_id) DESC) AS Ranks
  FROM
    post p
  JOIN comments c ON p.post_id = c.post_id
  JOIN users u ON p.user_id = u.user_id
  GROUP BY u.user_id, u.username, p.post_id
)
SELECT user_id, username, post_id, comments_count
FROM RankedPosts
WHERE Ranks <= 5;

-- Query 4: Calculate the total number of likes on posts by each user.

SELECT u.username, count(pl.post_id) AS total_likes
FROM users u
LEFT JOIN post_likes pl ON u.user_id = pl.user_id
GROUP BY u.username;

SELECT u.user_id, count(pl.post_id) AS total_likes
FROM users u
LEFT JOIN post_likes pl ON u.user_id = pl.user_id
GROUP BY u.user_id;

-- Query 5: Create a view to display the total number of comments and likes for each post:

SELECT * FROM PostCommentsAndLikes
ORDER BY post_id

--- Query 6: List the 10 most popular hashtags along with the number of posts they are used in:
WITH HashtagCounts AS (
    SELECT h.hashtag_name, COUNT(pt.post_id) AS post_count
    FROM hashtags AS h
    LEFT JOIN post_tags AS pt ON h.hashtag_id = pt.hashtag_id
    GROUP BY h.hashtag_name
)
SELECT TOP 10 hashtag_name, post_count
FROM HashtagCounts
ORDER BY post_count DESC;

--Query 7: List the users who have liked their own posts:
SELECT u.username
FROM users AS u
INNER JOIN post_likes AS pl ON u.user_id = pl.user_id
INNER JOIN post AS p ON u.user_id = p.user_id AND pl.post_id = p.post_id;

--Query 8: Find users who have not posted any photos or videos:
SELECT u.username
FROM users AS u
LEFT JOIN post AS p ON u.user_id = p.user_id
WHERE p.post_id IS NULL;

--Query 9: Find users who have bookmarked the same post that they liked:
SELECT u.username, b.post_id
FROM users AS u
INNER JOIN post_likes AS pl ON u.user_id = pl.user_id
INNER JOIN bookmarks AS b ON u.user_id = b.user_id AND pl.post_id = b.post_id;

--Query 10: Find the users who have commented on the most posts:
SELECT TOP 10 u.username, COUNT(c.comment_id) AS comments_count
FROM users AS u
INNER JOIN comments AS c ON u.user_id = c.user_id
GROUP BY u.username
ORDER BY comments_count DESC;

--Query 11: Any specific word in comment:
SELECT * FROM comments
WHERE comment_text LIKE '%good%' OR comment_text LIKE '%beautiful%';


