CREATE SCHEMA cost;


--- tabla consumo  ---

CREATE TABLE [cost].[consumo{nombre_cliente}](
	[InvoiceSectionName] [nvarchar](150) NULL,
	[AccountName] [nvarchar](150) NULL,
	[AccountOwnerId] [nvarchar](150) NULL,
	[SubscriptionId] [nvarchar](150) NULL,
	[SubscriptionName] [nvarchar](200) NULL,
	[ResourceGroup] [nvarchar](150) NULL,
	[ResourceLocation] [nvarchar](150) NULL,
	[Date] [date] NULL,
	[ProductName] [nvarchar](500) NULL,
	[MeterCategory] [nvarchar](300) NULL,
	[MeterSubCategory] [nvarchar](300) NULL,
	[MeterId] [nvarchar](150) NULL,
	[MeterName] [nvarchar](150) NULL,
	[MeterRegion] [nvarchar](150) NULL,
	[UnitOfMeasure] [nvarchar](200) NULL,
	[Quantity] [real] NULL,
	[EffectivePrice] [real] NULL,
	[CostInBillingCurrency] [real] NULL,
	[CostCenter] [nvarchar](200) NULL,
	[ConsumedService] [nvarchar](150) NULL,
	[ResourceId] [nvarchar](1000) NULL,
	[Tags] [nvarchar](3000) NULL,
	[OfferId] [nvarchar](150) NULL,
	[AdditionalInfo] [nvarchar](3000) NULL,
	[ServiceInfo1] [nvarchar](150) NULL,
	[ServiceInfo2] [nvarchar](150) NULL,
	[ResourceName] [nvarchar](200) NULL,
	[ReservationId] [nvarchar](150) NULL,
	[ReservationName] [nvarchar](150) NULL,
	[UnitPrice] [real] NULL,
	[ProductOrderId] [nvarchar](150) NULL,
	[ProductOrderName] [nvarchar](200) NULL,
	[Term] [nvarchar](150) NULL,
	[PublisherType] [nvarchar](150) NULL,
	[PublisherName] [nvarchar](150) NULL,
	[ChargeType] [nvarchar](150) NULL,
	[Frequency] [nvarchar](150) NULL,
	[PricingModel] [nvarchar](150) NULL,
	[AvailabilityZone] [nvarchar](150) NULL,
	[BillingAccountId] [nvarchar](150) NULL,
	[BillingAccountName] [nvarchar](150) NULL,
	[BillingCurrencyCode] [nvarchar](150) NULL,
	[BillingPeriodStartDate] [nvarchar](150) NULL,
	[BillingPeriodEndDate] [nvarchar](150) NULL,
	[BillingProfileId] [nvarchar](150) NULL,
	[BillingProfileName] [nvarchar](150) NULL,
	[InvoiceSectionId] [nvarchar](150) NULL,
	[IsAzureCreditEligible] [nvarchar](150) NULL,
	[PartNumber] [nvarchar](150) NULL,
	[PayGPrice] [nvarchar](150) NULL,
	[PlanName] [nvarchar](150) NULL,
	[ServiceFamily] [nvarchar](150) NULL,
	[CostAllocationRuleName] [nvarchar](150) NULL,
	[benefitId] [nvarchar](200) NULL,
	[benefitName] [nvarchar](200) NULL
);

--tabla staging--

