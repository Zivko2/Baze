SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserAlert] (
		[OID]                     [int] IDENTITY(1, 1) NOT FOR REPLICATION NOT NULL,
		[User]                    [uniqueidentifier] NULL,
		[Title]                   [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[Body]                    [nvarchar](256) COLLATE Latin1_General_CI_AS NULL,
		[Tag]                     [nvarchar](256) COLLATE Latin1_General_CI_AS NULL,
		[Duration]                [int] NULL,
		[ResourceImageName]       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Created]                 [datetime] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_UserAlert]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserAlert]
	WITH NOCHECK
	ADD CONSTRAINT [FK_UserAlert_User]
	FOREIGN KEY ([User]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[UserAlert]
	CHECK CONSTRAINT [FK_UserAlert_User]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_UserAlert]
	ON [dbo].[UserAlert] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iUser_UserAlert]
	ON [dbo].[UserAlert] ([User])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserAlert] SET (LOCK_ESCALATION = TABLE)
GO
