SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQARANCELFACTEXP] (@ar_codigo int, @fe_fechaini datetime, @fe_fechafin datetime)   as

SET NOCOUNT ON 
declare @me_codigo int

select @ME_CODIGO=me_codigo from arancel where ar_codigo=@ar_codigo


if exists (SELECT dbo.FACTEXPDET.AR_EXPMX FROM dbo.FACTEXP INNER JOIN dbo.FACTEXPDET ON dbo.FACTEXP.fe_CODIGO = dbo.FACTEXPDET.fe_CODIGO
WHERE (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXPDET.AR_EXPMX = @ar_codigo)
)
begin
	-- si existe en equivalencias
	if exists (SELECT dbo.FACTEXPDET.EQ_EXPMX FROM dbo.FACTEXPDET INNER JOIN dbo.ARANCEL ON dbo.FACTEXPDET.AR_EXPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTEXPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
			(dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXPDET.TI_CODIGO IN
                        (SELECT     ti_codigo FROM configuratipo WHERE cft_tipo <> 'P' AND cft_tipo <> 'S')))

		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_EXPMX=dbo.EQUIVALE.EQ_CANT
		FROM dbo.FACTEXPDET INNER JOIN dbo.ARANCEL ON dbo.FACTEXPDET.AR_EXPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTEXPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO 
		WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
		      (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXPDET.TI_CODIGO IN
                      (SELECT     ti_codigo FROM configuratipo WHERE cft_tipo <> 'P' AND cft_tipo <> 'S'))


	-- si la unidad de medida es kilogramos
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_EXPMX = dbo.FACTEXPDET.FED_PES_UNI
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO
		WHERE (dbo.FACTEXPDET.AR_EXPMX = @ar_codigo) AND 
		      (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXPDET.TI_CODIGO IN
                      (SELECT     ti_codigo FROM configuratipo WHERE cft_tipo <> 'P' AND cft_tipo <> 'S'))
			AND dbo.FACTEXPDET.FED_PES_UNI>0 AND dbo.FACTEXPDET.ME_AREXPMX in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_EXPMX = 1
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO
		WHERE (dbo.FACTEXPDET.AR_EXPMX = @ar_codigo) AND 
		      (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXPDET.TI_CODIGO IN
                      (SELECT     ti_codigo FROM configuratipo WHERE cft_tipo <> 'P' AND cft_tipo <> 'S'))
			AND (dbo.FACTEXPDET.FED_PES_UNI=0 OR dbo.FACTEXPDET.FED_PES_UNI IS NULL)
			AND dbo.FACTEXPDET.ME_AREXPMX in (select ME_KILOGRAMOS from configuracion) 


		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_EXPMX = 1
		WHERE (dbo.FACTEXPDET.FED_PES_UNI=0 OR dbo.FACTEXPDET.FED_PES_UNI IS NULL)
		AND dbo.FACTEXPDET.ME_AREXPMX in (select ME_KILOGRAMOS from configuracion) 

end


/* factor de conversion de fraccion importacion usa */


if exists (SELECT dbo.FACTEXPDET.AR_IMPFO FROM dbo.FACTEXP INNER JOIN dbo.FACTEXPDET ON dbo.FACTEXP.fe_CODIGO = dbo.FACTEXPDET.fe_CODIGO
WHERE (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXPDET.AR_IMPFO= @ar_codigo)
)
begin
	-- si existe en equivalencias
	if exists (SELECT dbo.FACTEXPDET.EQ_IMPFO FROM dbo.FACTEXPDET INNER JOIN dbo.ARANCEL ON dbo.FACTEXPDET.AR_IMPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTEXPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
			(dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXPDET.TI_CODIGO IN
                        (SELECT     ti_codigo FROM configuratipo WHERE cft_tipo <> 'P' AND cft_tipo <> 'S')))

		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_IMPFO=dbo.EQUIVALE.EQ_CANT
		FROM dbo.FACTEXPDET INNER JOIN dbo.ARANCEL ON dbo.FACTEXPDET.AR_IMPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTEXPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO 
		WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
		      (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXPDET.TI_CODIGO IN
                      (SELECT     ti_codigo FROM configuratipo WHERE cft_tipo <> 'P' AND cft_tipo <> 'S'))


	-- si la unidad de medida es kilogramos
	if @ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
	begin
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_IMPFO = dbo.FACTEXPDET.FED_PES_UNI
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO
		WHERE (dbo.FACTEXPDET.AR_IMPFO = @ar_codigo) AND 
		      (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXPDET.TI_CODIGO IN
                      (SELECT     ti_codigo FROM configuratipo WHERE cft_tipo <> 'P' AND cft_tipo <> 'S'))
			AND dbo.FACTEXPDET.FED_PES_UNI>0

		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_IMPFO = 1
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO
		WHERE (dbo.FACTEXPDET.AR_IMPFO = @ar_codigo) AND 
		      (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXPDET.TI_CODIGO IN
                      (SELECT     ti_codigo FROM configuratipo WHERE cft_tipo <> 'P' AND cft_tipo <> 'S'))
			AND (dbo.FACTEXPDET.FED_PES_UNI=0 OR dbo.FACTEXPDET.FED_PES_UNI IS NULL)


	end

		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_IMPFO = 1
		WHERE (dbo.FACTEXPDET.FED_PES_UNI=0 OR dbo.FACTEXPDET.FED_PES_UNI IS NULL)


end




































GO
