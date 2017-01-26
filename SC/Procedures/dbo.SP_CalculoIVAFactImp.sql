SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_CalculoIVAFactImp] (@ficodigo int)   as

SET NOCOUNT ON 
declare @fecha datetime, @IVA decimal(38,6), @ValorDTA decimal(38,6), @coniva char(1), @ccp_tipo varchar(2), @totalpartidasdta integer,
@dummy varchar(3), @dtaPorcenta decimal(38,6), @IVAtasa decimal(38,6), @conISAN char(1), @valoraduanatotal decimal(38,6)

	select @fecha=rvf_fechacruce from revorigen where fi_codigo=@ficodigo

	select  @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@ficodigo)


	-- calculo de DTA
	exec sp_calculoDTAFactImp  @ficodigo, @tipodta=@dummy output


	SELECT     @valoraduanatotal= SUM((dbo.FACTIMPDET.FID_COS_TOT + dbo.VFACTIMPFLETE.FI_FLETE + dbo.VFACTIMPFLETE.FI_SEGURO + dbo.VFACTIMPFLETE.FI_EMBALAJE + dbo.VFACTIMPFLETE.FI_OTROS
	                       )* dbo.FACTIMP.FI_TIPOCAMBIO)
	FROM         dbo.FACTIMPDET LEFT OUTER JOIN
	                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
	                      dbo.VFACTIMPFLETE ON dbo.FACTIMPDET.FI_CODIGO = dbo.VFACTIMPFLETE.FI_CODIGO
	WHERE     (dbo.FACTIMPDET.FI_CODIGO = @ficodigo)


	SELECT     @dtaPorcenta=case when CLAVEPED.CP_PAGODTA='O' then .008 when CLAVEPED.CP_PAGODTA='U' then .00176
		else 0 end FROM  CLAVEPED INNER JOIN REVORIGEN ON CLAVEPED.CP_CODIGO = REVORIGEN.CP_CODIGO
	WHERE     (REVORIGEN.FI_CODIGO = @ficodigo)


	if exists (select * from revorigen where fi_codigo =@ficodigo and (cp_codigo in 
		(SELECT CP_CODIGO from configuraclaveped WHERE CCP_TIPO IN ('CN', 'OC', 'RG', 'ED', 'SD', 'SI')) or
		 (cp_codigo in  (SELECT CP_CODIGO from configuraclaveped WHERE CCP_TIPO IN ('IE')))))
	begin
		set @coniva='S'
	end
	else
	begin
		set @coniva='N'
	end


	if @coniva='S'
	begin
	

		-- dta
		select @ValorDTA=rvc_monto 
		from RevOrigenContrib 
		where fi_codigo =@ficodigo and con_codigo in (select con_codigo from contribucion where con_clave='1')


		SELECT     @IVA=isnull(CONTRIBUCIONFIJA.COF_VALOR,0)/100
		FROM         CONTRIBUCIONFIJA INNER JOIN
		                      CONFIGURACONTRIBUCION ON CONTRIBUCIONFIJA.CON_CODIGO = CONFIGURACONTRIBUCION.CON_CODIGO AND 
		                      CONTRIBUCIONFIJA.COF_TIPOVALOR = CONFIGURACONTRIBUCION.CFB_TIPO
		WHERE     (CONTRIBUCIONFIJA.CON_CODIGO in(select con_codigo from contribucion where con_clave='3')) AND 
		(CONTRIBUCIONFIJA.COF_PERINI <=@fecha) AND (CONTRIBUCIONFIJA.COF_PERFIN >=@fecha)


		SELECT     @IVAtasa=isnull(CONTRIBUCIONFIJA.COF_VALOR,0)
		FROM         CONTRIBUCIONFIJA INNER JOIN
		                      CONFIGURACONTRIBUCION ON CONTRIBUCIONFIJA.CON_CODIGO = CONFIGURACONTRIBUCION.CON_CODIGO AND 
		                      CONTRIBUCIONFIJA.COF_TIPOVALOR = CONFIGURACONTRIBUCION.CFB_TIPO
		WHERE     (CONTRIBUCIONFIJA.CON_CODIGO in(select con_codigo from contribucion where con_clave='3')) AND 
		(CONTRIBUCIONFIJA.COF_PERINI <=@fecha) AND (CONTRIBUCIONFIJA.COF_PERFIN >=@fecha)

		select @totalpartidasdta = count(*) from factimpdet where fi_codigo = @ficodigo and fid_def_tip <> 'P'


		if exists (select * from RevOrigenContrib where fi_codigo =@ficodigo and con_codigo in(select con_codigo from contribucion where con_clave='3'))
		delete from RevOrigenContrib where fi_codigo=@ficodigo and con_codigo in(select con_codigo from contribucion where con_clave='3')

