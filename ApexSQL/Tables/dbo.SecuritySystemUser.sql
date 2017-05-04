SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SecuritySystemUser] (
		[Oid]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[StoredPassword]                 [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[ChangePasswordOnFirstLogon]     [bit] NULL,
		[UserName]                       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[IsActive]                       [bit] NULL,
		[OptimisticLockField]            [int] NULL,
		[GCRecord]                       [int] NULL,
		[ObjectType]                     [int] NULL,
		CONSTRAINT [PK_SecuritySystemUser]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemUser]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SecuritySystemUser_ObjectType]
	FOREIGN KEY ([ObjectType]) REFERENCES [dbo].[XPObjectType] ([OID])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SecuritySystemUser]
	CHECK CONSTRAINT [FK_SecuritySystemUser_ObjectType]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_SecuritySystemUser]
	ON [dbo].[SecuritySystemUser] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iObjectType_SecuritySystemUser]
	ON [dbo].[SecuritySystemUser] ([ObjectType])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemUser] SET (LOCK_ESCALATION = TABLE)
GO
