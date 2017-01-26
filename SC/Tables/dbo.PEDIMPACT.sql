SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PEDIMPACT] (
		[PI_CODIGO]         [int] NOT NULL,
		[PI_MOVIMIENTO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[cp_codigo]         [smallint] NULL,
		[PI_TIPO]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PI_ESTATUS]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PI_FEC_PAG]        [datetime] NULL
) ON [PRIMARY]
GO
