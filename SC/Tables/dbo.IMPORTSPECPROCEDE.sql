SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IMPORTSPECPROCEDE] (
		[IMS_CODIGO]                [int] NOT NULL,
		[IMP_PROCEDIMIENTO]         [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IMP_ORDER]                 [smallint] NOT NULL,
		[IMP_NOUSAPROCDINAMICO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPORTSPECPROCEDE]
	ADD
	CONSTRAINT [DF_IMPORTSPECPROCEDE_IMP_NOUSAPROCDINAMICO]
	DEFAULT ('N') FOR [IMP_NOUSAPROCDINAMICO]
GO
ALTER TABLE [dbo].[IMPORTSPECPROCEDE]
	ADD
	CONSTRAINT [DF_IMPORTSPECPROCEDE_IMP_ORDER]
	DEFAULT (1) FOR [IMP_ORDER]
GO
