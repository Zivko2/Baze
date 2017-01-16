SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_reestructuradescargas] (@user int, @consaldo char(1)='S')    as

--SET NOCOUNT ON 
declare @codigo int, @pidindiced int, @pid_saldogen decimal(38,6), @pid_can_gen decimal(38,6), @kap_indiced_ped int, @pid_saldogenr decimal(38,6), 
@pid_can_genr decimal(38,6), @Sumkap_CantDesc decimal(38,6), @countkardesped int, @fe_codigo int

	if @consaldo='S'
	exec sp_reestructuraPiSaldos @user

	print 'actualizando fed_descargado de las facturas que no se encuentran en kardesped'

--Nuevo query, modificado ya que en sql 2008 era muy lento
--2010-10-05
	UPDATE FACTEXPDET
	SET FACTEXPDET.FED_DESCARGADO='N'
	FROM FACTEXP 
	INNER JOIN FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO 
	where FACTEXP.FE_CODIGO not in (select kap_factrans from KARDESPED group by KAP_FACTRANS)
	and  FED_DESCARGADO='S'


	alter table factexp disable trigger UPDATE_FACTEXP

	print 'actualizando fe_descargada de las facturas que no se encuentran en kardesped'
		
--Nuevo query, modificado ya que en sql 2008 era muy lento
--2010-10-05
		UPDATE FACTEXP
		SET FACTEXP.FE_DESCARGADA='N', FACTEXP.FE_FECHADESCARGA=NULL,
			FE_DESCMANUAL='N'
		FROM FACTEXP 
	    where FACTEXP.FE_CODIGO not in (select kap_factrans from KARDESPED group by KAP_FACTRANS)			             
	    and (FACTEXP.FE_DESCARGADA='S' or FACTEXP.FE_FECHADESCARGA IS NOT NULL)
	    and tq_codigo not in (SELECT TQ_CODIGO FROM TEMBARQUE WHERE TQ_NOMBRE='EMPAQUE REUTILIZABLE')


	alter table factexp enable trigger UPDATE_FACTEXP

	print 'actualizando estatus de las facturas que no se encuentran en kardesped'
	Exec SP_ACTUALIZAESTATUSFACTEXPALL


	print 'actualizando la bandera de configuracion'
	update configuracion
	set cf_descargando='N', US_DESCARGANDO=0


	exec SP_CREATABLALOG 60
	insert into sysusrlog60 (user_id, mov_id, referencia, frmtag, fechahora)
	values (@user, 2, 'Reestructuracion de descargas', 60, getdate())

	exec sp_ligacorrecta_all @user

	if exists (select * from intradeglobal.dbo.avance where AVA_MENSAJENO>=0 and AVA_MENSAJENO<=1)
	delete from intradeglobal.dbo.avance where AVA_MENSAJENO>=0 and AVA_MENSAJENO<=1



























GO
