USE [EdenMDS-TST]

SET NOCOUNT ON

DECLARE @TableName		NVARCHAR(50)
DECLARE @ServerName		NVARCHAR(50)
DECLARE @DatabaseName	NVARCHAR(50)
DECLARE @TimeGenerated	DATETIME

SET	@ServerName		= CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(50))
SET	@DatabaseName	= CAST(DB_NAME() AS NVARCHAR(50))
SET	@TimeGenerated	= GETDATE()

-- ****************************************************************************************************
-- *** Obtain reference tables from foreign key constraints
-- *** Quantify entities based on foreign key constraints

IF  OBJECT_ID('TempDB..#tmpRefTables') IS NOT NULL
	BEGIN	DROP TABLE #tmpRefTables	END

SELECT DISTINCT
	SO1.name						 AS [nmTable]
	, SO1.type					 AS [nmType]
	, SC1.name					 AS [nmAttribute]
	, ST1.name					 AS [DataType]
	, SC1.isnullable			 AS [AllowNulls]
	, CASE WHEN		
		PK1.name IS NULL 
			THEN 0 
			ELSE 1	END		 AS [isPKey]
	, CASE WHEN 	
		FK1.parent_object_id IS NULL 
			THEN 0 
			ELSE 1	END		 AS [isFKey]
	, RF1.name [nmRefTable]
	, ISNULL(XP1.value,'')	 AS [Description]
INTO #tmpRefTables
FROM sysobjects						SO1
JOIN syscolumns						SC1	ON	SO1.id		= SC1.id
JOIN systypes							ST1	ON	SC1.xtype	= ST1.xtype 
LEFT JOIN (	SELECT  SO2.id
					, SC2.colid
					, SC2.name 
				FROM    syscolumns		SC2
				JOIN	sysobjects			SO2	ON		SO2.id		= SC2.id
				JOIN	sysindexkeys		SI2	ON		SO2.id		= SI2.id 
														AND	SC2.colid	= SI2.colid
				WHERE SI2.indid = 1)		PK1	ON		SO1.id		= PK1.id
														AND	SC1.colid	= PK1.colid
LEFT JOIN sys.foreign_key_columns	FK1	ON		SO1.id		= FK1.parent_object_id
														AND	SC1.colid	= FK1.parent_column_id
LEFT JOIN sys.objects					RF1	ON		FK1.referenced_object_id = RF1.object_id  
LEFT JOIN sys.extended_properties	XP1	ON		SO1.id		= XP1.major_id 
														  AND	SC1.colid	= XP1.minor_id
WHERE	SO1.Type	NOT IN	('FN', 'IT', 'P', 'S', 'SQ', 'UQ', 'V')
AND	SO1.Name	NOT IN	('sysdiagrams')

-- *** Sys.Objects Types
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

IF  OBJECT_ID('TempDB..#tmpRefTablesHasFK') IS NOT NULL
	BEGIN	DROP TABLE #tmpRefTablesHasFK	END
SELECT DISTINCT nmTable, nmRefTable
INTO			#tmpRefTablesHasFK
FROM			#tmpRefTables
WHERE			nmRefTable	IS NOT NULL

IF  OBJECT_ID('TempDB..#tmpRefTablesNoFK') IS NOT NULL
	BEGIN	DROP TABLE #tmpRefTablesNoFK	END
SELECT DISTINCT REF.nmTable
INTO			#tmpRefTablesNoFK
FROM			#tmpRefTables		  REF
LEFT JOIN	#tmpRefTablesHasFK  NFK	ON	REF.nmTable	= NFK.nmTable
WHERE			NFK.nmTable IS NULL

IF  OBJECT_ID('TempDB..#tmpRefTablesIsFK') IS NOT NULL
	BEGIN	DROP TABLE #tmpRefTablesIsFK	END
SELECT DISTINCT REF.nmRefTable
INTO			#tmpRefTablesIsFK
FROM			#tmpRefTables		  REF
INNER JOIN	#tmpRefTablesNoFK	  NFK	ON	REF.nmRefTable	= NFK.nmTable

-- ****************************************************************************************************


-- ****************************************************************************************************
-- *** Display entities with incoming Foreign Keys

DECLARE Tbls1 CURSOR
FOR

