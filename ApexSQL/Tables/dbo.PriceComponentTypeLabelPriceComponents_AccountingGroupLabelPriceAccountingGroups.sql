SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups] (
		[LabelPriceAccountingGroups]     [uniqueidentifier] NULL,
		[LabelPriceComponents]           [uniqueidentifier] NULL,
		[OID]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]            [int] NULL,
		CONSTRAINT [PK_PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups_LabelPriceAccountingGroups]
	FOREIGN KEY ([LabelPriceAccountingGroups]) REFERENCES [dbo].[AccountingGroup] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups]
	CHECK CONSTRAINT [FK_PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups_LabelPriceAccountingGroups]

GO
ALTER TABLE [dbo].[PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups_LabelPriceComponents]
	FOREIGN KEY ([LabelPriceComponents]) REFERENCES [dbo].[PriceComponentType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups]
	CHECK CONSTRAINT [FK_PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups_LabelPriceComponents]

GO
CREATE NONCLUSTERED INDEX [iLabelPriceAccountingGroups_PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups]
	ON [dbo].[PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups] ([LabelPriceAccountingGroups])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iLabelPriceAccountingGroupsLabelPriceComponents_PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups]
	ON [dbo].[PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups] ([LabelPriceAccountingGroups], [LabelPriceComponents])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iLabelPriceComponents_PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups]
	ON [dbo].[PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups] ([LabelPriceComponents])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceComponentTypeLabelPriceComponents_AccountingGroupLabelPriceAccountingGroups] SET (LOCK_ESCALATION = TABLE)
GO
