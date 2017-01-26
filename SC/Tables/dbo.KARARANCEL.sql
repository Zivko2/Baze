SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KARARANCEL] (
		[AR_CODIGO]       [int] NOT NULL,
		[KA_FEC_INI]      [datetime] NOT NULL,
		[KA_FEC_FIN]      [datetime] NOT NULL,
		[KA_EFECTIVO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[KA_FEC_REV]      [datetime] NULL,
		[KA_OBSERVA]      [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PA_CODIGO]       [int] NOT NULL,
		[KA_ADV]          [decimal](38, 6) NOT NULL,
		[KA_ADVDEF]       [decimal](38, 6) NOT NULL,
		[KA_BEN]          [decimal](38, 6) NOT NULL,
		[KA_ESPEC]        [decimal](38, 6) NOT NULL,
		[KA_MPF]          [decimal](38, 6) NOT NULL,
		[KA_CUOTA]        [decimal](38, 6) NOT NULL,
		[KA_IRC_RATE]     [decimal](38, 6) NOT NULL,
		[KA_IVA]          [decimal](38, 6) NOT NULL,
		[KA_TLC]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[KA_IEPS]         [decimal](38, 6) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
