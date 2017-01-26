SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.SP_ExplosionRetInvFis (@CodigoInv Int)   as


DECLARE @bst_pt int, @bst_hijo int, @ivfd_can_gen decimal(38,6), @bst_disch char(1), @ti_codigo char(1), @me_codigo int, @Factconv decimal(28,14), @me_gen int, @bst_incorpor decimal(38,6),
               @ivfd_indiced int, @MA_TIP_ENS char(1), @ivfd_retrabajo char(1)



DECLARE cur_retrabajo CURSOR FOR
SELECT     INVENTARIOFISDET.MA_CODIGO, RETRABAJO.MA_HIJO, SUM(INVENTARIOFISDET.IVFD_CAN_GEN) AS IVFD_CAN_GEN, 
           CONFIGURATIPO.CFT_TIPO, MAESTRO.ME_COM, RETRABAJO.FACTCONV, RETRABAJO.ME_GEN AS ME_GEN, 
           SUM(RETRABAJO.RE_INCORPOR) AS RE_INCORPOR, INVENTARIOFISDET.IVFD_INDICED, MAESTRO.MA_TIP_ENS,
   	   INVENTARIOFISDET.IVFD_RETRABAJO
FROM       RETRABAJO 
           RIGHT OUTER JOIN INVENTARIOFISDET ON RETRABAJO.FETR_INDICED = INVENTARIOFISDET.IVFD_INDICED LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.RETRABAJO.MA_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON INVENTARIOFISDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE (INVENTARIOFISDET.IVF_CODIGO = @CodigoInv) AND (INVENTARIOFISDET.IVFD_RETRABAJO = 'C' OR INVENTARIOFISDET.IVFD_RETRABAJO = 'R' OR
	         INVENTARIOFISDET.IVFD_RETRABAJO = 'D' OR INVENTARIOFISDET.IVFD_RETRABAJO = 'E')  AND MA_HIJO IS NOT NULL
GROUP BY INVENTARIOFISDET.MA_CODIGO, RETRABAJO.MA_HIJO, CONFIGURATIPO.CFT_TIPO, MAESTRO.ME_COM,
	 RETRABAJO.FACTCONV, RETRABAJO.ME_GEN, INVENTARIOFISDET.IVFD_INDICED, MAESTRO.MA_TIP_ENS,
         INVENTARIOFISDET.IVFD_RETRABAJO

UNION
/* para que se descargue el pt que entro para reparacion  en la facturas de importacion  y la mcia clasificada mp pero que ya utilizo otros materiales*/
SELECT     INVENTARIOFISDET.MA_CODIGO, MAESTRO_1.MA_CODIGO AS BST_HIJO, SUM(INVENTARIOFISDET.IVFD_CAN_GEN) AS IVFD_CAN_GEN, 
           CONFIGURATIPO.CFT_TIPO, INVENTARIOFISDET.ME_CODIGO, MAESTRO_1.EQ_GEN, dbo.MAESTRO.ME_COM AS ME_GEN, 1 AS RE_INCORPOR, 
           INVENTARIOFISDET.IVFD_INDICED, MAESTRO_1.MA_TIP_ENS, INVENTARIOFISDET.IVFD_RETRABAJO
FROM       MAESTRO MAESTRO_1 RIGHT OUTER JOIN
           INVENTARIOFISDET ON MAESTRO_1.MA_CODIGO = INVENTARIOFISDET.MA_CODIGO LEFT OUTER JOIN
           MAESTRO ON INVENTARIOFISDET.MA_GENERICO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
           CONFIGURATIPO ON INVENTARIOFISDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE (INVENTARIOFISDET.IVF_CODIGO = @CodigoInv) AND (INVENTARIOFISDET.IVFD_RETRABAJO = 'R') 
GROUP BY INVENTARIOFISDET.MA_CODIGO, MAESTRO_1.MA_CODIGO, 
         CONFIGURATIPO.CFT_TIPO, INVENTARIOFISDET.ME_CODIGO, MAESTRO_1.EQ_GEN, dbo.MAESTRO.ME_COM, 
         INVENTARIOFISDET.IVFD_INDICED, MAESTRO_1.MA_TIP_ENS, INVENTARIOFISDET.IVFD_RETRABAJO

open cur_retrabajo

fetch next from cur_retrabajo into  @bst_pt, @bst_hijo, @ivfd_can_gen,  @ti_codigo,
@me_codigo, @factconv, @me_gen, @bst_incorpor, @ivfd_indiced, @ma_tip_ens, @ivfd_retrabajo


WHILE (@@FETCH_STATUS = 0) 
BEGIN


	IF @ivfd_retrabajo = 'C'
		begin
			insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
			me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL,FACT_INV)
	
	
			values 
			(@CodigoInv, @bst_pt, @bst_hijo, @ivfd_can_gen, 'S', @ti_codigo,@me_codigo, 
			isnull(@factconv,1), isnull(@me_gen, @me_codigo), @bst_incorpor, @ivfd_indiced, @ma_tip_ens, 'M', 'RC','I')
		end
		else
		begin
			insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
			me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL,FACT_INV)
	
	
			values 
			(@CodigoInv, @bst_pt, @bst_hijo, @ivfd_can_gen, 'S', @ti_codigo,@me_codigo, 
			isnull(@factconv,1), isnull(@me_gen, @me_codigo), @bst_incorpor, @ivfd_indiced, @ma_tip_ens, 'N', 'RR','I')

		end
		fetch next from cur_retrabajo into  @bst_pt, @bst_hijo, @ivfd_can_gen,  @ti_codigo,
		@me_codigo, @factconv, @me_gen, @bst_incorpor, @ivfd_indiced, @ma_tip_ens, @ivfd_retrabajo


END

CLOSE cur_retrabajo
DEALLOCATE cur_retrabajo



	/* insertamos en almacen desperdicio el desperdicio que genero el retrabajo */

		--exec sp_DescRetrabajoDesp @CodigoInv PENDIENTE PARA LUIS

GO
