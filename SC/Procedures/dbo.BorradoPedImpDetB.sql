SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BorradoPedImpDetB] (@pi_codigo int)   as


if exists (select * from pedimpdetb where pi_codigo=@pi_codigo)
begin

	alter table [pedimpdetb] disable trigger [Del_PedImpDetB]


		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##pib_indiceb'  AND  type = 'U')
		begin
			drop table ##pib_indiceb
		end


		select pib_indiceb 
		INTO ##pib_indiceb
		from pedimpdet where pi_codigo=@pi_codigo

		delete from  PedImpDetIdentifica where pib_indiceb in (select pib_indiceb from ##pib_indiceb)
		
		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##pib_indiceb'  AND  type = 'U')
		begin
			drop table ##pib_indiceb
		end

		--IF EXISTS (SELECT * FROM PedImpDetIdentifica WHERE pib_indiceb in (select pib_indiceb from pedimpdetb where pi_codigo=@pi_codigo))
		--DELETE FROM PedImpDetIdentifica WHERE pib_indiceb in (select pib_indiceb from  pedimpdetb where pi_codigo=@pi_codigo)

		IF EXISTS (SELECT * FROM PedImpDetBContribucion where pi_codigo=@pi_codigo)
		DELETE FROM PedImpDetBContribucion where pi_codigo=@pi_codigo
	
		delete from pedimpdetb where pi_codigo=@pi_codigo
	
		update pedimp 
		set pi_cuentadetb=0
		where pi_codigo =@pi_codigo

	alter table [pedimpdetb] enable trigger [Del_PedImpDetB]
end
GO
