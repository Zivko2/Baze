SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE dbo.SP_DECANUALPROSEC ( @DACODIGO INT)   as

SET NOCOUNT ON 
declare @VENTASPROD decimal(38,6), @VENTASNAC decimal(38,6), @fecha datetime


--sealar el valor total en miles de pesos y dolares de la maquinaria y equipo que hubiere importado temporalmente aplicando arancel prosec.
exec SP_REPPPSIMPTEMPACTFIJ @dacodigo
-- sealar el valor total en miles de pesos y dolares de este tipo de mercancias que hubiere importado temporalmente aplicando arancel prosec.
exec SP_REPPPSIMPTEMPMAT @dacodigo

--indicar el valor total en miles de pesos y dolares de los cambios de regimen de maquinaria y equipo que hubieren efectuado aplicando arancel prosec.
exec SP_REPPPSMDONACACTFIJ @dacodigo

-- indicar el valor total en miles de pesos y dolares de los cambios de regimen de este tipo de mercancias que hubieren efectuado aplicando arancel prosec.
exec SP_REPPPSMDONACMAT @dacodigo
-- sealar el valor total en miles de pesos y dolares de la maquinaria y equipo que hubiere importado en definitiva aplicando arancel prosec
exec SP_REPPPSIMPDEFACTFIJ @dacodigo

--sealar el valor total en miles de pesos y dolares de este tipo de mercancias que hubiere importado aplicando arancel prosec.
exec SP_REPPPSIMPDEFMAT @dacodigo

-- Relaci>n de bienes producidos por producto sealando fraccion arancelaria.
exec SP_FILLDECANUALPPSDET @dacodigo



	SELECT @VENTASPROD=round(SUM(VALOR),6)
	FROM VREPPPSTOTALPROD
	WHERE DAP_CODIGO=@DACODIGO
	
	SELECT @VENTASNAC=round(SUM(VALOR),6)
	FROM VREPPPSTOTALNAC
	WHERE DAP_CODIGO=@DACODIGO
	
	UPDATE DECANUALPPS
	SET  DAP_VENTASPROD=round(ISNULL(@VENTASPROD,0),6),
	DAP_VENTASMDONAC= round(ISNULL(@VENTASNAC,0),6),
	DAP_VENTASUNIDEXP=round(ISNULL(@VENTASPROD,0)-ISNULL(@VENTASNAC,0),6)
	WHERE DAP_CODIGO=@DACODIGO


	select @fecha=DAP_FINAL
	from decanualpps
	where dap_codigo=@DACODIGO


	exec SP_INVENTARIOFECHAPROSEC @fecha, @DACODIGO





GO