CREATE TABLE [cost].[{nombre_cliente}Staging](
	[InvoiceSectionName] [nvarchar](150) NULL,
	[AccountName] [nvarchar](150) NULL,
	[AccountOwnerId] [nvarchar](150) NULL,
	[SubscriptionId] [nvarchar](150) NULL,
	[SubscriptionName] [nvarchar](200) NULL,
	[ResourceGroup] [nvarchar](150) NULL,
	[ResourceLocation] [nvarchar](150) NULL,
	[Date] [date] NULL,
	[ProductName] [nvarchar](500) NULL,
	[MeterCategory] [nvarchar](300) NULL,
	[MeterSubCategory] [nvarchar](300) NULL,
	[MeterId] [nvarchar](150) NULL,
	[MeterName] [nvarchar](150) NULL,
	[MeterRegion] [nvarchar](150) NULL,
	[UnitOfMeasure] [nvarchar](200) NULL,
	[Quantity] [real] NULL,
	[EffectivePrice] [real] NULL,
	[CostInBillingCurrency] [real] NULL,
	[CostCenter] [nvarchar](200) NULL,
	[ConsumedService] [nvarchar](150) NULL,
	[ResourceId] [nvarchar](2000) NULL,
	[Tags] [nvarchar](4000) NULL,
	[OfferId] [nvarchar](150) NULL,
	[AdditionalInfo] [nvarchar](4000) NULL,
	[ServiceInfo1] [nvarchar](250) NULL,
	[ServiceInfo2] [nvarchar](250) NULL,
	[ResourceName] [nvarchar](300) NULL,
	[ReservationId] [nvarchar](150) NULL,
	[ReservationName] [nvarchar](150) NULL,
	[UnitPrice] [real] NULL,
	[ProductOrderId] [nvarchar](150) NULL,
	[ProductOrderName] [nvarchar](200) NULL,
	[Term] [nvarchar](150) NULL,
	[PublisherType] [nvarchar](150) NULL,
	[PublisherName] [nvarchar](150) NULL,
	[ChargeType] [nvarchar](150) NULL,
	[Frequency] [nvarchar](150) NULL,
	[PricingModel] [nvarchar](150) NULL,
	[AvailabilityZone] [nvarchar](150) NULL,
	[BillingAccountId] [nvarchar](150) NULL,
	[BillingAccountName] [nvarchar](150) NULL,
	[BillingCurrencyCode] [nvarchar](150) NULL,
	[BillingPeriodStartDate] [nvarchar](150) NULL,
	[BillingPeriodEndDate] [nvarchar](150) NULL,
	[BillingProfileId] [nvarchar](150) NULL,
	[BillingProfileName] [nvarchar](150) NULL,
	[InvoiceSectionId] [nvarchar](150) NULL,
	[IsAzureCreditEligible] [nvarchar](150) NULL,
	[PartNumber] [nvarchar](150) NULL,
	[PayGPrice] [nvarchar](150) NULL,
	[PlanName] [nvarchar](150) NULL,
	[ServiceFamily] [nvarchar](150) NULL,
	[CostAllocationRuleName] [nvarchar](150) NULL,
	[benefitId] [nvarchar](200) NULL,
	[benefitName] [nvarchar](200) NULL
);


-- tabla consumo procesada --

CREATE TABLE [cost].[consumo{nombre_cliente}_agg](
	[fecha] [date] NULL,
	[suscriptionID] [nvarchar](150) NULL,
	[suscripcion] [nvarchar](200) NULL,
	[grupoRecursos] [nvarchar](150) NULL,
	[categoriaProducto] [nvarchar](300) NULL,
	[subCategoriaProducto] [nvarchar](300) NULL,
	[producto] [nvarchar](500) NULL,
	[IdInstancia] [nvarchar](200) NULL,
	[vendor] [nvarchar](4000) NULL,
	[ClusterName] [nvarchar](4000) NULL,
	[DatabricksEnvironment] [nvarchar](4000) NULL,
	[ServiceType] [nvarchar](4000) NULL,
	[ImageType] [nvarchar](4000) NULL,
	[VCPUs] [nvarchar](4000) NULL,
	[CategoriaMicrosoft] [varchar](12) NOT NULL,
	[ACR] [float] NULL,
	[cantidadConsumida] [float] NULL,
	[ChargeType] [nvarchar](150) NULL,
	[Proyecto] [nvarchar](4000) NULL,
	[Ambiente] [nvarchar](4000) NULL
)

-- comparativo mensual historico --

CREATE TABLE [cost].[consumo{nombre_cliente}_comparativo_historico](
	[suscripcion] [nvarchar](200) NULL,
	[categoriaProducto] [nvarchar](300) NULL,
	[ChargeType] [nvarchar](150) NULL,
	[anioMes] [date] NULL,
	[consumoActual] [float] NULL,
	[consumoMesAnterior] [float] NULL,
	[DiferenciaConsumo] [float] NULL,
	[diasRestantesMesActual] [int] NOT NULL
	
)

-- tabla de control utilizada por Azure function ---

CREATE TABLE [dbo].[CostManagementLogMC](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Customer] [varchar](32) NOT NULL,
	[Status] [int] NULL,
	[PeriodName] [varchar](8) NOT NULL,
	[StartDate] [datetime] NULL,
	[URL] [varchar](1024) NOT NULL,
	[Path] [varchar](255) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CostManagementLogMC] ADD  DEFAULT ((1)) FOR [Status]
GO

ALTER TABLE [dbo].[CostManagementLogMC] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
