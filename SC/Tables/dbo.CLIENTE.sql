SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CLIENTE] (
		[CL_CODIGO]                     [int] IDENTITY(1, 1) NOT NULL,
		[CL_RAZON]                      [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AC_CODIGO]                     [int] NULL,
		[CL_GIRO]                       [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_RFC]                        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_REP_RFC]                    [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_REP_PAT]                    [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_REP_MAT]                    [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_REP_NOM]                    [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PO_CODIGO]                     [int] NULL,
		[CL_REP_EMAIL]                  [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_REP_TEL]                    [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_REP_FAX]                    [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_REP_CURP]                   [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TE_CODIGO]                     [smallint] NULL,
		[CL_CON_VEN]                    [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_LIMCRE]                     [decimal](38, 6) NULL,
		[CL_COD_FAB]                    [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_CRH]                        [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_EIN]                        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_RNIE]                       [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_IRS]                        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_EXPED]                      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_RNIM]                       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_ANIOPPS]                    [int] NULL,
		[CL_NOPPS]                      [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_ALTEX]                      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_TIPO]                       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CL_EMPRESA]                    [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CL_REGPEDCONS]                 [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_PRODUCTOS]                  [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SE_CODIGO]                     [smallint] NULL,
		[CL_CORTO]                      [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_ANIOMAQ]                    [int] NULL,
		[CL_NOMAQ]                      [int] NULL,
		[CL_REGOCTAVA]                  [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VI_CODIGO]                     [smallint] NOT NULL,
		[CL_MATRIZ]                     [int] NULL,
		[AG_MEX]                        [smallint] NULL,
		[AG_USA]                        [smallint] NULL,
		[CL_TRAFICO]                    [int] NULL,
		[CL_CURP]                       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IT_ENTRADA]                    [smallint] NULL,
		[IT_SALIDA]                     [smallint] NULL,
		[MO_CODIGO]                     [int] NULL,
		[CT_CODIGO]                     [int] NULL,
		[AD_CODIGO]                     [int] NULL,
		[AD_SALIDA]                     [int] NULL,
		[PU_CARGA]                      [int] NULL,
		[PU_SALIDA]                     [int] NULL,
		[PU_ENTRADA]                    [int] NULL,
		[PU_DESTINO]                    [int] NULL,
		[SPI_CODIGO]                    [smallint] NULL,
		[PU_CARGAS]                     [int] NULL,
		[PU_SALIDAS]                    [int] NULL,
		[PU_ENTRADAS]                   [int] NULL,
		[PU_DESTINOS]                   [int] NULL,
		[ZO_CODIGO]                     [smallint] NULL,
		[CL_PASARCONTENEDOR]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BT_BTIPO]                      [smallint] NULL,
		[CL_REGPRONAC]                  [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_TIPOPRODUCTOR]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ET_TYPECODE1]                  [int] NULL,
		[ET_TYPECODE2]                  [int] NULL,
		[ET_TYPECODEENT]                [int] NULL,
		[ET_TYPECODEENT2]               [int] NULL,
		[US_CODIGO]                     [int] NULL,
		[MT_CODIGO]                     [int] NULL,
		[CL_FIRMSCODE]                  [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_INVOICETYPE]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_DESC_GRAL]                  [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_HEADER]                     [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FE_FOOTER]                     [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FI_INVOICETYPE]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FI_DESC_GRAL]                  [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FI_HEADER]                     [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FI_FOOTER]                     [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_CLAVEABT]                   [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_VIRTPAGACONTRIB]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TN_ENTRADA]                    [smallint] NULL,
		[TN_SALIDA]                     [smallint] NULL,
		[CL_CODEHTC]                    [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_EMPCERTIFICADA]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_AUTFRONTERIZA]              [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TV_CODIGO]                     [int] NULL,
		[CL_REPLEGTESTNOTARIAL]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_FECHAREPLEG]                [datetime] NULL,
		[CL_REGREVORIGEN]               [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_EMANIFESTCODE]              [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_TIPOPROVEE]                 [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CL_IMMEX]                      [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_AUTSUBMAQ]                  [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_FECHAAUTSUBMAQ]             [datetime] NULL,
		[CL_FECHAREGEMPCERTIFICADA]     [datetime] NULL,
		[CL_PASSWORDCOVE]               [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_EMAILCOVE]                  [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_TIPOIDENTIFICADORCOVE]      [int] NOT NULL,
		[CL_ARCHIVOCERTIFICADOCOVE]     [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_ARCHIVOKEYCOVE]             [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_URLCOVE]                    [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_CLAVELLAVECOVE]             [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_CLIENTE]
		UNIQUE
		NONCLUSTERED
		([CL_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLIENTE]
	ADD
	CONSTRAINT [PK_CLIENTE]
	PRIMARY KEY
	NONCLUSTERED
	([CL_RAZON])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLIENTE]
	ADD
	CONSTRAINT [DF_CLIENTE_CL_EMPRESA]
	DEFAULT ('N') FOR [CL_EMPRESA]
GO
ALTER TABLE [dbo].[CLIENTE]
	ADD
	CONSTRAINT [DF_CLIENTE_CL_TIPO]
	DEFAULT ('M') FOR [CL_TIPO]
GO
ALTER TABLE [dbo].[CLIENTE]
	ADD
	CONSTRAINT [DF_CLIENTE_CL_TIPOIDENTIFICADORCOVE]
	DEFAULT (1) FOR [CL_TIPOIDENTIFICADORCOVE]
GO
ALTER TABLE [dbo].[CLIENTE]
	ADD
	CONSTRAINT [DF_CLIENTE_CL_TIPOPRODUCTOR]
	DEFAULT ('D') FOR [CL_TIPOPRODUCTOR]
GO
ALTER TABLE [dbo].[CLIENTE]
	ADD
	CONSTRAINT [DF_CLIENTE_CL_TIPOPROVEE]
	DEFAULT ('A') FOR [CL_TIPOPROVEE]
GO
ALTER TABLE [dbo].[CLIENTE]
	ADD
	CONSTRAINT [DF_CLIENTE_CL_VIRTPAGACONTRIB]
	DEFAULT ('S') FOR [CL_VIRTPAGACONTRIB]
GO
ALTER TABLE [dbo].[CLIENTE]
	ADD
	CONSTRAINT [DF_CLIENTE_TV_CODIGO]
	DEFAULT (2) FOR [TV_CODIGO]
GO
ALTER TABLE [dbo].[CLIENTE]
	ADD
	CONSTRAINT [DF_CLIENTE_VI_CODIGO]
	DEFAULT (1) FOR [VI_CODIGO]
GO
CREATE CLUSTERED INDEX [IX_CLIENTE_1]
	ON [dbo].[CLIENTE] ([CL_CODIGO], [CL_RAZON])
	ON [PRIMARY]
GO
