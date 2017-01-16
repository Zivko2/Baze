SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VALIDADOR] (
		[VAL_CODIGO]                    [int] NOT NULL,
		[VAL_NOMBRE]                    [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[VAL_CLAVE]                     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_PRINCIPAL]                 [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[VAL_FTP]                       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_RUTALOCAL]                 [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_RUTALOCALRES]              [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_RUTAREMOTA]                [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_RUTAREMOTARES]             [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_USERNAME]                  [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_PASSWORD]                  [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_EXTENSIONRESUL]            [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_VALANTES]                  [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_VALDESPUES]                [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BAN_CODIGO]                    [int] NULL,
		[VAL_USAPREVAL]                 [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_CLAVEPREVAL]               [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_RUTAREMOTAPRE]             [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_RUTAREMOTARESPRE]          [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_EXTENSIONRESULPRE]         [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_BANANTES]                  [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_BANDESPUES]                [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_PASSWORDDESISTIMIENTO]     [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_BANGENERA]                 [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_BANGENERAPRE]              [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_VALDESPUESPRE]             [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_BANANTESPRE]               [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_BANDESPUESPRE]             [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_AVISOANTES]                [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_AVISOANTESRESP]            [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_TRASLADOANTES]             [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_TRASLADOANTESRESP]         [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_PLANTASANTES]              [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_PLANTASANTESRESP]          [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_FTPPASSIVE]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VALIDADOR]
	ADD
	CONSTRAINT [PK_VALIDADOR]
	PRIMARY KEY
	CLUSTERED
	([VAL_NOMBRE])
	WITH FILLFACTOR=90
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[VALIDADOR]
	ADD
	CONSTRAINT [DF_VALIDADOR_VAL_FTPPASSIVE]
	DEFAULT ('N') FOR [VAL_FTPPASSIVE]
GO
ALTER TABLE [dbo].[VALIDADOR]
	ADD
	CONSTRAINT [DF_VALIDADOR_VAL_PRINCIPAL]
	DEFAULT ('N') FOR [VAL_PRINCIPAL]
GO
ALTER TABLE [dbo].[VALIDADOR] SET (LOCK_ESCALATION = TABLE)
GO
