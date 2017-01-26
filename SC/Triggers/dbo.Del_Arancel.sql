SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE trigger Del_Arancel on dbo.ARANCEL for DELETE as
SET NOCOUNT ON 
begin
declare @consecutivo int

  IF EXISTS (SELECT * FROM PaisAra ,deleted WHERE PaisAra.Ar_Codigo = deleted.Ar_Codigo)
	begin
		DELETE PaisAra FROM PaisAra ,deleted WHERE PaisAra.Ar_Codigo = deleted.Ar_Codigo
		SELECT @consecutivo = isnull(MAX(PAR_CODIGO),0)+1 FROM PAISARA
		dbcc checkident (paisara, reseed, @consecutivo) WITH NO_INFOMSGS
	end


   IF EXISTS (SELECT * FROM SectorAra ,deleted WHERE SectorAra.Ar_Codigo = deleted.Ar_Codigo)
	begin
		DELETE SectorAra FROM SectorAra ,deleted WHERE SectorAra.Ar_Codigo = deleted.Ar_Codigo
		SELECT @consecutivo = isnull(MAX(SA_CODIGO),0)+1 FROM SECTORARA
		dbcc checkident (sectorara, reseed, @consecutivo) WITH NO_INFOMSGS
	end


	if not exists (select * from aranceldel where ar_codigo in (select ar_codigo from deleted))
	INSERT INTO ARANCELDEL(AR_CODIGO, AR_FRACCION)
	SELECT AR_CODIGO, AR_FRACCION FROM DELETED


	SELECT @consecutivo = isnull(MAX(AR_CODIGO),0)+1 FROM ARANCEL

	update consecutivo
	set cv_codigo = isnull(@consecutivo,0)
	where cv_tipo ='AR'


end




































GO
