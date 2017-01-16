SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_VERIFICAINTRADEvsSAAI] (@FechaIni VARCHAR(11), @FechaFin VARCHAR(11), @FILTROCLAVE CHAR(1) ='N', @TIPOMOV CHAR(1)='E')   as

		UPDATE    TempAgSaai 
	SET Patente = RTRIM(LTRIM(Patente)), Pedimento = RTRIM(LTRIM(Pedimento)), Aduana = RTRIM(LTRIM(Aduana)), TOper = RTRIM(LTRIM(TOper)), 
	    CveDocto = replace(RTRIM(LTRIM(CveDocto)),'ÿ',''), RFC = RTRIM(LTRIM(RFC)), Contribuyente = RTRIM(LTRIM(Contribuyente)), TipoPed = RTRIM(LTRIM(TipoPed)), 
	    Fraccion = RTRIM(LTRIM(Fraccion)), PaisOD = RTRIM(LTRIM(PaisOD)), PaisCV = RTRIM(LTRIM(PaisCV))

	TRUNCATE TABLE TempAgTotSaai

  -- se insertan todos los registros de TempAgSaai a TempAgTotSaai agrupados

	IF (SELECT CF_CONCILIASAAISEC FROM CONFIGURACION)='S'
		EXEC SP_VERIFICAINTRADEvsSAAISec @FechaIni, @FechaFin, @FILTROCLAVE, @TIPOMOV
	ELSE
		EXEC SP_VERIFICAINTRADEvsSAAIAgr @FechaIni, @FechaFin, @FILTROCLAVE, @TIPOMOV






	IF @FILTROCLAVE='S'
	DROP TABLE ##TEMPCLAVE 

	IF @FILTROCLAVE='Z'
	DROP TABLE ##TEMPCLAVE2 

	IF @FILTROCLAVE='A'
	begin
		DROP TABLE ##TEMPCLAVE 
		DROP TABLE ##TEMPCLAVE2 
	end
GO
