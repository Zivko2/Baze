SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SCHNEIDERMAESTROMTY]   as

/*
if exists (select * from sysobjects where id = object_id(N'[MaestroMty]') and OBJECTPROPERTY(id, N'IsTable') = 1)
DROP TABLE MaestroMty

CREATE TABLE [dbo].[MaestroMty] (
	[ITEM NUMBER] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ITEM DESCRIPTION] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[UM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TYPE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[STATUS] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MB CODE] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[COST PER UNIT] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[COST CODE] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CONTRACT] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[VENDOR] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PUR UM] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PUR CONV FCTR] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
*/


		exec Sp_GeneraTablaTemp 'MAESTRO'


		update MaestroMty
		set [PUR UM]=null
		where [PUR UM]=''



	       INSERT INTO TempImportMAESTRO (MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO ,MA_NOMBRE ,
		MA_NAME ,ME_COM ,PA_ORIGEN ,PA_PROCEDE ,AR_IMPMX ,AR_EXPMX) 

	
		SELECT 'I', 'F', [ITEM NUMBER], 16, [ITEM DESCRIPTION], [ITEM DESCRIPTION],
		MEDIDAAMAPS.ME_CODIGO, 154, 154, isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SINFRACCION'),0), isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SINFRACCION'),0)
		FROM MaestroMty inner join MEDIDAAMAPS on MEDIDAAMAPS.ME_AMAPS= isnull(MaestroMty.[PUR UM],MaestroMty.[UM])
		WHERE [MB CODE]='1' AND [ITEM NUMBER] NOT IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN='I' UNION
							      SELECT MA_NOPARTE FROM MAESTROREFER)



	       INSERT INTO TempImportMAESTRO (MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO ,MA_NOMBRE ,
		MA_NAME ,ME_COM ,PA_ORIGEN ,PA_PROCEDE ,AR_IMPMX ,AR_EXPMX, MA_DISCHARGE) 

	
		SELECT 'I', 'C', [ITEM NUMBER], 10, [ITEM DESCRIPTION], [ITEM DESCRIPTION],
		MEDIDAAMAPS.ME_CODIGO, 233, 233, isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SINFRACCION'),0), isnull((select AR_CODIGO from ARANCEL WHERE AR_FRACCION='SINFRACCION'),0),
		'S'
		FROM MaestroMty inner join MEDIDAAMAPS on MEDIDAAMAPS.ME_AMAPS= MaestroMty.[UM]
		WHERE [MB CODE]='2' AND [ITEM NUMBER] NOT IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN='I' UNION
							      SELECT MA_NOPARTE FROM MAESTROREFER)


		INSERT INTO MAESTRO(MA_CODIGO, MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO ,MA_NOMBRE ,
		MA_NAME ,ME_COM ,PA_ORIGEN ,PA_PROCEDE ,AR_IMPMX ,AR_EXPMX, MA_ULTIMAMODIF, MA_DISCHARGE)

		SELECT MA_CODIGO, MA_INV_GEN, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO ,MA_NOMBRE ,
		MA_NAME ,ME_COM ,PA_ORIGEN ,PA_PROCEDE ,AR_IMPMX ,AR_EXPMX, GETDATE(), MA_DISCHARGE
		FROM TempImportMAESTRO
		WHERE TI_CODIGO=10

		INSERT INTO MAESTROREFER(MA_CODIGO, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO ,MA_NOMBRE ,
		MA_NAME ,ME_COM ,PA_ORIGEN )

		SELECT MA_CODIGO, MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO ,MA_NOMBRE ,
		MA_NAME ,ME_COM ,PA_ORIGEN
		FROM TempImportMAESTRO
		WHERE TI_CODIGO=16

		declare @maximo int

		select @maximo= max(MA_CODIGO) from MAESTRO

		if exists(select * from maestrorefer) and (select isnull(max(ma_codigo),0) from maestrorefer)>@maximo
		select @maximo= isnull(max(MA_CODIGO),0) from MAESTROREFER


		update consecutivo
		set cv_codigo =  @maximo +1
		where cv_tipo = 'MA'



                   INSERT INTO MAESTROCOST (MA_CODIGO,SPI_CODIGO ,TCO_CODIGO ,MA_PERINI ,MA_COSTO) 
		   SELECT MAESTRO.MA_CODIGO, 22, 3, '01/01/1990', MAX([COST PER UNIT])
		   FROM MaestroMty INNER JOIN
		        MAESTRO ON MaestroMty.[ITEM NUMBER] = MAESTRO.MA_NOPARTE
		   WHERE convert(varchar(150),MAESTRO.MA_CODIGO)+ convert(varchar(150),22)+convert(varchar(150),3) not in
			(select convert(varchar(150),maestrocost.MA_CODIGO)+ convert(varchar(150),maestrocost.SPI_CODIGO)+convert(varchar(150),maestrocost.TCO_CODIGO)
			from maestrocost where maestrocost.ma_codigo=MAESTRO.MA_CODIGO)
			AND MaestroMty.[MB CODE]='2'
		   GROUP BY MAESTRO.MA_CODIGO


GO
