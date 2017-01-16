SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_ActualizaFactImpImportadas]  (@TABLA VARCHAR(150), @USER INT)   as

SET NOCOUNT ON 

/*
update factimp
set factimp.agt_codigo = agenciapatente.agt_codigo
from factimp 
inner join agenciapatente on agenciapatente.ag_codigo=factimp.ag_mex

where fi_folio in (select 
rtrim(ltrim(right (left(ri_registro, charindex(',',ri_registro)-1),
(len(left(ri_registro, charindex(',',ri_registro)-1))-charindex('=',ri_registro))
)))
from registrosimportados
)
and agenciapatente.agt_tipo='A'
and agenciapatente.agt_default='S'
*/
if exists (SELECT dbo.syscolumns.name FROM dbo.syscolumns INNER JOIN
                  dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id
WHERE     (dbo.sysobjects.name = N'tempimport144') AND (dbo.syscolumns.name = N'factimp0#agt_codigo'))
begin
	update tempimport144
	set factimp0#agt_codigo = 
	(select agenciapatente.agt_codigo 
	from cliente 
	inner join agenciapatente on cliente.ag_mex=agenciapatente.ag_codigo
	where cliente.cl_empresa='s'
	and agenciapatente.agt_default='s'
	and agenciapatente.agt_tipo='a')
	where tempimport144.factimp0#agt_codigo is null or tempimport144.factimp0#agt_codigo=0


	update factimp
	   set factimp.agt_codigo = agenciapatente.agt_codigo,
	
	/*tambien hay que actualizar el campo ag_mex*/  
	 factimp.ag_mex = agenciapatente.ag_codigo
	from factimp
	inner join tempimport144 on tempimport144.factimp0#fi_folio=factimp.fi_folio
	inner join agenciapatente on tempimport144.factimp0#agt_codigo =agenciapatente.agt_codigo
	where factimp.fi_folio in (select 
	rtrim(ltrim(right (left(ri_registro, charindex(',',ri_registro)-1),
	(len(left(ri_registro, charindex(',',ri_registro)-1))-charindex('=',ri_registro))
	)))
	from registrosimportados
	)
	and agenciapatente.agt_default='s'
	and agenciapatente.agt_tipo='a'
	
end	



--Actualiza las tasas de la Factura de Importacion

declare @factura_ActTasa int

declare cur_facturas_actualiza cursor for

select fi_codigo as factura_ActTasa from factimp
where fi_folio in (
select 
rtrim(ltrim(right (left(ri_registro, charindex(',',ri_registro)-1),
(len(left(ri_registro, charindex(',',ri_registro)-1))-charindex('=',ri_registro))
))) 
from registrosimportados
)
order by fi_codigo

open cur_facturas_actualiza

	FETCH NEXT FROM cur_facturas_actualiza INTO @factura_ActTasa

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
	 
	 exec SP_ACTUALIZATASABAJAFACTIMP  @factura_ActTasa



	FETCH NEXT FROM cur_facturas_actualiza INTO @factura_ActTasa

END

CLOSE cur_facturas_actualiza
DEALLOCATE cur_facturas_actualiza


/*Nota:
         Esta parte es la misma que el procedure  [SP_ACTUALIZAEQARANCELFACTIMPALL]  */
/*Se hizo asi porque el procedimiento es por periodo y aqui se ocupa por factura */
if exists (SELECT dbo.FACTIMPDET.AR_IMPMX FROM dbo.FACTIMP INNER JOIN dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) AND dbo.FACTIMPDET.AR_IMPMX>0)
begin
	-- si existe en equivalencias
	if exists (SELECT dbo.FACTIMPDET.EQ_IMPMX FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)*/) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX=dbo.EQUIVALE.EQ_CANT
		FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO 
		WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) */


	-- si la unidad de medida es kilogramos
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) */
			AND dbo.FACTIMPDET.FID_PES_UNI>0  AND dbo.FACTIMPDET.ME_ARIMPMX in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) */
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
		WHERE  (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) */
		AND dbo.MAESTROMEDIDA.EQ_IMPMX IS NOT NULL

end


/* factor de conversion de fraccion importacion usa */


if exists (SELECT dbo.FACTIMPDET.AR_EXPFO FROM dbo.FACTIMP INNER JOIN dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
WHERE (dbo.factimp.fi_codigo= @factura_ActTasa)
/*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)*/ AND (dbo.FACTIMPDET.AR_EXPFO>0))
begin
	-- si existe en equivalencias
	if exists (SELECT dbo.FACTIMPDET.EQ_EXPFO FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO WHERE 
			/*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)*/
                      (dbo.factimp.fi_codigo= @factura_ActTasa)   )

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO=dbo.EQUIVALE.EQ_CANT
		FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO 
		WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) */


	-- si la unidad de medida es kilogramos
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)*/ 
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.FACTIMPDET.FID_PES_UNI IS NOT NULL
		AND dbo.FACTIMPDET.AR_EXPFO IN (SELECT AR_CODIGO FROM ARANCEL WHERE ME_CODIGO in (select ME_KILOGRAMOS from configuracion) AND AR_CODIGO=dbo.FACTIMPDET.AR_EXPFO)

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)*/ 
			AND (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)
		AND dbo.FACTIMPDET.AR_EXPFO IN (SELECT AR_CODIGO FROM ARANCEL WHERE ME_CODIGO in (select ME_KILOGRAMOS from configuracion) AND AR_CODIGO=dbo.FACTIMPDET.AR_EXPFO)

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		WHERE (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)
		AND dbo.FACTIMPDET.AR_EXPFO IN (SELECT AR_CODIGO FROM ARANCEL WHERE ME_CODIGO in (select ME_KILOGRAMOS from configuracion) AND AR_CODIGO=dbo.FACTIMPDET.AR_EXPFO)


