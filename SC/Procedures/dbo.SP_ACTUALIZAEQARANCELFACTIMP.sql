SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQARANCELFACTIMP] (@ar_codigo int, @fi_fechaini datetime, @fi_fechafin datetime)   as

SET NOCOUNT ON 
declare @me_codigo int, @me_codigo2 int

select @ME_CODIGO=me_codigo from arancel where ar_codigo=@ar_codigo
select @ME_CODIGO2=me_codigo2 from arancel where ar_codigo=@ar_codigo


if exists (SELECT dbo.FACTIMPDET.AR_IMPMX FROM dbo.FACTIMP INNER JOIN dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
WHERE (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) AND (dbo.FACTIMPDET.AR_IMPMX = @ar_codigo)
)
begin
	-- si existe en equivalencias
	if exists (SELECT dbo.FACTIMPDET.EQ_IMPMX FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
			(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX=dbo.EQUIVALE.EQ_CANT
		FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO 
		WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 


	-- si la unidad de medida es kilogramos
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMPDET.AR_IMPMX = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 
			AND dbo.FACTIMPDET.FID_PES_UNI>0  AND dbo.FACTIMPDET.ME_ARIMPMX in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMPDET.AR_IMPMX = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 
			AND (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)
			AND dbo.FACTIMPDET.ME_ARIMPMX in (select ME_KILOGRAMOS from configuracion) 


		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = 1
		WHERE (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)
		AND dbo.FACTIMPDET.ME_ARIMPMX in (select ME_KILOGRAMOS from configuracion) 


		-- en base a maestromedida
		UPDATE dbo.FACTIMPDET
		SET     dbo.FACTIMPDET.EQ_IMPMX= dbo.MAESTROMEDIDA.EQ_IMPMX
		FROM         dbo.ARANCEL INNER JOIN
		                      dbo.FACTIMPDET INNER JOIN
		                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
		                      dbo.MAESTROMEDIDA ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
		                      dbo.FACTIMPDET.ME_CODIGO = dbo.MAESTROMEDIDA.ME_CODIGO ON dbo.ARANCEL.AR_CODIGO = dbo.FACTIMPDET.AR_IMPMX AND 
		                      dbo.ARANCEL.ME_CODIGO = dbo.FACTIMPDET.ME_ARIMPMX
		WHERE  (dbo.FACTIMPDET.AR_IMPMX = @ar_codigo)  AND (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 
		AND dbo.MAESTROMEDIDA.EQ_IMPMX IS NOT NULL

end


/* factor de conversion de fraccion importacion usa */


if exists (SELECT dbo.FACTIMPDET.AR_EXPFO FROM dbo.FACTIMP INNER JOIN dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
WHERE (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) AND (dbo.FACTIMPDET.AR_EXPFO= @ar_codigo))
begin
	-- si existe en equivalencias
	if exists (SELECT dbo.FACTIMPDET.EQ_EXPFO FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
			(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin))

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO=dbo.EQUIVALE.EQ_CANT
		FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO 
		WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 


	-- si la unidad de medida es kilogramos
	if @ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
	begin
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMPDET.AR_EXPFO = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.FACTIMPDET.FID_PES_UNI IS NOT NULL

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMPDET.AR_EXPFO = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 
			AND (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		WHERE (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)

	end




end



if exists (SELECT dbo.FACTIMPDET.AR_EXPFO FROM dbo.FACTIMP INNER JOIN dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
WHERE (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) AND (dbo.FACTIMPDET.AR_EXPFO= @ar_codigo))
begin
	-- si existe en equivalencias
	if exists (SELECT dbo.FACTIMPDET.EQ_EXPFO FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
			(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin))

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO=dbo.EQUIVALE.EQ_CANT
		FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO 
		WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 


	-- si la unidad de medida es kilogramos
	if @ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
	begin
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMPDET.AR_EXPFO = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.FACTIMPDET.FID_PES_UNI IS NOT NULL

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMPDET.AR_EXPFO = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 
			AND (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		WHERE (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)

	end
end

if exists (SELECT dbo.FACTIMPDET.AR_EXPFO FROM dbo.FACTIMP INNER JOIN dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
WHERE (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) AND (dbo.FACTIMPDET.AR_EXPFO= @ar_codigo))
begin
	-- si existe en equivalencias
	if exists (SELECT dbo.FACTIMPDET.EQ_EXPFO2 FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO2 = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
			(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin))

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO2=dbo.EQUIVALE.EQ_CANT
		FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO2 = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO 
		WHERE (dbo.ARANCEL.AR_CODIGO = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 


	-- si la unidad de medida es kilogramos
	if @ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion) 
	begin
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO2 = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMPDET.AR_EXPFO = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.FACTIMPDET.FID_PES_UNI IS NOT NULL

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO2 = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMPDET.AR_EXPFO = @ar_codigo) AND 
		      (dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) 
			AND (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO2 = 1
		WHERE (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)

	end

end































GO
