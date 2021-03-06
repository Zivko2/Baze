SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ERRORSAAISINT] (
		[ERR_CODIGO]        [int] IDENTITY(1, 1) NOT NULL,
		[ERR_TIPOERROR]     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ERR_NOERROR]       [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ERR_DESC]          [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_ERRORSAAISINT]
		UNIQUE
		NONCLUSTERED
		([ERR_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ERRORSAAISINT]
	ADD
	CONSTRAINT [PK_ERRORSAAISINT]
	PRIMARY KEY
	CLUSTERED
	([ERR_TIPOERROR], [ERR_NOERROR])
	ON [PRIMARY]
GO