SELECT DISTINCT Table_name
FROM			INFORMATION_SCHEMA.COLUMNS	INFSCH
INNER JOIN	#tmpRefTablesHasFK			RFK		ON	RFK.nmTable = INFSCH.Table_name
UNION ALL
SELECT		nmRefTable FROM #tmpRefTablesIsFK
ORDER BY 1

OPEN Tbls1

FETCH NEXT FROM Tbls1
INTO @TableName

PRINT '<!DOCTYPE html>'
PRINT '<html>'
PRINT '<head>'
PRINT '<title>' + @DatabaseName + ': Data Dictionary</title>'
PRINT '<meta http-equiv="X-UA-Compatible" content="IE=10; IE=9; IE=8; IE=7; IE=EDGE"/>'
PRINT '<style>'
PRINT 'body	{background-color: #FFFFFF}'
PRINT 'table	{border-collapse: collapse;}'
PRINT 'table, th, td {border: 1px solid #A5A5A5; padding: 4px;}'
PRINT 'table.entitydata {border: 1px solid #A5A5A5; padding: 4px;}'
--PRINT 'tr.entitydata {border: 1px solid #A5A5A5; padding: 4px;}'
--PRINT 'td.entitydata {border: 1px solid #A5A5A5; padding: 4px;}'
PRINT 'table.dbname {width:auto;}'
PRINT 'table.entitytoc {width: auto; border:1px solid #A5A5A5; padding: 3px;}'
PRINT 'tr.entitytoctr {width: auto; border:1px dotted #161A1D; padding: 3px;}'
PRINT 'td.entitytoctd {width: auto; border:1px dotted #161A1D; padding: 3px;}'
PRINT 'th		{background: #BFEFFF; text-align: left;}'
PRINT 'tr		{background: #FDFCDC;}'
PRINT 'tbody tr.hov:hover		{background:#F5F5F5;  color:#161A1D;}'
PRINT 'div#reporttitle	{font-size: 35px;}'
PRINT 'div#entityhasfk	{border:1px dotted #161A1D; padding: 4px; display: inline-block;}'
PRINT 'div#entitynofk	{border:1px dotted #161A1D; padding: 4px; display: inline-block;}'
--PRINT 'table	{width:100%;}'
--PRINT 'table#entityhasfk	{width: auto; border:1px dotted #161A1D; padding: 4px;}'
--PRINT 'table#entityhasfk td, tr {border: 0}'
--PRINT 'table#entitynofk	{width: auto; border:1px dotted #161A1D; padding: 4px;}'
--PRINT 'table#entitynofk td, tr {border: 0}'
PRINT '.fixed			{top:0;  position:fixed;  width:auto;  display:none;  border:none;}'
PRINT '.scrollMore	{margin-top:600px;}'
PRINT '.up					{cursor:pointer;}'
PRINT '</style>'
PRINT '</head>'
PRINT '<body>'
PRINT '<div id = "reporttitle">Data Dictionary: <i>' + @DatabaseName + '</i></div>'
PRINT '<br/>'
PRINT '<br/>'

PRINT '<table class = "dbname">'
PRINT '<tr><th><b>Database: </b></th><td>' + @DatabaseName + '</td></tr>'
PRINT '<tr><th><b>Server: </b></th><td>' + @ServerName + '</td></tr>'
PRINT '<tr><th><b>Generated on: </b></th><td>' + CAST(@TimeGenerated AS NVARCHAR(50)) + '</td></tr>'
PRINT '</table>'
PRINT '<br/>'
PRINT '<br/>'

PRINT '<div id = "entityhasfk">'
PRINT 'The following entities contain foreign keys, and are therefore related to one or more other entities within the database.'
PRINT '<br/>'
PRINT 'Entities that do not contain foreign keys are listed <a href="#entitynofk">here</a>'
PRINT '</div>'
PRINT '<br/>'
PRINT '<br/>'

PRINT '<table class = "entitytoc">'

WHILE @@FETCH_STATUS = 0 BEGIN
PRINT '	<tr class = "entitytoctr">'
PRINT '		<td class = "entitytoctd">'
PRINT '			<a href="#'+ @TableName + '">' + @TableName + '</a>'
PRINT '		</td>'
PRINT '	</tr>'
FETCH NEXT FROM Tbls1	INTO @TableName END;

PRINT '</table>'
PRINT '<br/>'
PRINT '<br/>'
PRINT '<br/>'

CLOSE		Tbls1
DEALLOCATE	Tbls1



DECLARE TblsData CURSOR
FOR