end


if exists (SELECT dbo.FACTIMPDET.AR_EXPFO FROM dbo.FACTIMP INNER JOIN dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)*/
 AND (dbo.FACTIMPDET.AR_EXPFO>0))
begin
	-- si existe en equivalencias
	if exists (SELECT dbo.FACTIMPDET.EQ_EXPFO2 FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO2 = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO WHERE 
			/*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)*/
                       (dbo.factimp.fi_codigo= @factura_ActTasa))

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO2=dbo.EQUIVALE.EQ_CANT
		FROM dbo.FACTIMPDET INNER JOIN dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO= dbo.ARANCEL.AR_CODIGO INNER JOIN
                      dbo.EQUIVALE ON dbo.FACTIMPDET.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO1 AND dbo.ARANCEL.ME_CODIGO2 = dbo.EQUIVALE.ME_CODIGO2 INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO 
		WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) */


	-- si la unidad de medida es kilogramos
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO2 = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)*/ 
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.FACTIMPDET.FID_PES_UNI IS NOT NULL
		AND dbo.FACTIMPDET.AR_EXPFO IN (SELECT AR_CODIGO FROM ARANCEL WHERE ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion) AND AR_CODIGO=dbo.FACTIMPDET.AR_EXPFO)

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO2 = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) */
			AND (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)
		AND dbo.FACTIMPDET.AR_EXPFO IN (SELECT AR_CODIGO FROM ARANCEL WHERE ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion) AND AR_CODIGO=dbo.FACTIMPDET.AR_EXPFO)

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO2 = 1
		WHERE (dbo.FACTIMPDET.FID_PES_UNI=0 OR dbo.FACTIMPDET.FID_PES_UNI IS NULL)
		AND dbo.FACTIMPDET.AR_EXPFO IN (SELECT AR_CODIGO FROM ARANCEL WHERE ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion) AND AR_CODIGO=dbo.FACTIMPDET.AR_EXPFO)


end
/*Nota: 
          Aqui termina la  parte del procedure  [SP_ACTUALIZAEQARANCELFACTIMPALL]  */




/*Nota:
           Esta parte es la misma que el procedure  [SP_ACTUALIZAEQGENFACTIMP]  */
/*Se hizo asi porque el procedimiento es por periodo y aqui se ocupa por factura */
		-- existe en equivalencias
		if exists (SELECT     dbo.FACTIMPDET.EQ_GEN
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTIMPDET.ME_GEN AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
				WHERE     /*(dbo.FACTIMP.FI_FECHA <= @fi_fechafin) AND (dbo.FACTIMP.FI_FECHA >= @fi_fechaini)*/
                                 (dbo.factimp.fi_codigo= @factura_ActTasa) )


			UPDATE dbo.FACTIMPDET
			SET dbo.FACTIMPDET.EQ_GEN=dbo.EQUIVALE.EQ_CANT
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTIMPDET.ME_GEN AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
				WHERE      (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA <= @fi_fechafin) AND (dbo.FACTIMP.FI_FECHA >= @fi_fechaini)*/



		-- me_gen igual a Kg
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_GEN = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE  (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)*/ 
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.FACTIMPDET.ME_GEN in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_GEN = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE  (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin)*/ 
			AND (dbo.FACTIMPDET.FID_PES_UNI is null or  dbo.FACTIMPDET.FID_PES_UNI=0) 
			AND dbo.FACTIMPDET.ME_GEN in (select ME_KILOGRAMOS from configuracion) 
			AND dbo.FACTIMPDET.ME_CODIGO not in (SELECT ME_CODIGO1 FROM EQUIVALE
			WHERE     ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion))


		-- en base a maestromedida
		UPDATE dbo.FACTIMPDET
		SET     dbo.FACTIMPDET.EQ_GEN= dbo.MAESTROMEDIDA.EQ_CANTIDAD
		FROM         dbo.MAESTRO MAESTRO_1 INNER JOIN
	                      dbo.MAESTRO ON MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO INNER JOIN
	                      dbo.FACTIMPDET INNER JOIN
	                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
	                      dbo.MAESTROMEDIDA ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      dbo.FACTIMPDET.ME_CODIGO = dbo.MAESTROMEDIDA.ME_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      MAESTRO_1.ME_COM = dbo.FACTIMPDET.ME_GEN
		WHERE  (dbo.factimp.fi_codigo= @factura_ActTasa) /*(dbo.FACTIMP.FI_FECHA >= @fi_fechaini) AND (dbo.FACTIMP.FI_FECHA <= @fi_fechafin) */

		-- sin factor de conversion
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_GEN = 1
		WHERE (dbo.FACTIMPDET.EQ_GEN=0 OR dbo.FACTIMPDET.EQ_GEN IS NULL)

/*Nota: 
          Aqui  termina la parte que es la misma que el procedure  [SP_ACTUALIZAEQGENFACTIMP]  */



























GO
