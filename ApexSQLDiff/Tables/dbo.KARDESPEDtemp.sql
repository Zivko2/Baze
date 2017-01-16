SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KARDESPEDtemp] (
		[KAP_CODIGO]                     [int] IDENTITY(1, 1) NOT NULL,
		[KAP_FACTRANS]                   [int] NULL,
		[KAP_INDICED_FACT]               [int] NULL,
		[KAP_INDICED_PED]                [int] NULL,
		[MA_HIJO]                        [int] NULL,
		[KAP_ESTATUS]                    [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_CANTDESC]                   [decimal](38, 6) NULL,
		[KAP_CantTotADescargar]          [decimal](38, 6) NULL,
		[KAP_Saldo_FED]                  [decimal](38, 6) NULL,
		[KAP_PADRESUST]                  [int] NULL,
		[KAP_SALAFECTADO]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PA_CODIGO]                      [int] NULL,
		[KAP_SALDOPEDANTESDESCARGAR]     [decimal](38, 6) NULL,
		[ME_SALDO]                       [int] NULL,
		[KAP_Tipo_Desc]                  [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_FisComp]                    [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_PadreMain]                  [int] NULL,
		CONSTRAINT [IX_KARDESPEDtemp]
		UNIQUE
		NONCLUSTERED
		([KAP_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KARDESPEDtemp]
	ADD
	CONSTRAINT [DF__KarDesPed__KAP_F__4BB21401]
	DEFAULT ('N') FOR [KAP_FisComp]
GO
ALTER TABLE [dbo].[KARDESPEDtemp]
	ADD
	CONSTRAINT [DF__KarDesPed__KAP_P__4CA6383A]
	DEFAULT (0) FOR [KAP_PadreMain]
GO
ALTER TABLE [dbo].[KARDESPEDtemp]
	ADD
	CONSTRAINT [DF_KARDESPEDtemp_KAP_SALAFECTADO]
	DEFAULT ('N') FOR [KAP_SALAFECTADO]
GO
ALTER TABLE [dbo].[KARDESPEDtemp] SET (LOCK_ESCALATION = TABLE)
GO