SELECT DISTINCT Table_name
FROM			INFORMATION_SCHEMA.COLUMNS	INFSCH
INNER JOIN	#tmpRefTablesHasFK			RFK		ON	RFK.nmTable = INFSCH.Table_name
UNION ALL
SELECT		nmRefTable FROM #tmpRefTablesIsFK
ORDER BY 1

OPEN TblsData

FETCH NEXT FROM TblsData
INTO @TableName

WHILE @@FETCH_STATUS = 0
BEGIN

PRINT '<table class = "entitydata">'
PRINT '<thead>'
PRINT '	<tr>'
PRINT '		<th colspan = "1", white-space: nowrap><b>Entity Name: </b></th>'
PRINT '		<td colspan = "8"><div id = "'+ @TableName + '">' + @TableName + '</div></td>'
PRINT '	</tr>'

--Get the Description of the table
--Characters 1-250
PRINT '	<tr>'
PRINT '		<th colspan = "1", white-space: nowrap><i><b>Entity Description: </b></i></th>'
PRINT '		<td colspan = "8"><i>'

SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),1,250) 
FROM	sys.extended_properties A
WHERE	A.major_id = OBJECT_ID(@TableName)
AND		name = 'MS_Description' and minor_id = 0

--Characters 251-500
SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),251, 250) 
FROM	sys.extended_properties A
WHERE	A.major_id = OBJECT_ID(@TableName)
AND		name = 'MS_Description' and minor_id = 0

PRINT '		</i>'
PRINT '		</td>'
PRINT '	</tr>'

PRINT '	<tr>'
--Set up the Column Headers for the Table
PRINT '		<th><b>Column Name</b></th>'
PRINT '		<th><b>Description</b></th>'
--PRINT '		<th><b>IDX</b></th>'
PRINT '		<th><b>PKey</b></th>'
PRINT '		<th><b>FKey</b></th>'
PRINT '		<th><b>DataType</b></th>'
PRINT '		<th><b>Length</b></th>'
--PRINT '<th><b>Numeric Precision</b></th>'
--PRINT '<th><b>Numeric Scale</b></th>'
PRINT '		<th><b>Nullable</b></th>'
--PRINT '<th><b>Computed</b></th>'
--PRINT '<th><b>Identity</b></th>'
PRINT '		<th><b>Default Value</b></th>'
PRINT '		<th><b>Reference Table</b></th>'
--PRINT '		<th><b>Table Name (TEMP Field)</b></th>'
PRINT '	</tr>'
PRINT '</thead>'
PRINT ''
PRINT '<tbody>'

--Get the Table Data
SELECT
	'	<tr class = "hov">' + 
	'		<td>' + CAST(clmns.name AS VARCHAR(50)) + '</td>'
	, '<td>' + SUBSTRING(ISNULL(CAST(exprop.value AS VARCHAR(255)),''),1,250),
			SUBSTRING(ISNULL(CAST(exprop.value AS VARCHAR(500)),''),251,250) + '</td>'
	--, '<td>' + CAST(ISNULL(idxcol.index_column_id, 0)AS VARCHAR(20)) + '</td>'
	, '<td>' + ISNULL(CAST(reftbl.isPKey AS VARCHAR(5)),'N') + '</td>'
	, '<td>' + CAST(ISNULL(
		(SELECT TOP 1 1
		  FROM	sys.foreign_key_columns	 AS fkclmn
		  WHERE	fkclmn.parent_column_id = clmns.column_id
		  AND		fkclmn.parent_object_id = clmns.object_id
		), 0) AS VARCHAR(20)) + '</td>'
	--, '<td>' + ISNULL(CAST(reftbl.isFKey AS VARCHAR(5)),'N') + '</td>'
	, '<td>' + CAST(udt.name AS CHAR(20)) + '</td>'	
	, '<td>' + CAST(CAST
				(CASE WHEN typ.name IN (N'nchar', N'nvarchar') AND clmns.max_length <> -1
				THEN clmns.max_length/2
				ELSE clmns.max_length 
				END 
				AS INT) AS VARCHAR(20)) + '</td>'
	--, '<td>' + CAST(CAST(clmns.precision AS INT) AS VARCHAR(20)) + '</td>',
	--, '<td>' + CAST(CAST(clmns.scale AS INT) AS VARCHAR(20)) + '</td>',
	, '<td>' + CAST(clmns.is_nullable AS VARCHAR(20)) + '</td>'
	--, '<td>' + CAST(clmns.is_computed AS VARCHAR(20)) + '</td>'
	--, '<td>' + CAST(clmns.is_identity AS VARCHAR(20)) + '</td>'
	, '<td>' + ISNULL(SUBSTRING(CAST(cnstr.definition AS VARCHAR(50)), 2,LEN(cnstr.definition)-2),'') + '</td>'
	, '<td>' + ISNULL(+ '<a href="#'+ reftbl.nmRefTable + '">' + reftbl.nmRefTable + '</a></td></tr>','</td></tr>') -- Uncomment when Extended Properties scripts are complete
	--, '<td>' + ISNULL(+ '<a href="#'+ reftbl.nmRefTable + '">' + reftbl.nmRefTable + '</a></td>','</td>') -- Delete when Extended Properties scripts are complete
	--, '<td>' + @TableName + '</td></tr>' -- Delete when Extended Properties scripts are complete

