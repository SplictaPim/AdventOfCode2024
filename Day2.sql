DROP TABLE IF EXISTS #Input
DROP TABLE IF EXISTS #StringSplit
DROP TABLE IF EXISTS [input2024].[Day2]

CREATE TABLE #Input (
[Level] varchar(255) NULL)

CREATE TABLE [input2024].[Day2] (
[Report] int IDENTITY(1,1) NOT NULL,
[Level] varchar(255) NULL,
[Safe] int DEFAULT 0)

CREATE TABLE #StringSplit (
[Report] int NOT NULL,
[Value] int NOT NULL,
[Ordinal] int NOT NULL)
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Read lines into table
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
BULK INSERT #Input
FROM 'C:\Users\pim\OneDrive\Documenten\Training\Advent of Code\2024\Input\Day2.txt'
WITH 
  (
    FIELDTERMINATOR = ' ', 
    ROWTERMINATOR = '\n' 
  )

INSERT INTO [input2024].[Day2] ([Level])
SELECT [Level] FROM #Input

INSERT INTO #StringSplit ([Report], [Value], [Ordinal])
SELECT t1.Report
	  ,convert(int, ss.[value]) AS [value]
	  ,ss.[ordinal]
FROM  [input2024].[Day2] t1
CROSS APPLY string_split(t1.[Level], ' ', 1) AS ss
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- vraag 1
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
;with cte_lead AS (
	SELECT [Report]
		  ,[Value]
		  ,LEAD([Value]) OVER(PARTITION BY [Report] ORDER BY [Ordinal]) AS [NextValue]
		  ,[Value] - LEAD([value]) OVER(PARTITION BY [Report] ORDER BY [Ordinal]) as [Diff]
		  ,CASE 
			WHEN [Value] - LEAD([value]) OVER(PARTITION BY [Report] ORDER BY [Ordinal]) > 0 THEN 1
			WHEN [Value] - LEAD([value]) OVER(PARTITION BY [Report] ORDER BY [Ordinal]) < 0 THEN -1
			ELSE 0
			END AS [PosOrNeg]
	FROM #StringSplit
	)
, cte_rules AS (
	SELECT [report] 
		  ,MAX(ABS([Diff])) AS [MaxDiff]
		  ,COUNT([Report]) -1 AS [Expected]
		  ,ABS(SUM(case when [NextValue] is not null then [PosOrNeg] else NULL end)) AS [SumPosOrNeg]
	FROM cte_lead
	GROUP BY [report]
	)
UPDATE t1
SET [Safe] = 1
FROM [input2024].[Day2] t1
INNER JOIN cte_rules t2
	ON t2.[Report] = t1.[Report]
WHERE t2.[MaxDiff] IN (1,2,3)
	AND t2.[Expected] = t2.[SumPosOrNeg]

SELECT SUM([Safe]) AS [Antwoord1] FROM [input2024].[Day2]
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
DECLARE @MaxOrdinal int = (select max([Ordinal]) from [#StringSplit])
DECLARE @CurrentOrdinal int = 1

WHILE @CurrentOrdinal <= @MaxOrdinal
BEGIN
	
	;with cte_unsafeLevels AS (
		SELECT t1.[Report]
			  ,t1.[Ordinal]
			  ,t1.[Value]
		FROM [#StringSplit] t1
		INNER JOIN [input2024].[Day2] t2
			ON t2.[Report] = t1.[Report]
			AND t2.[Safe] = 0
		WHERE t1.[Ordinal] != @CurrentOrdinal
	)
	,cte_lead AS (
		SELECT [Report]
			  ,[Value]
			  ,lead([value]) over(partition by [report] order by [Ordinal]) AS [NextValue]
			  ,[value] - lead([value]) over(partition by [report] order by [Ordinal]) as [Diff]
			  ,CASE 
				WHEN [value] - lead([value]) over(partition by [report] order by [Ordinal]) > 0 THEN 1
				WHEN [value] - lead([value]) over(partition by [report] order by [Ordinal]) < 0 THEN -1
				ELSE 0
				END AS [PosOrNeg]
		FROM cte_unsafeLevels
		)
	, cte_rules AS (
		SELECT [report] 
			  ,MAX(ABS([Diff])) AS [MaxDiff]
			  ,COUNT([Report]) -1 AS [Expected]
			  ,ABS(SUM(case when [NextValue] is not null then [PosOrNeg] else NULL end)) AS [SumPosOrNeg]
		FROM cte_lead
		GROUP BY [report]
	)
	UPDATE t1
	SET [Safe] = 1
	FROM [input2024].[Day2] t1
	INNER JOIN cte_rules t2
		ON t2.[Report] = t1.[Report]
	WHERE t2.[MaxDiff] IN (1,2,3)
		AND t2.[Expected] = t2.[SumPosOrNeg]

	SET @CurrentOrdinal = @CurrentOrdinal + 1

END

SELECT SUM([Safe]) AS [Antwoord2] FROM [input2024].[Day2]