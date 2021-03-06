SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PEDIMPDETB] (
		[PIB_INDICEB]                     [int] IDENTITY(1, 1) NOT NULL,
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
		[PIB_SECUENCIA]                   [int] NULL,
		[AR_EXPFO]                        [int] NULL,
		[PIB_RATEEXPFO]                   [decimal](38, 6) NULL,
		[EQ_EXPFO]                        [decimal](28, 14) NOT NULL,
		[PIB_VALORMCIANOORIG]             [decimal](38, 6) NOT NULL,
		[PIB_ADVMNIMPUSA]                 [decimal](38, 6) NOT NULL,
		[PIB_ADVMNIMPMEX]                 [decimal](38, 6) NOT NULL,
		[PIB_ADVUSDIMPMEX]                [decimal](38, 6) NULL,
		[PIB_EXCENCION]                   [decimal](38, 6) NOT NULL,
		[PIB_IMPORTECONTRSINRECARGOS]     [decimal](38, 6) NOT NULL,
		[PIB_IMPORTECONTR]                [decimal](38, 6) NOT NULL,
		[PIB_IMPORTECONTRUSD]             [decimal](38, 6) NULL,
		[PIB_IMPORTERECARGOS]             [decimal](38, 6) NOT NULL,
		[PIB_DESTNAFTA]                   [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIB_NOMBRE]                      [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIB_PAGACONTRIB]                 [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIB_DEF_TIP]                     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIB_SEC_IMP]                     [int] NULL,
		[SPI_CODIGO]                      [int] NULL,
		[PIB_CODIGOFACT]                  [int] NULL,
		[PIB_OBSERVA]                     [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIB_VAL_RET]                     [decimal](38, 6) NULL,
		[PIB_GENERA_EMPDET]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIB_SERVICIO]                    [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_PEDIMPDETB]
		UNIQUE
		NONCLUSTERED
		([PIB_INDICEB])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_EQ_EXPFO]
	DEFAULT (1) FOR [EQ_EXPFO]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_PIB_ADVMNIMPMEX]
	DEFAULT (0) FOR [PIB_ADVMNIMPMEX]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_PIB_ADVMNIMPUSA]
	DEFAULT (0) FOR [PIB_ADVMNIMPUSA]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_PIB_DESTNAFTA]
	DEFAULT ('S') FOR [PIB_DESTNAFTA]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_PIB_EXCENCION]
	DEFAULT (0) FOR [PIB_EXCENCION]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_PIB_GENERA_EMPDET]
	DEFAULT ('D') FOR [PIB_GENERA_EMPDET]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_PIB_IMPORTECONTR]
	DEFAULT (0) FOR [PIB_IMPORTECONTR]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_PIB_IMPORTECONTRSINRECARGOS]
	DEFAULT (0) FOR [PIB_IMPORTECONTRSINRECARGOS]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_PIB_IMPORTERECARGOS]
	DEFAULT (0) FOR [PIB_IMPORTERECARGOS]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_PIB_PAGACONTRIB]
	DEFAULT ('S') FOR [PIB_PAGACONTRIB]
GO
ALTER TABLE [dbo].[PEDIMPDETB]
	ADD
	CONSTRAINT [DF_PEDIMPDETB_PIB_VALORMCIANOORIG]
	DEFAULT (0) FOR [PIB_VALORMCIANOORIG]
GO
CREATE CLUSTERED INDEX [IX_PEDIMPDETB_1]
	ON [dbo].[PEDIMPDETB] ([PI_CODIGO], [PIB_INDICEB])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEDIMPDETB_10]
	ON [dbo].[PEDIMPDETB] ([PIB_INDICEB])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEDIMPDETB_2]
	ON [dbo].[PEDIMPDETB] ([PI_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEDIMPDETB_3]
	ON [dbo].[PEDIMPDETB] ([AR_IMPMX])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEDIMPDETB_4]
	ON [dbo].[PEDIMPDETB] ([ME_ARIMPMX])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEDIMPDETB_5]
	ON [dbo].[PEDIMPDETB] ([MA_GENERICO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEDIMPDETB_6]
	ON [dbo].[PEDIMPDETB] ([ME_GENERICO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEDIMPDETB_7]
	ON [dbo].[PEDIMPDETB] ([PA_ORIGEN])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEDIMPDETB_8]
	ON [dbo].[PEDIMPDETB] ([PA_PROCEDE])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PEDIMPDETB_9]
	ON [dbo].[PEDIMPDETB] ([AR_EXPFO])
	ON [PRIMARY]
GO
