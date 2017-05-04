SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AuditedObjectWeakReferencevv] (
		[Oid]             [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[GuidId]          [uniqueidentifier] NULL,
		[IntId]           [int] NULL,
		[DisplayName]     [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
		CONSTRAINT [PK_AuditedObjectWeakReference]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditedObjectWeakReferencevv]
	WITH NOCHECK
	ADD CONSTRAINT [FK_AuditedObjectWeakReference_Oid]
	FOREIGN KEY ([Oid]) REFERENCES [dbo].[XPWeakReference] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[AuditedObjectWeakReferencevv]
	CHECK CONSTRAINT [FK_AuditedObjectWeakReference_Oid]

GO
ALTER TABLE [dbo].[AuditedObjectWeakReferencevv] SET (LOCK_ESCALATION = TABLE)
GO
