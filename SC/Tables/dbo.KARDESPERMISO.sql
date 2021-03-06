SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KARDESPERMISO] (
		[KAR_CODIGO]                [int] IDENTITY(1, 1) NOT NULL,
		[FIR_CODIGO]                [int] NOT NULL,
		[FID_INDICED]               [int] NOT NULL,
		[FI_CODIGO]                 [int] NOT NULL,
		[PED_INDICED]               [int] NOT NULL,
		[KAR_CANTDESC]              [decimal](38, 6) NULL,
		[KAR_CantTotADescargar]     [decimal](38, 6) NULL,
		[KAR_Saldo_FID]             [decimal](38, 6) NULL,
		[KAR_TIPO]                  [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ME_CATEGORIA]              [int] NULL,
		[KAR_FACTIMP]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_KARDESPERMISO]
		UNIQUE
		NONCLUSTERED
		([KAR_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KARDESPERMISO]
	ADD
	CONSTRAINT [DF_KARDESPERMISO_KAR_FACTIMP]
	DEFAULT ('S') FOR [KAR_FACTIMP]
GO
ALTER TABLE [dbo].[KARDESPERMISO]
	ADD
	CONSTRAINT [DF_KARDESPERMISO_KAR_TIPO]
	DEFAULT ('C') FOR [KAR_TIPO]
GO
