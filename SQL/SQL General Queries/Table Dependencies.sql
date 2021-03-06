USE [EdenMDS-PRD]

DECLARE @tablename VARCHAR(64);
SET	  @tablename = 'tblLanguage_lan';

SELECT
	 SO_P.name		  AS [ParentTbl]
	 , SC_P.name	  AS [ParentCol]
	 , 'is FK of'	  AS [Relationship]
	 , SO_R.name	  AS [RefTbl]
	 , SC_R.name	  AS [RefCol]
	 --, *
FROM sys.foreign_key_columns	  FKC
INNER JOIN sys.objects			  SO_P ON  SO_P.object_id = FKC.parent_object_id
INNER JOIN sys.columns			  SC_P ON  SC_P.object_id = FKC.parent_object_id
												 AND SC_P.column_id = FKC.parent_column_id
INNER JOIN sys.objects			  SO_R ON  SO_R.object_id = FKC.referenced_object_id
INNER JOIN sys.columns			  SC_R ON  SC_R.object_id = FKC.referenced_object_id
												 AND SC_R.column_id = FKC.referenced_column_id
WHERE	  SO_R.name = @tablename
		  AND SO_R.type = 'U'		  
--OR		  SO_P.name = @tablename
--		  AND	SO_P.type = 'U'

SELECT
	 SO_P.name + '.' + SC_P.name	+ ' is FK of ' + SO_R.name + '.' + SC_R.name
FROM sys.foreign_key_columns	  FKC
INNER JOIN sys.objects			  SO_P ON  SO_P.object_id = FKC.parent_object_id
INNER JOIN sys.columns			  SC_P ON  SC_P.object_id = FKC.parent_object_id
												 AND SC_P.column_id = FKC.parent_column_id
INNER JOIN sys.objects			  SO_R ON  SO_R.object_id = FKC.referenced_object_id
INNER JOIN sys.columns			  SC_R ON  SC_R.object_id = FKC.referenced_object_id
												 AND SC_R.column_id = FKC.referenced_column_id
WHERE	  SO_R.name = @tablename
		  AND SO_R.type = 'U'		  
--OR		  SO_P.name = @tablename
--		  AND	SO_P.type = 'U'

SELECT
	 SOP.name	 AS  [PrntTbl]
	 , SCP.name	 AS  [ParentCol]
	 , SOR.name	 AS  [RefTab]
	 , SCR.name	 AS  [RefCol]
FROM sys.foreign_key_columns	  FKC
INNER JOIN sys.objects			  SOP ON  SOP.object_id = FKC.parent_object_id
INNER JOIN sys.columns			  SCP ON  SCP.object_id = FKC.parent_object_id
												AND SCP.column_id = FKC.parent_column_id
INNER JOIN sys.objects			  SOR ON  SOR.object_id = FKC.referenced_object_id
INNER JOIN sys.columns			  SCR ON  SCR.object_id = FKC.referenced_object_id
												AND SCR.column_id = FKC.referenced_column_id
--WHERE	  SOR.name = @EntityName
		  --AND SOR.type = 'U'
GROUP BY	
	 SOR.name
	 , SOP.name
	 , SCP.name
	 , SCR.name
	 , SOP.object_id
	 , SCP.object_id
	 , SCP.column_id
	 , SOR.object_id
	 , SCR.object_id
	 , SCR.column_id
ORDER BY 1