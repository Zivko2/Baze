SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MessageEntry] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[EntityId]                [uniqueidentifier] NULL,
		[MessageDate]             [datetime] NULL,
		[Message]                 [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[User]                    [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_MessageEntry]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageEntry]
	WITH NOCHECK
	ADD CONSTRAINT [FK_MessageEntry_User]
	FOREIGN KEY ([User]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[MessageEntry]
	CHECK CONSTRAINT [FK_MessageEntry_User]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_MessageEntry]
	ON [dbo].[MessageEntry] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iUser_MessageEntry]
	ON [dbo].[MessageEntry] ([User])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageEntry] SET (LOCK_ESCALATION = TABLE)
GO
