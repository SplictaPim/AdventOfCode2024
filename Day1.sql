DROP TABLE IF EXISTS [input2024].[Day1]

CREATE TABLE [input2024].[Day1] (
[LocationList] varchar(255) NULL)

BULK INSERT [input2024].[Day1]
FROM 'C:\Users\pim\OneDrive\Documenten\Training\Advent of Code\2024\Input\Day1.txt'
WITH 
  (
    FIELDTERMINATOR = ';', 
    ROWTERMINATOR = '\n' 
  )
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- vraag 1
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #LeftInput
DROP TABLE IF EXISTS #RightInput

CREATE TABLE #LeftInput (
	RowNum [int] IDENTITY(1,1) NOT NULL,
	Input [int] NOT NULL
	)

CREATE TABLE #RightInput (
	RowNum [int] IDENTITY(1,1) NOT NULL,
	Input [int] NOT NULL
	)

INSERT INTO #LeftInput ([Input])
SELECT CONVERT(int, LEFT(LocationList, charindex(' ', LocationList)-1))
FROM [AdventOfCode].[input2024].[Day1]
ORDER BY CONVERT(int, LEFT(LocationList, charindex(' ', LocationList)-1))

INSERT INTO #RightInput ([Input])
SELECT CONVERT(int, RIGHT(LocationList, charindex(' ', LocationList)-1))
FROM [AdventOfCode].[input2024].[Day1]
ORDER BY CONVERT(int, RIGHT(LocationList, charindex(' ', LocationList)-1))

SELECT SUM(ABS(t1.[Input] - t2.[Input])) AS [Diff]
FROM #LeftInput t1
INNER JOIN #RightInput t2
	ON t2.[RowNum] = t1.[RowNum]
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- vraag 2
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
; with cte_occurance AS (
	SELECT [Input]
		  ,COUNT(*) AS [Occurance]
	FROM #RightInput
	GROUP BY [Input])
SELECT SUM(t1.[Input] * t2.[Occurance])
FROM #LeftInput t1
LEFT JOIN cte_occurance t2
	ON t2.[Input] = t1.[Input]
