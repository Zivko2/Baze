SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FASTBARCODE] (
		[FST_CODIGO]         [int] NOT NULL,
		[BFST_TEXTO]         [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BFST_TIPO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ET_CODIGO]          [int] NOT NULL,
		[BFST_FOLIOFACT]     [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BFST_TIPOENTRY]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FASTBARCODE]
	ADD
	CONSTRAINT [PK_FASTBARCODE]
	PRIMARY KEY
	CLUSTERED
	([FST_CODIGO], [BFST_TEXTO], [BFST_TIPO], [ET_CODIGO], [BFST_FOLIOFACT], [BFST_TIPOENTRY])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FASTBARCODE]
	ADD
	CONSTRAINT [DF_FASTBARCODE_BFST_FOLIOFACT]
	DEFAULT ('') FOR [BFST_FOLIOFACT]
GO
ALTER TABLE [dbo].[FASTBARCODE]
	ADD
	CONSTRAINT [DF_FASTBARCODE_BFST_TIPOENTRY]
	DEFAULT ('N') FOR [BFST_TIPOENTRY]
GO
