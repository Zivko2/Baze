SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RateTypeRateTypes_PriceComponentTypePriceComponentTypes] (
		[PriceComponentTypes]     [uniqueidentifier] NULL,
		[RateTypes]               [uniqueidentifier] NULL,
		[OID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_RateTypeRateTypes_PriceComponentTypePriceComponentTypes]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RateTypeRateTypes_PriceComponentTypePriceComponentTypes]
	WITH NOCHECK
	ADD CONSTRAINT [FK_RateTypeRateTypes_PriceComponentTypePriceComponentTypes_PriceComponentTypes]
	FOREIGN KEY ([PriceComponentTypes]) REFERENCES [dbo].[PriceComponentType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[RateTypeRateTypes_PriceComponentTypePriceComponentTypes]
	CHECK CONSTRAINT [FK_RateTypeRateTypes_PriceComponentTypePriceComponentTypes_PriceComponentTypes]

GO
ALTER TABLE [dbo].[RateTypeRateTypes_PriceComponentTypePriceComponentTypes]
	WITH NOCHECK
	ADD CONSTRAINT [FK_RateTypeRateTypes_PriceComponentTypePriceComponentTypes_RateTypes]
	FOREIGN KEY ([RateTypes]) REFERENCES [dbo].[RateType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[RateTypeRateTypes_PriceComponentTypePriceComponentTypes]
	CHECK CONSTRAINT [FK_RateTypeRateTypes_PriceComponentTypePriceComponentTypes_RateTypes]

GO
CREATE NONCLUSTERED INDEX [iPriceComponentTypes_RateTypeRateTypes_PriceComponentTypePriceComponentTypes]
	ON [dbo].[RateTypeRateTypes_PriceComponentTypePriceComponentTypes] ([PriceComponentTypes])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iPriceComponentTypesRateTypes_RateTypeRateTypes_PriceComponentTypePriceComponentTypes]
	ON [dbo].[RateTypeRateTypes_PriceComponentTypePriceComponentTypes] ([PriceComponentTypes], [RateTypes])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iRateTypes_RateTypeRateTypes_PriceComponentTypePriceComponentTypes]
	ON [dbo].[RateTypeRateTypes_PriceComponentTypePriceComponentTypes] ([RateTypes])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[RateTypeRateTypes_PriceComponentTypePriceComponentTypes] SET (LOCK_ESCALATION = TABLE)
GO
