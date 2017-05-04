SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PhoneNumber] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Number]                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Party]                   [uniqueidentifier] NULL,
		[PhoneType]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_PhoneNumber]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PhoneNumber]
	WITH NOCHECK
	ADD CONSTRAINT [FK_PhoneNumber_Party]
	FOREIGN KEY ([Party]) REFERENCES [dbo].[Party] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[PhoneNumber]
	CHECK CONSTRAINT [FK_PhoneNumber_Party]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_PhoneNumber]
	ON [dbo].[PhoneNumber] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iParty_PhoneNumber]
	ON [dbo].[PhoneNumber] ([Party])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PhoneNumber] SET (LOCK_ESCALATION = TABLE)
GO
