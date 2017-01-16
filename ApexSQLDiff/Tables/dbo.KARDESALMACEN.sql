SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KARDESALMACEN] (
		[KAA_CODIGO]                [int] IDENTITY(1, 1) NOT NULL,
		[KAA_FECHADESC]             [datetime] NULL,
		[ALM_CODIGO]                [int] NOT NULL,
		[KAA_FACTRANS]              [int] NULL,
		[KAA_INDICED_FACT]          [int] NULL,
		[KAA_INDICED_PED]           [int] NULL,
		[MA_HIJO]                   [int] NOT NULL,
		[KAA_TIPO_DESC]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EQ_ALM]                    [decimal](28, 14) NOT NULL,
		[KAA_TIPO]                  [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[KAA_CANTDESC]              [decimal](38, 6) NULL,
		[KAA_SALDO_PED]             [decimal](38, 6) NOT NULL,
		[KAA_CantTotADescargar]     [decimal](38, 6) NULL,
		[KAA_SALDO_FED]             [decimal](38, 6) NULL,
		[ME_GENERICO]               [int] NULL,
		[KAA_ESTATUS]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_KARDESALMACEN]
		UNIQUE
		NONCLUSTERED
		([KAA_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KARDESALMACEN]
	ADD
	CONSTRAINT [DF_KARDESALMACEN_EQ_ALM]
	DEFAULT (1) FOR [EQ_ALM]
GO
ALTER TABLE [dbo].[KARDESALMACEN]
	ADD
	CONSTRAINT [DF_KARDESALMACEN_KAA_SALDO_PED]
	DEFAULT (0) FOR [KAA_SALDO_PED]
GO
ALTER TABLE [dbo].[KARDESALMACEN]
	ADD
	CONSTRAINT [DF_KARDESALMACEN_KAA_TIPO]
	DEFAULT ('S') FOR [KAA_TIPO]
GO
ALTER TABLE [dbo].[KARDESALMACEN] SET (LOCK_ESCALATION = TABLE)
GO
