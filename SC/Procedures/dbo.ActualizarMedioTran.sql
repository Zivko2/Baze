SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE ActualizarMedioTran as
	update mediotran set mt_nombre = b.mt_nombre
	from mediotran
		inner join original.dbo.mediotran b on mediotran.mt_cla_ped = b.mt_cla_ped

	insert into mediotran (mt_nombre, mt_name, mt_cla_ped, mt_cla_usa)
	select mt_nombre, mt_name, mt_cla_ped, mt_cla_usa
	 from original.dbo.mediotran b
	where mt_cla_ped not in (select mt_cla_ped from mediotran)

GO
