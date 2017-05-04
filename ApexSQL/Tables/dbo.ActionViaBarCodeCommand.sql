SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ActionViaBarCodeCommand] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[ActionName]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Id]                      [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[BarCode]                 [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[GlobalSetting]           [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_ActionViaBarCodeCommand]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActionViaBarCodeCommand]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ActionViaBarCodeCommand_GlobalSetting]
	FOREIGN KEY ([GlobalSetting]) REFERENCES [dbo].[GlobalSetting] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ActionViaBarCodeCommand]
	CHECK CONSTRAINT [FK_ActionViaBarCodeCommand_GlobalSetting]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_ActionViaBarCodeCommand]
	ON [dbo].[ActionViaBarCodeCommand] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGlobalSetting_ActionViaBarCodeCommand]
	ON [dbo].[ActionViaBarCodeCommand] ([GlobalSetting])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActionViaBarCodeCommand] SET (LOCK_ESCALATION = TABLE)
GO
