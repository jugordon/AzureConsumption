CREATE PROCEDURE [cost].[costos_procesamiento] @period int
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
	  -- borrar datos del periodo actual --
	  delete from [cost].[consumoAzure] where YEAR([Date]) = YEAR(@currentDate) and MONTH([Date]) = MONTH(@currentDate) and DAY([Date]) = DAY(@currentDate);
	  delete from [cost].[consumoAzure_agg] where YEAR([fecha]) = YEAR(@datePeriod) and MONTH([fecha]) = MONTH(@datePeriod);

	  -- con registros que tienen un json valido en el campo Tags --
	 insert into [cost].consumoAzure_agg
	  SELECT [Date] as [fecha]
		  ,[SubscriptionId] as [suscriptionID]
		  ,[SubscriptionName] as [suscripcion]
		  ,[ResourceLocation] as [region]
		  ,[UnitOfMeasure] as [UnidadDeMedida]
		  ,[ResourceGroup] as [grupoRecursos]
		  ,[MeterCategory] as [categoriaProducto]
		  ,[MeterSubCategory] as [subCategoriaProducto]
		  ,[ProductName] as [producto]
		  ,[ResourceName] as IdInstancia
		  ,JSON_VALUE([AdditionalInfo], '$.ServiceType') AS ServiceType
		  ,JSON_VALUE([AdditionalInfo], '$.ImageType') AS ImageType
		  ,JSON_VALUE([AdditionalInfo], '$.VCPUs') AS VCPUs
		  ,SUM([CostInBillingCurrency]) as [ACR]
		  ,SUM([Quantity]) as cantidadConsumida
		  ,[ChargeType] as ChargeType
			--- extraccion de etiquetas , modificar segun sea necesario
		  ,JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.Proyecto') AS Proyecto
		  ,JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.Ambiente') AS Ambiente
		  ,JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.Propietario') AS Propietario
	  FROM [cost].[consumoAzure]
	  WHERE ISJSON(CONCAT('{ ', [Tags], ' }')) > 0 
	  and YEAR([Date]) = YEAR(@datePeriod) and MONTH([Date]) = MONTH(@datePeriod)
	  GROUP BY [Date] ,[SubscriptionId],[SubscriptionName],[ResourceLocation],[UnitOfMeasure],[ResourceGroup],
	  [MeterCategory],[MeterSubCategory],[ProductName],[ResourceName],[ChargeType],
	  JSON_VALUE([AdditionalInfo], '$.ServiceType'),JSON_VALUE([AdditionalInfo], '$.ImageType'),
	  JSON_VALUE([AdditionalInfo], '$.VCPUs'),
	  --- extraccion de etiquetas , modificar segun sea necesario
	  JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.Proyecto'),JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.Ambiente'),
	  JSON_VALUE(CONCAT('{', [Tags], ' }'), '$.Propietario')
	  ORDER BY [Date];

	  -- registros con tags no validos (posibles json malformados) --
	 insert into [cost].consumoAzure_agg
	  SELECT [Date] as [fecha]
		  ,[SubscriptionId] as [suscriptionID]
		  ,[SubscriptionName] as [suscripcion]
		  ,[ResourceLocation] as [region]
		  ,[UnitOfMeasure] as [UnidadDeMedida]
		  ,[ResourceGroup] as [grupoRecursos]
		  ,[MeterCategory] as [categoriaProducto]
		  ,[MeterSubCategory] as [subCategoriaProducto]
		  ,[ProductName] as [producto]
		  ,[ResourceName] as IdInstancia
		  ,'' AS ServiceType
		  ,'' AS ImageType
		  ,'' AS VCPUs
		  ,SUM([CostInBillingCurrency]) as [ACR]
		  ,SUM([Quantity]) as cantidadConsumida
		  ,[ChargeType] as ChargeType
		  ,'' AS Proyecto
		  ,'' AS Ambiente
		  ,'' AS Propietario  
	  FROM [cost].[consumoAzure]
	  WHERE ISJSON(CONCAT('{ ', [Tags], ' }')) = 0 
	  and YEAR([Date]) = YEAR(@datePeriod) and MONTH([Date]) = MONTH(@datePeriod)
	  GROUP BY [Date] ,[SubscriptionId],[SubscriptionName],[ResourceLocation],[UnitOfMeasure],[ResourceGroup],
	  [MeterCategory],[MeterSubCategory],[ProductName],[ResourceName],[ChargeType]
	  ORDER BY [Date];

		-- tabla de comparativo mes a mes, se borra y se vuelve a generar en cada ejecucion --
		drop table cost.consumoAzure_comparativo_historico;

		SELECT [suscripcion],[categoriaProducto],[ChargeType],grupoRecursos, datefromparts(YEAR([fecha]),MONTH([fecha]),1) as anioMes, SUM([ACR]) AS consumoActual,   
			   LAG(SUM([ACR]), 1,0) OVER (PARTITION BY [suscripcion],[categoriaProducto],[ChargeType],grupoRecursos ORDER BY datefromparts(YEAR([fecha]),MONTH([fecha]),1)) AS consumoMesAnterior ,
			   SUM([ACR]) - LAG(SUM([ACR]),1,0) OVER (PARTITION BY [suscripcion],[categoriaProducto],[ChargeType],grupoRecursos ORDER BY  datefromparts(YEAR([fecha]),MONTH([fecha]),1)) AS DiferenciaConsumo,
			   0 as diasRestantesMesActual
		INTO cost.consumoAzure_comparativo_historico
		FROM [cost].consumoAzure_agg
		WHERE [fecha] >=  DATEADD(YEAR, -2, GETDATE()) and [ChargeType] IN ('Usage')
		GROUP by [suscripcion],[categoriaProducto],[ChargeType],[grupoRecursos],datefromparts(YEAR([fecha]),MONTH([fecha]),1)
		ORDER by 3;

		update cost.consumoAzure_comparativo_historico
		set consumoActual = consumoActual + ((consumoActual / DAY(@ayer)) * @diasRestantesMesActual)
		WHERE anioMes = datefromparts(YEAR(@ayer),MONTH(@ayer),1);

		update cost.consumoAzure_comparativo_historico
		set DiferenciaConsumo = consumoActual - consumoMesAnterior
		WHERE anioMes = datefromparts(YEAR(@ayer),MONTH(@ayer),1);

		update cost.consumoAzure_comparativo_historico
		set diasRestantesMesActual =  @diasRestantesMesActual;

		--- tabla dedicada al analisis de almacenamiento, se borra y se genera en cada ejecucion ---
		drop table cost.consumoAzure_agg_storage;

		select datefromparts(YEAR(t1.[fecha] ),MONTH(t1.[fecha] ),1) as anioMes,t1.IdInstancia,t1.[subCategoriaProducto] as [subCategoriaProducto],
		t1.[suscriptionID] as [suscriptionID],t1.[suscripcion] as suscriptionName,
		t1.[grupoRecursos] as grupoRecursos,t1.[UnidadDeMedida] as unidadMedida,t1.Proyecto as proyecto,
		SUM(t1.[ACR]) as ACR, SUM(t1.[cantidadConsumida]) as cantidadConsumida,0 as unidadMedidaNumerica, 0.0 as cantidadAlmacenada
		into cost.consumoAzure_agg_storage
		from [cost].consumoAzure_agg t1
		Where [categoriaProducto] = 'Storage' and [producto] Like '%Data Stored%'
		GROUP BY datefromparts(YEAR(t1.[fecha] ),MONTH(t1.[fecha] ),1),t1.IdInstancia,t1.[subCategoriaProducto],t1.[suscriptionID],
		t1.[suscripcion] ,t1.[grupoRecursos],t1.[UnidadDeMedida],t1.Proyecto;

        
		ALTER TABLE cost.consumoAzure_agg_storage		
		ALTER COLUMN cantidadAlmacenada float;

		
		update cost.consumoAzure_agg_storage
		set unidadMedidaNumerica = dbo.udf_GetNumeric(unidadMedida);

		update cost.consumoAzure_agg_storage
		set cantidadAlmacenada = cantidadConsumida / (unidadMedidaNumerica + 0.0)
		where cantidadConsumida > 0 and unidadMedida LIKE '%GB%';

		update cost.consumoAzure_agg_storage
		set cantidadAlmacenada = (cantidadConsumida * 1024) / (unidadMedidaNumerica + 0.0)
		where cantidadConsumida > 0 and unidadMedida LIKE '%TB%';


    END
  ELSE
  BEGIN
		PRINT 'Invalid period - Should be between -3 and 0';
  END
GO

