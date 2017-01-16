SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[fraccion] (
		[AR_CODIGO]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_FRACCION]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_DIGITO]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_OFICIAL]          [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_USO]              [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CS_CODIGO]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_TIPO]             [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_LN_DESC]          [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RA_CODIGO]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PA_CODIGO]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ME_CODIGO]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VI_CODIGO]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TV_CODIGO]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_ESTADO]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_FEC_REV]          [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_FEC_INI]          [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_FEC_FIN]          [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_OBSERVA]          [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_ADV]              [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_BEN]              [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_CUOTA]            [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_IVA]              [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_IEPS]             [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_ISAN]             [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_TIPOIMPUESTO]     [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_CANTUMESP]        [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_ESPEC]            [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_PORCENT_8VA]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_ADVDEF]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_CUOTA]            [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_IVA]              [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_IEPS]             [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_ISAN]             [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARR_CODIGO]          [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_CAPITULO]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fraccion] SET (LOCK_ESCALATION = TABLE)
GO
