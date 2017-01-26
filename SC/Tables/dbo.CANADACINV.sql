SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CANADACINV] (
		[FE_CODIGO]           [int] NOT NULL,
		[CD_TIPOFACT]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IT_CODIGO]           [smallint] NULL,
		[CD_OTHER_COND]       [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_CODIGO]           [smallint] NULL,
		[TE_CODIGO]           [smallint] NULL,
		[CD_OTHER_EXP]        [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PA_COUNT_TRANS]      [int] NULL,
		[CD_PLACE_DIR]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CD_1_17]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IV_CODIGO]           [int] NULL,
		[CD_OTHER_REF]        [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CD_DEP_RUL]          [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CD_23_25]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CD_TRANS_CHARG]      [decimal](38, 6) NULL,
		[CD_COST_CONST]       [decimal](38, 6) NULL,
		[CD_EXP_PACK]         [decimal](38, 6) NULL,
		[CD_TRANS_CHARG2]     [decimal](38, 6) NULL,
		[CD_AMOUN_COMM]       [decimal](38, 6) NULL,
		[CD_EXP_PACK2]        [decimal](38, 6) NULL,
		[CD_ROYAL]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CD_PURCHASER]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CD_FECHA]            [datetime] NOT NULL,
		[CD_FEC_DIR]          [datetime] NOT NULL,
		[CD_TIP_CAM]          [decimal](38, 6) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CANADACINV]
	ADD
	CONSTRAINT [PK_CANADACINV]
	PRIMARY KEY
	NONCLUSTERED
	([FE_CODIGO], [CD_TIPOFACT])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CANADACINV]
	ADD
	CONSTRAINT [DF_CANADACINV_CD_TIP_CAM]
	DEFAULT (1) FOR [CD_TIP_CAM]
GO
