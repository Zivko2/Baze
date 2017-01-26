SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[SP_ESTATUSKARDESPEDFED] (@fed_indiced int, @tipo char(1)='D')   as

SET NOCOUNT ON 

	if @tipo is null
	set @tipo='D'
	UPDATE kardespedtemp
	SET KAP_PADRESUST=0
	WHERE KAP_PADRESUST IS NULL
	AND KAP_INDICED_FACT=@fed_indiced


	UPDATE kardespedtemp
	SET kap_padremain=0
	WHERE kap_padremain IS NULL
	AND KAP_INDICED_FACT=@fed_indiced


	UPDATE kardespedtemp
	SET     KAP_ESTATUS='N'
	FROM         kardespedtemp
	WHERE     (KAP_INDICED_FACT = @fed_indiced) AND (KAP_CANTDESC=0)


	UPDATE kardespedtemp
	SET     KAP_ESTATUS='D'
	FROM         kardespedtemp
	WHERE     (KAP_INDICED_FACT = @fed_indiced) 
	AND KAP_CantTotADescargar=KAP_CANTDESC



	UPDATE kardespedtemp
	SET KAP_ESTATUS='D'
	FROM kardespedtemp
	WHERE KAP_INDICED_FACT = @fed_indiced and  (KAP_ESTATUS<>'D' OR KAP_ESTATUS IS NULL) and kap_fiscomp<>'S'
		AND KAP_CantTotADescargar =
				(SELECT     ROUND(SUM(KAP_CANTDESC), 6)  
				FROM         kardespedtemp K3
				WHERE     (K3.KAP_INDICED_FACT = @fed_indiced) and K3.kap_fiscomp<>'S' AND (K3.KAP_PADRESUST = 0 OR K3.KAP_PADRESUST=kardespedtemp.MA_HIJO)
				and (K3.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC OR K3.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC+'S')
				and K3.kap_saldo_fed >=0
				AND (K3.KAP_PADRESUST=kardespedtemp.MA_HIJO OR K3.MA_HIJO=kardespedtemp.MA_HIJO))
		AND (KAP_PADRESUST=0 OR KAP_PADRESUST=MA_HIJO)


