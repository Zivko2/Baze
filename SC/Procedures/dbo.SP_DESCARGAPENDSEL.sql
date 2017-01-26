SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[SP_DESCARGAPENDSEL] (@KAP_CODIGO INT, @PID_INDICED INT, @CANTIDADDESC decimal(38,6), @KAP_Saldo_FED decimal(38,6), @MA_CODIGO INT, @PICODIGO INT,
@KAP_FACTRANS INT, @KAP_INDICED_FACT INT, @MA_HIJOORIG INT, @KAP_TIPO_DESC VARCHAR(1), @KAP_CantTotADescargar decimal(38,6), @KAP_PADREMAIN INT, @KAP_CODIGO2 int, @KAP_ESTATUS char(1)='D') as


--declare @KAP_FACTRANS INT, @KAP_INDICED_FACT INT, @MA_HIJOORIG INT, @KAP_TIPO_DESC VARCHAR(1), @KAP_CantTotADescargar decimal(38,6), @KAP_PADREMAIN INT

--DECLARE @KAP_CODIGO2 INT



--	SELECT @MA_CODIGO=MA_CODIGO, @PICODIGO=PI_CODIGO FROM PIDESCARGA WHERE PID_INDICED=@PID_INDICED
/*

	IF @SELKAR='S'
	begin
		 if exists (select * from sysobjects where id = object_id('[KARDESPED_Temp]') and OBJECTPROPERTY(id, 'IsTable') = 1) 
 		drop table [KARDESPED_Temp]

		SELECT    KAP_FACTRANS, KAP_INDICED_FACT, MA_HIJO as MA_HIJOORIG, KAP_TIPO_DESC, KAP_CantTotADescargar,
		           isnull(KAP_PADREMAIN,0) as KAP_PADREMAIN
		INTO dbo.KARDESPED_Temp
		FROM         KARDESPED
		WHERE     (KAP_CODIGO =@KAP_CODIGO)
	end

	SELECT    @KAP_FACTRANS=KAP_FACTRANS, @KAP_INDICED_FACT=KAP_INDICED_FACT, @MA_HIJOORIG=MA_HIJOORIG, @KAP_TIPO_DESC=KAP_TIPO_DESC, @KAP_CantTotADescargar=KAP_CantTotADescargar,
	           @KAP_PADREMAIN=isnull(KAP_PADREMAIN,0) 
	FROM         KARDESPED_Temp


*/

--	SELECT @KAP_CODIGO2=ISNULL((SELECT MAX(KAP_CODIGO) FROM KARDESPED),0)+1


	begin tran
	INSERT INTO KARDESPED(KAP_CODIGO, KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, MA_HIJO, KAP_TIPO_DESC, KAP_ESTATUS, KAP_CantTotADescargar, KAP_Saldo_FED, KAP_CANTDESC, KAP_PADRESUST, KAP_PADREMAIN)	
	VALUES(@KAP_CODIGO2, @KAP_FACTRANS, @KAP_INDICED_FACT, @PID_INDICED, @MA_CODIGO, @KAP_TIPO_DESC, @KAP_ESTATUS, @KAP_CantTotADescargar, @KAP_Saldo_FED, @CANTIDADDESC, @MA_HIJOORIG, @KAP_PADREMAIN)
	commit tran


	begin tran
	UPDATE KARDESPED
	SET KAP_ESTATUS=@KAP_ESTATUS
	WHERE KAP_CODIGO=@KAP_CODIGO 
	commit tran

	begin tran
	delete from KARDESPED
	where KAP_CODIGO = @KAP_CODIGO and KAP_INDICED_PED is null
	commit tran

	begin tran
	UPDATE PIDESCARGA
	SET PID_SALDOGEN=PID_SALDOGEN-@CANTIDADDESC
	WHERE PID_INDICED=@PID_INDICED
	commit tran

	EXEC SP_ACTUALIZAESTATUSPEDIMP @PICODIGO





GO
