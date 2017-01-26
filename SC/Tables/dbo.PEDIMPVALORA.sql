SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PEDIMPVALORA] (
		[PIV_CODIGO]              [int] IDENTITY(1, 1) NOT NULL,
		[PI_CODIGO]               [int] NOT NULL,
		[PIV_DETCOMVENNAC]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_DETVINCAFECPREC]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_DETRESTRIC]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_DETCONTRA]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_DETREG]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_VTNOCOMVEN]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_VTNOTERRNAC]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_VTVINNOPREC]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_VTRESENAJENA]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_VTCONTRA]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_METMERCIDENT]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_METMERCSIM]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_METPRECIOUNI]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_METRECONST]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIV_METART78]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_PEDIMPVALORA]
		UNIQUE
		NONCLUSTERED
		([PIV_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [PK_PEDIMPVALORA]
	PRIMARY KEY
	CLUSTERED
	([PI_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_DETCOMVENNAC]
	DEFAULT ('N') FOR [PIV_DETCOMVENNAC]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_DETCONTRA]
	DEFAULT ('N') FOR [PIV_DETCONTRA]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_DETREG]
	DEFAULT ('N') FOR [PIV_DETREG]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_DETRESTRIC]
	DEFAULT ('N') FOR [PIV_DETRESTRIC]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_DETVINCAFECPREC]
	DEFAULT ('N') FOR [PIV_DETVINCAFECPREC]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_METART78]
	DEFAULT ('N') FOR [PIV_METART78]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_METMERCIDENT]
	DEFAULT ('N') FOR [PIV_METMERCIDENT]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_METMERCSIM]
	DEFAULT ('N') FOR [PIV_METMERCSIM]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_METPRECIOUNI]
	DEFAULT ('N') FOR [PIV_METPRECIOUNI]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_METRECONST]
	DEFAULT ('N') FOR [PIV_METRECONST]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_VTCONTRA]
	DEFAULT ('N') FOR [PIV_VTCONTRA]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_VTNOCOMVEN]
	DEFAULT ('N') FOR [PIV_VTNOCOMVEN]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_VTNOTERRNAC]
	DEFAULT ('N') FOR [PIV_VTNOTERRNAC]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_VTRESENAJENA]
	DEFAULT ('N') FOR [PIV_VTRESENAJENA]
GO
ALTER TABLE [dbo].[PEDIMPVALORA]
	ADD
	CONSTRAINT [DF_PEDIMPVALORA_PIV_VTVINNOPREC]
	DEFAULT ('N') FOR [PIV_VTVINNOPREC]
GO
