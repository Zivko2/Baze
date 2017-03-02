SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SP_SCHNEIDERMAESTRO]   as


			exec Sp_GeneraTablaTemp 'MAESTRO'


	       INSERT INTO TempImportMAESTRO (MA_INV_GEN , MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO ,MA_NOMBRE ,
		MA_NAME ,ME_COM ,PA_ORIGEN ,PA_PROCEDE ,MA_GENERICO ,AR_IMPMX ,AR_EXPMX) 

		SELECT 'I', 'C', RTRIM(LTRIM(TLBMS140.[PART NBR])), 10, 'MATERIAL NO CLASIFICADO', 'MATERIAL NO CLASIFICADO', 19, 233, 233, 0, 0, 0
		FROM         TLBMS140 
		WHERE RTRIM(LTRIM(TLBMS140.[PART NBR])) NOT IN (SELECT MA_NOPARTE FROM MAESTRO)



		INSERT INTO MAESTRO(MA_CODIGO, MA_INV_GEN , MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO ,MA_NOMBRE ,
		MA_NAME ,ME_COM ,PA_ORIGEN ,PA_PROCEDE ,MA_GENERICO ,AR_IMPMX ,AR_EXPMX, MA_ULTIMAMODIF)

		SELECT MA_CODIGO, MA_INV_GEN , MA_TIP_ENS ,MA_NOPARTE ,TI_CODIGO ,MA_NOMBRE ,
		MA_NAME ,ME_COM ,PA_ORIGEN ,PA_PROCEDE ,MA_GENERICO ,AR_IMPMX ,AR_EXPMX, GETDATE()
		FROM TempImportMAESTRO

		declare @maximo int

		select @maximo= max(MA_CODIGO) from MAESTRO

		if exists(select * from maestrorefer) and (select isnull(max(ma_codigo),0) from maestrorefer)>@maximo
		select @maximo= isnull(max(MA_CODIGO),0) from MAESTROREFER

		update consecutivo
		set cv_codigo =  @maximo + 1
		where cv_tipo = 'MA'


-- tipo adquisicion = 'C' cuando MB=2
UPDATE MAESTRO
SET     MAESTRO.MA_TIP_ENS='C'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE))
WHERE     (TLBMS140.MB = '2') AND (MAESTRO.MA_TIP_ENS <> 'C' OR
                      MAESTRO.MA_TIP_ENS IS NULL)

--tipo adquisicion = 'F' cuando MB=1
UPDATE MAESTRO
SET     MAESTRO.MA_TIP_ENS='F'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE))
WHERE     (TLBMS140.MB = '1') AND (MAESTRO.MA_TIP_ENS <> 'F' OR
                      MAESTRO.MA_TIP_ENS IS NULL)



-- tipo material 4 y se Descarga cuando tipo adquisicion = 'C' y Fraccion =39231001
UPDATE MAESTRO
SET     MAESTRO.TI_CODIGO=4, MAESTRO.MA_DISCHARGE='S'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE)) INNER JOIN
                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
WHERE     (MAESTRO.MA_TIP_ENS = 'C') AND (ARANCEL.AR_FRACCION = '39231001')


-- tipo material 7 y se Descarga, cuando tipo adquisicion = 'C' y Fraccion ='49119999', '48211001', '48219099', '39199099'
UPDATE MAESTRO
SET     MAESTRO.TI_CODIGO=7, MAESTRO.MA_DISCHARGE='S'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE)) INNER JOIN
                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
WHERE     (MAESTRO.MA_TIP_ENS = 'C') AND (ARANCEL.AR_FRACCION IN ('49119999', '48211001', '48219099', '39199099'))

-- tipo material 5 y se Descarga, cuando tipo adquisicion = 'C' y Fraccion ='48191001'
UPDATE MAESTRO
SET     MAESTRO.TI_CODIGO=5, MAESTRO.MA_DISCHARGE='S'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE)) INNER JOIN
                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
WHERE     (MAESTRO.MA_TIP_ENS = 'C') AND (ARANCEL.AR_FRACCION IN ('48191001'))


-- tipo material 17 y se Descarga, cuando tipo adquisicion = 'C' y Fraccion ='48195099', '48239099'
UPDATE MAESTRO
SET     MAESTRO.TI_CODIGO=17, MAESTRO.MA_DISCHARGE='S'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE)) INNER JOIN
                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