/*	UPDATE kardespedtemp
	SET KAP_ESTATUS='D'
	FROM kardespedtemp
	WHERE KAP_INDICED_FACT = @fed_indiced and  (KAP_ESTATUS<>'D' OR KAP_ESTATUS IS NULL) and kap_fiscomp='S'
		AND KAP_CantTotADescargar =
			(SELECT     ROUND(SUM(KAP_CANTDESC), 6)  
			FROM         kardespedtemp K3
			WHERE     (K3.KAP_INDICED_FACT = @fed_indiced) and K3.kap_fiscomp='S' AND (K3.KAP_PADREMAIN= 0 OR K3.KAP_PADREMAIN=kardespedtemp.MA_HIJO)
			and (K3.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC OR K3.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC+'S')
			and K3.kap_saldo_fed >=0
			AND (K3.KAP_PADREMAIN=kardespedtemp.MA_HIJO OR K3.MA_HIJO=kardespedtemp.MA_HIJO) and K3.kap_padresust =  kardespedtemp.kap_padresust)
		AND (KAP_PADREMAIN=0 OR KAP_PADREMAIN=MA_HIJO)
*/

	UPDATE kardespedtemp
	SET     KAP_ESTATUS='P'
	FROM         kardespedtemp
	WHERE     (KAP_INDICED_FACT = @fed_indiced)
	AND KAP_ESTATUS IS NULL


	UPDATE kardespedtemp
	SET KAP_ESTATUS='D'
	FROM kardespedtemp
	WHERE KAP_INDICED_FACT = @fed_indiced AND  KAP_ESTATUS<>'D' AND
		(KAP_PADRESUST IN (SELECT K_1.KAP_PADRESUST
				FROM  kardespedtemp K_1
				WHERE     (K_1.KAP_INDICED_FACT = @fed_indiced) AND (K_1.KAP_PADRESUST > 0)
				and K_1.kap_padresust = kardespedtemp.kap_padresust
				and (K_1.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC OR K_1.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC+'S')
				GROUP BY K_1.KAP_PADRESUST)
		OR MA_HIJO IN (SELECT K_2.KAP_PADRESUST
				FROM  kardespedtemp K_2
				WHERE     (K_2.KAP_INDICED_FACT = @fed_indiced) AND (K_2.KAP_PADRESUST > 0)				
				and K_2.kap_padresust = kardespedtemp.kap_padresust
				and (K_2.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC OR K_2.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC+'S')
				GROUP BY K_2.KAP_PADRESUST))
		AND (KAP_CantTotADescargar =
			(SELECT     ROUND(SUM(KAP_CANTDESC), 6)  
			FROM         kardespedtemp K3
			WHERE     (K3.KAP_INDICED_FACT = @fed_indiced) AND (K3.KAP_PADRESUST = 0 OR
			                      K3.KAP_PADRESUST = MA_HIJO)
			and (K3.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC OR K3.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC+'S')
			and K3.kap_saldo_fed >=0
			AND (K3.KAP_PADRESUST=kardespedtemp.MA_HIJO OR K3.MA_HIJO=kardespedtemp.MA_HIJO)			and K3.kap_padresust =  kardespedtemp.kap_padresust)

		OR KAP_CantTotADescargar =
			(SELECT     round(SUM(K4.KAP_CANTDESC) ,6)
			FROM         kardespedtemp K4
			WHERE     (K4.KAP_INDICED_FACT = @fed_indiced)  
			and K4.kap_saldo_fed >=0
			and (K4.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC OR K4.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC+'S') AND
			(K4.MA_HIJO = kardespedtemp.KAP_PADRESUST OR K4.KAP_PADRESUST = kardespedtemp.KAP_PADRESUST)))

		AND MA_HIJO NOT IN (SELECT K_2.kap_padresust
				FROM  kardespedtemp K_2
				WHERE     (K_2.KAP_INDICED_FACT = @fed_indiced) AND (K_2.kap_padresust > 0)
				and (K_2.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC OR K_2.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC+'S')
				GROUP BY K_2.kap_padresust)


/*
	UPDATE kardespedtemp
	SET KAP_ESTATUS='D'
	FROM kardespedtemp
	WHERE KAP_INDICED_FACT = @fed_indiced  and kap_fiscomp='S'
		AND MA_HIJO NOT IN (SELECT K_2.kap_padresust
				FROM  kardespedtemp K_2
				WHERE     (K_2.KAP_INDICED_FACT = @fed_indiced) AND (K_2.kap_padresust > 0)  and kap_fiscomp='S'
				and kap_estatus<>'D'
				and (K_2.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC OR K_2.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC+'S')
				GROUP BY K_2.kap_padresust)
		AND MA_HIJO  IN (SELECT K_3.kap_padresust
				FROM  kardespedtemp K_3
				WHERE     (K_3.KAP_INDICED_FACT = @fed_indiced) AND (K_3.kap_padresust > 0)  and kap_fiscomp='S'
				and (K_3.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC OR K_3.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC+'S')
				GROUP BY K_3.kap_padresust)
		AND  KAP_ESTATUS<>'D'



	UPDATE kardespedtemp
	SET KAP_ESTATUS='P'
	FROM kardespedtemp
	WHERE KAP_INDICED_FACT = @fed_indiced  and kap_fiscomp='S'
		AND MA_HIJO IN (SELECT K_2.kap_padresust
				FROM  kardespedtemp K_2
				WHERE     (K_2.KAP_INDICED_FACT = @fed_indiced) AND (K_2.kap_padresust > 0)  and kap_fiscomp='S'
				and kap_estatus<>'D'
				and (K_2.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC OR K_2.KAP_TIPO_DESC = kardespedtemp.KAP_TIPO_DESC+'S')
				GROUP BY K_2.kap_padresust)
		AND  KAP_ESTATUS<>'P'*/

GO
