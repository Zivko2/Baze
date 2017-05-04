SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UnitOfMeasureUnitsOfMeasure_ItemItems] (
		[Items]                   [uniqueidentifier] NULL,
		[UnitsOfMeasure]          [uniqueidentifier] NULL,
		[OID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_UnitOfMeasureUnitsOfMeasure_ItemItems]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UnitOfMeasureUnitsOfMeasure_ItemItems]
	WITH NOCHECK
	ADD CONSTRAINT [FK_UnitOfMeasureUnitsOfMeasure_ItemItems_Items]
	FOREIGN KEY ([Items]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[UnitOfMeasureUnitsOfMeasure_ItemItems]
	CHECK CONSTRAINT [FK_UnitOfMeasureUnitsOfMeasure_ItemItems_Items]

GO
ALTER TABLE [dbo].[UnitOfMeasureUnitsOfMeasure_ItemItems]
	WITH NOCHECK
	ADD CONSTRAINT [FK_UnitOfMeasureUnitsOfMeasure_ItemItems_UnitsOfMeasure]
	FOREIGN KEY ([UnitsOfMeasure]) REFERENCES [dbo].[UnitOfMeasure] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[UnitOfMeasureUnitsOfMeasure_ItemItems]
	CHECK CONSTRAINT [FK_UnitOfMeasureUnitsOfMeasure_ItemItems_UnitsOfMeasure]

GO
CREATE NONCLUSTERED INDEX [iItems_UnitOfMeasureUnitsOfMeasure_ItemItems]
	ON [dbo].[UnitOfMeasureUnitsOfMeasure_ItemItems] ([Items])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iItemsUnitsOfMeasure_UnitOfMeasureUnitsOfMeasure_ItemItems]
	ON [dbo].[UnitOfMeasureUnitsOfMeasure_ItemItems] ([Items], [UnitsOfMeasure])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iUnitsOfMeasure_UnitOfMeasureUnitsOfMeasure_ItemItems]
	ON [dbo].[UnitOfMeasureUnitsOfMeasure_ItemItems] ([UnitsOfMeasure])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[UnitOfMeasureUnitsOfMeasure_ItemItems] SET (LOCK_ESCALATION = TABLE)
GO