FROM				 sys.tables					 tbl
INNER JOIN		 sys.all_columns			 clmns	ON	 clmns.object_id	=	tbl.object_id
LEFT OUTER JOIN sys.indexes				 idx		ON	 idx.object_id		=	clmns.object_id
																AND 1 = idx.is_primary_key
LEFT OUTER JOIN sys.index_columns		 idxcol	ON	 idxcol.index_id	=	idx.index_id
																AND idxcol.column_id =	clmns.column_id
																AND idxcol.object_id =	clmns.object_id
																AND 0 = idxcol.is_included_column
LEFT OUTER JOIN sys.types					 udt		ON	 udt.user_type_id =	clmns.user_type_id
LEFT OUTER JOIN sys.types					 typ		ON	 typ.user_type_id =	clmns.system_type_id
																AND typ.user_type_id =	typ.system_type_id
LEFT JOIN		 sys.default_constraints cnstr	ON	 cnstr.object_id	=	clmns.default_object_id
LEFT OUTER JOIN sys.extended_properties exprop	ON	 exprop.major_id	=	clmns.object_id
																AND exprop.minor_id	=	clmns.column_id
																AND exprop.name		=	'MS_Description'
LEFT JOIN #tmpRefTables						 reftbl	ON	 reftbl.nmTable	=	@TableName
																AND reftbl.nmAttribute = clmns.name
--LEFT JOIN #tmpRefTablesIsFK				refisfk	ON	refisfk.nmTable = @TableName
WHERE		tbl.name	= @TableName
GROUP BY	clmns.column_id
			, clmns.object_id
			, clmns.name
			, exprop.value
			, reftbl.isPKey
			, reftbl.isFKey
			, udt.name
			, typ.name
			, clmns.max_length
			, clmns.is_nullable
			, cnstr.definition
			, reftbl.nmRefTable
ORDER BY clmns.column_id

PRINT '</tbody>'
PRINT '</table>'
PRINT ''
PRINT '<br/>'
PRINT '<br/>'

FETCH NEXT FROM TblsData
INTO @TableName
END

CLOSE		TblsData
DEALLOCATE	TblsData

-- ****************************************************************************************************
-- *** Display entities with no Foreign Keys


PRINT '<br/>'
PRINT '<div id = "entitynofk">'
PRINT 'The following entities do not contain foreign keys, and are therefore not related to any other entities within the database.'
PRINT '<br/>'
PRINT 'Entities that do contain foreign keys are listed <a href="#entityhasfk">here</a>'
PRINT '</div>'
PRINT '<br/>'
PRINT '<br/>'

DECLARE TblsNoFK CURSOR
FOR

SELECT DISTINCT Table_name
FROM			INFORMATION_SCHEMA.COLUMNS	 INFSCH
INNER JOIN	#tmpRefTablesNoFK				 NOFK		ON	NOFK.nmTable	  = INFSCH.Table_name
LEFT JOIN	#tmpRefTablesIsFK				 ISFK		ON	ISFK.nmRefTable  = INFSCH.Table_name
WHERE			ISFK.nmRefTable  IS NULL

OPEN TblsNoFK

FETCH NEXT FROM TblsNoFK
INTO @TableName

PRINT '<table class = "entitytoc">'

