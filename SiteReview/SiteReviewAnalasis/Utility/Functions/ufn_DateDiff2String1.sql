
-- =============================================
-- Author:		Adi Cohn
-- Create date: 01/06/2016
-- Update date: 
-- Description:	MakeString
-- =============================================
CREATE FUNCTION [Utility].[ufn_DateDiff2String1] (@FirstDate DATETIME = NULL, @SecondDate DATETIME = NULL)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @BeginDate DATETIME
	DECLARE @EndDate DATETIME
	DECLARE @TempDate DATETIME
	DECLARE @NumOfYears INT
	DECLARE @NumOfMonths INT
	DECLARE @NumOfDays INT
	DECLARE @DiffDesc VARCHAR(50) = ''

	--Make sure to work with the dates with the correct order
	IF ISNULL(@FirstDate,GETDATE()) < ISNULL(@SecondDate, GETDATE())
		SELECT @BeginDate = CAST(ISNULL(@FirstDate,GETDATE()) AS DATE), @EndDate = CAST(ISNULL(@SecondDate, GETDATE()) AS DATE)
	ELSE
		SELECT @BeginDate = CAST(ISNULL(@SecondDate,GETDATE()) AS DATE), @EndDate = CAST(ISNULL(@FirstDate, GETDATE()) AS DATE)

	--Getting the years part
	SET @NumOfYears = DATEDIFF(YEAR,@BeginDate,@EndDate)
	SET @NumOfYears = IIF(DATEADD(YEAR,@NumOfYears,@BeginDate) <= @EndDate,@NumOfYears,@NumOfYears - 1)

		--Getting the month part
	SELECT @TempDate = DATEADD(YEAR,@NumOfYears,@BeginDate)

	SET @NumOfMonths = DATEDIFF(MONTH,@TempDate,@EndDate)
	SET @NumOfMonths = IIF(DATEADD(MONTH,@NumOfMonths,@TempDate) <= @EndDate, @NumOfMonths, @NumOfMonths - 1)

	--Getting the day part
	SELECT @TempDate = DATEADD(MONTH,@NumOfMonths,@TempDate)

	SET @NumOfDays = DATEDIFF(DAY,@TempDate,@EndDate)

	--Creating the string
	SELECT @DiffDesc = CASE
		WHEN @NumOfYears > 1 THEN CONCAT(@NumOfYears, ' Years ')
		WHEN @NumOfYears = 1 THEN '1 Year '
		ELSE '' END + 
		CASE WHEN @NumOfMonths > 1 THEN CONCAT(@NumOfMonths, ' Months ')
		WHEN @NumOfMonths = 1 THEN '1 Month '
		ELSE '' END +
		CASE WHEN @NumOfDays > 1 THEN CONCAT(' ', @NumOfDays, ' Days')
		WHEN @NumOfDays = 1 THEN '1 Day'
		ELSE '' END

	IF @DiffDesc = ''
		SET @DiffDesc = 'No Differences'

	RETURN @DiffDesc
END