-- con dta

		exec sp_droptable 'tempIVAfactImp'

		SELECT fi_codigo, 0.0 AS RVC_MONTO
		into dbo.tempIVAfactImp
		from factimp where fi_codigo=@ficodigo


		if @dummy='OM'  OR @dummy='SM' or @dummy='CF' or @dummy='CFV' or @dummy='CFM'  
		begin
			if (select cp_usanaftadta from claveped where cp_codigo in (select cp_codigo from RevOrigen where fi_codigo=@ficodigo))<>'S'
			begin
				
				INSERT INTO tempIVAfactImp (FI_CODIGO, RVC_MONTO)
				SELECT     @ficodigo, SUM((@ValorDTA+dbo.FACTIMPDET.FID_COS_TOT + dbo.VFACTIMPFLETE.FI_FLETE + dbo.VFACTIMPFLETE.FI_SEGURO + dbo.VFACTIMPFLETE.FI_EMBALAJE + dbo.VFACTIMPFLETE.FI_OTROS
				                       )* dbo.FACTIMP.FI_TIPOCAMBIO)*.10
				FROM         dbo.FACTIMPDET LEFT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
				                      dbo.VFACTIMPFLETE ON dbo.FACTIMPDET.FI_CODIGO = dbo.VFACTIMPFLETE.FI_CODIGO
				WHERE     (dbo.FACTIMPDET.FI_CODIGO = @ficodigo) AND (dbo.FACTIMPDET.FID_DEF_TIP <> 'P')


				INSERT INTO tempIVAfactImp (FI_CODIGO, RVC_MONTO)
				SELECT     @ficodigo, SUM((dbo.FACTIMPDET.FID_COS_TOT + dbo.VFACTIMPFLETE.FI_FLETE + dbo.VFACTIMPFLETE.FI_SEGURO + dbo.VFACTIMPFLETE.FI_EMBALAJE + dbo.VFACTIMPFLETE.FI_OTROS
				                       )* dbo.FACTIMP.FI_TIPOCAMBIO)*.10
				FROM         dbo.FACTIMPDET LEFT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
				                      dbo.VFACTIMPFLETE ON dbo.FACTIMPDET.FI_CODIGO = dbo.VFACTIMPFLETE.FI_CODIGO
				WHERE     (dbo.FACTIMPDET.FI_CODIGO = @ficodigo) AND (dbo.FACTIMPDET.FID_DEF_TIP = 'P')



			end
			else
			begin
				INSERT INTO tempIVAfactImp (FI_CODIGO, RVC_MONTO)
				SELECT     @ficodigo, SUM((@ValorDTA+dbo.FACTIMPDET.FID_COS_TOT + dbo.VFACTIMPFLETE.FI_FLETE + dbo.VFACTIMPFLETE.FI_SEGURO + dbo.VFACTIMPFLETE.FI_EMBALAJE + dbo.VFACTIMPFLETE.FI_OTROS
				                       )* dbo.FACTIMP.FI_TIPOCAMBIO)*.10
				FROM         dbo.FACTIMPDET LEFT OUTER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
				                      dbo.VFACTIMPFLETE ON dbo.FACTIMPDET.FI_CODIGO = dbo.VFACTIMPFLETE.FI_CODIGO
				WHERE     (dbo.FACTIMPDET.FI_CODIGO = @ficodigo) 
			end	

		end
		else
		begin
-- sin dta
			INSERT INTO tempIVAfactImp (FI_CODIGO, RVC_MONTO)
			SELECT     @ficodigo, SUM((dbo.FACTIMPDET.FID_COS_TOT + dbo.VFACTIMPFLETE.FI_FLETE + dbo.VFACTIMPFLETE.FI_SEGURO + dbo.VFACTIMPFLETE.FI_EMBALAJE + dbo.VFACTIMPFLETE.FI_OTROS
			                       )* dbo.FACTIMP.FI_TIPOCAMBIO)*.10
			FROM         dbo.FACTIMPDET LEFT OUTER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
			                      dbo.VFACTIMPFLETE ON dbo.FACTIMPDET.FI_CODIGO = dbo.VFACTIMPFLETE.FI_CODIGO
			WHERE     (dbo.FACTIMPDET.FI_CODIGO = @ficodigo) 
		end


		insert into RevOrigenContrib(FI_CODIGO, CON_CODIGO, RVC_MONTO)
		select @ficodigo, (select con_codigo from contribucion where con_clave='3'),
		round(sum(rvc_monto),6)
		from tempIVAfactImp

		exec sp_droptable 'tempIVAfactImp'

	end



























GO
