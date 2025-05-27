---- Procedure para borrar datos del periodo seleccionado ----

CREATE PROCEDURE [cost].[limpiaPeriodoGenericov2] 
@period int,
@TableName NVARCHAR(128) 
AS 
  BEGIN 
	DECLARE @currentDate DATETIME
	SET @currentDate = GETDATE()
	DECLARE @Sql NVARCHAR(MAX);
	DECLARE @datePeriod DATETIME;
	DECLARE @yearPeriod NVARCHAR(100);
	DECLARE @monthPeriod NVARCHAR(100);

	SET @datePeriod = DATEADD(month, @period, @currentDate);
	SET @yearPeriod = CAST(YEAR(@datePeriod) as varchar(100));
	SET @monthPeriod = CAST(MONTH(@datePeriod) as varchar(100));
	
	SET @Sql = N'DELETE FROM cost.' + @TableName + N' WHERE YEAR([Date]) = '+ @yearPeriod + N' and MONTH([Date]) = '+ @monthPeriod;

	IF @period >= -3 and @period <= 0
		BEGIN
			EXECUTE sp_executesql @Sql;
		END
	ELSE
	BEGIN
			PRINT 'Invalid period - Should be between -3 and 0';
	END
  END;
GO


--- stored procedures utilizados para las tablas de control ---

CREATE PROCEDURE [dbo].[USP_CheckDatabase]
AS
BEGIN
    SET NOCOUNT ON
    SELECT 1
END;
GO


CREATE PROCEDURE [dbo].[USP_FinishCostManagementLogMC]
@ID int
AS
BEGIN
UPDATE [dbo].CostManagementLogMC SET Status = 3 WHERE ID = @ID
END;
GO


CREATE PROCEDURE [dbo].[USP_GetCostManagementLogMC]
@Customer varchar(32)
AS
BEGIN
	SELECT  Top 1 
		[ID]
		,[Customer]
		,[Status]
		,[PeriodName]
		,[URL]
		,[Path]
	FROM [dbo].[CostManagementLogMC]
	WHERE [Customer] = @Customer
	ORDER BY ID DESC
END;
GO


CREATE PROCEDURE [dbo].[USP_InsertCostManagementLogMC]
	@PeriodName varchar(8),
	@Customer varchar(32),
	@URL varchar(1024)
	AS
	BEGIN
		INSERT INTO [dbo].CostManagementLogMC (Customer,PeriodName, URL) VALUES (@Customer,@PeriodName,@URL);
		SELECT SCOPE_IDENTITY()
	END;
GO


CREATE PROCEDURE [dbo].[USP_UpdateCostManagementLogMC]
	@ID bigint,
	@Status int,
	@URL varchar(1024),
	@Path varchar(255)
	AS
		BEGIN
			UPDATE [dbo].CostManagementLogMC SET Status = @Status, URL = @URL,Path= @Path WHERE ID = @ID
		END;
GO


