SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE dbo.SP_DECANUALNVA ( @dancodigo INT)   as

SET NOCOUNT ON 
declare @tipo char(1), @cf_pagocontribucion char(1)

/*
Tipo
E	ECEX
M	MAQUILA
P	PITEX */


select @cf_pagocontribucion=cf_pagocontribucion from configuracion
select @tipo=cl_tipo from cliente where cl_codigo=1

exec SP_GENERAVISTASDECANUAL

--sealar el valor total en miles de pesos y dolares de la maquinaria y equipo que hubiere importado temporalmente en el periodo.
exec SP_REPANUALIMPTEMPACTFIJ @dancodigo
-- sealar el valor total en miles de pesos y dolares de este tipo de mercancias que hubiere importado temporalmente en el periodo.
exec SP_REPANUALIMPTEMPMAT @dancodigo

--indicar el valor total en miles de pesos y dolares de los cambios de regimen de maquinaria y equipo que hubieren efectuado en el periodo.
exec SP_REPANUALMDONACACTFIJ @dancodigo

-- indicar el valor total en miles de pesos y dolares de los cambios de regimen de este tipo de mercancias que hubieren efectuado en el periodo.
exec SP_REPANUALMDONACMAT @dancodigo
-- sealar el valor total en miles de pesos y dolares de la maquinaria y equipo que hubiere importado en definitiva en el periodo.
exec SP_REPANUALIMPDEFACTFIJ @dancodigo

--sealar el valor total en miles de pesos y dolares de este tipo de mercancias que hubiere importado en el periodo.
exec SP_REPANUALIMPDEFMAT @dancodigo

-- importaciones por categoria
UPDATE dbo.DECANUALNVA
SET DAN_IMPTEMPINDCATEG1=isnull((SELECT floor(round(SUM(PID_CTOT_DLS),0)/1000) FROM VDECANUALINDCAT1 WHERE DAN_CODIGO = @dancodigo),0),
DAN_IMPTEMPINDCATEG2=isnull((SELECT floor(round(SUM(PID_CTOT_DLS),0)/1000) FROM VDECANUALINDCAT2 WHERE DAN_CODIGO = @dancodigo),0),
DAN_IMPTEMPINDCATEG3Y4= isnull((SELECT floor(round(SUM(PID_CTOT_DLS),0)/1000) FROM VDECANUALINDCAT3Y4 WHERE DAN_CODIGO = @dancodigo),0),
DAN_IMPTEMPCATEG1=isnull((SELECT floor(round(SUM(PID_CTOT_DLS),0)/1000) FROM VDECANUALDIRCAT1 WHERE DAN_CODIGO = @dancodigo),0),
DAN_IMPTEMPCATEG2=isnull((SELECT floor(round(SUM(PID_CTOT_DLS),0)/1000) FROM VDECANUALDIRCAT2 WHERE DAN_CODIGO = @dancodigo),0),
DAN_IMPTEMPCATEG3Y4=isnull((SELECT floor(round(SUM(PID_CTOT_DLS),0)/1000) FROM VDECANUALDIRCAT3Y4 WHERE DAN_CODIGO = @dancodigo),0)
WHERE DAN_CODIGO=@dancodigo


--sumatoria de la relacion de pedimentos de exportacion directa o indirectamente en pesos.
UPDATE dbo.DECANUALNVA
SET DAN_TOTALEXP= isnull((SELECT     floor(round(SUM(VALOR),0)/1000)
	FROM         VDECANUALTOTALEXP
	GROUP BY DAN_CODIGO
	HAVING      (DAN_CODIGO =@dancodigo)),0),
 DAN_VENTATOTAL=isnull((SELECT     floor(round(SUM(VALOR),0)/1000)
	FROM         VDECANUALTOTALEXP
	GROUP BY DAN_CODIGO
	HAVING      (DAN_CODIGO =@dancodigo)),0)
WHERE DAN_CODIGO=@dancodigo

--sumatoria de la relacion de pedimentos de importacion directa o indirectamente de componentes en pesos.
UPDATE dbo.DECANUALNVA
SET DAN_TOTALIMP= 0 

WHERE DAN_CODIGO=@dancodigo


	if isnull((SELECT floor(round(SUM(ISNULL(PI_IMPORTECONTR, 0)),0)/1000) FROM VDECANUALIMPUESTO GROUP BY DAN_CODIGO HAVING (DAN_CODIGO = @dancodigo)),0)>0 or
                isnull((SELECT     floor(round(SUM(PIT_CONTRIBTOTMN),0)/1000) AS PIT_CONTRIBTOTMN FROM  VDECANUALIMPUESTOENT WHERE (DAN_CODIGO = @dancodigo)),0)>0
		UPDATE dbo.DECANUALNVA
		SET DAN_IMPUESTOTALPAG = isnull((SELECT floor(round(SUM(ISNULL(PI_IMPORTECONTR, 0)),0)/1000) FROM VDECANUALIMPUESTO GROUP BY DAN_CODIGO HAVING (DAN_CODIGO = @dancodigo)),0)+
						isnull((SELECT     floor(round(SUM(PIT_CONTRIBTOTMN),0)/1000) AS PIT_CONTRIBTOTMN FROM  VDECANUALIMPUESTOENT WHERE (DAN_CODIGO = @dancodigo)),0)
		WHERE DAN_CODIGO=@dancodigo
	else
		UPDATE dbo.DECANUALNVA
		SET DAN_IMPUESTOTALPAG = 0
		WHERE DAN_CODIGO=@dancodigo
	

	-- son impuestos determinados (no por pagar)
	if isnull((SELECT floor(round(SUM(IMPUESTOXPAGAR),0)/1000) FROM VDECANUALIMPUESTOXPAGAR WHERE (DAN_CODIGO = @dancodigo)),0)>0
		UPDATE dbo.DECANUALNVA
		SET DAN_IMPUESTOTALXPAG =isnull((SELECT floor(round(SUM(IMPUESTOXPAGAR),0)/1000) FROM VDECANUALIMPUESTOXPAGAR WHERE (DAN_CODIGO = @dancodigo)),0)
		WHERE DAN_CODIGO=@dancodigo
	else
		UPDATE dbo.DECANUALNVA
		SET DAN_IMPUESTOTALXPAG =0
		WHERE DAN_CODIGO=@dancodigo

	
-- Relaci>n de bienes producidos por producto sealando fraccion arancelaria.
exec SP_FILLDECANUALDET @dancodigo





GO
