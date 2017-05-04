SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[ShippingMethodShippingMethods_CostTypeCostTypes] (
		[CostTypes]               [uniqueidentifier] NULL,
		[ShippingMethods]         [uniqueidentifier] NULL,
		[OID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_ShippingMethodShippingMethods_CostTypeCostTypes]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShippingMethodShippingMethods_CostTypeCostTypes]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ShippingMethodShippingMethods_CostTypeCostTypes_CostTypes]
	FOREIGN KEY ([CostTypes]) REFERENCES [dbo].[CostType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ShippingMethodShippingMethods_CostTypeCostTypes]
	CHECK CONSTRAINT [FK_ShippingMethodShippingMethods_CostTypeCostTypes_CostTypes]

GO
ALTER TABLE [dbo].[ShippingMethodShippingMethods_CostTypeCostTypes]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ShippingMethodShippingMethods_CostTypeCostTypes_ShippingMethods]
	FOREIGN KEY ([ShippingMethods]) REFERENCES [dbo].[ShippingMethod] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ShippingMethodShippingMethods_CostTypeCostTypes]
	CHECK CONSTRAINT [FK_ShippingMethodShippingMethods_CostTypeCostTypes_ShippingMethods]

GO
CREATE NONCLUSTERED INDEX [iCostTypes_ShippingMethodShippingMethods_CostTypeCostTypes]
	ON [dbo].[ShippingMethodShippingMethods_CostTypeCostTypes] ([CostTypes])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iCostTypesShippingMethods_ShippingMethodShippingMethods_CostTypeCostTypes]
	ON [dbo].[ShippingMethodShippingMethods_CostTypeCostTypes] ([CostTypes], [ShippingMethods])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iShippingMethods_ShippingMethodShippingMethods_CostTypeCostTypes]
	ON [dbo].[ShippingMethodShippingMethods_CostTypeCostTypes] ([ShippingMethods])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShippingMethodShippingMethods_CostTypeCostTypes] SET (LOCK_ESCALATION = TABLE)
GO
