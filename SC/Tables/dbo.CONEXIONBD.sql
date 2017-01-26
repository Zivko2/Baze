SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONEXIONBD] (
		[CNX_CODIGO]               [int] NOT NULL,
		[CNX_NOMBRE]               [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CNX_CONNECTIONSTRING]     [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CNX_QUERY]                [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CNX_TIPOBD]               [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
