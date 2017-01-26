SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KITS] (
		[Kit_Id]         [int] IDENTITY(1, 1) NOT NULL,
		[Kt_Parte]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Kt_Codigo]      [int] NOT NULL,
		[Ma_NoParte]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Ma_Codigo]      [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KITS]
	ADD
	CONSTRAINT [PK_KITS]
	PRIMARY KEY
	NONCLUSTERED
	([Kt_Parte], [Ma_NoParte])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[KITS]
	ADD
	CONSTRAINT [DF_KITS_Kt_Parte]
	DEFAULT (0) FOR [Kt_Parte]
GO
ALTER TABLE [dbo].[KITS]
	ADD
	CONSTRAINT [DF_KITS_Ma_Codigo]
	DEFAULT (0) FOR [Ma_Codigo]
GO
