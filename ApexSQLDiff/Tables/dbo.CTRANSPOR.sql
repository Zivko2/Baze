SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CTRANSPOR] (
		[CT_CODIGO]             [int] IDENTITY(1, 1) NOT NULL,
		[CT_CORTO]              [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_NOMBRE]             [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CT_RFC]                [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_CURP]               [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_TIEMPO]             [int] NULL,
		[CT_TARRET]             [decimal](38, 6) NULL,
		[TE_CODIGO]             [smallint] NULL,
		[CT_CALLE]              [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_NOEXT]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_NOINT]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_COL]                [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_CP]                 [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_POBOX]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_CIUDAD]             [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_MUNIC]              [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ES_CODIGO]             [int] NULL,
		[PA_CODIGO]             [int] NULL,
		[CT_REFER]              [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_TEL1]               [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_TEL2]               [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_FAX]                [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_SCAC]               [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_RANGOINI]           [int] NULL,
		[CT_RANGOFIN]           [int] NULL,
		[CT_ENVIOCONSEC]        [int] NULL,
		[CT_TIPOCUOTA]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CT_TARIFA]             [decimal](38, 6) NULL,
		[CT_TIPOTARIFAADIC]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CT_INCPORADICXKG]      [decimal](38, 6) NULL,
		[CT_DECPORADICXKG]      [decimal](38, 6) NULL,
		[CT_FIJADLS]            [decimal](38, 6) NULL,
		[CT_FIJAPARTIRKG]       [decimal](38, 6) NULL,
		[CT_CUOTAMINIMA]        [decimal](38, 6) NULL,
		[CT_CIP]                [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_CAAT]               [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_CTRANSPOR]
		UNIQUE
		NONCLUSTERED
		([CT_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [PK_CTRANSPOR]
	PRIMARY KEY
	NONCLUSTERED
	([CT_NOMBRE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_CIUDAD]
	DEFAULT ('') FOR [CT_CIUDAD]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_COL]
	DEFAULT ('') FOR [CT_COL]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_CP]
	DEFAULT ('') FOR [CT_CP]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_FAX]
	DEFAULT ('') FOR [CT_FAX]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_MUNIC]
	DEFAULT ('') FOR [CT_MUNIC]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_NOINT]
	DEFAULT ('') FOR [CT_NOINT]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_POBOX]
	DEFAULT ('') FOR [CT_POBOX]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_TEL1]
	DEFAULT ('') FOR [CT_TEL1]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_TEL2]
	DEFAULT ('') FOR [CT_TEL2]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_TIPOCUOTA]
	DEFAULT ('K') FOR [CT_TIPOCUOTA]
GO
ALTER TABLE [dbo].[CTRANSPOR]
	ADD
	CONSTRAINT [DF_CTRANSPOR_CT_TIPOTARIFAADIC]
	DEFAULT ('N') FOR [CT_TIPOTARIFAADIC]
GO
CREATE CLUSTERED INDEX [IX_CTRANSPOR_1]
	ON [dbo].[CTRANSPOR] ([CT_CODIGO], [CT_NOMBRE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTRANSPOR] SET (LOCK_ESCALATION = TABLE)
GO
