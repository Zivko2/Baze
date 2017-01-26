SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[IMPORTSPECSGRPDET] (
		[IMGD_INDICED]     [int] NOT NULL,
		[IMG_CODIGO]       [int] NOT NULL,
		[IMS_CODIGO]       [int] NOT NULL,
		[IMGD_ORDEN]       [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPORTSPECSGRPDET]
	ADD
	CONSTRAINT [PK_IMPORTSPECSGRPDET]
	PRIMARY KEY
	CLUSTERED
	([IMG_CODIGO], [IMS_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPORTSPECSGRPDET]
	ADD
	CONSTRAINT [DF_IMPORTSPECSGRPDET_IMGD_ORDEN]
	DEFAULT (1) FOR [IMGD_ORDEN]
GO
