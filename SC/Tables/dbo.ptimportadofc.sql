SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ptimportadofc] (
		[PID_NOPARTE]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TI_CODIGO]         [smallint] NOT NULL,
		[PI_MOVIMIENTO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_CODIGO]         [smallint] NULL,
		[CP_CLAVE]          [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_RECTIFICA]      [smallint] NULL
) ON [PRIMARY]
GO
