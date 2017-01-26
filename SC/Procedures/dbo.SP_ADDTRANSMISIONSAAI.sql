SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



/*genera un registro en la tabla de transmision, este procedimiento se ejecuta desde el pedimento */
CREATE PROCEDURE [dbo].[SP_ADDTRANSMISIONSAAI] (@PI_CODIGO INT, @Tipo char(1))   as


declare @TRM_CODIGO int, @pi_folio varchar(20), @pi_fec_pag datetime, @cp_codigo int, @agt_codigo int, @fecha VARCHAR(11)


/*@Tipo = F  Firma electronica
   @Tipo = B  Pago a Banco
   @Tipo = P  Prevalidacion
   @Tipo=T Aviso de Traslado
*/

select @fecha=convert(varchar(10),getdate(),101)



	if @Tipo ='P'
	begin

		select @pi_folio=fc_folio from factcons where fc_codigo=@PI_CODIGO

		if not exists (select * from transmision where TRM_RECORDID='P'+@pi_folio and TRM_PREVIOCONS='P')
		begin
			EXEC  SP_GETCONSECUTIVO 'TRM', @VALUE = @TRM_CODIGO OUTPUT
	
			insert into TRANSMISION(TRM_CODIGO, TRM_RECORDID, TRM_FECHA, CL_CODIGO, CP_CODIGO, AGC_CODIGO, TRM_TIPO, TRM_TIPOSAAI, TRM_PREVIOCONS, 
			                      TRM_SAAI_CONS, AGT_CODIGO, VAL_CODIGO, BAN_CODIGO, TRM_ESTATUS, TRM_FOLIOPED)
			SELECT @TRM_CODIGO, 'P'+FC_FOLIO, @fecha, 1, CP_CODIGO, (select max(agc_codigo) from transmision where trm_tipo='P'), 'P', 1, 'P', 
				(SELECT CF_SAAI_CONS FROM CONFIGURACION), AGT_CODIGO, (select max(val_codigo) from transmision where trm_tipo='P'), 
				(select max(ban_codigo) from transmision where trm_tipo='P'), 'N', FC_FOLIO
			FROM FACTCONS WHERE FC_CODIGO=@PI_CODIGO
	
			if not exists(select * from TRANSMISIONREL where ET_CODIGO=@PI_CODIGO and TRM_CODIGO=@TRM_CODIGO)
			insert into TRANSMISIONREL(ET_CODIGO, TRM_CODIGO, TRL_TIPO)
			SELECT @PI_CODIGO, @TRM_CODIGO, 'P'
		
		
			update configuracion
			set CF_SAAI_CONS=isnull(CF_SAAI_CONS,0)+1
	
		end
		else
		begin
			select @TRM_CODIGO=TRM_CODIGO from transmision where TRM_RECORDID='P'+@pi_folio and TRM_PREVIOCONS='P'

			if not exists(select * from TRANSMISIONREL where ET_CODIGO=@PI_CODIGO and TRM_CODIGO=@TRM_CODIGO)
			insert into TRANSMISIONREL(ET_CODIGO, TRM_CODIGO, TRL_TIPO)
			SELECT @PI_CODIGO, @TRM_CODIGO, 'P'

		end


	end 

	if @Tipo ='F'
	begin

		select @pi_folio=pi_folio from pedimp where pi_codigo=@PI_CODIGO
	
		if not exists (select * from transmision where TRM_RECORDID='F'+@pi_folio and TRM_PREVIOCONS='F')
		begin
			EXEC  SP_GETCONSECUTIVO 'TRM', @VALUE = @TRM_CODIGO OUTPUT
	
			insert into TRANSMISION(TRM_CODIGO, TRM_RECORDID, TRM_FECHA, CL_CODIGO, CP_CODIGO, AGC_CODIGO, TRM_TIPO, TRM_TIPOSAAI, TRM_PREVIOCONS, 
			                      TRM_SAAI_CONS, AGT_CODIGO, VAL_CODIGO, BAN_CODIGO, TRM_ESTATUS, TRM_FOLIOPED)
			SELECT @TRM_CODIGO, 'F'+PI_FOLIO, PI_FEC_PAG, 1, CP_CODIGO, (select max(agc_codigo) from transmision where trm_tipo='P'), 'P', 1, 'F', 
				(SELECT CF_SAAI_CONS FROM CONFIGURACION), AGT_CODIGO, (select max(val_codigo) from transmision where trm_tipo='P'), 
				(select max(ban_codigo) from transmision where trm_tipo='P'), 'N', PI_FOLIO
			FROM PEDIMP
			WHERE PI_CODIGO=@PI_CODIGO
	
			if not exists(select * from TRANSMISIONREL where ET_CODIGO=@PI_CODIGO and TRM_CODIGO=@TRM_CODIGO)
			insert into TRANSMISIONREL(ET_CODIGO, TRM_CODIGO, TRL_TIPO)
			SELECT @PI_CODIGO, @TRM_CODIGO, 'F'
		
		
			update configuracion
			set CF_SAAI_CONS=isnull(CF_SAAI_CONS,0)+1
	
		end
		else
		begin
			select @TRM_CODIGO=TRM_CODIGO from transmision where TRM_RECORDID='F'+@pi_folio and TRM_PREVIOCONS='F'

			if not exists(select * from TRANSMISIONREL where ET_CODIGO=@PI_CODIGO and TRM_CODIGO=@TRM_CODIGO)
			insert into TRANSMISIONREL(ET_CODIGO, TRM_CODIGO, TRL_TIPO)
			SELECT @PI_CODIGO, @TRM_CODIGO, 'F'
		
	

		end
	end

	if @Tipo ='B'
	begin

		select @pi_folio=pi_folio from pedimp where pi_codigo=@PI_CODIGO	
	
		if not exists (select * from transmision where TRM_RECORDID='B'+@pi_folio and TRM_PREVIOCONS='B')
		begin
			EXEC  SP_GETCONSECUTIVO 'TRM', @VALUE = @TRM_CODIGO OUTPUT
	
			insert into TRANSMISION(TRM_CODIGO, TRM_RECORDID, TRM_FECHA, CL_CODIGO, CP_CODIGO, AGC_CODIGO, TRM_TIPO, TRM_TIPOSAAI, TRM_PREVIOCONS, 
			                      TRM_SAAI_CONS, AGT_CODIGO, VAL_CODIGO, BAN_CODIGO, TRM_ESTATUS, TRM_FOLIOPED)
			SELECT @TRM_CODIGO, 'B'+PI_FOLIO, PI_FEC_PAG, 1, CP_CODIGO, (select max(agc_codigo) from transmision where trm_tipo='P'), 'P', 1, 'B', 
				(SELECT CF_SAAI_CONS FROM CONFIGURACION), AGT_CODIGO, (select max(val_codigo) from transmision where trm_tipo='P'), 
				(select max(ban_codigo) from transmision where trm_tipo='P'), 'N', PI_FOLIO
			FROM PEDIMP
			WHERE PI_CODIGO=@PI_CODIGO
	
			if not exists(select * from TRANSMISIONREL where ET_CODIGO=@PI_CODIGO and TRM_CODIGO=@TRM_CODIGO)
			insert into TRANSMISIONREL(ET_CODIGO, TRM_CODIGO, TRL_TIPO)
			SELECT @PI_CODIGO, @TRM_CODIGO, 'B'
		
		
			update configuracion
			set CF_SAAI_CONS=isnull(CF_SAAI_CONS,0)+1
	
		end
		else
		begin
			select @TRM_CODIGO=TRM_CODIGO from transmision where TRM_RECORDID='B'+@pi_folio and TRM_PREVIOCONS='B'

			if not exists(select * from TRANSMISIONREL where ET_CODIGO=@PI_CODIGO and TRM_CODIGO=@TRM_CODIGO)
			insert into TRANSMISIONREL(ET_CODIGO, TRM_CODIGO, TRL_TIPO)
			SELECT @PI_CODIGO, @TRM_CODIGO, 'B'

		end
	end





	if @Tipo ='T'
	begin
		select @pi_folio=ati_folio from avisotraslado where ati_codigo=@PI_CODIGO

		if not exists (select * from transmision where TRM_RECORDID='T'+@pi_folio and TRM_PREVIOCONS='T')
		begin
			EXEC  SP_GETCONSECUTIVO 'TRM', @VALUE = @TRM_CODIGO OUTPUT
	
			insert into TRANSMISION(TRM_CODIGO, TRM_RECORDID, TRM_FECHA, CL_CODIGO, CP_CODIGO, AGC_CODIGO, TRM_TIPO, TRM_TIPOSAAI, TRM_PREVIOCONS, 
			                      TRM_SAAI_CONS, AGT_CODIGO, VAL_CODIGO, BAN_CODIGO, TRM_ESTATUS, TRM_FOLIOPED)
			SELECT @TRM_CODIGO, 'T'+FC_FOLIO, @fecha, 1, CP_CODIGO, (select max(agc_codigo) from transmision where trm_tipo='P'), 'P', 'A', 'T', 
				(SELECT CF_SAAI_CONS FROM CONFIGURACION), AGT_CODIGO, (select max(val_codigo) from transmision where trm_tipo='P'), 
				(select max(ban_codigo) from transmision where trm_tipo='P'), 'N', FC_FOLIO
			FROM FACTCONS WHERE FC_CODIGO=@PI_CODIGO
	
			if not exists(select * from TRANSMISIONREL where ET_CODIGO=@PI_CODIGO and TRM_CODIGO=@TRM_CODIGO)
			insert into TRANSMISIONREL(ET_CODIGO, TRM_CODIGO, TRL_TIPO)
			SELECT @PI_CODIGO, @TRM_CODIGO, 'T'
		
		
			update configuracion
			set CF_SAAI_CONS=isnull(CF_SAAI_CONS,0)+1
	
		end
		else
		begin
			select @TRM_CODIGO=TRM_CODIGO from transmision where TRM_RECORDID='T'+@pi_folio and TRM_PREVIOCONS='T'

			if not exists(select * from TRANSMISIONREL where ET_CODIGO=@PI_CODIGO and TRM_CODIGO=@TRM_CODIGO)
			insert into TRANSMISIONREL(ET_CODIGO, TRM_CODIGO, TRL_TIPO)
			SELECT @PI_CODIGO, @TRM_CODIGO, 'T'

		end


	end



GO
