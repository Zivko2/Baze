SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SaleLineItemType] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[LineNumber]              [int] NULL,
		[Name]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DefaultToItem]           [uniqueidentifier] NULL,
		[IsForReturns]            [bit] NULL,
		[IsForAdjustments]        [bit] NULL,
		[IsForServices]           [bit] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_SaleLineItemType]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SaleLineItemType]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SaleLineItemType_DefaultToItem]
	FOREIGN KEY ([DefaultToItem]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SaleLineItemType]
	CHECK CONSTRAINT [FK_SaleLineItemType_DefaultToItem]

GO
CREATE NONCLUSTERED INDEX [iDefaultToItem_SaleLineItemType]
	ON [dbo].[SaleLineItemType] ([DefaultToItem])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_SaleLineItemType]
	ON [dbo].[SaleLineItemType] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SaleLineItemType] SET (LOCK_ESCALATION = TABLE)
GO
