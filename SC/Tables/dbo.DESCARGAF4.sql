SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DESCARGAF4] (
		[F4_CODIGO]           [int] IDENTITY(1, 1) NOT NULL,
		[F4_FOLIO]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[F4_NOPARTEEXP]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[F4_CANTIDADEXP]      [decimal](38, 6) NULL,
		[F4_NOPARTEDESC]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[F4_PATENTEIMP]       [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[F4_PEDIMENTOIMP]     [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[F4_CANTTOTDESC]      [decimal](38, 6) NULL,
		[F4_CANTDESC]         [decimal](38, 6) NULL,
		[FED_INDICED]         [int] NULL,
		CONSTRAINT [IX_DESCARGAF4]
		UNIQUE
		NONCLUSTERED
		([F4_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
