SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[monedaTemporal] (
		[MO_CODIGO]       [int] IDENTITY(1, 1) NOT NULL,
		[PA_CODIGO]       [int] NOT NULL,
		[MO_NOMBRE]       [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MO_NAME]         [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MO_CLAVEPED]     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MO_SIMBOLO]      [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
