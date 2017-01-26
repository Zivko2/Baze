SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_REVORIGENCONTRIBUCION] (@ficodigo int)   as

declare @incrementables decimal(38,6), @dummy varchar(3)


	SELECT    @incrementables = sum(isnull(FI_FLETE,0)+ isnull(FI_SEGURO,0) + isnull(FI_EMBALAJE,0)+isnull(FI_OTROS,0))
	FROM         VFACTIMPFLETE
	WHERE     (FI_CODIGO = @ficodigo)


	-- advalorem

		if exists (select * from RevOrigenContrib where fi_codigo =@ficodigo and con_codigo in (select con_codigo from contribucion where con_clave='6'))
		delete from RevOrigenContrib where fi_codigo=@ficodigo and con_codigo in (select con_codigo from contribucion where con_clave='6')
	
	
		insert into RevOrigenContrib(FI_CODIGO, CON_CODIGO, RVC_MONTO)
	
		SELECT     @ficodigo, (select con_codigo from contribucion where con_clave='6'),
		round(SUM(((FACTIMPDET.FID_COS_TOT+@incrementables) * FACTIMP.FI_TIPOCAMBIO) * (FACTIMPDET.FID_POR_DEF/100)),6)
		FROM         FACTIMPDET INNER JOIN
		                      FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
		WHERE     (FACTIMPDET.FID_DEF_TIP <> 'P') AND (FACTIMPDET.FID_POR_DEF <> - 1) AND (FACTIMPDET.FI_CODIGO = @ficodigo)


	-- IVA y DTA
		exec sp_CalculoIVAFactImp  @ficodigo

	delete from RevOrigenContrib where RVC_MONTO=0



























GO
