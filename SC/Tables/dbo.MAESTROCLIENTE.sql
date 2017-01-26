SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MAESTROCLIENTE] (
		[MC_CODIGO]         [int] NOT NULL,
		[MA_CODIGO]         [int] NOT NULL,
		[CL_CODIGO]         [int] NOT NULL,
		[MC_NOPARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MC_GRAV_UNI]       [decimal](38, 6) NOT NULL,
		[MC_NG_UNI]         [decimal](38, 6) NOT NULL,
		[MC_PRECIO]         [decimal](38, 6) NOT NULL,
		[MC_VTR]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MC_NG_MP]          [decimal](38, 6) NOT NULL,
		[MC_NG_EMP]         [decimal](38, 6) NOT NULL,
		[MC_GRAV_MP]        [decimal](38, 6) NOT NULL,
		[MC_GRAV_EMP]       [decimal](38, 6) NOT NULL,
		[MC_GRAV_GI]        [decimal](38, 6) NOT NULL,
		[MC_GRAV_GI_MX]     [decimal](38, 6) NOT NULL,
		[MC_GRAV_MO]        [decimal](38, 6) NOT NULL,
		[MC_GRAVA_VA]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_MAESTROCLIENTE]
		UNIQUE
		NONCLUSTERED
		([MC_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [PK_MAESTROCLIENTE]
	PRIMARY KEY
	NONCLUSTERED
	([MA_CODIGO], [CL_CODIGO], [MC_VTR])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_CL_CODIGO]
	DEFAULT (0) FOR [CL_CODIGO]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_GRAV_EMP]
	DEFAULT (0) FOR [MC_GRAV_EMP]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_GRAV_GI]
	DEFAULT (0) FOR [MC_GRAV_GI]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_GRAV_GI_MX]
	DEFAULT (0) FOR [MC_GRAV_GI_MX]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_GRAV_MO]
	DEFAULT (0) FOR [MC_GRAV_MO]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_GRAV_MP]
	DEFAULT (0) FOR [MC_GRAV_MP]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_GRAV_UNI]
	DEFAULT (0) FOR [MC_GRAV_UNI]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_GRAVA_VA]
	DEFAULT ('S') FOR [MC_GRAVA_VA]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_NG_EMP]
	DEFAULT (0) FOR [MC_NG_EMP]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_NG_MP]
	DEFAULT (0) FOR [MC_NG_MP]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_NG_UNI]
	DEFAULT (0) FOR [MC_NG_UNI]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_NOPARTE]
	DEFAULT ('') FOR [MC_NOPARTE]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_PRECIO]
	DEFAULT (0) FOR [MC_PRECIO]
GO
ALTER TABLE [dbo].[MAESTROCLIENTE]
	ADD
	CONSTRAINT [DF_MAESTROCLIENTE_MC_VTR]
	DEFAULT ('N') FOR [MC_VTR]
GO
CREATE CLUSTERED INDEX [IX_MAESTROCLIENTE_1]
	ON [dbo].[MAESTROCLIENTE] ([MA_CODIGO], [MC_CODIGO])
	ON [PRIMARY]
GO
