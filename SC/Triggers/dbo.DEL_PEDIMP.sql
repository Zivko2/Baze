SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger DEL_PEDIMP on dbo.PEDIMP  for DELETE as
SET NOCOUNT ON
begin

declare @pi_codigo int, @rectificado int, @countrect int, @codigo int, @codigo2 int, @pi_movimiento char(1), @CCP_TIPO varchar(2), 
@cp_codigo int, @picodigo int, @cpcodigo int, @fc_codigo int, @cp_codigo1 int, @CCP_TIPORectificado varchar(2), @pi_rectifica int

	select @pi_codigo = pi_codigo, @pi_movimiento=pi_movimiento, @cp_codigo1=cp_codigo, @fc_codigo=fc_codigo, @pi_rectifica=pi_rectifica
	 from deleted

	SELECT     @CCP_TIPO = CCP_TIPO FROM CONFIGURACLAVEPED WHERE CP_CODIGO =@cp_codigo1


	select @CCP_TIPORectificado =ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo =@pi_rectifica)

	-- este no es un cursor porque las facturas ya tienen uno en el update
	if @pi_movimiento<>'S' 
	begin

		if @CCP_TIPO='CN' or @CCP_TIPORectificado='CN' or @CCP_TIPO='RG'  or @CCP_TIPORectificado='RG' or @CCP_TIPO='RP' or @CCP_TIPORectificado='RP'
		begin
			update factexp
			set pi_codigo=-1
			where pi_codigo =@pi_codigo

			update factexp
			set pi_rectifica=-1
			where pi_rectifica =@pi_codigo
		end
		else
		begin
			update factimp
			set pi_codigo=-1
			where pi_codigo =@pi_codigo

			update factimp
			set pi_rectifica=-1
			where pi_rectifica =@pi_codigo
		end
	end
	else
	begin	
			update factexp
			set pi_codigo=-1
			where pi_codigo =@pi_codigo

			update factexp
			set pi_rectifica=-1
			where pi_rectifica =@pi_codigo

			if @CCP_TIPO='CT' and exists (select * from vpedexp where pi_complementa=@pi_codigo)
			update pedimp
			set pi_complementa=-1
			where pi_complementa=@pi_codigo
	end	


  IF EXISTS (SELECT * FROM PedImprect  WHERE Pi_no_rect =@pi_codigo)
  begin
	declare curPiRectupdate cursor for
		select pi_codigo from pedimprect where pi_no_rect=@pi_codigo	
	open curPiRectupdate
	fetch next from curPiRectupdate into @rectificado

		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			select @cp_codigo=cp_codigo from pedimp where pi_codigo =@rectificado

			select @countrect = count(*) from pedimprect where pi_codigo=@rectificado	

			if @countrect > 1 and  not update(pi_rectestatus)
			update pedimp
			set pi_rectestatus='M'
			where pi_codigo=@rectificado 
		
			if @countrect = 1 and  not update(pi_rectestatus)
			update pedimp
			set pi_rectestatus='S'
			where pi_codigo = @rectificado
	
	
			exec SP_ACTUALIZAESTATUSPEDIMP @rectificado, @cp_codigo

		fetch next from curPiRectupdate into @rectificado

		END
	CLOSE curPiRectupdate
	DEALLOCATE curPiRectupdate

  end


	if exists (select * from pedimp where pi_rectifica=@pi_codigo)
	begin
		select @picodigo=pi_codigo, @cpcodigo=cp_codigo from pedimp where pi_rectifica=@pi_codigo
	
		update pedimp
		set pi_rectifica=0
		where pi_rectifica=@pi_codigo

		exec SP_ACTUALIZAESTATUSPEDIMP @picodigo, @cpcodigo
	end


