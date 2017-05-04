SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SecuritySystemRole] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		[ObjectType]              [int] NULL,
		[Name]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[IsAdministrative]        [bit] NULL,
		[CanEditModel]            [bit] NULL,
		CONSTRAINT [PK_SecuritySystemRole]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemRole]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SecuritySystemRole_ObjectType]
	FOREIGN KEY ([ObjectType]) REFERENCES [dbo].[XPObjectType] ([OID])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SecuritySystemRole]
	CHECK CONSTRAINT [FK_SecuritySystemRole_ObjectType]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_SecuritySystemRole]
	ON [dbo].[SecuritySystemRole] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iObjectType_SecuritySystemRole]
	ON [dbo].[SecuritySystemRole] ([ObjectType])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemRole] SET (LOCK_ESCALATION = TABLE)
GO
