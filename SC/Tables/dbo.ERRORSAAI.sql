SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ERRORSAAI] (
		[ERR_CODIGO]           [int] IDENTITY(1, 1) NOT NULL,
		[ERR_TIPOREGISTRO]     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ERR_CAMPO]            [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ERR_TIPOERROR]        [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ERR_NOERROR]          [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ERR_DESC]             [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ERR_JUSTIFICABLE]     [int] NULL,
		[ERR_INICIOVIG]        [datetime] NULL,
		[ERR_FINVIG]           [datetime] NULL,
		CONSTRAINT [IX_ERRORSAAI]
		UNIQUE
		NONCLUSTERED
		([ERR_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ERRORSAAI]
	ADD
	CONSTRAINT [PK_ERRORSAAI]
	PRIMARY KEY
	CLUSTERED
	([ERR_TIPOREGISTRO], [ERR_CAMPO], [ERR_TIPOERROR], [ERR_NOERROR])
	ON [PRIMARY]
GO
