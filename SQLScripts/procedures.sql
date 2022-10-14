ALTER PROCEDURE [dbo].[generaAgregadoSATv1]
@Start_Date DATE
AS   
  PRINT 'Iniciando agregadoSAT con fecha inicio '  + RTRIM(@Start_Date);
  delete from dbo.consumoSAT_agg where fecha >= @Start_Date;
  insert into consumoSAT_agg
  SELECT [Fecha (Date)] as [fecha]
	  ,[Ubicación de los recursos (SubscriptionGuid)] as [suscriptionID]
      ,[Nombre de la suscripción (SubscriptionName)] as [suscripcion]
      ,[Grupo de recursos (ResourceGroup)] as [grupoRecursos]
      ,[Categoría del medidor (MeterCategory)] as [categoriaProducto]
      ,[Subcategoría del medidor (MeterSubCategory)] as [subCategoriaProducto]
      ,[Producto (Product)] as [producto]
	  ,[Id  de instancia (InstanceId)] as IdInstancia
	  ,JSON_VALUE([Etiquetas (Tags)], '$.Vendor') AS vendor
	  ,JSON_VALUE([Etiquetas (Tags)], '$.ClusterName') AS ClusterName
	  ,JSON_VALUE([Etiquetas (Tags)], '$.DatabricksEnvironment') AS DatabricksEnvironment
	  ,JSON_VALUE([Información adicional (AdditionalInfo)], '$.ServiceType') AS ServiceType
	  ,JSON_VALUE([Información adicional (AdditionalInfo)], '$.ImageType') AS ImageType
	  ,JSON_VALUE([Información adicional (AdditionalInfo)], '$.VCPUs') AS VCPUs
	  ,'Apps & Infra' as CategoriaMicrosoft
      ,SUM([Costo (Cost)]) as [ACR]
	  ,SUM([Cantidad consumida (ConsumedQuantity)]) as cantidadConsumida
  FROM [dbo].[consumoSAT]
  WHERE [Fecha (Date)] >= @Start_Date
  GROUP BY [Fecha (Date)],[Ubicación de los recursos (SubscriptionGuid)],[Nombre de la suscripción (SubscriptionName)],[Grupo de recursos (ResourceGroup)],
  [Categoría del medidor (MeterCategory)],[Subcategoría del medidor (MeterSubCategory)],[Producto (Product)],[Id  de instancia (InstanceId)],
  JSON_VALUE([Etiquetas (Tags)], '$.Vendor'),JSON_VALUE([Etiquetas (Tags)], '$.ClusterName'),JSON_VALUE([Etiquetas (Tags)], '$.DatabricksEnvironment'),
  JSON_VALUE([Información adicional (AdditionalInfo)], '$.ServiceType'),JSON_VALUE([Información adicional (AdditionalInfo)], '$.ImageType')
  ,JSON_VALUE([Información adicional (AdditionalInfo)], '$.VCPUs')
  ORDER BY [Fecha (Date)];