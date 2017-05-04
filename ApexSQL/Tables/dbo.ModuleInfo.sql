SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ModuleInfo] (
		[ID]                      [int] IDENTITY(1, 1) NOT FOR REPLICATION NOT NULL,
		[Version]                 [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Name]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[AssemblyFileName]        [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[IsMain]                  [bit] NULL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_ModuleInfo]
		PRIMARY KEY
		CLUSTERED
		([ID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModuleInfo] SET (LOCK_ESCALATION = TABLE)
GO
