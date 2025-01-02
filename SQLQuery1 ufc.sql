/*
Date: 12/23/2024
The purpose of this project was to apply SQL skills learned on a topic interesting to me

*/


--Fighters with the highest victory percentage given they had 15 or more victories
SELECT 
	name, 
	wins Wins,
	CAST (wins AS int) + CAST (losses AS int) + CAST (draws AS int) AS [Total Matches],
	round(
	(CAST(wins AS float)) / (CAST (wins AS int) + CAST (losses AS int) + CAST (draws AS int)),3) * 100 AS [Victory Percentage]
FROM 
	UFCProject.dbo.[ufc-fighters-statistics(in)]
WHERE
	CAST (wins AS int) >= 15 AND wins NOT LIKE '0'
ORDER BY 
	[Victory Percentage] DESC





--Categorizing fighters by weight classes 
SELECT 
	name,
	weight_in_kg as [Weight in kg],
	WeightClass
FROM(
	SELECT
		name, 
		weight_in_kg, 
		CASE
			WHEN weight_in_kg < 52.6 THEN 'Strawweight'
			WHEN weight_in_kg > 53 AND weight_in_kg < 57.2 THEN 'Flyweight'
			WHEN weight_in_kg > 58 AND weight_in_kg < 61.7 THEN 'Bantamweight'
			WHEN weight_in_kg > 62 AND weight_in_kg < 66.2 THEN 'Featherweight'
			WHEN weight_in_kg > 67 AND weight_in_kg < 70.8 THEN 'Lightweight'
			WHEN weight_in_kg > 71 AND weight_in_kg < 79.8 THEN 'Welterweight'
			WHEN weight_in_kg > 80 AND weight_in_kg < 84.4 THEN 'Middleweight'
			WHEN weight_in_kg > 85 AND weight_in_kg < 93.4 THEN 'Light heavyweight'
			WHEN weight_in_kg > 94 AND weight_in_kg < 120.7 THEN 'Heavyweight'
			ELSE 'Unknown'
		END AS 
			WeightClass
	FROM 
		UFCProject.dbo.[ufc-fighters-statistics(in)])
	AS Categorized
WHERE 
	WeightClass NOT LIKE 'Unknown' 
ORDER BY 
	weight_in_kg DESC





--Most offensively accurate fighters
SELECT 
	name, 
	significant_striking_accuracy,
	takedown_accuracy,
	(CAST (significant_striking_accuracy AS float) + CAST (takedown_accuracy AS float)) / 2 AS [Offensive Accuracy] 
FROM 
	UFCProject.dbo.[ufc-fighters-statistics(in)] 
WHERE 
	significant_strikes_landed_per_minute NOT LIKE '0' AND
	takedown_accuracy NOT LIKE '0' AND 
	wins NOT LIKE '0'
ORDER BY 
	[Offensive Accuracy] DESC





--Accuracy of strikes by stances 
SELECT  
	stance,
	round(AVG(CAST(significant_striking_accuracy AS float)),2) as [Average Accuracy]
FROM
	UFCProject.dbo.[ufc-fighters-statistics(in)]
WHERE	
	stance NOT LIKE 'NULL' AND 
	significant_strikes_landed_per_minute NOT LIKE '0'
GROUP BY 
	stance
ORDER BY 
	[Average Accuracy] DESC





-- Most active grappler 
SELECT 
    name, 
    average_takedowns_landed_per_15_minutes, 
    average_submissions_attempted_per_15_minutes, 
    ROUND(
        (CAST(average_takedowns_landed_per_15_minutes AS float) + CAST(average_submissions_attempted_per_15_minutes AS float)) / 
        (
            (SELECT MAX(CAST(average_takedowns_landed_per_15_minutes AS float)) FROM UFCProject.dbo.[ufc-fighters-statistics(in)]) +
            (SELECT MAX(CAST(average_submissions_attempted_per_15_minutes AS float)) FROM UFCProject.dbo.[ufc-fighters-statistics(in)])
        ), 4) * 100 AS [Activeness Percentage]
FROM 
    UFCProject.dbo.[ufc-fighters-statistics(in)]
WHERE 
    average_submissions_attempted_per_15_minutes NOT LIKE '0' AND 
    average_takedowns_landed_per_15_minutes NOT LIKE '0'
ORDER BY 
    [Activeness Percentage] DESC;

	




/*
-Active fighters with the highest defense percentage  

Fighters are assumed to be retired at 40 years old (Average ages retire between 35 and 40) 
*/
SELECT 
	name,
	significant_strike_defence,
	takedown_defense, 
	DATEDIFF(YY, date_of_birth, GETDATE()) AS [Age],
	(cast(significant_strike_defence AS int) + CAST (takedown_defense AS int)) / 2 AS [Defense Percentage]

FROM 
	UFCProject.dbo.[ufc-fighters-statistics(in)]

WHERE 
	significant_strike_defence NOT LIKE '0' AND
	takedown_defense NOT LIKE '0' AND 
	wins NOT LIKE '0' AND 
	date_of_birth NOT LIKE 'NULL' AND
	DATEDIFF(YY, date_of_birth, GETDATE()) < 40 

ORDER BY 
	[Defense Percentage] DESC