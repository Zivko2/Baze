SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[ImprimeEtiquetas] (
		[eti_consecutivo]     [smallint] IDENTITY(1, 1) NOT NULL,
		[FST_CODIGO]          [int] NULL,
		CONSTRAINT [IX_ImprimeEtiquetas]
		UNIQUE
		NONCLUSTERED
		([eti_consecutivo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
