CREATE FUNCTION Utility.SQL_Signature (@p1 NVARCHAR(MAX), @ParseLength INT = 4000)
RETURNS NVARCHAR(4000)
AS
BEGIN
	DECLARE @pos AS INT, @mode AS CHAR(10), @maxlength AS INT, @p2len AS INT
	DECLARE @p2 AS NCHAR(4000), @currchar AS CHAR(1), @nextchar AS CHAR(1)

	SET @maxlength = LEN(RTRIM(SUBSTRING(@p1,1,4000)));
	SET @maxlength = CASE WHEN @maxlength > @ParseLength
			THEN @ParseLength ELSE @maxlength END
	SET @pos = 1; SET @p2 = ''; SET @p2len = 0; SET @currchar = '';
	SET @nextchar = ''; SET @mode = 'command';

	WHILE (@pos <= @maxlength) BEGIN
		SET @currchar = SUBSTRING(@p1,@pos,1)
		SET @nextchar = SUBSTRING(@p1,@pos+1,1)
		IF @mode = 'command' BEGIN
			SET @p2 = LEFT(@p2,@p2len) + @currchar
			SET @p2len = @p2len + 1
			IF @currchar IN (',','(',' ','=','<','>','!') AND
			 @nextchar BETWEEN '0' AND '9' BEGIN
				SET @mode = 'number'
				SET @p2 = LEFT(@p2,@p2len) + '#'
				SET @p2len = @p2len + 1
				END
			IF @currchar = '''' BEGIN
				SET @mode = 'literal'
				SET @p2 = LEFT(@p2,@p2len) + '#'''
				SET @p2len = @p2len + 2
				END
			END
		ELSE IF @mode = 'number' AND @nextchar IN (',',')',' ','=','<','>','!')
			SET @mode= 'command'
		ELSE IF @mode = 'literal' AND @currchar = ''''
			SET @mode= 'command'

		SET @pos = @pos + 1
	END
	RETURN @p2
END

