USE	[EdenSSO-PRD]

--SELECT TOP (5) * FROM INFORMATION_SCHEMA.COLUMNS
--WHERE	Table_name NOT LIKE 'vw%'	
----AND		Table_name NOT LIKE '%bkup%'
--ORDER BY Table_name


IF  OBJECT_ID('TempDB..#tmpRefTables') IS NOT NULL
	DROP TABLE #tmpRefTables
ELSE
	DROP TABLE #tmpRefTables
SELECT DISTINCT
A.name			[nmTable]
, A.type		[nmType]
, B.name		[nmAttribute]
, C.name		[DataType]
, B.isnullable	[Allow Nulls?]
, CASE WHEN D.name				IS NULL THEN 0 ELSE 1 END [isPKey]
, CASE WHEN E.parent_object_id	IS NULL THEN 0 ELSE 1 END [isFKey]
, G.name [nmRefTable]
, ISNULL(H.value,'')	[Description]
INTO #tmpRefTables
FROM sysobjects						A
JOIN syscolumns						B	ON	A.id = B.id
JOIN systypes						C	ON	B.xtype = C.xtype 
LEFT JOIN (	SELECT  SO.id, SC.colid, SC.name 
			FROM    syscolumns		SC
			JOIN	sysobjects		SO	ON	SO.id = SC.id
			JOIN	sysindexkeys	SI	ON	SO.id = SI.id 
										AND SC.colid = SI.colid
			WHERE SI.indid = 1)		D	ON	A.id = D.id 
										AND	B.colid = D.colid
LEFT JOIN sys.foreign_key_columns	E	ON	A.id = E.parent_object_id 
										AND	B.colid = E.parent_column_id    
LEFT JOIN sys.objects				G	ON	E.referenced_object_id = G.object_id  
LEFT JOIN sys.extended_properties	H	ON	A.id = H.major_id 
										AND	B.colid = H.minor_id
--WHERE A.Type = 'UQ'
WHERE	A.Type	NOT IN	('FN', 'IT', 'P', 'S', 'SQ', 'UQ', 'V')
AND		A.Name	NOT IN	('sysdiagrams')
--Type	Type_Desc
--D 	DEFAULT_CONSTRAINT
--F 	FOREIGN_KEY_CONSTRAINT
--FN	SQL_SCALAR_FUNCTION
--IT	INTERNAL_TABLE
--P 	SQL_STORED_PROCEDURE
--PK	PRIMARY_KEY_CONSTRAINT
--S 	SYSTEM_TABLE
--SQ	SERVICE_QUEUE
--U 	USER_TABLE
--UQ	UNIQUE_CONSTRAINT
--V 	VIEW
--SELECT * FROM #tmpRefTables



IF  OBJECT_ID('TempDB..#tmpRefTablesHasFK') IS NOT NULL
	DROP TABLE #tmpRefTablesHasFK
ELSE
	DROP TABLE #tmpRefTablesHasFK
SELECT DISTINCT nmTable, nmRefTable
INTO	#tmpRefTablesHasFK
FROM	#tmpRefTables
WHERE	nmRefTable	IS NOT NULL
ORDER BY 1

SELECT * FROM #tmpRefTablesHasFK

IF  OBJECT_ID('TempDB..#tmpRefTablesNoFK') IS NOT NULL
	DROP TABLE #tmpRefTablesNoFK
ELSE
	DROP TABLE #tmpRefTablesNoFK
SELECT DISTINCT REF.nmTable
INTO		#tmpRefTablesNoFK
FROM		#tmpRefTables		REF
LEFT JOIN	#tmpRefTablesHasFK	HFK	ON	REF.nmTable	= HFK.nmTable
WHERE HFK.nmTable IS NULL
ORDER BY 1
SELECT DISTINCT nmTable FROM #tmpRefTablesNoFK


SELECT DISTINCT nmTable FROM #tmpRefTables
SELECT DISTINCT nmTable FROM #tmpRefTablesHasFK
SELECT DISTINCT nmTable FROM #tmpRefTablesNoFK
