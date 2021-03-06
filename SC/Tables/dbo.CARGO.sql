SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CARGO] (
		[CAR_CODIGO]      [int] NOT NULL,
		[CAR_ABREVIA]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CAR_DESC]        [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CAR_TIPO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CARGO]
	ADD
	CONSTRAINT [PK_CARGO]
	PRIMARY KEY
	CLUSTERED
	([CAR_ABREVIA])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CARGO]
	ADD
	CONSTRAINT [DF_CARGO_CAR_ABREVIA]
	DEFAULT ('') FOR [CAR_ABREVIA]
GO
ALTER TABLE [dbo].[CARGO]
	ADD
	CONSTRAINT [DF_CARGO_CAR_DESC]
	DEFAULT ('') FOR [CAR_DESC]
GO
ALTER TABLE [dbo].[CARGO]
	ADD
	CONSTRAINT [DF_CARGO_CAR_TIPO]
	DEFAULT ('T') FOR [CAR_TIPO]
GO
