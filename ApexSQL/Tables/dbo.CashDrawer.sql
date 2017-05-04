SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CashDrawer] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[FriendlyName]            [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[MachineName]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DeviceType]              [uniqueidentifier] NULL,
		[DeviceId]                [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_CashDrawer]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CashDrawer]
	WITH NOCHECK
	ADD CONSTRAINT [FK_CashDrawer_DeviceType]
	FOREIGN KEY ([DeviceType]) REFERENCES [dbo].[CashDrawerDeviceType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[CashDrawer]
	CHECK CONSTRAINT [FK_CashDrawer_DeviceType]

GO
CREATE NONCLUSTERED INDEX [iDeviceType_CashDrawer]
	ON [dbo].[CashDrawer] ([DeviceType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_CashDrawer]
	ON [dbo].[CashDrawer] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CashDrawer] SET (LOCK_ESCALATION = TABLE)
GO
