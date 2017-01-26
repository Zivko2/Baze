SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTIMPAGRU] (
		[FIA_CODIGO]         [int] NOT NULL,
		[FIA_FOLIO]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TF_CODIGO]          [smallint] NOT NULL,
		[TQ_CODIGO]          [smallint] NOT NULL,
		[FIA_PINICIAL]       [datetime] NOT NULL,
		[FIA_PFINAL]         [datetime] NOT NULL,
		[FIA_FECHA]          [datetime] NOT NULL,
		[FIA_TIPOCAMBIO]     [decimal](38, 6) NULL,
		[FIA_TIPO]           [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FIA_NO_SEM]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_CODIGO]          [smallint] NULL,
		[PR_CODIGO]          [int] NULL,
		[DI_PROVEE]          [int] NULL,
		[CL_DESTFIN]         [int] NULL,
		[DI_DESTFIN]         [int] NULL,
		[AG_MEX]             [smallint] NULL,
		[AG_USA]             [smallint] NULL,
		[PU_CARGA]           [int] NULL,
		[PU_SALIDA]          [int] NULL,
		[PU_ENTRADA]         [int] NULL,
		[PU_DESTINO]         [int] NULL,
		[FIA_FEC_ENV]        [datetime] NULL,
		[FIA_FEC_ARR]        [datetime] NULL,
		[ZO_CODIGO]          [smallint] NULL,
		[CT_CODIGO]          [int] NULL,
		[MT_CODIGO]          [smallint] NULL,
		[FIA_GUIA]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RU_CODIGO]          [smallint] NULL,
		[FIA_TRAC_CHO]       [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IT_CODIGO]          [smallint] NULL,
		[FIA_FLETE]          [decimal](38, 6) NULL,
		[CJ_CODIGO]          [int] NULL,
		[FIA_CONT_MX]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIA_CONT_US]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIA_CONT_REG]       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIA_SELLO]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CA_CODIGO]          [int] NULL,
		[FIA_CA_MARCA]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FIA_CA_MODELO]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FIA_TRAC_MX]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIA_TRAC_US]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[YA_CODIGO]          [int] NULL,
		[CL_COMP]            [int] NULL,
		[DI_COMP]            [int] NULL,
		[CL_IMP]             [int] NULL,
		[DI_IMP]             [int] NULL,
		[CL_DESTINT]         [int] NULL,
		[DI_DESTINT]         [int] NULL,
		[CL_EXP]             [int] NULL,
		[DI_EXP]             [int] NULL,
		[CL_VEND]            [int] NULL,
		[DI_VEND]            [int] NULL,
		[CL_PROD]            [int] NULL,
		[DI_PROD]            [int] NULL,
		[FIA_ESTATUS]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIA_COMENTA]        [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIA_COMENTAUS]      [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIA_TOTALB]         [decimal](38, 6) NULL,
		[MO_CODIGO]          [int] NULL,
		[FIA_MANIFIESTO]     [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SPI_CODIGO]         [smallint] NULL,
		[CP_CODIGO]          [smallint] NULL,
		[FIA_SEGURO]         [decimal](38, 6) NULL,
		[FIA_EMBALAJE]       [decimal](38, 6) NULL,
		[TCA_CODIGO]         [smallint] NULL,
		[TN_CODIGO]          [smallint] NOT NULL,
		[FIA_NUM_INBON]      [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIA_TIPO_INBON]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIA_FEC_INBON]      [datetime] NULL,
		[FIA_HEADER]         [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIA_FOOTER]         [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MT_ORIGEN]          [int] NULL,
		[FIA_GUIAORIGEN]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_FACTIMPAGRU]
		UNIQUE
		NONCLUSTERED
		([FIA_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPAGRU]
	ADD
	CONSTRAINT [PK_FACTIMPAGRU]
	PRIMARY KEY
	NONCLUSTERED
	([FIA_FOLIO], [FIA_TIPO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPAGRU]
	ADD
	CONSTRAINT [DF_FACTIMPAGRU_FIA_CA_MARCA]
	DEFAULT ('') FOR [FIA_CA_MARCA]
GO
ALTER TABLE [dbo].[FACTIMPAGRU]
	ADD
	CONSTRAINT [DF_FACTIMPAGRU_FIA_CA_MODELO]
	DEFAULT ('') FOR [FIA_CA_MODELO]
GO
ALTER TABLE [dbo].[FACTIMPAGRU]
	ADD
	CONSTRAINT [DF_FACTIMPAGRU_FIA_FOOTER]
	DEFAULT ('') FOR [FIA_FOOTER]
GO
ALTER TABLE [dbo].[FACTIMPAGRU]
	ADD
	CONSTRAINT [DF_FACTIMPAGRU_FIA_HEADER]
	DEFAULT ('') FOR [FIA_HEADER]
GO
ALTER TABLE [dbo].[FACTIMPAGRU]
	ADD
	CONSTRAINT [DF_FACTIMPAGRU_TN_CODIGO]
	DEFAULT (4) FOR [TN_CODIGO]
GO
CREATE CLUSTERED INDEX [IX_FACTIMPAGRU_1]
	ON [dbo].[FACTIMPAGRU] ([FIA_CODIGO], [FIA_FOLIO])
	ON [PRIMARY]
GO
