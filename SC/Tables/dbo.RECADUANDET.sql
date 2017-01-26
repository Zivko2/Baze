SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RECADUANDET] (
		[RN_CODIGO]          [int] NOT NULL,
		[MA_CODIGO]          [int] NOT NULL,
		[ME_CODIGO]          [int] NOT NULL,
		[RND_PRE_UNI]        [decimal](38, 6) NOT NULL,
		[RND_PRE_DLS]        [decimal](38, 6) NOT NULL,
		[RND_SECOFI]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RND_CANTIDAD]       [decimal](38, 6) NOT NULL,
		[RND_OBSERVA]        [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EQ_CANT]            [decimal](28, 14) NOT NULL,
		[MA_GENERICO]        [int] NOT NULL,
		[RND_CTOT_MN]        [decimal](38, 6) NOT NULL,
		[RND_CTOT_DLS]       [decimal](38, 6) NOT NULL,
		[RND_COST_ADUA]      [decimal](38, 6) NOT NULL,
		[RND_PES_UNI]        [decimal](38, 6) NOT NULL,
		[RND_PES_NET]        [decimal](38, 6) NOT NULL,
		[RND_PES_BRU]        [decimal](38, 6) NOT NULL,
		[RND_PES_SALDO]      [decimal](38, 6) NOT NULL,
		[RND_PES_SALPOR]     [decimal](38, 6) NOT NULL,
		[AR_IMP]             [int] NOT NULL,
		[AR_IMPO]            [int] NOT NULL,
		[RND_SEC_IMP]        [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RND_TIP_IMP]        [smallint] NOT NULL,
		[RND_POR_IMP]        [decimal](38, 6) NOT NULL,
		[AR_CAM]             [int] NOT NULL,
		[RND_SEC_CAM]        [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RND_TIP_CAM]        [smallint] NOT NULL,
		[RND_POR_CAM]        [decimal](38, 6) NOT NULL,
		[RND_INDICED]        [int] NOT NULL,
		[RND_CLASIFICA]      [decimal](38, 6) NOT NULL,
		[FI_CODIGO]          [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