WHERE     (MAESTRO.MA_TIP_ENS = 'C') AND (ARANCEL.AR_FRACCION IN ('48195099', '48239099')) AND (TLBMS140.CCC = 'B')


-- tipo material 13 y NO se Descarga, cuando tipo adquisicion = 'C' y CAT = 'R'
UPDATE MAESTRO
SET     MAESTRO.TI_CODIGO=13, MAESTRO.MA_DISCHARGE='N'       
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE))
WHERE     (MAESTRO.MA_TIP_ENS = 'C') AND (TLBMS140.CAT = 'R')

-- tipo material 2 y se NO Descarga, cuando tipo adquisicion = 'C' y ISS = '3'
UPDATE MAESTRO
SET     MAESTRO.TI_CODIGO=2, MAESTRO.MA_DISCHARGE='N'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE))
WHERE     (MAESTRO.MA_TIP_ENS = 'C') AND ( (TLBMS140.ISS = '3') OR  (TLBMS140.CCC NOT IN ('K','N') ) )


-- tipo material 10 y se Descarga, cuando tipo adquisicion = 'C' y (CAT  <> 'E' o CAT  <> 'R' o ISS <> '3'   o
--FRACCION <> ('39231001', '49119999', '48211001', '48219099', '39199099', '48191001', '48195099', '48239099'))
UPDATE MAESTRO
SET     MAESTRO.TI_CODIGO=10, MAESTRO.MA_DISCHARGE='S'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE)) INNER JOIN
                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
WHERE     (MAESTRO.MA_TIP_ENS = 'C') 
AND ((ARANCEL.AR_FRACCION NOT IN ('39231001', '49119999', '48211001', '48219099', '39199099', '48191001', '48195099', '48239099')) OR (TLBMS140.ISS <> '3')
OR (TLBMS140.CAT NOT IN ('R', 'E'))
OR (TLBMS140.CCC = 'B')
)


-- tipo material  10 14  y no se Descarga, , cuando tipo adquisicion = 'F'
 UPDATE MAESTRO
SET     MAESTRO.TI_CODIGO=14, MAESTRO.MA_DISCHARGE='N'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE))
WHERE     (MAESTRO.MA_TIP_ENS = 'F') 
AND (TLBMS140.CCC = 'M')

-- Estatus Obsoleto y no se descarga, cuando tipo adquisicion = 'C' y ISS = '4',  Y  cat= “O”
UPDATE MAESTRO
SET     MAESTRO.MA_EST_MAT='O', MAESTRO.MA_DISCHARGE='N'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE)) 
WHERE     (MAESTRO.MA_TIP_ENS = 'C') 
AND (TLBMS140.CAT = 'O') AND (TLBMS140.ISS = '4')

-- Estatus Activo, cuando tipo adquisicion = 'C' y (CAT <> 'O' o ISS <> '4')
UPDATE MAESTRO
SET     MAESTRO.MA_EST_MAT='A'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE)) 
WHERE     (MAESTRO.MA_TIP_ENS = 'C') AND ((TLBMS140.CAT <> 'O') OR (TLBMS140.ISS <> '4'))


-- tipo material 2 y NO se Descarga, cuando tipo adquisicion = 'C' y CAT = 'E' 
UPDATE MAESTRO
SET     MAESTRO.TI_CODIGO=2, MAESTRO.MA_DISCHARGE='N'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE))
WHERE     (MAESTRO.MA_TIP_ENS = 'C') AND (TLBMS140.CAT = 'E')



-- tipo material 16 y no se Descarga,   cuando CCC = 'K','N' O TPLNR = 'KANBAN'
UPDATE MAESTRO
SET     MAESTRO.TI_CODIGO=16, MAESTRO.MA_DISCHARGE='N'
FROM         TLBMS140 INNER JOIN
                      MAESTRO ON RTRIM(LTRIM(TLBMS140.[PART NBR])) = RTRIM(LTRIM(MAESTRO.MA_NOPARTE))
WHERE       (MAESTRO.MA_TIP_ENS = 'F') AND (
(TLBMS140.CCC IN ('K','N')) OR (PLNRTXT = 'KANBAN') )

GO