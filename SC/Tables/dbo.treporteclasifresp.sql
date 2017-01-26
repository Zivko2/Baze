SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[treporteclasifresp] (
		[CR_Codigo]          [int] IDENTITY(1, 1) NOT NULL,
		[CR_Descripcion]     [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CR_Description]     [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CR_FORMA]           [int] NOT NULL,
		[CR_PRINCIPAL]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CR_IMPRESION]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
