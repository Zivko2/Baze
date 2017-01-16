SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[identificaresp] (
		[IDE_CODIGO]         [int] IDENTITY(1, 1) NOT NULL,
		[IDE_CLAVE]          [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDE_NOMBRE]         [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDE_DESC]           [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDE_NIVEL]          [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDE_TIPO]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDE_CANTCAMP]       [smallint] NOT NULL,
		[IDE_INCLUIDOAP]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDE_MOTIVO]         [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDE_IDENTPERM]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDE_TABLA]          [int] NOT NULL,
		[IDE_CAMPO]          [int] NOT NULL,
		[IDE_CAMPO2]         [int] NOT NULL,
		[IDE_APLICA]         [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDE_USAFACT]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDE_MOTIVOB]        [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDE_TIPOB]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDE_TABLAB]         [int] NULL,
		[IDE_CAMPOB]         [int] NULL,
		[IDE_CAMPO2B]        [int] NULL,
		[IDE_MOTIVOC]        [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDE_TIPOC]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDE_TABLAC]         [int] NULL,
		[IDE_CAMPOC]         [int] NULL,
		[IDE_CAMPO2C]        [int] NULL,
		[IDE_OBSOLETO]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[identificaresp] SET (LOCK_ESCALATION = TABLE)
GO
