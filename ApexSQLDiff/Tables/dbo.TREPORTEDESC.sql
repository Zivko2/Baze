SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TREPORTEDESC] (
		[TRD_NOMBRE_RTM]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TRD_NOMBRE]          [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRD_DESCRIPCION]     [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRD_DESCRIPTION]     [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRD_INFO]            [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRD_INFOI]           [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TRD_OBSERVA]         [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CR_CODIGO]           [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TREPORTEDESC]
	ADD
	CONSTRAINT [PK_TREPORTEDESC]
	PRIMARY KEY
	NONCLUSTERED
	([TRD_NOMBRE_RTM])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[TREPORTEDESC] SET (LOCK_ESCALATION = TABLE)
GO
