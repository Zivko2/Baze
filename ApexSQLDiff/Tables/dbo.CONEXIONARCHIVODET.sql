SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONEXIONARCHIVODET] (
		[ARD_CODIGO]             [int] IDENTITY(1, 1) NOT NULL,
		[ARC_CODIGO]             [int] NOT NULL,
		[ARN_CODIGO]             [int] NULL,
		[ARD_SECCAMPO]           [int] NULL,
		[ARD_DESCCAMPO]          [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARD_CAMPO]              [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARD_OBLIGATORIEDAD]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARD_CASONULO]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARD_VALOROMISION]       [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARD_TIPOCAMPO]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARD_SIZE]               [int] NULL,
		[ARD_MASCARA]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARD_MOVIMIENTO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARD_CONDICION]          [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_CONEXIONARCHIVODET]
		UNIQUE
		NONCLUSTERED
		([ARD_CODIGO])
		WITH FILLFACTOR=90
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONEXIONARCHIVODET] SET (LOCK_ESCALATION = TABLE)
GO
