SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[COMMINV] (
		[FE_CODIGO]          [int] NOT NULL,
		[IV_CODIGO]          [int] NOT NULL,
		[IV_FOLIO]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IV_TIPOFACT]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IV_FECHA]           [datetime] NOT NULL,
		[IV_FEC_EXP]         [datetime] NULL,
		[IV_SALES_TERMS]     [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IV_OTHER_COND]      [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IV_OTHER_EXP]       [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IV_DICTAMEN]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IV_FEC_DIC]         [datetime] NULL,
		[IV_INSTR]           [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_CODIGO]          [smallint] NULL,
		[CL_CODIGO]          [int] NULL,
		[ET_CODIGO]          [int] NOT NULL,
		[US_CODIGO]          [int] NULL,
		[IV_PEDIDO]          [varchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_COMMINV]
		UNIQUE
		NONCLUSTERED
		([IV_CODIGO])
		ON [PRIMARY],
		CONSTRAINT [IX_COMMINV_FOLIO]
		UNIQUE
		NONCLUSTERED
		([IV_FOLIO])
		ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[COMMINV]
	ADD
	CONSTRAINT [PK_COMMINV]
	PRIMARY KEY
	NONCLUSTERED
	([IV_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[COMMINV]
	ADD
	CONSTRAINT [DF_COMMINV_ET_CODIGO]
	DEFAULT ((-1)) FOR [ET_CODIGO]
GO