WHILE @@FETCH_STATUS = 0 BEGIN
PRINT '	<tr class = "entitytoctr">'
PRINT '		<td class = "entitytoctd">'
PRINT '			<a href="#'+ @TableName + '">' + @TableName + '</a>'
PRINT '		</td>'
PRINT '		</tr>'
FETCH NEXT FROM TblsNoFK	INTO @TableName END;

PRINT '</table>'
PRINT '<br/>'
PRINT '<br/>'
PRINT '<br/>'

CLOSE		TblsNoFK
DEALLOCATE	TblsNoFK


DECLARE Tbls CURSOR
FOR

SELECT DISTINCT Table_name
FROM			INFORMATION_SCHEMA.COLUMNS	 INFSCH
INNER JOIN	#tmpRefTablesNoFK				 NOFK		ON	NOFK.nmTable	  = INFSCH.Table_name
LEFT JOIN	#tmpRefTablesIsFK				 ISFK		ON	ISFK.nmRefTable  = INFSCH.Table_name
WHERE			ISFK.nmRefTable  IS NULL

OPEN Tbls

FETCH NEXT FROM Tbls
INTO @TableName

WHILE @@FETCH_STATUS = 0
BEGIN

PRINT '<table>'
PRINT '<thead>'
PRINT '	<tr>'
PRINT '		<th colspan = "1", white-space: nowrap><b>Entity Name: </b></th>'
PRINT '		<td colspan = "8"><div id = "'+ @TableName + '">' + @TableName + '</div></td>'
PRINT '	</tr>'

--Get the Description of the table
--Characters 1-250
PRINT '	<tr>'
PRINT '		<th colspan = "1", white-space: nowrap><i><b>Entity Description: </b></i></th>'
PRINT '		<td colspan = "8"><i>'

SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),1,250) 
FROM	sys.extended_properties A
WHERE	A.major_id = OBJECT_ID(@TableName)
AND		name = 'MS_Description' and minor_id = 0

--Characters 251-500
SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),251, 250) 
FROM	sys.extended_properties A
WHERE	A.major_id = OBJECT_ID(@TableName)
AND		name = 'MS_Description' and minor_id = 0

PRINT '		</i>'
PRINT '		</td>'
PRINT '	</tr>'

PRINT '	<tr>'
--Set up the Column Headers for the Table
PRINT '		<th><b>Column Name</b></th>'
PRINT '		<th><b>Description</b></th>'
--PRINT '		<th><b>IDX</b></th>'
PRINT '		<th><b>PKey</b></th>'
PRINT '		<th><b>FKey</b></th>'
PRINT '		<th><b>DataType</b></th>'
PRINT '		<th><b>Length</b></th>'
--PRINT '<th><b>Numeric Precision</b></th>'
--PRINT '<th><b>Numeric Scale</b></th>'
PRINT '		<th><b>Nullable</b></th>'
--PRINT '<th><b>Computed</b></th>'
--PRINT '<th><b>Identity</b></th>'
PRINT '		<th><b>Default Value</b></th>'
PRINT '		<th><b>Reference Table</b></th>'
--PRINT '		<th><b>Table Name (TEMP Field)</b></th>'
PRINT '	</tr>'
PRINT '</thead>'
PRINT ''
PRINT '<tbody>'

