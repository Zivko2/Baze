SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_REVISAVALPEDFACT]   as


/*
UPDATE PEDIMP
		SET PI_LIGACORRECTA='N'
		WHERE PI_CODIGO IN (SELECT     PI_CODIGO
				      FROM dbo.VRELERRORFACTURAPED
			   	    GROUP BY PI_CODIGO
				    HAVING (round(SUM(ISNULL(PID_CTOT_DLS, 0)),6) - round(SUM(ISNULL(FID_COS_TOT, 0)),6)>2 OR
						round(SUM(ISNULL(PID_CTOT_DLS, 0)),6) - round(SUM(ISNULL(FID_COS_TOT, 0)),6)<-2)
						AND SUM(FID_COS_TOT) IS NOT NULL)
	             and pi_estatus not in ('A', 'B', 'F', 'G', 'C', 'L', 'O', 'R') 
	             and pi_codigo not in (select pi_codigo from pedimp where pi_ediciondet='S')
		     and pi_ligacorrecta <> 'N' --Se agrego condicion tuning Manuel G. 13-May-2010

*/
-- Se cambio ya que era muy lento y complejo para el query processor
update pedimp set pi_ligacorrecta='N'
from pedimp	inner join
					(SELECT     PI_CODIGO
				      FROM dbo.VRELERRORFACTURAPED
			   	    GROUP BY PI_CODIGO
				    HAVING (round(SUM(ISNULL(PID_CTOT_DLS, 0)),6) - round(SUM(ISNULL(FID_COS_TOT, 0)),6)>2 OR
						round(SUM(ISNULL(PID_CTOT_DLS, 0)),6) - round(SUM(ISNULL(FID_COS_TOT, 0)),6)<-2)
						AND SUM(FID_COS_TOT) IS NOT NULL) a on pedimp.pi_codigo = a.pi_codigo
where
	              pi_estatus not in ('A', 'B', 'F', 'G', 'C', 'L', 'O', 'R') 
	             and pedimp.pi_codigo not in (select pi_codigo from pedimp where pi_ediciondet='S')
		     and pi_ligacorrecta <> 'N' --Se agrego condicion tuning Manuel G. 13-May-2010











GO
