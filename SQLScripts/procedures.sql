CREATE PROCEDURE [cost].[{nombre_cliente}_procesamiento] @period int
AS   
  --- Variables ---
  DECLARE @ayer AS DATE;
  DECLARE @diasRestantesMesActual AS INT;
  DECLARE @datePeriod DATETIME;
  DECLARE @currentDate DATETIME;
  --DECLARE @period INT;
  --SET @period = 0;
  SET @currentDate = GETDATE();
  SET @ayer = DATEADD(day, -1, (getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time'));
  SET @diasRestantesMesActual = DATEDIFF(DAY, @ayer,EOMONTH(@ayer));
  SET @datePeriod = DATEADD(month, @period, @currentDate);
  IF @period >= -3 and @period <= 0
	BEGIN
	  --borrar datos del dia actual ( es informacion incompleta) ---
	  delete from [cost].[consumo{nombre_cliente}] where YEAR([Date]) = YEAR(@currentDate) and MONTH([Date]) = MONTH(@currentDate) and DAY([Date]) = DAY(@currentDate);
	  delete from [cost].[consumo{nombre_cliente}_agg] where YEAR([fecha]) = YEAR(@datePeriod) and MONTH([fecha]) = MONTH(@datePeriod);

	  -- con tags json valido --

	 insert into [cost].consumo{nombre_cliente}_agg
	  SELECT [Date] as [fecha]
		  ,[SubscriptionId] as [suscriptionID]
		  ,[SubscriptionName] as [suscripcion]
		  ,[ResourceGroup] as [grupoRecursos]
		  ,[MeterCategory] as [categoriaProducto]
		  ,[MeterSubCategory] as [subCategoriaProducto]
		  ,[ProductName] as [producto]
		  ,[ResourceName] as IdInstancia
		  ,JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.Vendor') AS vendor
		  ,JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.ClusterName') AS ClusterName
		  ,JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.DatabricksEnvironment') AS DatabricksEnvironment
		  ,JSON_VALUE([AdditionalInfo], '$.ServiceType') AS ServiceType
		  ,JSON_VALUE([AdditionalInfo], '$.ImageType') AS ImageType
		  ,JSON_VALUE([AdditionalInfo], '$.VCPUs') AS VCPUs
		  ,'Apps & Infra' as CategoriaMicrosoft
		  ,SUM([CostInBillingCurrency]) as [ACR]
		  ,SUM([Quantity]) as cantidadConsumida
		  ,[ChargeType] as ChargeType
		  ,JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.application') AS Proyecto
		  ,JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.environment') AS Ambiente
	  --INTO [cost].consumo{nombre_cliente}_agg
	  FROM [cost].[consumo{nombre_cliente}]
	  WHERE ISJSON(CONCAT('{ ', [Tags], ' }')) > 0 and YEAR([Date]) = YEAR(@datePeriod) and MONTH([Date]) = MONTH(@datePeriod)
	  --WHERE [Fecha (Date)] >= '2022-06-01 00:00:00.000'
	  GROUP BY [Date] ,[SubscriptionId],[SubscriptionName],[ResourceGroup],
	  [MeterCategory],[MeterSubCategory],[ProductName],[ResourceName],[ChargeType],
	  JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.Vendor'),JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.ClusterName'),JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.DatabricksEnvironment'),
	  JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.application'),JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.environment'),
	  JSON_VALUE([AdditionalInfo], '$.ServiceType'),JSON_VALUE([AdditionalInfo], '$.ImageType')
	  ,JSON_VALUE([AdditionalInfo], '$.VCPUs')
	  ORDER BY [Date];

	  -- sin json en tags valido --
	 insert into [cost].consumo{nombre_cliente}_agg
	  SELECT [Date] as [fecha]
		  ,[SubscriptionId] as [suscriptionID]
		  ,[SubscriptionName] as [suscripcion]
		  ,[ResourceGroup] as [grupoRecursos]
		  ,[MeterCategory] as [categoriaProducto]
		  ,[MeterSubCategory] as [subCategoriaProducto]
		  ,[ProductName] as [producto]
		  ,[ResourceName] as IdInstancia
		  ,'' AS vendor
		  ,'' AS ClusterName
		  ,'' AS DatabricksEnvironment
		  ,'' AS ServiceType
		  ,'' AS ImageType
		  ,'' AS VCPUs
		  ,'Apps & Infra' as CategoriaMicrosoft
		  ,SUM([CostInBillingCurrency]) as [ACR]
		  ,SUM([Quantity]) as cantidadConsumida
		  ,[ChargeType] as ChargeType
		  ,'' AS Proyecto
		  ,'' AS Ambiente
	  --INTO [cost].consumo{nombre_cliente}_agg
	  FROM [cost].[consumo{nombre_cliente}]
	  WHERE ISJSON(CONCAT('{ ', [Tags], ' }')) = 0 and YEAR([Date]) = YEAR(@datePeriod) and MONTH([Date]) = MONTH(@datePeriod)
	  --WHERE [Fecha (Date)] >= '2022-06-01 00:00:00.000'
	  GROUP BY [Date] ,[SubscriptionId],[SubscriptionName],[ResourceGroup],
	  [MeterCategory],[MeterSubCategory],[ProductName],[ResourceName],[ChargeType]
	  ORDER BY [Date];

	  -- Actualizando categorias Azure Data Services ---

		UPDATE [cost].[consumo{nombre_cliente}_agg]
	  set CategoriaMicrosoft = 'ADS' 
  		WHERE [categoriaProducto] IN('Azure Analysis Services','Azure Cognitive Search',
	'Azure Cosmos DB','Azure Data Factory v2','Azure Database for Mysql',
	'Azure Database for PostgreSQL','Azure Databricks','Azure Purview',
	'Azure Search','Azure Synapse Analytics','Cognitive Services ',
	'Data Lake Store','Event Hubs','HDInsight','IoTHub','Log analytics','Machine Learning Service',
	'Machine Learning Studio','Power BI Embedded','Redis Cache','SQL Advanced Thread Protection',
	'SQL Data Warehouse','SQL Database','Stream Analytics');

	  UPDATE [cost].[consumo{nombre_cliente}_agg]
	  set CategoriaMicrosoft = 'ADS' 
  		WHERE [subCategoriaProducto] IN ('SQL Server Enterprise','SQL Server Standard');

	  UPDATE [cost].[consumo{nombre_cliente}_agg]
	  set CategoriaMicrosoft = 'ADS' 
  		WHERE [subCategoriaProducto] IN ('Azure Data Lake Storage Gen2 Hierarchical Namespace');


		-- comparativo mes a mes ---
		drop table cost.consumo{nombre_cliente}_comparativo_historico;


		SELECT [suscripcion],[categoriaProducto],[ChargeType], datefromparts(YEAR([fecha]),MONTH([fecha]),1) as anioMes, SUM([ACR]) AS consumoActual,   
			   LAG(SUM([ACR]), 1,0) OVER (PARTITION BY [suscripcion],[categoriaProducto],[ChargeType] ORDER BY datefromparts(YEAR([fecha]),MONTH([fecha]),1)) AS consumoMesAnterior ,
			   SUM([ACR]) - LAG(SUM([ACR]),1,0) OVER (PARTITION BY [suscripcion],[categoriaProducto],[ChargeType] ORDER BY  datefromparts(YEAR([fecha]),MONTH([fecha]),1)) AS DiferenciaConsumo,
			   0 as diasRestantesMesActual
		INTO cost.consumo{nombre_cliente}_comparativo_historico
		FROM [cost].consumo{nombre_cliente}_agg
		WHERE [fecha] >=  DATEADD(YEAR, -2, GETDATE())
		GROUP by [suscripcion],[categoriaProducto],[ChargeType],datefromparts(YEAR([fecha]),MONTH([fecha]),1)
		ORDER by 3;

		update cost.consumo{nombre_cliente}_comparativo_historico
		set consumoActual = consumoActual + ((consumoActual / DAY(@ayer)) * @diasRestantesMesActual)
		WHERE anioMes = datefromparts(YEAR(@ayer),MONTH(@ayer),1);

		update cost.consumo{nombre_cliente}_comparativo_historico
		set DiferenciaConsumo = consumoActual - consumoMesAnterior
		WHERE anioMes = datefromparts(YEAR(@ayer),MONTH(@ayer),1);

		update cost.consumo{nombre_cliente}_comparativo_historico
		set diasRestantesMesActual =  @diasRestantesMesActual;
    END
  ELSE
  BEGIN
		PRINT 'Invalid period - Should be between -3 and 0';
  END
