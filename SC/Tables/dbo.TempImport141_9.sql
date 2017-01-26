SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempImport141_9] (
		[Col_2]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Col_3]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Col_4]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Col_5]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Col_6]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Col_7]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Col_8]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAESTROCOST9#MA_COSTO]          [float] NULL,
		[MAESTRO9#MA_NOPARTEAUX]         [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAESTROCOST9#SPI_CODIGO]        [int] NULL,
		[MAESTROCOST9#MA_PERINI]         [datetime] NULL,
		[MAESTROCOST9#TCO_CODIGO]        [smallint] NULL,
		[MAESTRO9#MA_INV_GEN]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAESTRO9#MA_NOPARTE]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAESTROCOST9#MA_GRAV_MP]        [float] NULL,
		[MAESTROCOST9#MA_NG_MP]          [float] NULL,
		[MAESTROCOST9#MA_GRAV_EMP]       [float] NULL,
		[MAESTROCOST9#MA_NG_EMP]         [float] NULL,
		[MAESTROCOST9#MA_GRAV_ADD]       [float] NULL,
		[MAESTROCOST9#MA_GRAV_GI_MX]     [float] NULL,
		[MAESTROCOST9#MA_GRAV_MO]        [float] NULL,
		[MAESTRODEF9#MA_DEFNO1]          [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempImport141_9]
	ADD
	CONSTRAINT [DF__TempImpor__MAEST__597BBAC8]
	DEFAULT ((0)) FOR [MAESTROCOST9#MA_COSTO]
GO
