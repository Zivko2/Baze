SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_GeneraTempPedImpDet] (@pi_codigo varchar(20))   as



if not exists (select * from sysobjects where name='TempPedImpDet'+@pi_codigo)
begin
exec ('CREATE TABLE [dbo].[TempPedImpDet'+@pi_codigo+'] (
	[PI_CODIGO] [int] NOT NULL ,
	[PID_INDICED] [int] IDENTITY (1, 1) NOT NULL ,
	[MA_CODIGO] [int] NOT NULL ,
	[PID_NOPARTE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_NOPARTE] DEFAULT (''''),
	[PID_NOMBRE] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PID_NAME] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PID_COS_UNI] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_COS_UNI] DEFAULT (0),
	[PID_COS_UNIADU] decimal(38,6) NULL ,
	[PID_COS_UNIGEN] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_COS_UNIGEN] DEFAULT (0),
	[PID_COS_UNIVA] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_COS_UNIVA] DEFAULT (0),
	[PID_COS_UNIMATGRA] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_COS_UNIGRA] DEFAULT (0),
	[PID_CANT] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_CANT] DEFAULT (0),
	[PID_CAN_AR] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_CAN_AR] DEFAULT (0),
	[PID_CAN_GEN] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_CAN_GEN] DEFAULT (0),
	[PID_VAL_ADU] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_VAL_ADU] DEFAULT (0),
	[PID_CTOT_DLS] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_CTOT_DLS] DEFAULT (0),
	[PID_PES_UNI] decimal(38,6) NULL ,
	[PID_PES_NET] decimal(38,6) NULL ,
	[PID_PES_TOT] decimal(38,6) NULL ,
	[ME_CODIGO] [int] NULL ,
	[ME_GENERICO] [int] NULL ,
	[MA_GENERICO] [int] NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_MA_GENERICO] DEFAULT (0),
	[EQ_GENERICO] decimal(28,14) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_EQ_GENERICO] DEFAULT (1),
	[EQ_IMPMX] decimal(28,14) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_EQ_IMPMX] DEFAULT (1),
	[AR_IMPMX] [int] NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_AR_IMPMX] DEFAULT (0),
	[ME_ARIMPMX] [int] NULL ,
	[AR_EXPFO] [int] NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_AR_EXPFO] DEFAULT (0),
	[PID_RATEEXPFO] decimal(38,6) NULL ,
	[PID_SEC_IMP] [smallint] NULL ,
	[PID_DEF_TIP] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_DEF_TIP] DEFAULT (''G''),
	[PID_POR_DEF] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_POR_DEF] DEFAULT (0),
	[CS_CODIGO] [smallint] NULL ,
	[PID_SALDOGEN] decimal(38,6) NULL ,
	[TI_CODIGO] [smallint] NOT NULL ,
	[PA_ORIGEN] [int] NULL ,
	[PA_PROCEDE] [int] NULL ,
	[ES_ORIGEN] [int] NULL ,
	[ES_DESTINO] [int] NULL ,
	[ES_COMPRADOR] [int] NULL ,
	[ES_VENDEDOR] [int] NULL ,
	[SPI_CODIGO] [smallint] NULL ,
	[PR_CODIGO] [int] NULL ,
	[PID_IMPRIMIR] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_IMPRIMIR] DEFAULT (''S''),
	[PID_GENERA_EMP] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PID_CANT_DESP] decimal(38,6) NULL ,
	[PID_DESCARGABLE] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_DESCARGABLE] DEFAULT (''S''),
	[PID_MA_CODIGOPADREKIT] [int] NULL ,
	[PID_REGIONFIN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempPedImpDet'+@pi_codigo+'_PID_REGIONFIN] DEFAULT (''F''),
	[SE_CODIGO] [int] NULL ,
	CONSTRAINT [IX_TempPedImpDet'+@pi_codigo+'] UNIQUE  NONCLUSTERED 
	(
		[PID_INDICED]
	)  ON [PRIMARY] 
) ON [PRIMARY]')
end

exec ('declare @maximo int

TRUNCATE TABLE TempPedImpDet'+@pi_codigo+'

SELECT     @maximo= MAX(PID_INDICED)+1
FROM         dbo.PEDIMPDET

	dbcc checkident (TempPedimpdet'+@pi_codigo+', reseed, @maximo) WITH NO_INFOMSGS')

GO
