SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PEDIMPADVERTENCIA] (
		[PIN_CODIGO]        [int] IDENTITY(1, 1) NOT NULL,
		[PI_CODIGO]         [int] NOT NULL,
		[PI_COMENTARIO]     [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_PEDIMPADVERTENCIA]
		UNIQUE
		NONCLUSTERED
		([PIN_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
