SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ENTRYSUM] (
		[ET_CODIGO]             [int] NOT NULL,
		[ET_ENTRY_NO]           [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EA_ENTRADA]            [smallint] NULL,
		[EB_ENTRADA]            [smallint] NULL,
		[ET_FEC_ENTRY]          [datetime] NOT NULL,
		[ET_FEC_ENTRYS]         [datetime] NOT NULL,
		[ET_FEC_GEN]            [datetime] NOT NULL,
		[ET_FEC_IMP]            [datetime] NOT NULL,
		[ET_BOND]               [smallint] NULL,
		[BT_BTIPO]              [smallint] NULL,
		[AG_CODIGO]             [smallint] NULL,
		[PA_CODIGO]             [int] NULL,
		[ET_MISMAYOR2]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MI_CODIGO]             [smallint] NULL,
		[MI_CODIGO2]            [smallint] NULL,
		[PU_FOREING]            [int] NULL,
		[PU_ENTRADA]            [int] NULL,
		[ET_LOCAT]              [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[US_DECLARANT]          [smallint] NULL,
		[ET_IDECLARE]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ET_FURTHER]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ET_VOYAGE]             [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ET_DES_GRAL]           [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ET_MANIFEST]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ET_BL_AWB]             [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ET_NO_INB]             [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ET_FEC_INB]            [datetime] NULL,
		[ET_IMPORTER]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ET_DLLS_MPF]           [decimal](38, 6) NOT NULL,
		[ET_DLLS_RATE]          [decimal](38, 6) NOT NULL,
		[ET_DLLS_IRC]           [decimal](38, 6) NOT NULL,
		[ET_DLLS_VISA]          [decimal](38, 6) NOT NULL,
		[ET_FLAGGED]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ET_FIRMS]              [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PU_ARRIBO]             [int] NULL,
		[ET_MANIFIESTDATE]      [datetime] NULL,
		[ET_ARRIBODATE]         [datetime] NULL,
		[MT_CODIGO]             [smallint] NULL,
		[ET_MANIFIESTDESC1]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ET_MANIFIESTDESC2]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_CODIGO]             [int] NULL,
		[US_INCHARGE]           [smallint] NULL,
		[ET_DLLS_TOTAL]         [decimal](38, 6) NULL,
		[TRM_CODIGO]            [int] NULL,
		[ETC_CODIGO]            [int] NOT NULL,
		CONSTRAINT [IX_ENTRYSUM]
		UNIQUE
		NONCLUSTERED
		([ET_CODIGO])
		ON [PRIMARY],
		CONSTRAINT [IX_ENTRYSUM_1]
		UNIQUE
		NONCLUSTERED
		([ET_ENTRY_NO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [PK_ENTRYSUM]
	PRIMARY KEY
	CLUSTERED
	([ET_CODIGO], [ET_ENTRY_NO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [DF_ENTRYSUM_ET_DLLS_IRC]
	DEFAULT (0) FOR [ET_DLLS_IRC]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [DF_ENTRYSUM_ET_DLLS_MPF]
	DEFAULT (0) FOR [ET_DLLS_MPF]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [DF_ENTRYSUM_ET_DLLS_RATE]
	DEFAULT (0) FOR [ET_DLLS_RATE]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [DF_ENTRYSUM_ET_DLLS_VISA]
	DEFAULT (0) FOR [ET_DLLS_VISA]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [DF_ENTRYSUM_ET_FLAGGED]
	DEFAULT ('N') FOR [ET_FLAGGED]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [DF_ENTRYSUM_ET_FURTHER]
	DEFAULT ('X') FOR [ET_FURTHER]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [DF_ENTRYSUM_ET_IDECLARE]
	DEFAULT ('X') FOR [ET_IDECLARE]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [DF_ENTRYSUM_ET_LOCAT]
	DEFAULT ('') FOR [ET_LOCAT]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [DF_ENTRYSUM_ET_MISMAYOR2]
	DEFAULT ('N') FOR [ET_MISMAYOR2]
GO
ALTER TABLE [dbo].[ENTRYSUM]
	ADD
	CONSTRAINT [DF_ENTRYSUM_ETC_CODIGO]
	DEFAULT (0) FOR [ETC_CODIGO]
GO
