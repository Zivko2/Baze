SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SecuritySystemTypePermissionsObject] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[TargetType]              [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[AllowRead]               [bit] NULL,
		[AllowWrite]              [bit] NULL,
		[AllowCreate]             [bit] NULL,
		[AllowDelete]             [bit] NULL,
		[AllowNavigate]           [bit] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		[ObjectType]              [int] NULL,
		[Owner]                   [uniqueidentifier] NULL,
		CONSTRAINT [PK_SecuritySystemTypePermissionsObject]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemTypePermissionsObject]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SecuritySystemTypePermissionsObject_ObjectType]
	FOREIGN KEY ([ObjectType]) REFERENCES [dbo].[XPObjectType] ([OID])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SecuritySystemTypePermissionsObject]
	CHECK CONSTRAINT [FK_SecuritySystemTypePermissionsObject_ObjectType]

GO
ALTER TABLE [dbo].[SecuritySystemTypePermissionsObject]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SecuritySystemTypePermissionsObject_Owner]
	FOREIGN KEY ([Owner]) REFERENCES [dbo].[SecuritySystemRole] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SecuritySystemTypePermissionsObject]
	CHECK CONSTRAINT [FK_SecuritySystemTypePermissionsObject_Owner]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_SecuritySystemTypePermissionsObject]
	ON [dbo].[SecuritySystemTypePermissionsObject] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iObjectType_SecuritySystemTypePermissionsObject]
	ON [dbo].[SecuritySystemTypePermissionsObject] ([ObjectType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iOwner_SecuritySystemTypePermissionsObject]
	ON [dbo].[SecuritySystemTypePermissionsObject] ([Owner])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemTypePermissionsObject] SET (LOCK_ESCALATION = TABLE)
GO
