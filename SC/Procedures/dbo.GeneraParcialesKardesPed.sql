SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[GeneraParcialesKardesPed] (@fechaini varchar(10), @fechafin varchar(10), @fe_codigo int=0, @borraMod char(1)='S')   as

SET NOCOUNT ON 
declare @kap_codigo int, @cantRestar decimal(38,6), @kap_tipo_desc char(2), @KAP_TIPO_DESCb char(1), @ma_hijo int,
@kap_fiscomp char(1), @kap_indiced_fact int, @kap_padresust int, @CF_DESCARGASBUS char(1)


	exec sp_droptable 'RetrabajoMod'

	if @fe_codigo>0 
	begin
--		print 'Creando tabla RetrabajoMod'
		select fed_indiced
		into dbo.RetrabajoMod
		from factexpdet left outer join factexp
		on factexp.fe_codigo=factexpdet.fe_codigo
		where fed_indiced in (SELECT KAP_INDICED_FACT FROM KARDESPED where (kap_estatus='p' or kap_estatus='n') and kap_factrans=@fe_codigo)
		and factexpdet.fe_codigo=@fe_codigo
	end
	else
	begin
--		print 'Creando tabla RetrabajoMod'
		select fed_indiced
		into dbo.RetrabajoMod
		from factexpdet left outer join factexp
		on factexp.fe_codigo=factexpdet.fe_codigo
		where fed_indiced in (SELECT KAP_INDICED_FACT FROM KARDESPED left outer join factexp on kardesped.kap_factrans=factexp.fe_codigo
				        where (kap_estatus='p'or kap_estatus='n') and fe_fecha>=@fechaini and fe_fecha<=@fechafin)
	end



	if exists(select * from kardesped where  KAP_INDICED_FACT IN (SELECT fed_indiced FROM RetrabajoMod) and kap_estatus='N')
	delete from kardesped
	WHERE KAP_INDICED_FACT IN (SELECT fed_indiced FROM RetrabajoMod)
	and kap_estatus='N'


	exec sp_droptable 'Pendienteskap'

	if @fe_codigo=0
	begin
		SELECT     kap_codigo, kap_fiscomp, kap_indiced_fact, kap_tipo_desc, kap_padresust, ma_hijo, kap_estatus, KAP_CantTotADescargar, kap_saldo_fed,
		KAP_CantTotADescargar KAP_CantTotADescargarbk, kap_saldo_fed kap_saldo_fedbk
		into dbo.Pendienteskap
		FROM         dbo.FACTEXP INNER JOIN
		                      dbo.KARDESPED ON dbo.FACTEXP.FE_CODIGO = dbo.KARDESPED.KAP_FACTRANS
		WHERE     dbo.FACTEXP.FE_FECHA >= @fechaini AND dbo.FACTEXP.FE_FECHA <= @fechafin
			and dbo.KARDESPED.KAP_ESTATUS='P'
	end
	else
	begin
		SELECT     kap_codigo, kap_fiscomp, kap_indiced_fact, kap_tipo_desc, kap_padresust, ma_hijo, kap_estatus, KAP_CantTotADescargar, kap_saldo_fed,
		KAP_CantTotADescargar KAP_CantTotADescargarbk, kap_saldo_fed kap_saldo_fedbk
		into dbo.Pendienteskap
		FROM         dbo.KARDESPED 

		WHERE  	kap_factrans=@fe_codigo 
 			and dbo.KARDESPED.KAP_ESTATUS='P'
			

	end

	DELETE FROM Pendienteskap where kap_fiscomp='S' AND kap_padresust=0


	SELECT     @CF_DESCARGASBUS = CF_DESCARGASBUS
	FROM         dbo.CONFIGURACION


	--@cantRestar cantidad que se alcanzo a descargar

	UPDATE Pendienteskap
	set KAP_ESTATUS='D', 
	@cantRestar=round(KAP_CantTotADescargarbk- isnull((SELECT     ROUND(SUM(KAP_CANTDESC), 6)  
					FROM         kardesped K3
					WHERE     (K3.KAP_INDICED_FACT = Pendienteskap.KAP_INDICED_FACT) and K3.kap_fiscomp<>'S' 
					and (K3.KAP_TIPO_DESC = Pendienteskap.KAP_TIPO_DESC OR K3.KAP_TIPO_DESC = Pendienteskap.KAP_TIPO_DESC+'S')
					and K3.kap_saldo_fed >=0
					AND (K3.KAP_PADRESUST=Pendienteskap.KAP_PADRESUST OR K3.MA_HIJO=Pendienteskap.KAP_PADRESUST)),0),6),
	KAP_CantTotADescargar= round(KAP_CantTotADescargar-isnull(@cantRestar,0),6),
	kap_saldo_fed= round(kap_saldo_fed-@cantRestar,6)
	FROM        Pendienteskap
	where kap_fiscomp<>'S' and Pendienteskap.KAP_PADRESUST > 0


	UPDATE Pendienteskap
	set KAP_ESTATUS='D', 
	@cantRestar=round(KAP_CantTotADescargarbk- isnull((SELECT     ROUND(SUM(KAP_CANTDESC), 6)  
					FROM         kardesped K3
					WHERE     (K3.KAP_INDICED_FACT = Pendienteskap.KAP_INDICED_FACT) and K3.kap_fiscomp<>'S' 
					--AND (K3.KAP_PADRESUST = 0 OR K3.KAP_PADRESUST=Pendienteskap.MA_HIJO)
					and (K3.KAP_TIPO_DESC = Pendienteskap.KAP_TIPO_DESC OR K3.KAP_TIPO_DESC = Pendienteskap.KAP_TIPO_DESC+'S')
					and K3.kap_saldo_fed >=0
					AND (K3.KAP_PADRESUST=Pendienteskap.MA_HIJO OR K3.MA_HIJO=Pendienteskap.MA_HIJO)),0),6),
	KAP_CantTotADescargar= round(KAP_CantTotADescargar-isnull(@cantRestar,0),6),
	kap_saldo_fed= round(kap_saldo_fed-@cantRestar,6)
	FROM        Pendienteskap
	where kap_fiscomp<>'S' and Pendienteskap.KAP_PADRESUST = 0


				
	UPDATE Pendienteskap
	set KAP_ESTATUS='D', 
	@cantRestar=round(KAP_CantTotADescargar- (SELECT     ROUND(SUM(KAP_CANTDESC), 6)  
			FROM         kardesped K3
			WHERE     (K3.KAP_INDICED_FACT = Pendienteskap.KAP_INDICED_FACT) and K3.kap_fiscomp='S' AND (K3.KAP_PADREMAIN= 0 OR K3.KAP_PADREMAIN=Pendienteskap.MA_HIJO)
			and (K3.KAP_TIPO_DESC = Pendienteskap.KAP_TIPO_DESC OR K3.KAP_TIPO_DESC = Pendienteskap.KAP_TIPO_DESC+'S')
			and K3.kap_saldo_fed >=0
			AND (K3.KAP_PADREMAIN=Pendienteskap.MA_HIJO OR K3.MA_HIJO=Pendienteskap.MA_HIJO) and K3.kap_padresust =  Pendienteskap.kap_padresust),6),
	KAP_CantTotADescargar= round(KAP_CantTotADescargar-@cantRestar,6),
	kap_saldo_fed= round(kap_saldo_fed-isnull(@cantRestar,0),6)
	FROM        Pendienteskap
	where kap_fiscomp='S' AND kap_padresust>0


	UPDATE KARDESPED
	SET KAP_ESTATUS=Pendienteskap.KAP_ESTATUS, 
		KAP_CantTotADescargar=Pendienteskap.KAP_CantTotADescargar, 
		kap_saldo_fed=Pendienteskap.kap_saldo_fed
	FROM KARDESPED INNER JOIN Pendienteskap
	 ON KARDESPED.KAP_CODIGO=Pendienteskap.KAP_CODIGO
	WHERE Pendienteskap.KAP_ESTATUS='D'


	UPDATE kardesped
	SET KAP_ESTATUS='D'
	FROM kardesped
	WHERE KAP_INDICED_FACT  in (select fed_indiced from RetrabajoMod)  and kap_fiscomp='S'
		AND MA_HIJO NOT IN (SELECT K_2.kap_padresust
				FROM  kardesped K_2
				WHERE     (K_2.KAP_INDICED_FACT = kardesped.KAP_INDICED_FACT) AND (K_2.kap_padresust > 0)  and kap_fiscomp='S'
				and kap_estatus<>'D'
				and (K_2.KAP_TIPO_DESC = kardesped.KAP_TIPO_DESC OR K_2.KAP_TIPO_DESC = kardesped.KAP_TIPO_DESC+'S')
				GROUP BY K_2.kap_padresust)
		AND MA_HIJO  IN (SELECT K_3.kap_padresust
				FROM  kardesped K_3
				WHERE     (K_3.KAP_INDICED_FACT = kardesped.KAP_INDICED_FACT) AND (K_3.kap_padresust > 0)  and kap_fiscomp='S'
				and (K_3.KAP_TIPO_DESC = kardesped.KAP_TIPO_DESC OR K_3.KAP_TIPO_DESC = kardesped.KAP_TIPO_DESC+'S')
				GROUP BY K_3.kap_padresust)
		AND  KAP_ESTATUS<>'D'



	

	exec sp_droptable 'Pendienteskap'

	if @borraMod='S'
	exec sp_droptable 'RetrabajoMod'



GO
