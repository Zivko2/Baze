SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[maestroprohibido2] (
		[MP_CODIGO]           [int] IDENTITY(1, 1) NOT NULL,
		[MA_CODIGO]           [int] NOT NULL,
		[MP_FECHAINICIAL]     [datetime] NOT NULL,
		[MP_FECHAFINAL]       [datetime] NOT NULL,
		[MP_PROHIBIDO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
