SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DICTAMENFISCAL] (
		[DF_CODIGO]       [int] NOT NULL,
		[DF_FECHAINI]     [datetime] NULL,
		[DF_FECHAFIN]     [datetime] NULL,
		[DF_CONTADOR]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DF_NUMREG]       [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_CODIGO]       [int] NULL,
		CONSTRAINT [IX_DICTAMENFISCAL]
		UNIQUE
		NONCLUSTERED
		([DF_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DICTAMENFISCAL]
	ADD
	CONSTRAINT [PK_DICTAMENFISCAL]
	PRIMARY KEY
	NONCLUSTERED
	([DF_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DICTAMENFISCAL]
	ADD
	CONSTRAINT [DF_DICTAMENFISCAL_DF_CONTADOR]
	DEFAULT ('') FOR [DF_CONTADOR]
GO
ALTER TABLE [dbo].[DICTAMENFISCAL]
	ADD
	CONSTRAINT [DF_DICTAMENFISCAL_DF_NUMREG]
	DEFAULT ('') FOR [DF_NUMREG]
GO
