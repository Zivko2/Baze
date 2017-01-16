SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ORDTRABAJODET] (
		[OT_CODIGO]               [int] NOT NULL,
		[OTD_INDICED]             [int] NOT NULL,
		[MA_CODIGO]               [int] NULL,
		[OTD_NOPARTE]             [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OTD_NOMBRE]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OTD_SIZELOTE]            [decimal](38, 6) NULL,
		[ME_CODIGO]               [int] NULL,
		[OTD_SALDO]               [decimal](38, 6) NULL,
		[OTD_SALDOSURT]           [decimal](38, 6) NULL,
		[OTD_PRECIOVENTA]         [decimal](38, 6) NULL,
		[OTD_PRECIOCOMPRA]        [decimal](38, 6) NULL,
		[OTD_OBSERVA]             [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OTD_ENUSO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[OTD_FECHAENTREGA]        [datetime] NULL,
		[PD_CODIGO]               [int] NULL,
		[PDD_INDICED]             [int] NULL,
		[PD_FOLIO]                [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OTD_SALDOORDTRABAJO]     [decimal](38, 6) NULL,
		[END_INDICED]             [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORDTRABAJODET]
	ADD
	CONSTRAINT [PK_ORDTRABAJODET]
	PRIMARY KEY
	NONCLUSTERED
	([OTD_INDICED])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORDTRABAJODET]
	ADD
	CONSTRAINT [DF_ORDTRABAJODET_END_INDICED]
	DEFAULT ((-1)) FOR [END_INDICED]
GO
ALTER TABLE [dbo].[ORDTRABAJODET]
	ADD
	CONSTRAINT [DF_ORDTRABAJODET_OTD_ENUSO]
	DEFAULT ('N') FOR [OTD_ENUSO]
GO
ALTER TABLE [dbo].[ORDTRABAJODET] SET (LOCK_ESCALATION = TABLE)
GO
