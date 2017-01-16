SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MAESTROPROHIBIDO] (
		[MP_CODIGO]           [int] IDENTITY(1, 1) NOT NULL,
		[MA_CODIGO]           [int] NOT NULL,
		[MP_FECHAINICIAL]     [datetime] NOT NULL,
		[MP_FECHAFINAL]       [datetime] NOT NULL,
		[MP_PROHIBIDO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAESTROPROHIBIDO]
	ADD
	CONSTRAINT [PK_MAESTROPROHIBIDO]
	PRIMARY KEY
	CLUSTERED
	([MP_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAESTROPROHIBIDO]
	ADD
	CONSTRAINT [DF_MAESTROPROHIBIDO_MP_PROHIBIDO]
	DEFAULT ('N') FOR [MP_PROHIBIDO]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MAESTROPROHIBIDO]
	ON [dbo].[MAESTROPROHIBIDO] ([MP_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAESTROPROHIBIDO] SET (LOCK_ESCALATION = TABLE)
GO
