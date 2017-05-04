SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[ItemAffinityItems_CustomerPreferredCustomers] (
		[PreferredCustomers]      [uniqueidentifier] NULL,
		[AffinityItems]           [uniqueidentifier] NULL,
		[OID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_ItemAffinityItems_CustomerPreferredCustomers]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemAffinityItems_CustomerPreferredCustomers]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemAffinityItems_CustomerPreferredCustomers_AffinityItems]
	FOREIGN KEY ([AffinityItems]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemAffinityItems_CustomerPreferredCustomers]
	CHECK CONSTRAINT [FK_ItemAffinityItems_CustomerPreferredCustomers_AffinityItems]

GO
ALTER TABLE [dbo].[ItemAffinityItems_CustomerPreferredCustomers]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemAffinityItems_CustomerPreferredCustomers_PreferredCustomers]
	FOREIGN KEY ([PreferredCustomers]) REFERENCES [dbo].[Customer] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemAffinityItems_CustomerPreferredCustomers]
	CHECK CONSTRAINT [FK_ItemAffinityItems_CustomerPreferredCustomers_PreferredCustomers]

GO
CREATE NONCLUSTERED INDEX [iAffinityItems_ItemAffinityItems_CustomerPreferredCustomers]
	ON [dbo].[ItemAffinityItems_CustomerPreferredCustomers] ([AffinityItems])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPreferredCustomers_ItemAffinityItems_CustomerPreferredCustomers]
	ON [dbo].[ItemAffinityItems_CustomerPreferredCustomers] ([PreferredCustomers])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iPreferredCustomersAffinityItems_ItemAffinityItems_CustomerPreferredCustomers]
	ON [dbo].[ItemAffinityItems_CustomerPreferredCustomers] ([PreferredCustomers], [AffinityItems])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemAffinityItems_CustomerPreferredCustomers] SET (LOCK_ESCALATION = TABLE)
GO
