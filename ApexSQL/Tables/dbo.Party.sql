SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Party] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Photo]                   [varbinary](max) NULL,
		[Address1]                [uniqueidentifier] NULL,
		[Address2]                [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_Party]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Party]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Party_Address1]
	FOREIGN KEY ([Address1]) REFERENCES [dbo].[Address] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Party]
	CHECK CONSTRAINT [FK_Party_Address1]

GO
ALTER TABLE [dbo].[Party]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Party_Address2]
	FOREIGN KEY ([Address2]) REFERENCES [dbo].[Address] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Party]
	CHECK CONSTRAINT [FK_Party_Address2]

GO
CREATE NONCLUSTERED INDEX [iAddress1_Party]
	ON [dbo].[Party] ([Address1])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iAddress2_Party]
	ON [dbo].[Party] ([Address2])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Party]
	ON [dbo].[Party] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Party] SET (LOCK_ESCALATION = TABLE)
GO
