SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_GeneraTempPedImpDetB] (@pi_codigo varchar(20))   as


if not exists (select * from sysobjects where name='TempPedImpDetB'+@pi_codigo)
begin
exec ('CREATE TABLE [dbo].[TempPedimpDetB'+@pi_codigo+'] (
	[PI_CODIGO] [int] NOT NULL ,
	[PIB_COS_UNIGEN] decimal(38,6) NULL ,
	[PIB_COS_UNIGRA] decimal(38,6) NULL ,
	[PIB_COS_UNIVA] decimal(38,6) NULL ,
	[PIB_CANT] decimal(38,6) NULL ,
	[PIB_CAN_AR] decimal(38,6) NULL ,
	[PIB_CAN_GEN] decimal(38,6) NULL ,
	[PIB_VAL_FAC] decimal(38,6) NULL ,
	[PIB_VAL_ADU] decimal(38,6) NULL ,
	[PIB_VAL_US] decimal(38,6) NULL ,
	[PIB_ESTADO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AR_IMPMX] [int] NULL ,
	[PIB_POR_DEF] decimal(38,6) NULL ,
	[ME_ARIMPMX] [int] NULL ,
	[MA_GENERICO] [int] NULL ,
	[ME_GENERICO] [int] NULL ,
	[PA_ORIGEN] [int] NULL ,
	[PA_PROCEDE] [int] NULL ,
	[ES_ORIGEN] [int] NULL ,
	[ES_DESTINO] [int] NULL ,
	[ES_COMPRADOR] [int] NULL ,
	[ES_VENDEDOR] [int] NULL ,
	[PIB_SECUENCIA] [int] IDENTITY (1, 1) NOT NULL ,
	[AR_EXPFO] [int] NULL ,
	[PIB_RATEEXPFO] decimal(38,6) NULL ,
	[EQ_EXPFO] decimal(28,14) NOT NULL CONSTRAINT [DF_TempPedimpDetB'+@pi_codigo+'_EQ_EXPFO] DEFAULT (1),
	[PIB_VALORMCIANOORIG] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedimpDetB'+@pi_codigo+'_PIB_VALORMCIANOORIG] DEFAULT (0),
	[PIB_ADVMNIMPUSA] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedimpDetB'+@pi_codigo+'_PI_ADVMNIMPUSA] DEFAULT (0),
	[PIB_ADVMNIMPMEX] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedimpDetB'+@pi_codigo+'_PI_ADVMNIMPMEX] DEFAULT (0),
	[PIB_EXCENCION] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedimpDetB'+@pi_codigo+'_PI_EXCENCION] DEFAULT (0),
	[PIB_IMPORTECONTRSINRECARGOS] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedimpDetB'+@pi_codigo+'_PI_IMPORTECONTRSINRECARGOS] DEFAULT (0),
	[PIB_IMPORTECONTR] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedimpDetB'+@pi_codigo+'_PI_IMPORTECONTR] DEFAULT (0),
	[PIB_IMPORTERECARGOS] decimal(38,6) NOT NULL CONSTRAINT [DF_TempPedimpDetB'+@pi_codigo+'_PI_IMPORTERECARGOS] DEFAULT (0),
	[PIB_DESTNAFTA] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempPedimpDetB'+@pi_codigo+'_PIB_DESTNAFTA] DEFAULT (''S''),
	[PIB_NOMBRE] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	CONSTRAINT [IX_TempPedimpDetB'+@pi_codigo+'] UNIQUE  NONCLUSTERED 
	(
		[PIB_SECUENCIA]
	)  ON [PRIMARY] 
) ON [PRIMARY]')
end


exec ('declare @maximo int

TRUNCATE TABLE TempPedImpDetB'+@pi_codigo+'

SELECT @maximo= ISNULL(max(pib_secuencia),0)+1 from pedimpdetb where pi_codigo='+@pi_codigo +'

	dbcc checkident (TempPedimpdetB'+@pi_codigo+', reseed, @maximo) WITH NO_INFOMSGS')




GO
