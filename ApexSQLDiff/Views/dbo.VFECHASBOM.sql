SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























































CREATE VIEW dbo.VFECHASBOM
with encryption as
	SELECT     BST_PERINI, BSU_SUBENSAMBLE
	FROM         tempBOMexp
	GROUP BY BST_PERINI, BSU_SUBENSAMBLE

	union
	SELECT     BST_PERFIN+1, BSU_SUBENSAMBLE
	FROM         tempBOMexp
	GROUP BY BST_PERFIN, BSU_SUBENSAMBLE



























































GO
