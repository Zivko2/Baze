SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ADDARANCELBASETIGIE] (@fraccion varchar(20), @pa_codigo int, @art_tipo varchar(1))   as

SET NOCOUNT ON 
declare @ART_CODIGO int, @consecutivo int, @ar_codigo int


	if not exists (select * from arancel where replace(ar_fraccion,'.','') = @fraccion and PA_CODIGO=@pa_codigo and ar_tipo=@art_tipo)
	begin

		SELECT @CONSECUTIVO=ISNULL(MAX(AR_CODIGO),0) FROM ARANCEL
		SET @CONSECUTIVO=@CONSECUTIVO+1

	
		insert into arancel (AR_CODIGO, AR_FRACCION, AR_DIGITO, AR_OFICIAL, AR_USO, AR_TIPO, AR_TIPOREG, PA_CODIGO, 
	                      ME_CODIGO, AR_TIPOIMPUESTO, AR_CANTUMESP, AR_ESPEC, AR_PORCENT_8VA, AR_ADVDEF, 
	                       AR_CAPITULO, AR_DESCCAPITULO, AR_PARTIDA, AR_DESCPARTIDA, AR_FECHAREVISION, AR_IVA, AR_IVAFRANJA, ME_CODIGO2, AR_ULTMODIFTIGIE)

		SELECT    @consecutivo, @fraccion, ART_DIGITO, ART_OFICIAL, ART_USO, ISNULL(ART_TIPO,'A'), ART_TIPOREG, PA_CODIGO, 
		                   ME_CODIGO, ART_TIPOIMPUESTO, ART_CANTUMESP, ART_ESPEC, ART_PORCENT_8VA, ART_ADVDEF, 
		                    ART_CAPITULO, ART_DESCCAPITULO, ART_PARTIDA, ART_DESCPARTIDA, ART_FECHAREVISION, ART_IVA, ART_IVAFRANJA, ME_CODIGO2,
			GETDATE()
		FROM         intradeglobal.dbo.ARANCELTIGIE
		WHERE ART_FRACCION =@fraccion and PA_CODIGO=@pa_codigo and art_tipo=@art_tipo
		

	end
	begin
		select @CONSECUTIVO=ar_codigo from arancel where replace(ar_fraccion,'.','') = @fraccion and PA_CODIGO=@pa_codigo and ar_tipo=@art_tipo
	end



		SELECT    @ART_CODIGO=ART_CODIGO
		FROM         intradeglobal.dbo.ARANCELTIGIE
		WHERE ART_FRACCION =@fraccion and PA_CODIGO=@pa_codigo and art_tipo = @art_tipo



		IF @pa_codigo=154 
		begin

			delete from paisara where ar_codigo=@consecutivo

			insert into paisara (AR_CODIGO, PA_CODIGO, PAR_BEN, SPI_CODIGO)
			select @consecutivo, PA_CODIGO, PART_BEN, SPI_CODIGO
			from intradeglobal.dbo.paisaratigie 
			where art_codigo =@ART_CODIGO
			and convert(varchar(25),PA_CODIGO)+convert(varchar(25),SPI_CODIGO)	 
			 not in (select convert(varchar(25),PA_CODIGO)+convert(varchar(25),SPI_CODIGO) from paisara where ar_codigo=@consecutivo)


			-- se agrega Mexico como pais de origen
			insert into paisara (AR_CODIGO, PA_CODIGO, PAR_BEN, SPI_CODIGO)
			select @consecutivo, 154, PAR_BEN, SPI_CODIGO
			from paisara 
			where ar_codigo =@consecutivo and pa_codigo=233
			and convert(varchar(25),154)+convert(varchar(25),SPI_CODIGO)	 
			 not in (select convert(varchar(25),p1.PA_CODIGO)+convert(varchar(25),p1.SPI_CODIGO) from paisara p1 where p1.ar_codigo=@consecutivo)			


			delete from sectorara where ar_codigo=@consecutivo
	

			if (SELECT CF_TIGIESECTORPERM FROM CONFIGURACION)='S'
			begin

				delete from sectorara where SE_CODIGO not 
				in (select se_codigo from vsectorperm)
				
				insert into sectorara (AR_CODIGO, SE_CODIGO, SA_PORCENT)
				select @consecutivo, SE_CODIGO, SAT_PORCENT
				from intradeglobal.dbo.sectoraratigie 
				where art_codigo =@ART_CODIGO and SE_CODIGO not in (select SE_CODIGO from sectorara where ar_codigo=@consecutivo)
				and SE_CODIGO in (select se_codigo from vsectorperm)

			end
			else
			begin
				insert into sectorara (AR_CODIGO, SE_CODIGO, SA_PORCENT)
				select @consecutivo, SE_CODIGO, SAT_PORCENT
				from intradeglobal.dbo.sectoraratigie 
				where art_codigo =@ART_CODIGO and SE_CODIGO not in (select SE_CODIGO from sectorara where ar_codigo=@consecutivo)

			end


			delete from arancelpermiso where ar_codigo=@consecutivo
	
			insert into arancelpermiso (AR_CODIGO, ARP_PERMISO)
			select @consecutivo, ARP_PERMISO
			from intradeglobal.dbo.aranceltigiepermiso 
			where art_codigo =@ART_CODIGO 
			order by arp_codigo
	
			delete from arancelcc where ar_codigo=@consecutivo
	
			insert into arancelcc(ar_codigo, producto, pa_codigo, empresa, cuota, tasa)
			select @consecutivo, producto, pa_codigo, empresa, cuota, tasa
			from intradeglobal.dbo.aranceltigiecc 
			where art_codigo =@ART_CODIGO 
			order by codigo
		end


		UPDATE ARANCEL
		SET AR_ADVDEF=-1 WHERE AR_ADVDEF IS NULL		

		DELETE paisara WHERE PAR_BEN IS NULL
		DELETE FROM SECTORARA WHERE SA_PORCENT IS NULL


select @ar_codigo= max(ar_codigo) from arancel

	update consecutivo
	set cv_codigo =  isnull(@ar_codigo,0) + 1
	where cv_tipo = 'AR'


GO