GO


---- Procedure para borrar datos del periodo seleccionado ----

CREATE PROCEDURE [cost].[limpiaPeriodoGenerico] 
@period int,
@TableName NVARCHAR(128) 
AS 
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
        --delete from @TableName where YEAR([Fecha (Date)]) = YEAR(@datePeriod) and MONTH([Fecha (Date)]) = MONTH(@datePeriod);
		EXECUTE sp_executesql @Sql;
		--PRINT @Sql;
    END
  ELSE
  BEGIN
		PRINT 'Invalid period - Should be between -3 and 0';
  END





/****** Object:  StoredProcedure [dbo].[USP_CheckDatabase]    Script Date: 11/24/2022 1:40:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_CheckDatabase]
AS
BEGIN
    SET NOCOUNT ON
    SELECT 1
END
GO

/****** Object:  StoredProcedure [dbo].[USP_FinishCostManagementLogMC]    Script Date: 11/24/2022 1:40:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_FinishCostManagementLogMC]
@ID int
AS
BEGIN
UPDATE [dbo].CostManagementLogMC SET Status = 3 WHERE ID = @ID
END
GO

/****** Object:  StoredProcedure [dbo].[USP_GetCostManagementLogMC]    Script Date: 11/24/2022 1:40:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
END
GO

/****** Object:  StoredProcedure [dbo].[USP_InsertCostManagementLogMC]    Script Date: 11/24/2022 1:40:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_InsertCostManagementLogMC]
	@PeriodName varchar(8),
	@Customer varchar(32),
	@URL varchar(1024)
	AS
	BEGIN
		INSERT INTO [dbo].CostManagementLogMC (Customer,PeriodName, URL) VALUES (@Customer,@PeriodName,@URL);
		SELECT SCOPE_IDENTITY()
	END
GO

/****** Object:  StoredProcedure [dbo].[USP_UpdateCostManagementLogMC]    Script Date: 11/24/2022 1:40:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateCostManagementLogMC]
	@ID bigint,
	@Status int,
	@URL varchar(1024),
	@Path varchar(255)
	AS
		BEGIN
			UPDATE [dbo].CostManagementLogMC SET Status = @Status, URL = @URL,Path= @Path WHERE ID = @ID
		END
GO