--Get the Table Data
SELECT
	'	<tr class = "hov">' + 
	'		<td>' + CAST(clmns.name AS VARCHAR(50)) + '</td>'
	, '<td>' + SUBSTRING(ISNULL(CAST(exprop.value AS VARCHAR(255)),''),1,250),
			SUBSTRING(ISNULL(CAST(exprop.value AS VARCHAR(500)),''),251,250) + '</td>'
	--, '<td>' + CAST(ISNULL(idxcol.index_column_id, 0)AS VARCHAR(20)) + '</td>'
	, '<td>' + ISNULL(CAST(reftbl.isPKey AS VARCHAR(5)),'N') + '</td>'
	, '<td>' + CAST(ISNULL(
		(SELECT TOP 1 1
		  FROM	sys.foreign_key_columns	 AS fkclmn
		  WHERE	fkclmn.parent_column_id = clmns.column_id
		  AND		fkclmn.parent_object_id = clmns.object_id
		), 0) AS VARCHAR(20)) + '</td>'
	--, '<td>' + ISNULL(CAST(reftbl.isFKey AS VARCHAR(5)),'N') + '</td>'
	, '<td>' + CAST(udt.name AS CHAR(20)) + '</td>'	
	, '<td>' + CAST(CAST
				(CASE WHEN typ.name IN (N'nchar', N'nvarchar') AND clmns.max_length <> -1
				THEN clmns.max_length/2
				ELSE clmns.max_length 
				END 
				AS INT) AS VARCHAR(20)) + '</td>'
	--, '<td>' + CAST(CAST(clmns.precision AS INT) AS VARCHAR(20)) + '</td>',
	--, '<td>' + CAST(CAST(clmns.scale AS INT) AS VARCHAR(20)) + '</td>',
	, '<td>' + CAST(clmns.is_nullable AS VARCHAR(20)) + '</td>'
	--, '<td>' + CAST(clmns.is_computed AS VARCHAR(20)) + '</td>'
	--, '<td>' + CAST(clmns.is_identity AS VARCHAR(20)) + '</td>'
	, '<td>' + ISNULL(SUBSTRING(CAST(cnstr.definition AS VARCHAR(50)), 2,LEN(cnstr.definition)-2),'') + '</td>'
	, '<td>' + ISNULL(+ '<a href="#'+ reftbl.nmRefTable + '">' + reftbl.nmRefTable + '</a></td></tr>','</td></tr>') -- Uncomment when Extended Properties scripts are complete
	--, '<td>' + ISNULL(+ '<a href="#'+ reftbl.nmRefTable + '">' + reftbl.nmRefTable + '</a></td>','</td>') -- Delete when Extended Properties scripts are complete
	--, '<td>' + @TableName + '</td></tr>' -- Delete when Extended Properties scripts are complete

FROM				 sys.tables					 tbl
INNER JOIN		 sys.all_columns			 clmns	ON	 clmns.object_id	=	tbl.object_id
LEFT OUTER JOIN sys.indexes				 idx		ON	 idx.object_id		=	clmns.object_id
																AND 1 = idx.is_primary_key
LEFT OUTER JOIN sys.index_columns		 idxcol	ON	 idxcol.index_id	=	idx.index_id
																AND idxcol.column_id =	clmns.column_id
																AND idxcol.object_id =	clmns.object_id
																AND 0 = idxcol.is_included_column
LEFT OUTER JOIN sys.types					 udt		ON	 udt.user_type_id =	clmns.user_type_id
LEFT OUTER JOIN sys.types					 typ		ON	 typ.user_type_id =	clmns.system_type_id
																AND typ.user_type_id =	typ.system_type_id
LEFT JOIN		 sys.default_constraints cnstr	ON	 cnstr.object_id	=	clmns.default_object_id
LEFT OUTER JOIN sys.extended_properties exprop	ON	 exprop.major_id	=	clmns.object_id
																AND exprop.minor_id	=	clmns.column_id
																AND exprop.name		=	'MS_Description'
LEFT JOIN #tmpRefTables						 reftbl	ON	 reftbl.nmTable	=	@TableName
																AND reftbl.nmAttribute = clmns.name
--LEFT JOIN #tmpRefTablesIsFK				refisfk	ON	refisfk.nmTable = @TableName
WHERE		tbl.name	= @TableName
GROUP BY	clmns.column_id
			, clmns.object_id
			, clmns.name
			, exprop.value
			, reftbl.isPKey
			, reftbl.isFKey
			, udt.name
			, typ.name
			, clmns.max_length
			, clmns.is_nullable
			, cnstr.definition
			, reftbl.nmRefTable
ORDER BY clmns.column_id

PRINT '</tbody>'
PRINT '</table>'
PRINT ''
PRINT '<br/>'
PRINT '<br/>'

FETCH NEXT FROM Tbls
INTO @TableName
END

PRINT '</body>'
PRINT '</html>'

CLOSE Tbls
DEALLOCATE Tbls


-- ****************************************************************************************************
-- *** Drop temporary tables
BEGIN	DROP TABLE #tmpRefTables		END
BEGIN	DROP TABLE #tmpRefTablesHasFK	END
BEGIN	DROP TABLE #tmpRefTablesNoFK	END
BEGIN	DROP TABLE #tmpRefTablesIsFK	END

-- ****************************************************************************************************
-- *** Sandbox
/* =CONCATENATE("EXEC sys.sp_updateextendedproperty @name  = N'MS_Description', @value = N'",B16,"', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'",J16,"', @level2type = N'COLUMN',@level2name = N'",A16,"'; ")*/
