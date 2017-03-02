SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CopiaFracciones] (@BDOrigen varchar(50), @BDDestino varchar(50))    as

/*== fracciones arancelarias ==*/
	IF  NOT EXISTS (SELECT name 
		   FROM  [tempdb].dbo.sysobjects 
		   WHERE  (name = '##ARANCEL' )
		   AND 	 ( type = 'U'))
	begin
		
		CREATE TABLE [##ARANCEL] (
			[AR_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
			[AR_FRACCION] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[AR_DIGITO] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ARANCEL_AR_DIGITO] DEFAULT (''),
			[AR_OFICIAL] [varchar] (1500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[AR_USO] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ARANCEL_AR_USO] DEFAULT (''),
			[CS_CODIGO] [smallint] NULL ,
			[AR_TIPO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[AR_TIPOREG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ARANCEL_AR_TIPOREG] DEFAULT ('F'),
			[AR_LN_DESC] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ARANCEL_AR_LN_DESC] DEFAULT (''),
			[RA_CODIGO] [int] NULL ,
			[PA_CODIGO] [int] NOT NULL ,
			[ME_CODIGO] [int] NOT NULL ,
			[ME_CODIGO2] [int] NULL ,
			[VI_CODIGO] [smallint] NULL ,
			[TV_CODIGO] [smallint] NULL ,
			[AR_ESTADO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ARANCEL_AR_ESTADO] DEFAULT (''),
			[AR_FEC_REV] [datetime] NULL ,
			[AR_PERINI] [datetime] NOT NULL CONSTRAINT [DF_ARANCEL_AR_PERINI] DEFAULT ('1/1/1999'),
			[AR_PERFIN] [datetime] NOT NULL CONSTRAINT [DF_ARANCEL_AR_PERFIN] DEFAULT ('1/1/9999'),
			[AR_OBSERVA] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[PG_ADV] [smallint] NULL ,
			[PG_BEN] [smallint] NULL ,
			[PG_CUOTA] [smallint] NULL ,
			[PG_IVA] [smallint] NULL ,
			[PG_IEPS] [smallint] NULL ,
			[PG_ISAN] [smallint] NULL ,
			[AR_TIPOIMPUESTO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ARANCEL_AR_TIPOIMPUESTO] DEFAULT ('A'),
			[AR_CANTUMESP] [decimal](38, 6) NULL ,
			[AR_ESPEC] [decimal](38, 6) NULL ,
			[AR_PORCENT_8VA] [decimal](38, 6) NOT NULL CONSTRAINT [DF_ARANCEL_AR_PORCENT_8VA] DEFAULT ((-1)),
			[AR_ADVDEF] [decimal](38, 6) NOT NULL CONSTRAINT [DF_ARANCEL_AR_ADVDEF] DEFAULT ((-1)),
			[AR_CUOTA] [decimal](38, 6) NULL ,
			[AR_IVA] [decimal](38, 6) NOT NULL CONSTRAINT [DF_ARANCEL_AR_IVA] DEFAULT ((-1)),
			[AR_IVAFRANJA] [decimal](38, 6) NOT NULL CONSTRAINT [DF_ARANCEL_AR_IVAFRANJA] DEFAULT ((-1)),
			[AR_IEPS] [decimal](38, 6) NULL ,
			[AR_ISAN] [decimal](38, 6) NULL ,
			[ARR_CODIGO] [int] NULL ,
			[AR_CAPITULO] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[AR_DESCCAPITULO] [varchar] (1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[AR_PARTIDA] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[AR_DESCPARTIDA] [varchar] (1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[AR_FECHAREVISION] [datetime] NOT NULL CONSTRAINT [DF_ARANCEL_AR_FECHAREVISION] DEFAULT (convert(varchar(10),getdate(),101)),
			[AR_OBSOLETA] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ARANCEL_AR_OBSOLETA] DEFAULT ('N'),
			[AR_PAGAISAN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ARANCEL_AR_PAGAISAN] DEFAULT ('N'),
			[AR_ULTMODIFTIGIE] [datetime] NULL ,
			[AR_ADVFRONTERA] [decimal](38, 6) NOT NULL CONSTRAINT [DF_ARANCEL_AR_ADVFRONTERA] DEFAULT ((-1)),
			CONSTRAINT [PK_ARANCEL] PRIMARY KEY  NONCLUSTERED 
			(
				[AR_FRACCION],
				[AR_TIPO],
				[PA_CODIGO]
			)  ON [PRIMARY] ,
			CONSTRAINT [IX_ARANCEL] UNIQUE  NONCLUSTERED 
			(
				[AR_CODIGO]
			)  ON [PRIMARY] 
		) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	end

DECLARE @MAXIMO INT

SELECT @MAXIMO=ISNULL(MAX(AR_CODIGO),0)+1 FROM ARANCEL

DBCC CHECKIDENT ([##ARANCEL], RESEED, @MAXIMO)


EXEC('INSERT INTO ##ARANCEL (AR_FRACCION, AR_DIGITO, AR_OFICIAL, AR_USO, CS_CODIGO, AR_TIPO, AR_TIPOREG, AR_LN_DESC, RA_CODIGO, 
                      PA_CODIGO, ME_CODIGO, ME_CODIGO2, VI_CODIGO, TV_CODIGO, AR_ESTADO, AR_FEC_REV, AR_PERINI, AR_PERFIN, AR_OBSERVA, PG_ADV, 
                      PG_BEN, PG_CUOTA, PG_IVA, PG_IEPS, PG_ISAN, AR_TIPOIMPUESTO, AR_CANTUMESP, AR_ESPEC, AR_PORCENT_8VA, AR_ADVDEF, AR_CUOTA, 
                      AR_IVA, AR_IVAFRANJA, AR_IEPS, AR_ISAN, ARR_CODIGO, AR_CAPITULO, AR_DESCCAPITULO, AR_PARTIDA, AR_DESCPARTIDA, AR_FECHAREVISION, 
                      AR_OBSOLETA, AR_PAGAISAN, AR_ULTMODIFTIGIE, AR_ADVFRONTERA)

SELECT     AR_FRACCION, AR_DIGITO, AR_OFICIAL, AR_USO, CS_CODIGO, AR_TIPO, AR_TIPOREG, AR_LN_DESC, RA_CODIGO, 
                      PA_CODIGO, ME_CODIGO, ME_CODIGO2, VI_CODIGO, TV_CODIGO, AR_ESTADO, AR_FEC_REV, AR_PERINI, AR_PERFIN, AR_OBSERVA, PG_ADV, 
                      PG_BEN, PG_CUOTA, PG_IVA, PG_IEPS, PG_ISAN, AR_TIPOIMPUESTO, AR_CANTUMESP, AR_ESPEC, AR_PORCENT_8VA, AR_ADVDEF, AR_CUOTA, 
                      AR_IVA, AR_IVAFRANJA, AR_IEPS, AR_ISAN, ARR_CODIGO, AR_CAPITULO, AR_DESCCAPITULO, AR_PARTIDA, AR_DESCPARTIDA, AR_FECHAREVISION, 
                      AR_OBSOLETA, AR_PAGAISAN, AR_ULTMODIFTIGIE, AR_ADVFRONTERA
FROM         '+@BDOrigen+'.DBO.ARANCEL ARANCELOrig
WHERE AR_FRACCION NOT IN (SELECT AR_FRACCION FROM ARANCEL)')


INSERT INTO ARANCEL (AR_CODIGO, AR_FRACCION, AR_DIGITO, AR_OFICIAL, AR_USO, CS_CODIGO, AR_TIPO, AR_TIPOREG, AR_LN_DESC, RA_CODIGO, 
                      PA_CODIGO, ME_CODIGO, ME_CODIGO2, VI_CODIGO, TV_CODIGO, AR_ESTADO, AR_FEC_REV, AR_PERINI, AR_PERFIN, AR_OBSERVA, PG_ADV, 
                      PG_BEN, PG_CUOTA, PG_IVA, PG_IEPS, PG_ISAN, AR_TIPOIMPUESTO, AR_CANTUMESP, AR_ESPEC, AR_PORCENT_8VA, AR_ADVDEF, AR_CUOTA, 
                      AR_IVA, AR_IVAFRANJA, AR_IEPS, AR_ISAN, ARR_CODIGO, AR_CAPITULO, AR_DESCCAPITULO, AR_PARTIDA, AR_DESCPARTIDA, AR_FECHAREVISION, 
                      AR_OBSOLETA, AR_PAGAISAN, AR_ULTMODIFTIGIE, AR_ADVFRONTERA)

SELECT AR_CODIGO, AR_FRACCION, AR_DIGITO, AR_OFICIAL, AR_USO, CS_CODIGO, AR_TIPO, AR_TIPOREG, AR_LN_DESC, RA_CODIGO, 
                      PA_CODIGO, ME_CODIGO, ME_CODIGO2, VI_CODIGO, TV_CODIGO, AR_ESTADO, AR_FEC_REV, AR_PERINI, AR_PERFIN, AR_OBSERVA, PG_ADV, 
                      PG_BEN, PG_CUOTA, PG_IVA, PG_IEPS, PG_ISAN, AR_TIPOIMPUESTO, AR_CANTUMESP, AR_ESPEC, AR_PORCENT_8VA, AR_ADVDEF, AR_CUOTA, 
                      AR_IVA, AR_IVAFRANJA, AR_IEPS, AR_ISAN, ARR_CODIGO, AR_CAPITULO, AR_DESCCAPITULO, AR_PARTIDA, AR_DESCPARTIDA, AR_FECHAREVISION, 
                      AR_OBSOLETA, AR_PAGAISAN, AR_ULTMODIFTIGIE, AR_ADVFRONTERA
FROM ##ARANCEL

EXEC('INSERT INTO SECTORARA(AR_CODIGO, SE_CODIGO, SA_PORCENT, PG_CODIGO, SA_PERINI, SA_PERFIN)
SELECT     ARANCEL_1.AR_CODIGO, SECTORARAOrig.SE_CODIGO, SECTORARAOrig.SA_PORCENT, SECTORARAOrig.PG_CODIGO, SECTORARAOrig.SA_PERINI, 
                      SECTORARAOrig.SA_PERFIN
FROM         '+@BDOrigen+'.DBO.ARANCEL ARANCELOrig INNER JOIN
                      '+@BDOrigen+'.DBO.SECTORARA SECTORARAOrig ON ARANCELOrig.AR_CODIGO = SECTORARAOrig.AR_CODIGO INNER JOIN
                      ##ARANCEL ARANCEL_1 ON ARANCELOrig.AR_FRACCION = ARANCEL_1.AR_FRACCION
WHERE SECTORARAOrig.SE_CODIGO NOT IN (SELECT SE_CODIGO FROM SECTORARA WHERE AR_CODIGO=ARANCEL_1.AR_CODIGO)')


EXEC('INSERT INTO PAISARA(AR_CODIGO, PA_CODIGO, PAR_BEN, SPI_CODIGO, PAR_CUOTA, PAR_IVA, 
                      PAR_TLC, PAR_IEPS, PAR_ISAN, AR_TIPOIMPUESTO, PAR_PERINI, PAR_PERFIN)

SELECT     ARANCEL_1.AR_CODIGO, PAISARAOrig.PA_CODIGO, PAISARAOrig.PAR_BEN, PAISARAOrig.SPI_CODIGO, PAISARAOrig.PAR_CUOTA, PAISARAOrig.PAR_IVA, 
                      PAISARAOrig.PAR_TLC, PAISARAOrig.PAR_IEPS, PAISARAOrig.PAR_ISAN, PAISARAOrig.AR_TIPOIMPUESTO, PAISARAOrig.PAR_PERINI, PAISARAOrig.PAR_PERFIN
FROM         '+@BDOrigen+'.DBO.PAISARA PAISARAOrig INNER JOIN
                      '+@BDOrigen+'.DBO.ARANCEL ARANCELOrig ON PAISARAOrig.AR_CODIGO = ARANCELOrig.AR_CODIGO INNER JOIN
                      ##ARANCEL ARANCEL_1 ON ARANCELOrig.AR_FRACCION = ARANCEL_1.AR_FRACCION
WHERE PAISARAOrig.PA_CODIGO NOT IN (SELECT PA_CODIGO FROM PAISARA WHERE AR_CODIGO=ARANCEL_1.AR_CODIGO)')

	update consecutivo
	set cv_codigo =  isnull((select max(AR_CODIGO) from ARANCEL),0) + 1
	where cv_tipo = 'AR'


drop table ##ARANCEL


GO