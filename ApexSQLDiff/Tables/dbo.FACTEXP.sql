SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTEXP] (
		[FE_CODIGO]               [int] NOT NULL,
		[FE_FOLIO]                [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_FECHA]                [datetime] NULL,
		[TF_CODIGO]               [smallint] NOT NULL,
		[TQ_CODIGO]               [smallint] NOT NULL,
		[FE_TIPO]                 [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_PINICIAL]             [datetime] NOT NULL,
		[FE_PFINAL]               [datetime] NOT NULL,
		[FC_CODIGO]               [int] NOT NULL,
		[TN_CODIGO]               [smallint] NOT NULL,
		[FE_NO_SEM]               [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_DOCUMENTO]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_DESTINO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AG_MX]                   [int] NOT NULL,
		[AG_US]                   [int] NOT NULL,
		[CL_PROD]                 [int] NOT NULL,
		[DI_PROD]                 [int] NULL,
		[CL_COMP]                 [int] NULL,
		[DI_COMP]                 [int] NULL,
		[CO_COMP]                 [smallint] NULL,
		[CL_COMPFIN]              [int] NULL,
		[DI_COMPFIN]              [int] NULL,
		[CO_COMPFIN]              [smallint] NULL,
		[CL_EXP]                  [int] NOT NULL,
		[DI_EXP]                  [int] NULL,
		[CL_EXPFIN]               [int] NULL,
		[DI_EXPFIN]               [int] NULL,
		[CL_DESTINI]              [int] NOT NULL,
		[DI_DESTINI]              [int] NULL,
		[CO_DESTINI]              [smallint] NULL,
		[CL_DESTFIN]              [int] NULL,
		[DI_DESTFIN]              [int] NULL,
		[CO_DESTFIN]              [smallint] NULL,
		[CL_VEND]                 [int] NULL,
		[DI_VEND]                 [int] NULL,
		[CL_IMP]                  [int] NULL,
		[DI_IMP]                  [int] NULL,
		[CO_IMP]                  [smallint] NULL,
		[PU_CARGA]                [int] NULL,
		[PU_SALIDA]               [int] NULL,
		[PU_ENTRADA]              [int] NULL,
		[PU_DESTINO]              [int] NULL,
		[FE_FEC_ENV]              [datetime] NULL,
		[FE_FEC_ARR]              [datetime] NULL,
		[FE_NUM_ENV]              [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_ENV_INST]             [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_ORD_COMP]             [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_NUM_CTL]              [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_NUM_INBON]            [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_TIPO_INBON]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_FEC_INBON]            [datetime] NULL,
		[FE_FIRMS]                [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_COMENTA]              [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_COMENTAUS]            [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_CODIGO]               [smallint] NULL,
		[CT_COMPANY1]             [int] NULL,
		[CA_COMPANY1]             [int] NULL,
		[CJ_COMPANY1]             [int] NULL,
		[CT_COMPANY2]             [int] NULL,
		[CA_COMPANY2]             [int] NULL,
		[CJ_COMPANY2]             [int] NULL,
		[FE_TRAC_US1]             [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_TRAC_MX1]             [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_CONT1_REG]            [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_CONT1_US]             [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_CONT1_SELL]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TCA_CONT1]               [smallint] NULL,
		[PG_COMPANY1]             [smallint] NULL,
		[FE_TRAC_CHO1]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_LIM1]                 [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RU_COMPANY1]             [smallint] NULL,
		[FE_TPAGO_FLETE1]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_TPAGO_FLETE2]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IT_COMPANY1]             [smallint] NULL,
		[MT_COMPANY1]             [smallint] NULL,
		[FE_GUIA1]                [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_TRAC_US2]             [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_TRAC_MX2]             [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_CONT2_REG]            [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_CONT2_US]             [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_CONT2_SELL]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TCA_CONT2]               [smallint] NULL,
		[PG_COMPANY2]             [smallint] NULL,
		[FE_TRAC_CHO2]            [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_LIM2]                 [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RU_COMPANY2]             [smallint] NULL,
		[IT_COMPANY2]             [smallint] NULL,
		[MT_COMPANY2]             [smallint] NULL,
		[FE_GUIA2]                [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_TOTALB]               [decimal](38, 6) NOT NULL,
		[FE_TIPOCAMBIO]           [decimal](38, 6) NULL,
		[FE_MANIF]                [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_MANIF_DATE]           [datetime] NULL,
		[FE_AWB]                  [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_INCOTLUGAR1]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_INCOTLUGAR2]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_LAGNO]                [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_DESCARGADA]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_FACTAGRU]             [int] NOT NULL,
		[FE_ESTATUS]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_CANCELADO]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_MOSTRARDIV]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MO_CODIGO]               [int] NULL,
		[SPI_CODIGO]              [smallint] NULL,
		[FE_CON_PEDCR]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_DESCRIPTION1]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_DESCRIPTION2]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_INVOICETYPE]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_HEADER]               [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_FOOTER]               [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_COMENTACO]            [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ALM_CODIGO]              [smallint] NULL,
		[FE_DISCHCONTENEDOR1]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PI_CODIGO]               [int] NOT NULL,
		[PI_RECTIFICA]            [int] NOT NULL,
		[PI_TRANS]                [int] NOT NULL,
		[FE_DESCARGABLE]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_USACONSOLIDADO]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_SEL]                  [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_AUXDESC]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_BARCODE]              [image] NULL,
		[FE_PREVIADESC]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_DESCSUST]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BC_CODIGO]               [int] NOT NULL,
		[FE_DESCITALICA]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_FECHADESCARGA]        [datetime] NULL,
		[FE_CUENTADET]            [int] NOT NULL,
		[FE_CONSECUTIVOPED]       [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_TRANSNOORIG]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_TRANSNO]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_GAFETECHOFER]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AGT_CODIGO]              [int] NULL,
		[FE_DESCMANUAL]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ETC_CODIGO]              [int] NOT NULL,
		[ET_CODIGO]               [int] NOT NULL,
		[FE_NUMVEHICULOS]         [int] NOT NULL,
		[FE_PRIORIDAD]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_CODIGO]               [int] NULL,
		[FE_USAPESODESP]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FEG_CODIGO]              [int] NOT NULL,
		[FE_PROCESOSUBMAQ]        [varchar](5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_INICIOCRUCE]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_FIRMAAVISO]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_FIRMAELECTAVANZ]      [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_BARCODEREMESA]        [image] NULL,
		[BC_REMESA]               [int] NOT NULL,
		[FE_TIPOCAMBIOUSD]        [decimal](38, 6) NOT NULL,
		[FE_FOLIOCLIENTE]         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_FEACODBARRAS]         [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_EDOCUMENT]            [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_FACTEXP]
		UNIQUE
		NONCLUSTERED
		([FE_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [PK_FACTEXP]
	PRIMARY KEY
	NONCLUSTERED
	([FE_FOLIO], [FE_TIPO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_BC_CODIGO]
	DEFAULT (0) FOR [BC_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_BC_REMESA]
	DEFAULT (0) FOR [BC_REMESA]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_CL_PROD]
	DEFAULT (1) FOR [CL_PROD]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_ET_CODIGO]
	DEFAULT ((-1)) FOR [ET_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_ETC_CODIGO]
	DEFAULT (0) FOR [ETC_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FC_CODIGO]
	DEFAULT (0) FOR [FC_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_AUXDESC]
	DEFAULT ('N') FOR [FE_AUXDESC]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_CANCELADO]
	DEFAULT ('N') FOR [FE_CANCELADO]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_CON_PEDCR]
	DEFAULT ('N') FOR [FE_CON_PEDCR]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_CUENTADET]
	DEFAULT (0) FOR [FE_CUENTADET]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_DESCARGABLE]
	DEFAULT ('S') FOR [FE_DESCARGABLE]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_DESCARGADA]
	DEFAULT ('N') FOR [FE_DESCARGADA]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_DESCITALICA]
	DEFAULT ('N') FOR [FE_DESCITALICA]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_DESCMANUAL]
	DEFAULT ('N') FOR [FE_DESCMANUAL]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_ESTATUS]
	DEFAULT ('D') FOR [FE_ESTATUS]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_FACTAGRU]
	DEFAULT ((-1)) FOR [FE_FACTAGRU]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_INICIOCRUCE]
	DEFAULT ('N') FOR [FE_INICIOCRUCE]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_MOSTRARDIV]
	DEFAULT ('S') FOR [FE_MOSTRARDIV]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_NUMVEHICULOS]
	DEFAULT (1) FOR [FE_NUMVEHICULOS]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_PREVIADESC]
	DEFAULT ('N') FOR [FE_PREVIADESC]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_PRIORIDAD]
	DEFAULT ('N') FOR [FE_PRIORIDAD]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_SEL]
	DEFAULT ('N') FOR [FE_SEL]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_TIPO]
	DEFAULT ('F') FOR [FE_TIPO]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_TIPOCAMBIOUSD]
	DEFAULT (1) FOR [FE_TIPOCAMBIOUSD]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_TOTALB]
	DEFAULT (0) FOR [FE_TOTALB]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_USACONSOLIDADO]
	DEFAULT ('N') FOR [FE_USACONSOLIDADO]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FE_USAPESODESP]
	DEFAULT ('N') FOR [FE_USAPESODESP]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_FEG_CODIGO]
	DEFAULT ((-1)) FOR [FEG_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_PI_CODIGO]
	DEFAULT ((-1)) FOR [PI_CODIGO]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_PI_RECTIFICA]
	DEFAULT ((-1)) FOR [PI_RECTIFICA]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_PI_TRANS]
	DEFAULT ((-1)) FOR [PI_TRANS]
GO
ALTER TABLE [dbo].[FACTEXP]
	ADD
	CONSTRAINT [DF_FACTEXP_TN_CODIGO]
	DEFAULT (4) FOR [TN_CODIGO]
GO
CREATE CLUSTERED INDEX [IX_FACTEXP_1]
	ON [dbo].[FACTEXP] ([FE_CODIGO], [FE_FOLIO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXP_2]
	ON [dbo].[FACTEXP] ([PI_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXP_3]
	ON [dbo].[FACTEXP] ([PI_RECTIFICA])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXP_4]
	ON [dbo].[FACTEXP] ([TF_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXP_5]
	ON [dbo].[FACTEXP] ([TQ_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXP_6]
	ON [dbo].[FACTEXP] ([FE_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FACTEXP_7]
	ON [dbo].[FACTEXP] ([FE_DESCARGADA], [PI_CODIGO], [PI_RECTIFICA])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXP] SET (LOCK_ESCALATION = TABLE)
GO
