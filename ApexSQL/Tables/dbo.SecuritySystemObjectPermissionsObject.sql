SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SecuritySystemObjectPermissionsObject] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Criteria]                [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[AllowRead]               [bit] NULL,
		[AllowWrite]              [bit] NULL,
		[AllowDelete]             [bit] NULL,
		[AllowNavigate]           [bit] NULL,
		[Owner]                   [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_SecuritySystemObjectPermissionsObject]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemObjectPermissionsObject]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SecuritySystemObjectPermissionsObject_Owner]
	FOREIGN KEY ([Owner]) REFERENCES [dbo].[SecuritySystemTypePermissionsObject] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SecuritySystemObjectPermissionsObject]
	CHECK CONSTRAINT [FK_SecuritySystemObjectPermissionsObject_Owner]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_SecuritySystemObjectPermissionsObject]
	ON [dbo].[SecuritySystemObjectPermissionsObject] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iOwner_SecuritySystemObjectPermissionsObject]
	ON [dbo].[SecuritySystemObjectPermissionsObject] ([Owner])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemObjectPermissionsObject] SET (LOCK_ESCALATION = TABLE)
GO
