use spotify_streaming;
Describe spotify_history;
Select * from spotify_history; 


-- What time of day do they typically listen to music?
SELECT CASE 
            WHEN HOUR(ts) BETWEEN 6 AND 12 THEN 'Morning'
            WHEN HOUR(ts) BETWEEN 12 AND 18 THEN 'Afternoon'
            WHEN HOUR(ts) BETWEEN 18 AND 24 THEN 'Evening'
            ELSE 'Night'
       END AS time_of_day,
       COUNT(*) AS play_count
FROM spotify_history
GROUP BY time_of_day
ORDER BY play_count ;


-- How often do they explore new artists versus replaying favorites?
WITH ArtistPlayCount AS (
    SELECT artist_name, COUNT(*) AS play_count
    FROM spotify_history
    GROUP BY artist_name
)
SELECT 
    SUM(CASE WHEN play_count = 1 THEN 1 ELSE 0 END) AS new_artists,
    SUM(CASE WHEN play_count > 1 THEN 1 ELSE 0 END) AS repeat_artists,
    (SUM(CASE WHEN play_count = 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS new_artist_ratio
FROM ArtistPlayCount;


-- 1: How many tracks were played in total?
SELECT COUNT(*) AS total_tracks_played
FROM spotify_history;


-- 2: List the unique artists in the dataset.
SELECT DISTINCT artist_name
FROM spotify_history;

-- 3: Find the most frequently played track and its artist.
SELECT track_name, artist_name,
    COUNT(*) AS play_count FROM spotify_history
GROUP BY track_name, artist_name ORDER BY play_count DESC LIMIT 1;

-- User Engagement Trends
-- A. Identify Peak Listening Hours (Hourly Trend) Purpose: Identifies the hours when users are most active, ranking them from highest to lowest.

WITH HourlyPlayCounts AS (
    SELECT ts AS play_hour, COUNT(*) AS play_count
    FROM spotify_history GROUP BY play_hour
) SELECT play_hour, play_count, 
       RANK() OVER (ORDER BY play_count DESC) AS Rankformusic FROM HourlyPlayCounts;
       
-- Weekly Listening Trends Purpose: Determines which day of the week users are most engaged.

WITH WeeklyPlayCounts AS (
    SELECT ts AS day_of_week, COUNT(*) AS play_count FROM spotify_history
    GROUP BY day_of_week
)
SELECT day_of_week, play_count, RANK() OVER (ORDER BY play_count DESC) AS ranks FROM WeeklyPlayCounts;

--  Platform-Based User Engagement Purpose: Identifies which platforms users prefer for streaming.
SELECT 
    platform, 
    COUNT(*) AS total_plays, 
    SUM(ms_played) / (1000 * 60) AS total_minutes_played
FROM spotify_history GROUP BY platform ORDER BY total_plays DESC;

-- Listening Behavior Analysis
-- A. Most Played Tracks Purpose: Finds the top 10 most played songs along with their respective artists.

SELECT 
    track_name, 
    artist_name, 
    COUNT(*) AS total_plays FROM spotify_history GROUP BY track_name, artist_name ORDER BY total_plays DESC LIMIT 10;

-- Most Played Artists (Using Window Function) Purpose: Finds the top 10 most played artists.
WITH ArtistPlayCounts AS (
    SELECT 
        artist_name, 
        COUNT(*) AS total_plays FROM spotify_history GROUP BY artist_name
)
SELECT artist_name, total_plays, 
       DENSE_RANK() OVER (ORDER BY total_plays DESC) AS ranks
       FROM ArtistPlayCounts LIMIT 10;

-- Using Window and Self Join
WITH ArtistPlayCounts AS (
    SELECT 
        s1.artist_name, 
        COUNT(s1.spotify_track_uri) AS total_plays
    FROM spotify_history s1
    JOIN spotify_history s2 ON s1.artist_name = s2.artist_name GROUP BY s1.artist_name
)
SELECT artist_name, total_plays, 
       DENSE_RANK() OVER (ORDER BY total_plays DESC) AS ranks FROM ArtistPlayCounts LIMIT 10;




--  Skip Rate Analysis  Purpose: Identifies artists with the highest skip rates.

SELECT 
    artist_name, 
    COUNT(*) AS total_plays,
    SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) AS total_skips,
    ROUND(100 * SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) / COUNT(*), 2) AS skip_rate
FROM spotify_history GROUP BY artist_name ORDER BY skip_rate DESC LIMIT 10;

-- Which songs have they played the most? How often do they skip them?
SELECT track_name, artist_name, COUNT(*) AS play_count, 
       SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) AS skip_count, 
       (SUM(CASE WHEN skipped = TRUE THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS skip_rate
FROM spotify_history
GROUP BY track_name, artist_name ORDER BY play_count DESC LIMIT 10;


-- Impact of Shuffle Mode Purpose: Determines how shuffle mode affects listening behavior.
WITH ShuffleAnalysis AS (
    SELECT 
        shuffle, 
        COUNT(*) AS total_plays, 
        SUM(ms_played) / (1000 * 60) AS total_minutes_played FROM spotify_history GROUP BY shuffle
)
SELECT shuffle, total_plays, total_minutes_played, 
       PERCENT_RANK() OVER (ORDER BY total_plays DESC) AS ranks FROM ShuffleAnalysis;

-- Conclusion
-- This MySQL case study uses Joins, CTEs, and Window Functions to analyze User Engagement Trends and Listening Behavior. Key takeaways include:
-- ✅ Peak listening hours and days help in content promotion strategies.
-- ✅ Platform analysis guides optimizations for different devices.
-- ✅ Identifying top artists, albums, and tracks helps in recommendations.
-- ✅ Understanding skip rates assists in refining playlists and improving user experience.
-- ✅ Analyzing shuffle behavior reveals user preference for algorithmic vs. manual playback.











