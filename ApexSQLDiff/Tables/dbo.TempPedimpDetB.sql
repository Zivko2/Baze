SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempPedimpDetB] (
		[PI_CODIGO]                       [int] NOT NULL,
		[PIB_COS_UNIGEN]                  [decimal](38, 6) NULL,
		[PIB_COS_UNIGRA]                  [decimal](38, 6) NULL,
		[PIB_COS_UNIVA]                   [decimal](38, 6) NULL,
		[PIB_CANT]                        [decimal](38, 6) NULL,
		[PIB_CAN_AR]                      [decimal](38, 6) NULL,
		[PIB_CAN_GEN]                     [decimal](38, 6) NULL,
		[PIB_VAL_FAC]                     [decimal](38, 6) NULL,
		[PIB_VAL_ADU]                     [decimal](38, 6) NULL,
		[PIB_VAL_US]                      [decimal](38, 6) NULL,
		[PIB_ESTADO]                      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AR_IMPMX]                        [int] NULL,
		[PIB_POR_DEF]                     [decimal](38, 6) NULL,
		[ME_ARIMPMX]                      [int] NULL,
		[MA_GENERICO]                     [int] NULL,
		[ME_GENERICO]                     [int] NULL,
		[PA_ORIGEN]                       [int] NULL,
		[PA_PROCEDE]                      [int] NULL,
		[ES_ORIGEN]                       [int] NULL,
		[ES_DESTINO]                      [int] NULL,
		[ES_COMPRADOR]                    [int] NULL,
		[ES_VENDEDOR]                     [int] NULL,
		[PIB_SECUENCIA]                   [int] IDENTITY(1, 1) NOT NULL,
		[AR_EXPFO]                        [int] NULL,
		[PIB_RATEEXPFO]                   [decimal](38, 6) NULL,
		[EQ_EXPFO]                        [decimal](28, 14) NOT NULL,
		[PIB_VALORMCIANOORIG]             [decimal](38, 6) NOT NULL,
		[PIB_ADVMNIMPUSA]                 [decimal](38, 6) NOT NULL,
		[PIB_ADVMNIMPMEX]                 [decimal](38, 6) NOT NULL,
		[PIB_EXCENCION]                   [decimal](38, 6) NOT NULL,
		[PIB_IMPORTECONTRSINRECARGOS]     [decimal](38, 6) NOT NULL,
		[PIB_IMPORTECONTR]                [decimal](38, 6) NOT NULL,
		[PIB_IMPORTERECARGOS]             [decimal](38, 6) NOT NULL,
		[PIB_DESTNAFTA]                   [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIB_NOMBRE]                      [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIB_PAGACONTRIB]                 [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIB_DEF_TIP]                     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIB_SEC_IMP]                     [int] NULL,
		[SPI_CODIGO]                      [int] NULL,
		[PIB_CODIGOFACT]                  [int] NULL,
		[PIB_SECUENCIAPID]                [int] NULL,
		[PIB_CTOT_MN]                     [decimal](38, 6) NULL,
		[PIB_VAL_RET]                     [decimal](38, 6) NULL,
		[PIB_GENERA_EMPDET]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIB_SERVICIO]                    [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TempPedimpDetB]
		UNIQUE
		NONCLUSTERED
		([PIB_SECUENCIA])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempPedimpDetB]
	ADD
	CONSTRAINT [DF_TempPedimpDetB_EQ_EXPFO]
	DEFAULT (1) FOR [EQ_EXPFO]
GO
ALTER TABLE [dbo].[TempPedimpDetB]
	ADD
	CONSTRAINT [DF_TempPedimpDetB_PIB_ADVMNIMPMEX]
	DEFAULT (0) FOR [PIB_ADVMNIMPMEX]
GO
ALTER TABLE [dbo].[TempPedimpDetB]
	ADD
	CONSTRAINT [DF_TempPedimpDetB_PIB_ADVMNIMPUSA]
	DEFAULT (0) FOR [PIB_ADVMNIMPUSA]
GO
ALTER TABLE [dbo].[TempPedimpDetB]
	ADD
	CONSTRAINT [DF_TempPedimpDetB_PIB_DESTNAFTA]
	DEFAULT ('S') FOR [PIB_DESTNAFTA]
GO
ALTER TABLE [dbo].[TempPedimpDetB]
	ADD
	CONSTRAINT [DF_TempPedimpDetB_PIB_EXCENCION]
	DEFAULT (0) FOR [PIB_EXCENCION]
GO
ALTER TABLE [dbo].[TempPedimpDetB]
	ADD
	CONSTRAINT [DF_TempPedimpDetB_PIB_IMPORTECONTR]
	DEFAULT (0) FOR [PIB_IMPORTECONTR]
GO
ALTER TABLE [dbo].[TempPedimpDetB]
	ADD
	CONSTRAINT [DF_TempPedimpDetB_PIB_IMPORTECONTRSINRECARGOS]
	DEFAULT (0) FOR [PIB_IMPORTECONTRSINRECARGOS]
GO
ALTER TABLE [dbo].[TempPedimpDetB]
	ADD
	CONSTRAINT [DF_TempPedimpDetB_PIB_IMPORTERECARGOS]
	DEFAULT (0) FOR [PIB_IMPORTERECARGOS]
GO
ALTER TABLE [dbo].[TempPedimpDetB]
	ADD
	CONSTRAINT [DF_TempPedimpDetB_PIB_PAGACONTRIB]
	DEFAULT ('S') FOR [PIB_PAGACONTRIB]
GO
ALTER TABLE [dbo].[TempPedimpDetB]
	ADD
	CONSTRAINT [DF_TempPedimpDetB_PIB_VALORMCIANOORIG]
	DEFAULT (0) FOR [PIB_VALORMCIANOORIG]
GO
ALTER TABLE [dbo].[TempPedimpDetB] SET (LOCK_ESCALATION = TABLE)
GO
