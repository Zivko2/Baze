SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[cERRARSALDOS] (
		[Pedimento]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FechaPed]           [datetime] NULL,
		[PID_FECHAVENCE]     [datetime] NULL,
		[ClavePed]           [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[NoParte]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_NOMBRE]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Saldo]              [decimal](38, 6) NOT NULL,
		[Tipo]               [smallint] NOT NULL,
		[Grupo]              [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CantidadUMImp]      [decimal](38, 6) NOT NULL,
		[UMImp]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CantidadGen]        [decimal](38, 6) NOT NULL,
		[UMG]                [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ValorDlls]          [decimal](38, 6) NOT NULL,
		[CantDescargada]     [decimal](38, 6) NULL,
		[ValorSaldo]         [decimal](38, 6) NULL
) ON [PRIMARY]
GO
