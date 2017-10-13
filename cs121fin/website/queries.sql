-- [Problem 4a]
-- The title, upload time, and downloads for the top 20 photos and
-- videos by user 'bopeep', ordered by descending downloads.
SELECT title, upload_time, downloads
FROM uploaded NATURAL JOIN media_item
WHERE username = 'bopeep'
ORDER BY downloads DESC
LIMIT 20;

-- [Problem 4b]
-- The album name, description, number of media items, and filename
-- of summary photo for each album by user 'garth'. If there is no
-- summary_photo, include NULL for filename.
SELECT album_name, album_description, num_items, photo_filename
FROM albums JOIN photo ON summary_photo <=> photo_data NATURAL JOIN
(SELECT album_name, COUNT(item_id) AS num_items
        FROM uploaded
        WHERE username = 'garth'
        GROUP BY album_name) AS item_counts
WHERE username = 'garth';

-- [Problem 4c]
-- Username and number of comments for top 10 commenters.
SELECT username, num_comments
FROM (
    SELECT username, COUNT(*) AS num_comments
    FROM comments
    GROUP BY username) AS comment_counts
ORDER BY num_comments DESC
LIMIT 10;
