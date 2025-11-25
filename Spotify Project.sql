-- Spotify SQL Project

-- Create table


drop table if exists spotify;
create table spotify 
		(
			Artist VARCHAR(50),
			Track VARCHAR(255),
			Album VARCHAR(255),
			Album_type VARCHAR(50),
			Danceability FLOAT,
			Energy FLOAT,
			Loudness FLOAT,
			Speechiness FLOAT,
			Acousticness FLOAT, 
			Instrumentalness FLOAT,
			Liveness FLOAT,
			Valence FLOAT,
			Tempo FLOAT,
			Duration_min FLOAT,
			Title VARCHAR(255),
			Channel VARCHAR(255),
			Views FLOAT,
			Likes BIGINT,
			Comments BIGINT,
			Licensed BOOLEAN,
			official_video BOOLEAN,
			Stream BIGINT,
			EnergyLiveness FLOAT,
			most_playedon VARCHAR(50)
		);
select * from spotify;


-- EDA
Select 
			count(*),
			count(distinct Artist) as artists,
			count(distinct track) as artists,
			count(distinct album) as albums,
			count(distinct album_type) as album_type,
			count(distinct channel) as channel,
			count(distinct most_playedon) as stream
		from spotify;
		
select 
		distinct album_type
	from spotify;

select 
		distinct most_playedon
	from spotify;

select 
		max(duration_min) as max_duration,
		min(duration_min) as min_duration
	from spotify;

select *
	from spotify
	where duration_min = 0;

delete from spotify
	where duration_min = 0;

-- PROBLEMS TO BE SOLVED

--1. Retrieve the names of all tracks that have more than 1 billion streams.

Select *
	from spotify;

Select *
	from spotify
	where stream >= 1000000000;

-- 2. List all albums along with their respective artists.
select 
		album,
		artist
	from spotify;

-- 3. Get the total number of comments for tracks where licensed = TRUE.
select 
		sum(comments) as total_comments
	from spotify
	where licensed = 'True';

-- 4. Find all tracks that belong to the album type single.
select 
		track,
		album,
		album_type
	from spotify
	where album_type = 'single'

-- 5. Count the total number of tracks by each artist
select 
		artist,
		count(*) as no_of_tracks
	from spotify
	group by artist
	order by no_of_tracks desc;

-- 6. Calculate the average danceability of tracks in each album.

select 
		album,
		avg(danceability) as avg_danceability
	from spotify
	group by album
	order by avg_danceability desc;

-- 7. Find the top 5 tracks with the highest energy values.
select 
		track,
		max(energy) as max_energy
	from spotify
	group by track,energy
	order by energy desc
	limit 5;

-- 8. List all tracks along with their views and likes where official_video = TRUE.
		-- track
		-- views
		-- likes
		-- official_video = TRUE
select *
	from spotify;

select 
		track,
		sum(views) as total_views,
		sum(likes) as total_likes
	from spotify
	where official_video = 'TRUE'
	group by track
	order by total_views desc;

-- 9. For each album, calculate the total views of all associated tracks.
select 
		album,
		track,
		sum(views) as total_views
	from spotify
	group by album,track
	order by total_views desc;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
		-- track
		-- most_playedon = 'Youtube'
select *
	from spotify;
with t1 as 
	(
		select
				track,
				coalesce(sum(case when most_playedon='Youtube'then stream end),0) as streamed_youtube,
				coalesce(sum(case when most_playedon='Spotify'then stream end),0) as streamed_spotify
			from spotify
			group by track
	)
select *
	from t1
	where streamed_spotify>streamed_youtube
		and 
			streamed_youtube <> 0;


-- 11. Find the top 3 most-viewed tracks for each artist using window functions
			-- top 3 most-viewed track for each artist.
			-- Each artist
select *
	from spotify;

with t1 as
		(
			select
					artist,
					track,
					sum(views) as total_view,
					dense_rank() over(partition by artist order by sum(views) desc) as rank
				from spotify 
				group by 1,2
				order by artist,total_view desc
			)
		select *
			from t1
			where rank <= 3 ;

-- 12 Write a query to find tracks where the liveness score is above the average.
		-- tracks
		-- liveness > average
		-- sub-query the average
select *
	from spotify;

select 
		avg(liveness)
	from spotify;

select 
		Track,
		Artist,
		liveness
	from spotify
	where liveness > (Select avg(liveness) from spotify)
	order by liveness desc;

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
select *
		from spotify;

with t1 as 
			(
				select 
					album,
					max(energy) as max_energy,
					min(energy) as min_energy
				from spotify
				group by album
			)
		select 
				*,
				max_energy-min_energy as difference
			from t1
			order by difference desc;
;

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
select *
	from spotify;

select 
		track,
		energy,
		liveness,
		energy/liveness as ratio
	from spotify
	group by energy, liveness, track
	having energy/liveness >1.2 
	order by ratio desc;

-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
select *
	from spotify;


select
		track,
		views,
		likes,
		sum(likes) over(partition by track order by views desc)
	from spotify;

-- Query Optimization
explain analyze  
select 
		artist,
		track,
		views
	from spotify
	where artist = 'Gorillaz'
		and
		most_playedon = 'Youtube'
	order by stream desc 
	limit 25;

-- Create index
create index artist_index on spotify(artist);

			
/* End of Project*/

