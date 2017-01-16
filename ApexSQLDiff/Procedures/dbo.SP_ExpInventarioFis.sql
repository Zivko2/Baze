SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[SP_ExpInventarioFis] (@CodigoInv Int)   as

SET NOCOUNT ON 
DECLARE  @me_codigo int, @Factconv decimal(28,14), @me_gen int, @DescargaEmpaque char(1), @DescargaEmpaqueDet char(1), 
	@HayRetrabajo int, @HayNormal Int, @CF_CONTENEDOR CHAR(1), @empaqueadicional int,
	@countdescargable int, @cs_codigo smallint,  @TEmbarque char(1), @tipodesc varchar(5)
          

DECLARE @COUNTMP INT, @COUNTPT INT, @COUNTFIS_COMP INT,@bst_hijo int, @ivf_mesreferencia datetime, @ivfd_can_gen decimal(38,6),
	    @ivfd_indiced integer, @ivfd_fec_struct datetime, @ma_tip_ens char(1), @ti_codigo char(1)


DELETE FROM BOM_DESCTEMP WHERE FE_CODIGO=@CodigoInv and FACT_INV = 'I'

-- Luis
SELECT @COUNTFIS_COMP =COUNT(IVFD_INDICED)
FROM INVENTARIOFISDET
LEFT OUTER JOIN MAESTRO ON INVENTARIOFISDET.MA_CODIGO = MAESTRO.MA_CODIGO
WHERE (MAESTRO.MA_TIP_ENS = 'A') AND (IVF_CODIGO = @CodigoInv)
--

SELECT @COUNTMP =COUNT(IVFD_INDICED)
FROM INVENTARIOFISDET
LEFT OUTER JOIN MAESTRO ON INVENTARIOFISDET.MA_CODIGO = MAESTRO.MA_CODIGO
WHERE (MAESTRO.MA_TIP_ENS = 'C') AND (IVF_CODIGO = @CodigoInv)


SELECT @COUNTPT =COUNT(IVFD_INDICED)
FROM INVENTARIOFISDET
LEFT OUTER JOIN MAESTRO ON INVENTARIOFISDET.MA_CODIGO = MAESTRO.MA_CODIGO
WHERE (MAESTRO.MA_TIP_ENS = 'F' OR MAESTRO.MA_TIP_ENS = 'E') AND (IVF_CODIGO = @CodigoInv)

SELECT @HayRetrabajo = COUNT(IVFD_INDICED) 
FROM INVENTARIOFISDET
WHERE (IVFD_RETRABAJO = 'R' OR IVFD_RETRABAJO = 'D' OR IVFD_RETRABAJO = 'E' OR IVFD_RETRABAJO = 'C' )
AND (IVF_CODIGO = @CodigoInv)

SELECT @HayNormal = COUNT(IVFD_INDICED) 
FROM INVENTARIOFISDET
WHERE (IVFD_RETRABAJO = 'N' OR IVFD_RETRABAJO = 'C')
AND (IVF_CODIGO = @CodigoInv)


SELECT     @CF_CONTENEDOR = CF_CONTENEDOR, @DescargaEmpaqueDet = CF_MAN_EMPAQUE,
@DescargaEmpaque = CF_EMPAQUE_BOM
FROM         dbo.CONFIGURACION

select @ivf_mesreferencia=ivf_mesreferencia from inventariofis where ivf_codigo=@CodigoInv
	
	/* cuando hay pt o sub en detalle insertamos en bom_desctemp por medio del  SP_DescExplosionBomFactExp -explosionandolos a 13 niveles maximo*/
	--PRINT 'HOLA'
	
	IF @COUNTPT > 0 AND @HayNormal >0
		EXEC  SP_ExpBomInvFis @CodigoInv


	IF @HayRetrabajo >0
		EXEC sp_ExplosionRetInvFis @CodigoInv         /* inserta en bom_desctemp la lista de retrabajo */ --Este ya quedo




	IF @COUNTMP > 0 OR @COUNTFIS_COMP > 0 
	BEGIN
		/* cuando hay mp en detalle insertamos en bom_desctemp la materia prima que viene directamente */
		declare CUR_DETALLEINVMP cursor for
			SELECT INVENTARIOFISDET.MA_CODIGO, SUM(INVENTARIOFISDET.IVFD_CAN_GEN) AS IVFD_CAN_GEN, CONFIGURATIPO.CFT_TIPO, INVENTARIOFISDET.ME_CODIGO, INVENTARIOFISDET.EQ_GENERICO, ISNULL(INVENTARIOFISDET.ME_GENERICO, 19), 
      				INVENTARIOFISDET.IVFD_INDICED, INVENTARIOFISDET.IVFD_FEC_STRUCT, MAESTRO.MA_TIP_ENS
       				FROM INVENTARIOFISDET 
				LEFT OUTER JOIN MAESTRO ON MAESTRO.MA_CODIGO = INVENTARIOFISDET.MA_CODIGO 
				LEFT OUTER JOIN CONFIGURATIPO ON INVENTARIOFISDET.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
       				WHERE (MAESTRO.MA_TIP_ENS ='C' OR MAESTRO.MA_TIP_ENS ='A') AND (INVENTARIOFISDET.IVFD_RETRABAJO = 'N') AND (INVENTARIOFISDET.IVF_CODIGO = @CodigoInv) 
       				GROUP BY INVENTARIOFISDET.MA_CODIGO, CONFIGURATIPO.CFT_TIPO, INVENTARIOFISDET.ME_CODIGO, INVENTARIOFISDET.EQ_GENERICO, ISNULL(INVENTARIOFISDET.ME_GENERICO, 19), 
       				INVENTARIOFISDET.IVFD_INDICED, INVENTARIOFISDET.IVFD_FEC_STRUCT, MAESTRO.MA_TIP_ENS
       				HAVING (SUM(INVENTARIOFISDET.IVFD_CAN_GEN) > 0) 
		 OPEN CUR_DETALLEINVMP
		FETCH NEXT FROM CUR_DETALLEINVMP INTO @bst_hijo, @ivfd_can_gen, @ti_codigo,
		@me_codigo, @factconv, @me_gen, @ivfd_indiced, @ivfd_fec_struct, @ma_tip_ens
		  WHILE (@@fetch_status = 0) 
		  BEGIN  
			insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
			me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, ma_tip_ens, bst_entravigor, bst_perini, bst_perfin,
			bst_tipodesc, bst_pertenece, bst_tipocosto,fact_inv)
			values
			(@CodigoInv, @bst_hijo, @bst_hijo, @ivfd_can_gen, 'S', @ti_codigo,
			@me_codigo, @factconv, @me_gen, 1, @ivfd_indiced, 'MP',@ma_tip_ens, @ivf_mesreferencia,  @ivf_mesreferencia,  @ivf_mesreferencia, 'N',
			@bst_hijo, 'S','I')
          		              FETCH NEXT FROM CUR_DETALLEINVMP INTO @bst_hijo, @ivfd_can_gen, @ti_codigo,
			@me_codigo, @factconv, @me_gen, @ivfd_indiced, @ivfd_fec_struct, @ma_tip_ens
		END
		CLOSE CUR_DETALLEINVMP
		DEALLOCATE CUR_DETALLEINVMP
	END











GO
