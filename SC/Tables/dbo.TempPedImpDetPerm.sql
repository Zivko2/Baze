SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempPedImpDetPerm] (
		[PIP_INDICE]      [int] IDENTITY(1, 1) NOT NULL,
		[PIB_INDICEB]     [int] NOT NULL,
		[PI_CODIGO]       [int] NOT NULL,
		[IDE_CODIGO]      [int] NULL,
		[PE_CODIGO]       [int] NOT NULL,
		[PIP_FOLIO]       [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIP_FIRMA]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIP_VALOR]       [decimal](38, 6) NULL,
		[PIP_CANT]        [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempPedImpDetPerm]
	ADD
	CONSTRAINT [DF_TempPedImpDetPerm_PIP_FIRMA]
	DEFAULT ('') FOR [PIP_FIRMA]
GO
ALTER TABLE [dbo].[TempPedImpDetPerm]
	ADD
	CONSTRAINT [DF_TempPedImpDetPerm_PIP_FOLIO]
	DEFAULT ('') FOR [PIP_FOLIO]
GO
