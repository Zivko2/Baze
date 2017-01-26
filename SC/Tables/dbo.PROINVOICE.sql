SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PROINVOICE] (
		[TD_CODIGO]         [int] NOT NULL,
		[FD_CODIGO]         [int] NOT NULL,
		[PN_FOLIO]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PN_FEC]            [datetime] NULL,
		[PA_CODIGO]         [int] NOT NULL,
		[PN_COMM_TERM]      [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PN_PRE_CARRI]      [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PN_LETT_CRED]      [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PN_NOTIFY]         [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PN_FEC_SALE]       [datetime] NULL,
		[PN_EXCH_RATE]      [int] NOT NULL,
		[MO_CODIGO]         [int] NOT NULL,
		[PN_EXP_NO]         [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PN_PART_TRANS]     [smallint] NOT NULL,
		[PN_DEC_GOOD]       [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PN_TOTAL_CAL]      [smallint] NOT NULL,
		[PN_ABOVE_PRIC]     [smallint] NOT NULL,
		[PN_FRGHT_CHRG]     [smallint] NOT NULL,
		[PN_FRGHT_EXIT]     [decimal](38, 6) NOT NULL,
		[PN_FRGHT_DEST]     [decimal](38, 6) NOT NULL,
		[PN_FRGHT_CUR]      [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PN_CONT]           [smallint] NOT NULL,
		[PN_RAZON_EXP]      [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PN_ESTATUS]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TE_CODIGO]         [smallint] NOT NULL,
		[PN_MARKS_NO]       [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PN_REMARKS]        [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PN_DUTY_CHARG]     [smallint] NOT NULL,
		[PN_DIF_EXP]        [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[US_CODIGO]         [smallint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
