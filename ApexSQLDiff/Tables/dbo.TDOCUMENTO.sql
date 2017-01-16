SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TDOCUMENTO] (
		[TD_CODIGO]           [int] IDENTITY(1, 1) NOT NULL,
		[TD_NOMBRE]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TD_TIPO_DOC]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TD_TIPO_FAC]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TD_NOMBRE_TABLA]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TD_NUM_FORMA]        [smallint] NOT NULL,
		[TD_COLUMNA]          [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TD_ENTRY]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TD_TIPOAGRU]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_TDOCUMENTO]
		UNIQUE
		NONCLUSTERED
		([TD_CODIGO])
		WITH FILLFACTOR=90
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TDOCUMENTO]
	ADD
	CONSTRAINT [PK_TDOCUMENTO]
	PRIMARY KEY
	NONCLUSTERED
	([TD_NOMBRE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[TDOCUMENTO]
	ADD
	CONSTRAINT [DF_TDOCUMENTO_TD_ENTRY]
	DEFAULT ('F') FOR [TD_ENTRY]
GO
ALTER TABLE [dbo].[TDOCUMENTO] SET (LOCK_ESCALATION = TABLE)
GO
