SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceComponentType] (
		[Oid]                                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[AlternateIncomeAccount]                [uniqueidentifier] NULL,
		[GenerateAlternateAccountTransfers]     [bit] NULL,
		[LineNumber]                            [int] NULL,
		[IsItemBaseValue]                       [bit] NULL,
		[IsRoundingAdjustment]                  [bit] NULL,
		[PriceAdjustmentVariable]               [money] NULL,
		[Description]                           [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[Category]                              [int] NULL,
		[OptimisticLockField]                   [int] NULL,
		[GCRecord]                              [int] NULL,
		CONSTRAINT [PK_PriceComponentType]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceComponentType]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PriceComponentType_AlternateIncomeAccount]
	FOREIGN KEY ([AlternateIncomeAccount]) REFERENCES [dbo].[GLAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PriceComponentType]
	CHECK CONSTRAINT [FK_PriceComponentType_AlternateIncomeAccount]

GO
CREATE NONCLUSTERED INDEX [iAlternateIncomeAccount_PriceComponentType]
	ON [dbo].[PriceComponentType] ([AlternateIncomeAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_PriceComponentType]
	ON [dbo].[PriceComponentType] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceComponentType] SET (LOCK_ESCALATION = TABLE)
GO
