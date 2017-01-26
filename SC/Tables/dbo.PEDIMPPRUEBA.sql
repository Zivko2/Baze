SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PEDIMPPRUEBA] (
		[PI_CODIGO]           [int] NOT NULL,
		[PIS_FOLIODOC]        [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIS_FECHADOC]        [datetime] NOT NULL,
		[PRU_CODIGO]          [smallint] NULL,
		[PIS_IMPUESTOUSA]     [decimal](38, 6) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPPRUEBA]
	ADD
	CONSTRAINT [PK_PEDIMPPRUEBA]
	PRIMARY KEY
	NONCLUSTERED
	([PI_CODIGO], [PIS_FOLIODOC])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPPRUEBA]
	ADD
	CONSTRAINT [DF_PEDIMPPRUEBA_PIS_IMPUESTOUSA]
	DEFAULT (0) FOR [PIS_IMPUESTOUSA]
GO
