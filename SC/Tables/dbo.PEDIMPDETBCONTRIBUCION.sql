SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[PEDIMPDETBCONTRIBUCION] (
		[PIB_CODIGO]            [int] IDENTITY(1, 1) NOT NULL,
		[PIB_INDICEB]           [int] NOT NULL,
		[PI_CODIGO]             [int] NOT NULL,
		[CON_CODIGO]            [smallint] NOT NULL,
		[PIB_CONTRIBPOR]        [decimal](38, 6) NOT NULL,
		[PIB_CONTRIBAPLICA]     [decimal](38, 6) NOT NULL,
		[PIB_CONTRIBTOTMN]      [decimal](38, 6) NOT NULL,
		[PG_CODIGO]             [smallint] NOT NULL,
		[TTA_CODIGO]            [smallint] NULL,
		CONSTRAINT [IX_PEDIMPDETBCONTRIBUCION]
		UNIQUE
		NONCLUSTERED
		([PIB_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPDETBCONTRIBUCION]
	ADD
	CONSTRAINT [PK_PEDIMPDETBCONTRIBUCION]
	PRIMARY KEY
	CLUSTERED
	([PIB_INDICEB], [CON_CODIGO], [PIB_CONTRIBPOR], [PG_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPDETBCONTRIBUCION]
	ADD
	CONSTRAINT [DF_PEDIMPDETBCONTRIBUCION_PG_CODIGO]
	DEFAULT (6) FOR [PG_CODIGO]
GO
ALTER TABLE [dbo].[PEDIMPDETBCONTRIBUCION]
	ADD
	CONSTRAINT [DF_PEDIMPDETBCONTRIBUCION_PIB_CONTRIBAPLICA]
	DEFAULT (100) FOR [PIB_CONTRIBAPLICA]
GO
ALTER TABLE [dbo].[PEDIMPDETBCONTRIBUCION]
	ADD
	CONSTRAINT [DF_PEDIMPDETBCONTRIBUCION_PIB_CONTRIBPOR]
	DEFAULT ((-1)) FOR [PIB_CONTRIBPOR]
GO
