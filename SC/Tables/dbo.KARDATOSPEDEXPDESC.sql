SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KARDATOSPEDEXPDESC] (
		[KAP_CODIGO]           [int] NOT NULL,
		[KAP_PED_CONST]        [int] NULL,
		[KAP_INDICED_PED]      [int] NULL,
		[KAP_INDICED_FACT]     [int] NULL,
		[PI_CODIGOPEDEXP]      [int] NOT NULL,
		[PIB_INDICEB]          [int] NULL,
		[KAP_CANTDESC]         [decimal](38, 6) NULL,
		[PI_TIP_CAM]           [decimal](38, 6) NULL,
		[MA_CODIGO]            [int] NULL,
		[PID_NOPARTE]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_NOMBRE]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_COS_UNI]          [decimal](38, 6) NULL,
		[AR_IMPMX]             [int] NULL,
		[PID_POR_DEF]          [decimal](38, 6) NULL,
		[KAP_DEF_TIP]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_PAGACONTRIB]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_SECIMP]           [smallint] NULL,
		[SPI_CODIGO]           [smallint] NULL,
		[PA_ORIGEN]            [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KARDATOSPEDEXPDESC]
	ADD
	CONSTRAINT [PK_KARDATOSPEDEXPDESC]
	PRIMARY KEY
	CLUSTERED
	([KAP_CODIGO], [PI_CODIGOPEDEXP])
	ON [PRIMARY]
GO
