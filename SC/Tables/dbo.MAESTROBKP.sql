SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MAESTROBKP] (
		[MA_CODIGO]             [int] NOT NULL,
		[MA_NOPARTE]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_INV_GEN]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TI_CODIGO]             [smallint] NOT NULL,
		[CS_CODIGO]             [smallint] NOT NULL,
		[MA_NOMBRE]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_NAME]               [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_TIP_ENS]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ME_COM]                [int] NOT NULL,
		[ME_ALM]                [int] NULL,
		[EQ_GEN]                [float] NOT NULL,
		[EQ_IMPMX]              [float] NOT NULL,
		[EQ_ALM]                [float] NOT NULL,
		[EQ_EXPMX]              [float] NOT NULL,
		[EQ_IMPFO]              [float] NOT NULL,
		[EQ_RETRA]              [float] NOT NULL,
		[EQ_DESP]               [float] NOT NULL,
		[EQ_EXPFO]              [float] NOT NULL,
		[PA_ORIGEN]             [int] NOT NULL,
		[PA_PROCEDE]            [int] NOT NULL,
		[MA_CONSTA]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_GENERICO]           [int] NOT NULL,
		[MA_FAMILIA]            [int] NOT NULL,
		[MA_FAMILIAMP]          [int] NOT NULL,
		[MA_EXPENS]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_DEF_TIP]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_PESO_KG]            [float] NOT NULL,
		[MA_PESO_LB]            [float] NOT NULL,
		[MA_EST_MAT]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_MARCA]              [varchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_COLOR]              [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_MODELO]             [varchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MP_CODIGO]             [smallint] NULL,
		[MA_EMP_PEL]            [int] NOT NULL,
		[MA_IDENTI]             [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_IMPMX]              [int] NULL,
		[AR_EXPMX]              [int] NULL,
		[AR_IMPFO]              [int] NULL,
		[AR_RETRA]              [int] NULL,
		[AR_DESP]               [int] NULL,
		[AR_EXPFO]              [int] NULL,
		[CX_CODIGO]             [smallint] NULL,
		[MA_TALLA]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_ESTILO]             [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_DISCHARGE]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SE_CODIGO]             [smallint] NULL,
		[MA_SEC_IMP]            [smallint] NULL,
		[SPI_CODIGO]            [smallint] NULL,
		[MA_REPARA]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_GENERA_EMP]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_EMPAQUE]            [int] NULL,
		[MA_CANTEMP]            [float] NOT NULL,
		[MA_NOPARTEAUX]         [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CC_CODIGO]             [int] NULL,
		[MA_PELIGROSO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AR_IMPFOUSA]           [int] NULL,
		[EQ_IMPFOUSA]           [float] NOT NULL,
		[AR_IMPEMPFOUSA]        [int] NULL,
		[EQ_IMPEMPFOUSA]        [float] NULL,
		[MA_SEL]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_EMPFACT]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_TIEMPOENSMIN]       [float] NOT NULL,
		[TEM_CODIGO]            [int] NULL,
		[MA_SERVICIO]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_OCULTO]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_TONMAQUINAS]        [float] NULL,
		[PA_CORTE]              [int] NULL,
		[MA_TRANS]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_SOLOBOM]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_ESTRUCTURA]         [int] NULL,
		[MA_DESCOSTOARR]        [smallint] NOT NULL,
		[MA_DESCOSTOABA]        [smallint] NOT NULL,
		[MA_ENUSO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_YEAR]               [int] NULL,
		[EQ_EXPFO2]             [float] NOT NULL,
		[LIN_CODIGO]            [int] NULL,
		[MA_ULTIMAMODIF]        [datetime] NULL,
		[MA_MULTIPAIS]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_NAFTATEMP]          [smallint] NOT NULL,
		[AR_DESPMX]             [int] NULL,
		[EQ_DESPMX]             [float] NOT NULL,
		[AR_IMPMXR8]            [int] NULL,
		[EQ_IMPMXR8]            [float] NOT NULL,
		[MA_SEC_IMPCERTDEF]     [int] NOT NULL,
		[MA_NOMBREDESP]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MA_NAMEDESP]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
