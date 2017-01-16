SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTEXPAGRU] (
		[FEA_CODIGO]           [int] NOT NULL,
		[FEA_FOLIO]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FEA_FECHA]            [datetime] NOT NULL,
		[TF_CODIGO]            [smallint] NOT NULL,
		[TQ_CODIGO]            [smallint] NOT NULL,
		[FEA_TIPO]             [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FEA_PINICIAL]         [datetime] NOT NULL,
		[FEA_PFINAL]           [datetime] NOT NULL,
		[TN_CODIGO]            [smallint] NULL,
		[FEA_NO_SEM]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_DOCUMENTO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_DESTINO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_TIPOCAMBIO]       [decimal](38, 6) NULL,
		[AG_MX]                [smallint] NULL,
		[AG_US]                [smallint] NULL,
		[CL_PROD]              [int] NULL,
		[DI_PROD]              [int] NULL,
		[CL_COMP]              [int] NULL,
		[DI_COMP]              [int] NULL,
		[CO_COMP]              [int] NULL,
		[CL_COMPFIN]           [int] NULL,
		[DI_COMPFIN]           [int] NULL,
		[CO_COMPFIN]           [int] NULL,
		[CL_EXP]               [int] NULL,
		[DI_EXP]               [int] NULL,
		[CL_EXPFIN]            [int] NULL,
		[DI_EXPFIN]            [int] NULL,
		[CL_DESTINI]           [int] NULL,
		[DI_DESTINI]           [int] NULL,
		[CO_DESTINI]           [int] NULL,
		[CL_DESTFIN]           [int] NULL,
		[DI_DESTFIN]           [int] NULL,
		[CO_DESTFIN]           [int] NULL,
		[CL_VEND]              [int] NULL,
		[DI_VEND]              [int] NULL,
		[CL_IMP]               [int] NULL,
		[DI_IMP]               [int] NULL,
		[PU_CARGA]             [int] NULL,
		[PU_SALIDA]            [int] NULL,
		[PU_ENTRADA]           [int] NULL,
		[PU_DESTINO]           [int] NULL,
		[FEA_FEC_ENV]          [datetime] NULL,
		[FEA_FEC_ARR]          [datetime] NULL,
		[FEA_NUM_ENV]          [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_ENV_INST]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_ORD_COMP]         [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_NUM_CTL]          [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_NUM_INBON]        [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_TIPO_INBON]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_FEC_INBON]        [datetime] NULL,
		[FEA_FIRMS]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_COMENTA]          [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_COMENTAUS]        [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_CODIGO]            [smallint] NULL,
		[CT_COMPANY1]          [int] NULL,
		[CA_COMPANY1]          [int] NULL,
		[CJ_COMPANY1]          [int] NULL,
		[CT_COMPANY2]          [int] NULL,
		[CA_COMPANY2]          [int] NULL,
		[CJ_COMPANY2]          [int] NULL,
		[FEA_TPAGO_FLETE1]     [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_TPAGO_FLETE2]     [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_TRAC_US1]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_TRAC_MX1]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CONT1_REG]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CONT1_US]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CONT1_MX]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CONT1_SELL]       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_COMPANY1]          [smallint] NULL,
		[FEA_TRAC_CHO1]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_LIM1]             [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RU_COMPANY1]          [smallint] NULL,
		[FEA_FAIRE_MAR1]       [decimal](38, 6) NULL,
		[FEA_F_TERR1]          [decimal](38, 6) NULL,
		[FEA_G_MANEJO1]        [decimal](38, 6) NULL,
		[FEA_OTROS_CAR1]       [decimal](38, 6) NULL,
		[FEA_SEGURO1]          [decimal](38, 6) NULL,
		[FEA_TOTAL_TRANS1]     [decimal](38, 6) NULL,
		[FEA_TRAB_EXT1]        [decimal](38, 6) NULL,
		[FEA_TRANSFER1]        [decimal](38, 6) NULL,
		[MT_COMPANY1]          [smallint] NULL,
		[FEA_GUIA1]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_TRAC_US2]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_TRAC_MX2]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CONT2_REG]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CONT2_US]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CONT2_MX]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CONT2_SELL]       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PG_COMPANY2]          [smallint] NULL,
		[FEA_TRAC_CHO2]        [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_LIM2]             [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RU_COMPANY2]          [smallint] NULL,
		[FEA_FAIRE_MAR2]       [decimal](38, 6) NULL,
		[FEA_F_TERR2]          [decimal](38, 6) NULL,
		[FEA_G_MANEJO2]        [decimal](38, 6) NULL,
		[FEA_OTROS_CAR2]       [decimal](38, 6) NULL,
		[FEA_SEGURO2]          [decimal](38, 6) NULL,
		[FEA_TOTAL_TRANS2]     [decimal](38, 6) NULL,
		[FEA_TRAB_EXT2]        [decimal](38, 6) NULL,
		[FEA_TRANSFER2]        [decimal](38, 6) NULL,
		[MT_COMPANY2]          [smallint] NULL,
		[FEA_GUIA2]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_TOTALB]           [decimal](38, 6) NULL,
		[FEA_MANIF]            [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_MANIF_DATE]       [datetime] NULL,
		[FEA_AWB]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[fea_NUM_MANIFIES]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_VREDONDO1]        [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_VREDONDO2]        [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_FLETE2]           [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_FLETE]            [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_INCOTLUGAR1]      [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_INCOTLUGAR2]      [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_T_AND_E]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_B_OF_L]           [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_LAGNO]            [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_ESTATUS]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MO_CODIGO]            [int] NULL,
		[SPI_CODIGO]           [smallint] NULL,
		[FEA_DESCRIPTION1]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_DESCRIPTION2]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_INVOICETYPE]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_HEADER]           [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_FOOTER]           [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IT_COMPANY1]          [int] NULL,
		[IT_COMPANY2]          [int] NULL,
		[TCA_CONT1]            [smallint] NULL,
		[TCA_CONT2]            [smallint] NULL,
		[FEA_CA_MARCA1]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CA_MODELO1]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CA_MARCA2]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_CA_MODELO2]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEA_TIPOTRANS]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_FACTEXPAGRU]
		UNIQUE
		NONCLUSTERED
		([FEA_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPAGRU]
	ADD
	CONSTRAINT [PK_FACTEXPAGRU]
	PRIMARY KEY
	NONCLUSTERED
	([FEA_FOLIO], [FEA_TIPO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPAGRU]
	ADD
	CONSTRAINT [DF_FACTEXPAGRU_FEA_NO_SEM]
	DEFAULT ('nada') FOR [FEA_NO_SEM]
GO
ALTER TABLE [dbo].[FACTEXPAGRU]
	ADD
	CONSTRAINT [DF_FACTEXPAGRU_FEA_TIPOTRANS]
	DEFAULT ('O') FOR [FEA_TIPOTRANS]
GO
CREATE CLUSTERED INDEX [IX_FACTEXPAGRU_1]
	ON [dbo].[FACTEXPAGRU] ([FEA_CODIGO], [FEA_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPAGRU] SET (LOCK_ESCALATION = TABLE)
GO
