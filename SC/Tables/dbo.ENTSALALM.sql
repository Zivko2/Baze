SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ENTSALALM] (
		[EN_CODIGO]                [int] NOT NULL,
		[EN_FOLIO]                 [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EN_FECHA]                 [datetime] NOT NULL,
		[EN_TIPO]                  [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TM_CODIGO]                [int] NOT NULL,
		[EN_REFERENCIA]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EN_OBSERVA]               [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EN_CUENTAMAYOR]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PR_CODIGO]                [int] NOT NULL,
		[DI_PROVEE]                [int] NULL,
		[CL_DESTINO]               [int] NOT NULL,
		[DI_DESTINO]               [int] NULL,
		[US_CODIGO]                [int] NULL,
		[EN_NOAUTORIZA]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EN_TIPOCAMBIO]            [decimal](38, 6) NULL,
		[EN_ESTATUS]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EN_ORDENTRABAJO]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EN_SOLINVENTARIO]         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EN_CANCELADO]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EN_FOLIOAUTORIZACION]     [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EN_TOTALB]                [decimal](38, 6) NULL,
		[RC_CODIGO]                [int] NULL,
		[ALM_ORIGEN]               [int] NULL,
		[ALM_DESTINO]              [int] NULL,
		[ALM_SALDOAFECTADO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_ENTSALALM]
		UNIQUE
		NONCLUSTERED
		([EN_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ENTSALALM]
	ADD
	CONSTRAINT [PK_ENTSALALM]
	PRIMARY KEY
	NONCLUSTERED
	([EN_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ENTSALALM]
	ADD
	CONSTRAINT [DF_ENTSALALM_ALM_DESTINO]
	DEFAULT (0) FOR [ALM_DESTINO]
GO
ALTER TABLE [dbo].[ENTSALALM]
	ADD
	CONSTRAINT [DF_ENTSALALM_ALM_ORIGEN]
	DEFAULT (0) FOR [ALM_ORIGEN]
GO
ALTER TABLE [dbo].[ENTSALALM]
	ADD
	CONSTRAINT [DF_ENTSALALM_ALM_SALDOAFECTADO]
	DEFAULT ('N') FOR [ALM_SALDOAFECTADO]
GO
ALTER TABLE [dbo].[ENTSALALM]
	ADD
	CONSTRAINT [DF_ENTSALALM_CL_DESTINO]
	DEFAULT (1) FOR [CL_DESTINO]
GO
ALTER TABLE [dbo].[ENTSALALM]
	ADD
	CONSTRAINT [DF_ENTSALALM_EN_CANCELADO]
	DEFAULT ('N') FOR [EN_CANCELADO]
GO
ALTER TABLE [dbo].[ENTSALALM]
	ADD
	CONSTRAINT [DF_ENTSALALM_EN_ESTATUS]
	DEFAULT ('S') FOR [EN_ESTATUS]
GO
ALTER TABLE [dbo].[ENTSALALM]
	ADD
	CONSTRAINT [DF_ENTSALALM_EN_TIPO]
	DEFAULT ('S') FOR [EN_TIPO]
GO
CREATE CLUSTERED INDEX [IX_ENTSALALM_1]
	ON [dbo].[ENTSALALM] ([EN_CODIGO], [EN_FOLIO])
	ON [PRIMARY]
GO
