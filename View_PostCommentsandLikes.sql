CREATE VIEW PostCommentsAndLikes AS
WITH CommentCounts AS (
  SELECT post_id, COUNT(comment_id) AS total_comments
  FROM comments
  GROUP BY post_id
),
LikeCounts AS (
  SELECT p.post_id, COUNT(pl.post_id) AS total_likes
  FROM post p
  JOIN users u ON p.user_id = u.user_id
  JOIN post_likes pl ON pl.user_id = u.user_id
  GROUP BY p.post_id
)
SELECT COALESCE(cc.post_id, lc.post_id) AS post_id,
       COALESCE(total_comments, 0) AS total_comments,
       COALESCE(total_likes, 0) AS total_likes
FROM CommentCounts cc
FULL JOIN LikeCounts lc ON cc.post_id = lc.post_id;


