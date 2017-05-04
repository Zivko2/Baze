SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions] (
		[ChildConversions]        [uniqueidentifier] NULL,
		[ParentConversions]       [uniqueidentifier] NULL,
		[OID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions]
	WITH NOCHECK
	ADD CONSTRAINT [FK_UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions_ChildConversions]
	FOREIGN KEY ([ChildConversions]) REFERENCES [dbo].[UnitOfMeasureConversion] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions]
	CHECK CONSTRAINT [FK_UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions_ChildConversions]

GO
ALTER TABLE [dbo].[UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions]
	WITH NOCHECK
	ADD CONSTRAINT [FK_UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions_ParentConversions]
	FOREIGN KEY ([ParentConversions]) REFERENCES [dbo].[UnitOfMeasureConversion] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions]
	CHECK CONSTRAINT [FK_UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions_ParentConversions]

GO
CREATE NONCLUSTERED INDEX [iChildConversions_UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions]
	ON [dbo].[UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions] ([ChildConversions])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iChildConversionsParentConversions_UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions]
	ON [dbo].[UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions] ([ChildConversions], [ParentConversions])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iParentConversions_UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions]
	ON [dbo].[UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions] ([ParentConversions])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[UnitOfMeasureConversionParentConversions_UnitOfMeasureConversionChildConversions] SET (LOCK_ESCALATION = TABLE)
GO
