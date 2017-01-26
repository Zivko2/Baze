SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[identificadetresp] (
		[IDED_CODIGO]     [int] NOT NULL,
		[IDE_CODIGO]      [int] NOT NULL,
		[IDED_COMPL]      [smallint] NOT NULL,
		[IDED_DESC]       [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDED_VALOR]      [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_APLICA]     [varchar](2100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
