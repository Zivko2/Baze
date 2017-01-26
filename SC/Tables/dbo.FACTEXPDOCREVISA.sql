SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTEXPDOCREVISA] (
		[FER_CODIGO]            [int] IDENTITY(1, 1) NOT NULL,
		[FE_CODIGO]             [int] NOT NULL,
		[FER_DOCUMENTO]         [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FER_OBSERVACIONES]     [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FER_REQUERIDO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FER_FECHA]             [datetime] NULL,
		[US_CODIGO]             [smallint] NULL,
		CONSTRAINT [IX_FACTEXPDOCREVISA]
		UNIQUE
		NONCLUSTERED
		([FER_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPDOCREVISA]
	ADD
	CONSTRAINT [PK_FACTEXPDOCREVISA]
	PRIMARY KEY
	CLUSTERED
	([FE_CODIGO], [FER_DOCUMENTO])
	ON [PRIMARY]
GO