update factexp
set fe_con_pedcr='N'
where pi_codigo=@pi_codigo and
(fe_con_pedcr='S' or fe_con_pedcr is null)


  IF EXISTS (SELECT * FROM PedImprect  WHERE Pi_no_rect =@pi_codigo)
	  delete from pedimprect where pi_no_rect=@pi_codigo

  IF EXISTS (SELECT * FROM PedImprect  WHERE Pi_codigo =@pi_codigo)
	  delete from pedimprect where pi_codigo=@pi_codigo



  /* Se borran los incrementables*/
  IF EXISTS (SELECT * FROM PedImpIncrementa, Deleted  WHERE  PedImpIncrementa.Pi_Codigo = Deleted.Pi_codigo)
     DELETE PedImpIncrementa FROM PedImpIncrementa, Deleted  WHERE PedImpIncrementa.Pi_Codigo = Deleted.Pi_codigo

  /* Se borran las contribuciones*/
  IF EXISTS (SELECT * FROM PedImpContribucion, Deleted  WHERE  PedImpContribucion.Pi_Codigo = Deleted.Pi_codigo)
     DELETE PedImpContribucion FROM PedImpContribucion, Deleted  WHERE PedImpContribucion.Pi_Codigo = Deleted.Pi_codigo

  /* Se borran valoracion*/
  IF EXISTS (SELECT * FROM PedImpValora, Deleted  WHERE  PedImpValora.Pi_Codigo = Deleted.Pi_codigo)
     DELETE PedImpValora FROM PedImpValora, Deleted  WHERE PedImpValora.Pi_Codigo = Deleted.Pi_codigo


	/* actualiza el estatus de la premodulacion*/
	  IF EXISTS (SELECT * FROM Factcons  WHERE Fc_codigo =@fc_codigo)
	update factcons
	set fc_estatus='A'
	where fc_codigo=@fc_codigo

	  /* Se borra el detalle del pedimento */
	  IF EXISTS (SELECT * FROM PedImpDet, Deleted  WHERE  PedImpDet.Pi_Codigo = Deleted.Pi_codigo)
	     DELETE PedImpDet FROM PedImpDet, Deleted  WHERE PedImpDet.Pi_Codigo = Deleted.Pi_codigo

	  /* Se borra los saldos del pedimento */
	  IF EXISTS (SELECT * FROM PiDescarga, Deleted  WHERE  PiDescarga.Pi_Codigo = Deleted.Pi_codigo)
	     DELETE PiDescarga FROM PiDescarga, Deleted  WHERE PiDescarga.Pi_Codigo = Deleted.Pi_codigo
	
	
	  /* Se borran los detalles B*/
	  IF EXISTS (SELECT * FROM PedImpDetB, Deleted  WHERE  PedImpDetB.Pi_Codigo = Deleted.Pi_codigo)
	     DELETE PedImpDetB FROM PedImpDetB, Deleted  WHERE PedImpDetB.Pi_Codigo = Deleted.Pi_codigo
	
	  /* Se borran los detalles Prueba Suficiente*/
	  IF EXISTS (SELECT * FROM PedImpprueba, Deleted  WHERE  PedImpprueba.Pi_Codigo = Deleted.Pi_codigo)
	     DELETE PedImpprueba FROM PedImpprueba, Deleted  WHERE PedImpprueba.Pi_Codigo = Deleted.Pi_codigo


	  /* Se borran el historico del R1*/
	  IF EXISTS (SELECT * FROM PedImpR1Hist, Deleted  WHERE  PedImpR1Hist.Pi_Codigo = Deleted.Pi_codigo)
	     DELETE PedImpR1Hist FROM PedImpR1Hist, Deleted  WHERE PedImpR1Hist.Pi_Codigo = Deleted.Pi_codigo



	  IF EXISTS (SELECT * FROM KARDATOSPEDEXPDESC, Deleted  WHERE  KARDATOSPEDEXPDESC.PI_CODIGOPEDEXP = Deleted.Pi_codigo)
	     DELETE KARDATOSPEDEXPDESC FROM KARDATOSPEDEXPDESC, Deleted  WHERE KARDATOSPEDEXPDESC.PI_CODIGOPEDEXP = Deleted.Pi_codigo

	  IF EXISTS (SELECT * FROM KARDATOSPEDEXPPAGOUSA, Deleted  WHERE  KARDATOSPEDEXPPAGOUSA.Pi_Codigo = Deleted.Pi_codigo)
	     DELETE KARDATOSPEDEXPPAGOUSA FROM KARDATOSPEDEXPPAGOUSA, Deleted  WHERE KARDATOSPEDEXPPAGOUSA.Pi_Codigo = Deleted.Pi_codigo

	declare @consecutivo int

	SELECT @consecutivo = isnull(MAX(PI_CODIGO),0)+1 FROM PEDIMP

	update consecutivo
	set cv_codigo = isnull(@consecutivo,0)
	where cv_tipo ='PI'






END



















GO
