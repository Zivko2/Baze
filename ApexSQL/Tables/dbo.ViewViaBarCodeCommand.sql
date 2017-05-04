SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ViewViaBarCodeCommand] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[BarCode]                 [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ViewName]                [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[GlobalSetting]           [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_ViewViaBarCodeCommand]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ViewViaBarCodeCommand]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ViewViaBarCodeCommand_GlobalSetting]
	FOREIGN KEY ([GlobalSetting]) REFERENCES [dbo].[GlobalSetting] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ViewViaBarCodeCommand]
	CHECK CONSTRAINT [FK_ViewViaBarCodeCommand_GlobalSetting]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_ViewViaBarCodeCommand]
	ON [dbo].[ViewViaBarCodeCommand] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGlobalSetting_ViewViaBarCodeCommand]
	ON [dbo].[ViewViaBarCodeCommand] ([GlobalSetting])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ViewViaBarCodeCommand] SET (LOCK_ESCALATION = TABLE)
GO
