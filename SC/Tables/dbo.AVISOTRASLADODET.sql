SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AVISOTRASLADODET] (
		[ATID_INDICED]          [int] NOT NULL,
		[ATI_CODIGO]            [int] NOT NULL,
		[MA_CODIGO]             [int] NOT NULL,
		[ATID_NOPARTE]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ATID_NOMBRE]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ATID_CANT]             [decimal](38, 6) NULL,
		[ATID_COS_TOT]          [decimal](38, 6) NULL,
		[ME_CODIGO]             [int] NULL,
		[ATID_TIP_ENS]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ATID_FECHA_STRUCT]     [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AVISOTRASLADODET]
	ADD
	CONSTRAINT [PK_AVISOTRASLADODET]
	PRIMARY KEY
	CLUSTERED
	([ATID_INDICED])
	ON [PRIMARY]
GO
