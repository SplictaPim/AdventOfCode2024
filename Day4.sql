DROP TABLE IF EXISTS [input2024].[Day4]
DROP TABLE IF EXISTS [dbo].[FoundWords]

DECLARE @BulkColumn VARCHAR(max)
DECLARE @CharPosition int = 1
DECLARE @MaxCharLength int
DECLARE @RowPosition int
DECLARE @MaxRowPosition int 

CREATE TABLE [input2024].[Day4] (
[RowId] int IDENTITY(1,1) NOT NULL,
[Input] varchar(255) NULL)


CREATE TABLE [dbo].[FoundWords] (
[Word] nvarchar(4) NOT NULL,
[Order] [int] NULL)
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Read lines into table
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT @BulkColumn = replace(BulkColumn, char(10), '~')
FROM OPENROWSET(BULK 'C:\Users\pim\OneDrive\Documenten\Training\Advent of Code\2024\Input\Day4.txt', SINGLE_CLOB) MyFile

INSERT INTO [input2024].[Day4] ([Input])
SELECT REPLACE([value], char(13), '')
FROM string_split(@BulkColumn, '~')

SET @MaxCharLength = (select max(len([Input])) from [input2024].[Day4])
SET @MaxRowPosition = (select max([RowId]) from [input2024].[Day4])
SET @CharPosition = 1
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Puzzel 1 
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
WHILE @CharPosition <= @MaxCharLength
BEGIN
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--RIGHT and LEFT => test = 5
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
	INSERT INTO [dbo].[FoundWords] ([Word], [Order])
	SELECT [Word], 1
	FROM (
		SELECT SUBSTRING([Input], @CharPosition, 4) AS [Word]
		FROM [input2024].[Day4]
		) AS A
	WHERE A.[Word] IN ('XMAS', 'SAMX')
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
	SET @RowPosition = 1

	WHILE @RowPosition <= @MaxRowPosition
	BEGIN
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Up and Down => test = 3
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
		INSERT INTO [dbo].[FoundWords] ([Word], [Order])
		SELECT [Word], 2
		FROM (
			SELECT CONCAT
					(SUBSTRING(t1.[Input], @CharPosition, 1)
					,(select SUBSTRING([Input], @CharPosition, 1) from [input2024].[Day4] where RowId=@RowPosition+1) 
					,(select SUBSTRING([Input], @CharPosition, 1) from [input2024].[Day4] where RowId=@RowPosition+2) 
					,(select SUBSTRING([Input], @CharPosition, 1) from [input2024].[Day4] where RowId=@RowPosition+3) 
					) AS [Word]
			FROM [input2024].[Day4] t1
			WHERE t1.[RowId] = @RowPosition) AS B
		WHERE B.[Word] IN ('XMAS', 'SAMX')
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Diagonal Up/Left and Down/Right
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
		INSERT INTO [dbo].[FoundWords] ([Word], [Order])
		SELECT [Word], 3
		FROM (
			SELECT CONCAT
					(SUBSTRING(t1.[Input], @CharPosition, 1)
					,(select SUBSTRING([Input], @CharPosition+1, 1) from [input2024].[Day4] where RowId=@RowPosition+1) 
					,(select SUBSTRING([Input], @CharPosition+2, 1) from [input2024].[Day4] where RowId=@RowPosition+2) 
					,(select SUBSTRING([Input], @CharPosition+3, 1) from [input2024].[Day4] where RowId=@RowPosition+3) 
					) AS [Word]
			FROM [input2024].[Day4] t1
			WHERE t1.[RowId] = @RowPosition) AS B
		WHERE B.[Word] IN ('XMAS', 'SAMX')
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Diagonal Up/Right and Down/Left
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
		INSERT INTO [dbo].[FoundWords] ([Word], [Order])
		SELECT [Word], 4
		FROM (
			SELECT CONCAT
					(SUBSTRING(t1.[Input], @CharPosition, 1)
					,(select SUBSTRING([Input], @CharPosition-1, 1) from [input2024].[Day4] where RowId=@RowPosition+1) 
					,(select SUBSTRING([Input], @CharPosition-2, 1) from [input2024].[Day4] where RowId=@RowPosition+2) 
					,(select SUBSTRING([Input], @CharPosition-3, 1) from [input2024].[Day4] where RowId=@RowPosition+3) 
					) AS [Word]
			FROM [input2024].[Day4] t1
			WHERE t1.[RowId] = @RowPosition) AS B
		WHERE B.[Word] IN ('XMAS', 'SAMX')
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
		SET @RowPosition += 1

	END 
	SET @CharPosition += 1
END
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Antwoord vraag 1: 2571
SELECT COUNT(*)
FROM [dbo].[FoundWords]
WHERE [Order] <= 4
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Puzzel 2
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
SET @CharPosition = 1

WHILE @CharPosition <= @MaxCharLength
BEGIN
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
	SET @RowPosition = 1

	WHILE @RowPosition <= @MaxRowPosition
	BEGIN
		IF (select SUBSTRING([Input], @CharPosition, 1) from [input2024].[Day4] where [RowId] = @RowPosition) = 'A'
		BEGIN 
			INSERT INTO [dbo].[FoundWords] ([Word], [Order])
			SELECT [Word], 5
			FROM (
				SELECT DISTINCT CONCAT(
				--Linksboven
					(select SUBSTRING([Input], @CharPosition-1, 1) from [input2024].[Day4] where RowId=@RowPosition-1)
				--Rechtsboven
					,(select SUBSTRING([Input], @CharPosition+1, 1) from [input2024].[Day4] where RowId=@RowPosition-1)
				--Linksonder
					,(select SUBSTRING([Input], @CharPosition-1, 1) from [input2024].[Day4] where RowId=@RowPosition+1)
				--Rechtsonder
					,(select SUBSTRING([Input], @CharPosition+1, 1) from [input2024].[Day4] where RowId=@RowPosition+1)
					) AS [Word]
				FROM [input2024].[Day4]
				) AS C
			WHERE C.[Word] IN ('SSMM', 'SMSM', 'MMSS', 'MSMS')
		
		END
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
		SET @RowPosition += 1

	END 
	SET @CharPosition += 1
END
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Antwoord vraag 1: 2571
SELECT COUNT(*)
FROM [dbo].[FoundWords]
WHERE [Order] = 5
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

