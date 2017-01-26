SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




















CREATE PROCEDURE [dbo].[SP_temp_20011]   as


		insert into sysusrlog44(user_id, mov_id, referencia, fechahora, frmtag) 
	SELECT     user_id, mov_id, referencia, fechahora, 44
	FROM         intradeglobal.dbo.sysusrlog
	WHERE     (frmtag = 44)
	order by sysusrlog_id



	insert into sysusrlog62(user_id, mov_id, referencia, fechahora,frmtag) 
	SELECT     user_id, mov_id, referencia, fechahora, 62
	FROM         intradeglobal.dbo.sysusrlog
	WHERE     (frmtag = 62)
	order by sysusrlog_id

	insert into sysusrlog41(user_id, mov_id, referencia, fechahora, frmtag) 
	SELECT     user_id, mov_id, referencia, fechahora, 41
	FROM         intradeglobal.dbo.sysusrlog
	WHERE     (frmtag = 41)
	order by sysusrlog_id



















GO
