SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SecuritySystemMemberPermissionsObject] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Members]                 [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[AllowRead]               [bit] NULL,
		[AllowWrite]              [bit] NULL,
		[Criteria]                [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[Owner]                   [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_SecuritySystemMemberPermissionsObject]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemMemberPermissionsObject]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SecuritySystemMemberPermissionsObject_Owner]
	FOREIGN KEY ([Owner]) REFERENCES [dbo].[SecuritySystemTypePermissionsObject] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SecuritySystemMemberPermissionsObject]
	CHECK CONSTRAINT [FK_SecuritySystemMemberPermissionsObject_Owner]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_SecuritySystemMemberPermissionsObject]
	ON [dbo].[SecuritySystemMemberPermissionsObject] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iOwner_SecuritySystemMemberPermissionsObject]
	ON [dbo].[SecuritySystemMemberPermissionsObject] ([Owner])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemMemberPermissionsObject] SET (LOCK_ESCALATION = TABLE)
GO
