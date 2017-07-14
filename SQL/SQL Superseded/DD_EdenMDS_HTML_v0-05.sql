USE [EdenMDS-TST]

SET NOCOUNT ON

DECLARE @EntityName		NVARCHAR(50)
DECLARE @ServerName		NVARCHAR(50)
DECLARE @DatabaseName	NVARCHAR(50)
DECLARE @TimeGenerated	DATETIME

SET	@ServerName		= CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(50))
SET	@DatabaseName	= CAST(DB_NAME() AS NVARCHAR(50))
SET	@TimeGenerated	= GETDATE()

-- ****************************************************************************************************
-- *** List reference tables from foreign key constraints
-- *** Quantify entities based on foreign key constraints

IF  OBJECT_ID('TempDB..#tmpRefTables') IS NOT NULL
	BEGIN	DROP TABLE #tmpRefTables	END

SELECT DISTINCT
	SO1.name				AS [nmTable]
	, SO1.type				AS [nmType]
	, SC1.name				AS [nmAttribute]
	, ST1.name				AS [DataType]
	, SC1.isnullable		AS [AllowNulls]
	, CASE WHEN		
		PK1.name IS NULL 
			THEN 0 
			ELSE 1	END		AS [isPKey]
	, CASE WHEN 	
		FK1.parent_object_id IS NULL 
			THEN 0 
			ELSE 1	END		AS [isFKey]
	, RF1.name [nmRefTable]
	, ISNULL(XP1.value, '')	AS [Description]
INTO #tmpRefTables
FROM sysobjects	SO1
JOIN syscolumns	SC1	ON	SO1.id		= SC1.id
JOIN systypes	ST1	ON	SC1.xtype	= ST1.xtype 
LEFT JOIN (	SELECT  SO2.id
					, SC2.colid
					, SC2.name 
			FROM	  syscolumns		SC2
			JOIN	  sysobjects		SO2		ON	SO2.id			 = SC2.id
			JOIN	  sysindexkeys		SI2		ON	SI2.id			 = SO2.id 
												AND	SI2.colid		 = SC2.colid
			WHERE SI2.indid = 1
			)							PK1		ON	PK1.id			 = SO1.id
												AND	PK1.colid		 = SC1.colid
LEFT JOIN sys.foreign_key_columns		FK1		ON	SO1.id			 = FK1.parent_object_id
												AND	SC1.colid		 = FK1.parent_column_id
LEFT JOIN sys.objects					RF1		ON	RF1.object_id	 = FK1.referenced_object_id 
LEFT JOIN sys.extended_properties		XP1		ON	SO1.id			 = XP1.major_id 
												AND	SC1.colid		 = XP1.minor_id
														
WHERE	SO1.Type	NOT IN	('FN', 'IT', 'S', 'SQ', 'UQ', 'V', 'P')
AND		SO1.Name	NOT IN	('sysdiagrams')

--SELECT * FROM #tmpRefTables

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

IF  OBJECT_ID('TempDB..#tmpRefTablesHasPK') IS NOT NULL
	BEGIN	DROP TABLE #tmpRefTablesHasPK	END
SELECT DISTINCT nmTable, nmRefTable
INTO		#tmpRefTablesHasPK
FROM		#tmpRefTables
WHERE		isPKey		= '1'

IF  OBJECT_ID('TempDB..#tmpRefTablesHasFK') IS NOT NULL
	BEGIN	DROP TABLE #tmpRefTablesHasFK	END
SELECT DISTINCT nmTable, nmRefTable
INTO		#tmpRefTablesHasFK
FROM		#tmpRefTables
WHERE		nmRefTable	IS NOT NULL

IF  OBJECT_ID('TempDB..#tmpRefTablesNoFK') IS NOT NULL
	BEGIN	DROP TABLE #tmpRefTablesNoFK	END
SELECT DISTINCT REF.nmTable
INTO		#tmpRefTablesNoFK
FROM		#tmpRefTables			REF
LEFT JOIN	#tmpRefTablesHasFK		NFK	ON	REF.nmTable		= NFK.nmTable
WHERE		NFK.nmTable IS NULL

IF  OBJECT_ID('TempDB..#tmpRefTablesIsFK') IS NOT NULL
	BEGIN	DROP TABLE #tmpRefTablesIsFK	END
SELECT DISTINCT REF.nmRefTable
INTO		#tmpRefTablesIsFK
FROM		#tmpRefTables			REF
INNER JOIN	#tmpRefTablesNoFK		NFK	ON	REF.nmRefTable	= NFK.nmTable

-- *** End: List reference tables from foreign key constraints
-- ****************************************************************************************************


-- ****************************************************************************************************
-- *** Begin: List of TABLES with dependencies and the tables they are dependent on

IF  OBJECT_ID('TempDB..#tmpDependentTables') IS NOT NULL
	BEGIN	DROP TABLE #tmpDependentTables	END
SELECT
	 SOP.name	 AS  [ParentTbl]
	 , SCP.name	 AS  [ParentCol]
	 , SOR.name	 AS  [RefTbl]
	 , SCR.name	 AS  [RefCol]
INTO #tmpDependentTables
FROM sys.foreign_key_columns	  FKC
INNER JOIN sys.objects			  SOP	ON  SOP.object_id = FKC.parent_object_id
INNER JOIN sys.columns			  SCP	ON  SCP.object_id = FKC.parent_object_id
										AND SCP.column_id = FKC.parent_column_id
INNER JOIN sys.objects			  SOR	ON  SOR.object_id = FKC.referenced_object_id
INNER JOIN sys.columns			  SCR	ON  SCR.object_id = FKC.referenced_object_id
										AND SCR.column_id = FKC.referenced_column_id
ORDER BY [ParentTbl]

IF  OBJECT_ID('TempDB..#tmpDependentTablesCount') IS NOT NULL
	BEGIN	DROP TABLE #tmpDependentTablesCount	END
SELECT
	[RefTbl]
	, COUNT(DISTINCT([ParentTbl])) AS	 [CountObj]
INTO	 #tmpDependentTablesCount
FROM	 #tmpDependentTables
GROUP BY [RefTbl]

-- *** End: List of TABLES with dependencies and the tables they are dependent on
-- ****************************************************************************************************

--SELECT * FROM #tmpRefTables
--SELECT * FROM #tmpRefTablesHasPK
--SELECT * FROM #tmpRefTablesHasFK
--SELECT * FROM #tmpRefTablesNoFK
--SELECT * FROM #tmpRefTablesIsFK
----SELECT * FROM #tmpDepentTables
----SELECT * FROM #tmpDepentTablesCount
----SELECT * FROM #tmpDepentViews
----SELECT * FROM #tmpDepentViewsCount
----SELECT * FROM #tmpDepentFunctions
----SELECT * FROM #tmpDepentFunctionsCount
----SELECT * FROM #tmpDepentStoredProcs
----SELECT * FROM #tmpDepentStoredProcsCount



-- ****************************************************************************************************
-- *** Begin: List of VIEWS with dependencies and the tables they are dependent on

IF  OBJECT_ID('TempDB..#tmpDependentViews') IS NOT NULL
	BEGIN	DROP TABLE #tmpDependentViews	END
SELECT DISTINCT	
	 SOR.name	 AS  [RefTbl]
	 , SOP.name	 AS  [ParentObj]
	 --, SCR.name	 AS  [RefTblCol]
	 --, SCP.name	 AS  [ParentObjCol]
	 , SOP.type	 AS  [ParentObjType] 
	 , SOR.type	 AS  [RefTblType] 
INTO #tmpDependentViews
FROM sys.sql_expression_dependencies	SXD
INNER JOIN sys.objects					SOP	ON  SOP.object_id = SXD.referencing_id
INNER JOIN sys.columns					SCP	ON  SCP.object_id = SXD.referencing_id
INNER JOIN sys.objects					SOR	ON  SOR.object_id = SXD.referenced_id
INNER JOIN sys.columns					SCR	ON  SCR.object_id = SXD.referenced_id
WHERE	 SOP.type = 'V'
ORDER BY [RefTbl]


IF  OBJECT_ID('TempDB..#tmpDependentViewsCount') IS NOT NULL
	BEGIN	DROP TABLE #tmpDependentViewsCount	END
SELECT
	[RefTbl]
	, COUNT(DISTINCT([ParentObj])) AS	 [CountObj]
INTO	 #tmpDependentViewsCount
FROM	 #tmpDependentViews
GROUP BY [RefTbl]

-- *** End: List of VIEWS with dependencies and the tables they are dependent on
-- ****************************************************************************************************


-- ****************************************************************************************************
-- *** Begin: List of FUNCTIONS with dependencies and the tables they are dependent on

IF  OBJECT_ID('TempDB..#tmpDependentFunctions') IS NOT NULL
	BEGIN	DROP TABLE #tmpDependentFunctions	END
SELECT DISTINCT	
	 SOR.name	 AS  [RefTbl]
	 , SOP.name	 AS  [ParentObj]
	 , SOP.type	 AS  [ParentObjType] 
	 , SOR.type	 AS  [RefTblType] 
INTO #tmpDependentFunctions
FROM sys.sql_expression_dependencies	SXD
INNER JOIN sys.objects					SOP	ON  SOP.object_id = SXD.referencing_id
INNER JOIN sys.columns					SCP	ON  SCP.object_id = SXD.referencing_id
INNER JOIN sys.objects					SOR	ON  SOR.object_id = SXD.referenced_id
INNER JOIN sys.columns					SCR	ON  SCR.object_id = SXD.referenced_id
WHERE	 SOP.type IN ('TF', 'FN')
ORDER BY [RefTbl]

IF  OBJECT_ID('TempDB..#tmpDependentFunctionsCount') IS NOT NULL
	BEGIN	DROP TABLE #tmpDependentFunctionsCount	END
SELECT
	[RefTbl]
	, COUNT(DISTINCT([ParentObj])) AS	 [CountObj]
INTO	 #tmpDependentFunctionsCount
FROM	 #tmpDependentFunctions
GROUP BY [RefTbl]

-- *** End: List of FUNCTIONS with dependencies and the tables they are dependent on
-- ****************************************************************************************************


-- ****************************************************************************************************
-- *** Begin: List of STORED PROCEDURES with dependencies and the tables they are dependent on

IF  OBJECT_ID('TempDB..#tmpDependentStoredProcs') IS NOT NULL
	BEGIN	DROP TABLE #tmpDependentStoredProcs	END
SELECT DISTINCT
	SXD.referenced_entity_name	AS  [RefTbl]
	, SOP.name					AS  [ParentObj]
INTO	 #tmpDependentStoredProcs
FROM sys.sql_expression_dependencies	SXD
INNER JOIN	sys.objects					SOP	ON  SOP.object_id = SXD.referencing_id
WHERE SOP.type = 'P'
ORDER BY [RefTbl]

IF  OBJECT_ID('TempDB..#tmpDependentStoredProcsCount') IS NOT NULL
	BEGIN	DROP TABLE #tmpDependentStoredProcsCount	END
SELECT
	[RefTbl]
	, COUNT(DISTINCT([ParentObj])) AS	 [CountObj]
INTO	 #tmpDependentStoredProcsCount
FROM	 #tmpDependentStoredProcs
GROUP BY [RefTbl]

-- *** End: List of FUNCTIONS with dependencies and the tables they are dependent on
-- ****************************************************************************************************



-- ****************************************************************************************************
-- *** BEGIN SECTION: Tables that are related to another table in the database

-- *** Begin: Report Title and related tables TOC

DECLARE ObjTOC CURSOR
FOR

SELECT DISTINCT Table_name
FROM			INFORMATION_SCHEMA.COLUMNS	INFSCH
INNER JOIN		#tmpRefTablesHasFK			RFK		ON	RFK.nmTable = INFSCH.Table_name
UNION ALL
SELECT			nmRefTable FROM #tmpRefTablesIsFK
ORDER BY 1

OPEN ObjTOC

FETCH NEXT 
FROM ObjTOC
INTO @EntityName

PRINT '<!DOCTYPE html>
<html>
<head>
<title>' + @DatabaseName + ': Data Dictionary</title>
<meta http-equiv = "X-UA-Compatible" content = "IE=10; IE=9; IE=8; IE=7; IE=EDGE"/>'

--PRINT '
--<!-- DataTables CSS -->
--<link rel = "stylesheet" type = "text/css" href = "CSS/jquery.dataTables.css">
  
--<!-- jQuery -->
--<script type = "text/javascript" src = "JS/jquery-1.11.3.min.js"></script>

--<!--<script type = "text/javascript" charset = "utf8" src = "https://code.jquery.com/jquery-1.10.2.min.js"></script>-->
  
--<!-- DataTables -->
--<script type = "text/javascript" charset = "utf8" src = "JS/jquery.dataTables.js"></script>

--<script type = "text/javascript">
--$(document).ready(function() {
--    $(''table.entitydatatbl'').DataTable();
--} );
--</script>

--<!-- DataTables Javascript Init -->
--<script type = "text/javascript">
--    $(''table.entitydatatbl'').DataTable({
--        buttons: [
--        ''copy'', ''excel'', ''pdf''
--    ]
--    });
--</script>'

PRINT '<style type = "text/css">'
PRINT --'@media print, screen {'
'
 a      {color: #0099FF;}
 body	  {color:black; background:#FFFFFF; font-family:sans-serif;}
 table  {border-collapse:collapse; border:1px solid #A5A5A5; padding:4px;}
 th		  {background:#757575; padding:4px; border:1px solid #A5A5A5; text-align:left; font-size:13px; color:#FFFFFF;}
 tr	    {background:#FFFFFF;}
 td	    {border:1px solid #A5A5A5; padding:4px;}  
 tfoot  {display:table-row-group;}
 tfoot .trlinktop td {text-align:right; padding:2px; border:1px solid #FFFFFF;}
 
 .reporttitle		    {background:#FFFFFF; padding:0px; border:0px; width:auto; border-collapse:separate;}
 .reporttitlehead	  {background:#FFFFFF; padding:2px; border:0px; width:auto; font-size:28px; font-weight:bold; font-style:italic;}
 .reporttitlebody	  {background:#FFFFFF; padding:2px; border:0px; width:auto; font-size:28px; font-weight:bold;}
 .reporttitleimage  {background:#FFFFFF; padding:0px; border:0px; width:auto; text-align:center;}
 
 .dbdetails			    {border:0px; width:auto; border-collapse:separate;}
 .dbdetailsheadtr	  {background:#F5F5F5; padding:2px; font-size:16px; font-weight:bold;}
 .dbdetailsbodytr	  {background:#FFFFFF; padding:2px; font-size:14px;}

 .entitydesctbl     {border:0px; width:100%; border-collapse:separate;}
 .entitydescheadtr  {background:#F5F5F5; padding:2px; font-size:16px; font-style:italic; font-weight:bold;}
 .entitydesctr      {background:#FFFFFF; padding:2px; font-size:14px;} 
 .otherentypes			    {background:#FFFFFF; padding:2px; width:110px; font-size:13px; text-align:center;}
 .otherentypes:hover	  {background:#F5F5F5; padding:2px; font-size:13px; font-style:italic;}
 
 .entitydatatbl         {border:1px solid #A5A5A5; padding:4px; page-break-after:left}
 .entitydatadiv         {display:inline-block;}
 .entitydatadiv:hover   {box-shadow:2px 2px 10px 2px #D6D6D6;}
 .entitydatanametd      {background:#F5F5F5; font-size:13px; font-weight:bold;}
 .entitydatadesctd      {background:#FFFFE0; font-size:13px; font-style:italic;}
 .entitydatatr			    {font-size:12px;}
 .entitydatatr:hover	  {background:#F5F5F5;  color:#161A1D;}
 .entitydataattnametd	  {background:#F5F5F5;}

 .footheader_dep_table      {background:#FFEECC;}
 .footheader_dep_view       {background:#FFF1D6;}
 .footheader_dep_function   {background:#FFF3DB;}
 .footheader_dep_storedproc {background:#FFF5E0;}

 .footheader_dep_table, .footheader_dep_view, .footheader_dep_function, .footheader_dep_storedproc
  	{text-align:left; font-size:12px;}
 	
 .footdetail_dep_table, .footdetail_dep_view, .footdetail_dep_function ,.footdetail_dep_storedproc
	  {background:#FFFFFF; text-align:left; font-size:12px;}
	
 .footdetail_dep_table:hover, .footdetail_dep_view:hover, .footdetail_dep_function:hover, .footdetail_dep_storedproc:hover
	  {background:#F5F5F5;  color:#161A1D;}

 #reporttitle       {background:#F5F5F5; padding:7px; font-size:30px; font-weight:bold; display:inline-block; border:1px solid #A5A5A5;}
 #reportlinks       {background:#FFFFFF; padding:7px;}
 #reportdesc1       {background:#FFFFFF; padding:7px; font-size:15px;}
 #reportdesc2       {background:#FFFFFF; padding:7px; font-size:14px; font-style:italic;}
  
 #entitytoc	        {font-size:13px; page-break-before:avoid; page-break-after:always; list-style-type:none; overflow:hidden; width:100%;}
 #entitytoc li      {float:left; width:25%; overflow:hidden}
 #entitytoc li a    {display:block; padding:2px; width:auto;}

 span               {background:#FFFFFF; padding:4px; font-size:14px;}
 span:hover         {background:#F5F5F5; font-style:italic;}
 li:hover           {font-weight:bold;} 
 .linktop           {background:#FFFFFF; padding:2px; font-size:11px;}
 div.dataTables_wrapper {margin-bottom:0.5em; margin-top:0.5em;}'
PRINT --'{'
'
</style>
</head>
 
<body>'

-- *** Display report title and database details

PRINT '
<table class = "reporttitle">
    <tr>
		  <td class = "reporttitleimage"><img alt="Environmental Protection Agency Ireland" src = "https://www.edenireland.ie/Content/images/epa.png" width=75%; height=75%/></td>
		  <td class = "reporttitlehead">Data Dictionary: </td>
		  <td class = "reporttitlebody">' + @DatabaseName + '</td>
	 </tr>
</table>

<div id = "reportlinks">
	 <span><a href="#entityhasfk">Tables - Related</a></span> | 
	 <span><a href="#entitynofk">Tables - Unrelated</a></span> | 
	 <span><a href="#entitynofk">Views</a></span> | 
	 <span><a href="#entitynofk">Functions</a></span>
</div>

<br/>

<table class = "dbdetails">
    <tr class = "dbdetailsheadtr"><td colspan = "2">Database Details</td></tr>
    <tr class = "dbdetailsbodytr"><th>Database: </th><td>' + @DatabaseName + '</td></tr>
    <tr class = "dbdetailsbodytr"><th>Server: </th><td>' + @ServerName + '</td></tr>
    <tr class = "dbdetailsbodytr"><th>Generated on: </th><td>' + CAST(@TimeGenerated AS NVARCHAR(50)) + '</td></tr>
</table>

<br/>'

-- *** Begin TOC: Display list of all tables that that are related to other tables in the database

PRINT '

<div id = "entityhasfk">
<table class = "entitydesctbl">
    <tr class = "entitydescheadtr"><td colspan = "2">Tables - Related</td></tr>
    <tr class = "entitydesctr">
        <td>The following tables are related to one or more other tables within the <i>'
        + @DatabaseName + '</i> database</td><td class = "otherentypes"><a href="#reportlinks">Other entity types</a></td>
	 </tr>
</table>
</div>

<div id = "entitytoc">
	 <ul>'

WHILE @@FETCH_STATUS = 0 BEGIN
PRINT '		<li><a href="#'+ @EntityName + '">' + @EntityName + '</a></li>'
FETCH NEXT FROM ObjTOC	INTO @EntityName END;
PRINT ' </ul>
</div>

<br/>
<br/>'

CLOSE		ObjTOC
DEALLOCATE	ObjTOC

-- *** End TOC: Display list of all tables that that are related to other tables in the database

-- *** End: Report Title and related tables TOC



-- **************************************
-- *** BEGIN SECTION: Display table data

DECLARE ObjData CURSOR
FOR

-- *** Begin constraint: Restrict tables displayed - must be related to another table

SELECT DISTINCT Table_name
FROM			INFORMATION_SCHEMA.COLUMNS	INFSCH
INNER JOIN		#tmpRefTablesHasFK			RFK		ON	RFK.nmTable = INFSCH.Table_name
UNION ALL
SELECT			nmRefTable FROM #tmpRefTablesIsFK
ORDER BY 1

-- *** End constraint: Restrict tables displayed - must be related to another table


-- *** Begin Loop: Loop to display table data

OPEN ObjData

FETCH NEXT FROM ObjData
INTO @EntityName

WHILE @@FETCH_STATUS = 0
BEGIN

PRINT '
<div class = "entitydatadiv">
<table id = "" class = "entitydatatbl">
<thead>
	 <tr>
		  <th colspan = "1", white-space: nowrap><b>Entity Name: </b></th>
		  <td class = "entitydatanametd", colspan = "8"><div id = "' + @EntityName + '">' + @EntityName + '</div></td>
	 </tr>'

-- *** Table Description - Characters 1-250
PRINT '	<tr>
		  <th colspan = "1", white-space: nowrap><i><b>Entity Description: </b></i></th>
				<td class = "entitydatadesctd", colspan = "8">'

SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),1,250) 
FROM	sys.extended_properties A
WHERE	A.major_id	= OBJECT_ID(@EntityName)
AND		name		= 'MS_Description' 
AND		minor_id	= 0

-- *** Table Description - Characters 251-500
SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),251, 250) 
FROM	sys.extended_properties A
WHERE	A.major_id	= OBJECT_ID(@EntityName)
AND		name		= 'MS_Description' 
AND		minor_id	= 0

PRINT '		</td>
	 </tr>
	 <tr>'

-- *** Display the column headers

PRINT '			<th>Column Name</th>
		  <th>Description</th>
		  <th>PK</th>
		  <th>FK</th>
		  <th>Data Type</th>
		  <th>Size</th>
		  <th>Null</th>
		  <th>Default</th>
		  <th>FK Dependencies</th>
	 </tr>
</thead>'

-- *** Display the table data dictionary

PRINT ''
PRINT '<tbody>'

SELECT
	'	<tr class = "entitydatatr">' + 
	'		<td class = "entitydataattnametd">' + CAST(ALLCOL.name AS VARCHAR(50)) + '</td>
			<td>' + SUBSTRING(ISNULL(CAST(EXTPRP.value AS VARCHAR(255)),''), 1,   250),
					SUBSTRING(ISNULL(CAST(EXTPRP.value AS VARCHAR(500)),''), 251, 250) + '</td>
			<td>' + ISNULL(CAST(REFTBL.isPKey AS VARCHAR(5)),'N') + '</td>'
	 ,	   '<td>' + CAST(ISNULL
					 (
						  (
								SELECT TOP 1 1
									 FROM	sys.foreign_key_columns		 FKCOL
									 WHERE	FKCOL.parent_column_id	=	 ALLCOL.column_id
									 AND	FKCOL.parent_object_id	=	 ALLCOL.object_id
							), 0) AS VARCHAR(20)) + '</td>'
	 ,	   '<td>' + CAST(USRTYP.name AS CHAR(20)) + '</td>'	
	 ,	   '<td>' + CAST
					  (
						  CAST
						  (
								CASE 
									 WHEN SYSTYP.name IN (N'nchar', N'nvarchar') 
									 AND  ALLCOL.max_length <> -1
										  THEN ALLCOL.max_length / 2
										  ELSE ALLCOL.max_length 
								END 
								AS INT
							)
							AS VARCHAR(20)) + '</td>'
	 ,	'<td>' + CAST(ALLCOL.is_nullable AS VARCHAR(20)) + '</td>'
	 ,	'<td>' + ISNULL(SUBSTRING(CAST(DFCNST.definition AS VARCHAR(50)), 2, LEN(DFCNST.definition)-2),'') + '</td>'
	 ,	'<td>' + ISNULL(+ '<a href="#'+ REFTBL.nmRefTable + '">' + REFTBL.nmRefTable + '</a></td></tr>','</td></tr>') -- Uncomment when Extended Properties scripts are complete

FROM			sys.tables					SYSTBL
INNER JOIN		sys.all_columns				ALLCOL	ON	ALLCOL.object_id		=	SYSTBL.object_id
LEFT OUTER JOIN sys.indexes					IDX		ON	IDX.object_id			=	ALLCOL.object_id
													AND IDX.is_primary_key		=	1
LEFT OUTER JOIN sys.index_columns			IDXCOL	ON	IDXCOL.index_id			=	IDX.index_id
													AND IDXCOL.column_id		=	ALLCOL.column_id
													AND IDXCOL.object_id		=	ALLCOL.object_id
													AND IDXCOL.is_included_column = 0
LEFT OUTER JOIN sys.types					USRTYP	ON	USRTYP.user_type_id		=	ALLCOL.user_type_id
LEFT OUTER JOIN sys.types					SYSTYP	ON	SYSTYP.user_type_id		=	ALLCOL.system_type_id
													AND SYSTYP.user_type_id		=	SYSTYP.system_type_id
LEFT JOIN		sys.default_constraints		DFCNST	ON	DFCNST.object_id		=	ALLCOL.default_object_id
LEFT OUTER JOIN sys.extended_properties		EXTPRP	ON	EXTPRP.major_id			=	ALLCOL.object_id
													AND EXTPRP.minor_id			=	ALLCOL.column_id
													AND EXTPRP.name				=	'MS_Description'
LEFT JOIN #tmpRefTables						REFTBL	ON	REFTBL.nmTable			=	@EntityName
													AND REFTBL.nmAttribute		=	ALLCOL.name
WHERE		SYSTBL.name	= @EntityName
GROUP BY	ALLCOL.column_id
			, ALLCOL.object_id
			, ALLCOL.name
			, EXTPRP.value
			, REFTBL.isPKey
			, REFTBL.isFKey
			, USRTYP.name
			, SYSTYP.name
			, ALLCOL.max_length
			, ALLCOL.is_nullable
			, DFCNST.definition
			, REFTBL.nmRefTable
ORDER BY ALLCOL.column_id

PRINT '</tbody>'

-- *** End: Display the table data dictionary

PRINT ''

-- *** Begin: Display ENTITIES dependent on the featured table

PRINT '<tfoot class = "dependencies">'

-- *** Display all TABLES dependent on the featured table

PRINT ' <tr class = "footheader_dep_table">
		  <td colspan = "9"><i> '
PRINT ' <b>Tables</b> in</i> ' + @DatabaseName + ' <i>dependent on </i><b>' + @EntityName + '</b><i>:'

DECLARE @CountTabTemp AS INT
SELECT TOP 1 @CountTabTemp = COALESCE
	((
	SELECT  [CountObj] 
	FROM	#tmpDependentTablesCount	
	WHERE	[RefTbl] = @EntityName
	), 0) 
SELECT @CountTabTemp

--SELECT COALESCE
--	((
--	SELECT  [CountObj] 
--	FROM	#tmpDependentTablesCount 
--	WHERE	[RefTbl] = @EntityName 
--	), 0) 

PRINT '</i></td>'

SELECT '	<tr class = "footdetail_dep_table">
		<td colspan = "3"><a href="#' + [ParentTbl] + '">' + [ParentTbl] + '</a></td>
			<td colspan = "3">' + [ParentCol] + '</td>
			<td colspan = "3"><i>[Depends on:]</i> ' + [RefCol] + '</i></td>
		</tr>'
FROM	  #tmpDependentTables
WHERE	  [RefTbl] = @EntityName

-- *** End: Display all TABLES dependent on the featured table


-- *** Begin: Display all VIEWS dependent on the featured table

PRINT ' <tr class = "footheader_dep_view">
		  <td colspan = "9"><i> '
		  
PRINT ' <b>Views</b> in</i> ' + @DatabaseName + ' <i>dependent on </i><b>' + @EntityName + '</b><i>:'

DECLARE @CountVwTemp AS INT
SELECT TOP 1 @CountVwTemp = COALESCE
	((
	SELECT  [CountObj] 
	FROM	#tmpDependentViewsCount	
	WHERE	[RefTbl] = @EntityName
	), 0) 
SELECT @CountVwTemp

--SELECT COALESCE
--	((
--	SELECT  [CountObj] 
--	FROM	#tmpDependentViewsCount	
--	WHERE	[RefTbl] = @EntityName 
--	), 0) 

PRINT '		</i></td>
	</tr>'

IF 	@CountVwTemp > 0
BEGIN
	PRINT '	<tr>
		<td colspan = "9">'
END

IF 	@CountVwTemp > 0
BEGIN
	SELECT '		<a class = "footdetail_dep_view" href="#' + [ParentObj] + '">' + [ParentObj] + '</a>'
	FROM	  #tmpDependentViews
	WHERE	  [RefTbl] = @EntityName
END

IF 	@CountVwTemp > 0
BEGIN
	PRINT '		</td>
	</tr>'
END

-- *** End: Display all VIEWS dependent on the featured table

-- *** Begin: Display all FUNCTIONS dependent on the featured table

PRINT ' <tr class = "footheader_dep_function">
		  <td colspan = "9"><i> '
		  
PRINT ' <b>Functions</b> in</i> ' + @DatabaseName + ' <i>dependent on </i><b>' + @EntityName + '</b><i>:'

DECLARE @CountFnTemp AS INT
SELECT TOP 1 @CountFnTemp = COALESCE
	((
	SELECT  [CountObj] 
	FROM	#tmpDependentFunctionsCount	
	WHERE	[RefTbl] = @EntityName
	), 0) 
SELECT @CountFnTemp

--SELECT COALESCE
--	((
--	SELECT  [CountObj] 
--	FROM	#tmpDependentFunctionsCount	
--	WHERE	[RefTbl] = @EntityName 
--	), 0) 

PRINT '		</i></td>
	</tr>'

IF 	@CountFnTemp > 0
BEGIN
	PRINT '	<tr>
		<td colspan = "9">'
END

IF 	@CountFnTemp > 0
BEGIN
	SELECT '		<a class = "footdetail_dep_function" href="#' + [ParentObj] + '">' + [ParentObj] + '</a>'
	FROM	  #tmpDependentFunctions
	WHERE	  [RefTbl] = @EntityName
END

IF 	@CountFnTemp > 0
BEGIN
	PRINT '		</td>
	</tr>'
END
-- *** End: Display all FUNCTIONS dependent on the featured table

-- *** Begin: Display all STORED PROCEDURES dependent on the featured table

PRINT ' <tr class = "footheader_dep_storedproc">
		  <td colspan = "9"><i> '
		  
PRINT ' <b>Stored Procedures</b> in</i> ' + @DatabaseName + ' <i>dependent on </i><b>' + @EntityName + '</b><i>:'

DECLARE @CountSPTemp AS INT
SELECT TOP 1 @CountSPTemp = COALESCE
	((
	SELECT  [CountObj] 
	FROM	#tmpDependentStoredProcsCount	
	WHERE	[RefTbl] = @EntityName
	), 0) 
SELECT @CountSPTemp

--DECLARE @RNTemp AS INT
--SELECT TOP 1 @RNTemp = 
--	(
--	SELECT (ROW_NUMBER() OVER (ORDER BY [RefTbl] ASC))
--	FROM #tmpDependentStoredProcs 
--	WHERE [RefTbl] = 'tblApprovalMeasurement_apm'
--	)
--SELECT @RNTemp

	--WITH CTE AS 
	--(
	--	SELECT RowNum = (ROW_NUMBER() OVER (ORDER BY [RefTbl] ASC))
	--	FROM #tmpDependentStoredProcs 
	--	WHERE [RefTbl] = 'tblApprovalMeasurement_apm'
	--)

	--SELECT	TOP 1 (RowNum)
	--FROM    CTE
	--ORDER BY RowNum DESC
			
	--BEGIN SELECT '|'	
	--END

PRINT '		</i></td>
	</tr>'

IF 	@CountSPTemp > 0
BEGIN
	PRINT '	<tr>
		<td colspan = "9">'
END

IF 	@CountSPTemp > 0
BEGIN
	SELECT '		<a class = "footdetail_dep_storedproc" href="#' + [ParentObj] + '">' + [ParentObj] + '</a>'
	FROM	  #tmpDependentStoredProcs
	WHERE	  [RefTbl] = @EntityName
	
	--IF 	(@CountSPTemp = @CountSPTemp)
	--BEGIN
	--	SELECT '		<a class = "footdetail_dep_storedproc" href="#' + [ParentObj] + '">' + [ParentObj] + '</a>'
	--	FROM	  #tmpDependentStoredProcs
	--	WHERE	  [RefTbl] = @EntityName
	--END
END

IF 	@CountSPTemp > 0
BEGIN
	PRINT '		</td>
	</tr>'
END

-- *** End: Display all STORED PROCEDURES dependent on the featured table

-- *** Link to top of report [link placed right bottom of each table]

PRINT '	<tr class = "trlinktop"><td colspan = "9"><span class = "linktop"><a href="#reportlinks">[Top]</a></span></td></tr>'
PRINT '</tfoot>'

-- *** End: Display all ENTITIES dependent on the featured table

PRINT '</table>
</div>
<br/>
<br/>
<br/>'

FETCH NEXT 
FROM ObjData
INTO @EntityName
END

-- *** End Loop: Loop to display table data

CLOSE		ObjData
DEALLOCATE	ObjData


-- *** END SECTION: Tables with that are related to another table in the database
-- ****************************************************************************************************


-- ****************************************************************************************************
-- *** BEGIN SECTION: Tables with no with no relationship to another table in the database

-- *** Begin TOC: Display list of all tables that that are not related to another table in the database

PRINT '<br/>'

PRINT '<div id = "entitynofk">
<table class = "entitydesctbl">
    <tr class = "entitydescheadtr"><td colspan = "2">Tables - Unrelated</td></tr>
    <tr class = "entitydesctr">
        <td>The following tables are not related to any other tables within the  <i>'
        + @DatabaseName + '</i> database, but may have dependent views or functions<td class = "otherentypes"><a href="#reportlinks">Other entity types</a></td>
	  </tr>
</table>
</div>

</div>

<div id = "entitytoc">
	 <ul>'

DECLARE ObjTOC CURSOR
FOR

SELECT DISTINCT Table_name
FROM		INFORMATION_SCHEMA.COLUMNS	 INFSCH
INNER JOIN	#tmpRefTablesNoFK			 NOFK	ON	NOFK.nmTable	 = INFSCH.Table_name
LEFT JOIN	#tmpRefTablesIsFK			 ISFK	ON	ISFK.nmRefTable  = INFSCH.Table_name
WHERE		ISFK.nmRefTable  IS NULL

OPEN ObjTOC

FETCH NEXT 
FROM ObjTOC
INTO @EntityName

WHILE @@FETCH_STATUS = 0 BEGIN
PRINT '		<li><a href="#'+ @EntityName + '">' + @EntityName + '</a></li>'
FETCH NEXT FROM ObjTOC	INTO @EntityName END;
PRINT ' </ul>
</div>

<br/>
<br/>'

CLOSE		ObjTOC
DEALLOCATE	ObjTOC

-- *** End TOC: Display list of all tables that that are not related to another table in the database

-- **************************************
-- *** BEGIN SECTION: Display table data

DECLARE ObjData CURSOR
FOR

-- *** Begin constraint: Restrict tables displayed - must not be related to another table

SELECT DISTINCT Table_name
FROM		INFORMATION_SCHEMA.COLUMNS	 INFSCH
INNER JOIN	#tmpRefTablesNoFK			 NOFK		ON	NOFK.nmTable	 = INFSCH.Table_name
LEFT JOIN	#tmpRefTablesIsFK			 ISFK		ON	ISFK.nmRefTable  = INFSCH.Table_name
WHERE		ISFK.nmRefTable  IS NULL


SELECT * FROM #tmpRefTablesNoFK
SELECT * FROM #tmpRefTablesIsFK
-- *** End constraint: Restrict tables displayed - must not be related to another table

-- *** Begin Loop: Loop to display table data

OPEN ObjData

FETCH NEXT FROM ObjData
INTO @EntityName

WHILE @@FETCH_STATUS = 0
BEGIN

PRINT '
<table class = "entitydatatbl">
<thead>
	 <tr>
		  <th colspan = "1", white-space: nowrap><b>Entity Name: </b></th>
		  <td class = "entityname", colspan = "8"><div id = "' + @EntityName + '">' + @EntityName + '</div></td>
	 </tr>'

-- *** Table Description - Characters 1-250
PRINT '	<tr>
		  <th colspan = "1", white-space: nowrap><i><b>Entity Description: </b></i></th>
				<td class = "entitydatadesctd", colspan = "8">'
SELECT REPLACE (SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),1,250), '  ', '') 
FROM	sys.extended_properties A
--SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),1,250) 
--FROM	sys.extended_properties A
WHERE	A.major_id = OBJECT_ID(@EntityName)
AND		name = 'MS_Description' AND minor_id = 0

-- *** Table Description - Characters 251-500
--SELECT REPLACE (, '  ', '') 
SELECT REPLACE (SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),251, 250), '  ', '') 
FROM	sys.extended_properties A
--SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),251, 250) 
--FROM	sys.extended_properties A
WHERE	A.major_id = OBJECT_ID(@EntityName)
AND		name = 'MS_Description' and minor_id = 0
PRINT '		</td>
	 </tr>
	 <tr>'

-- *** Display the column headers

PRINT '		<th>Column Name</th>
		  <th>Description</th>
		  <th>PK</th>
		  <th>FK</th>
		  <th>Data Type</th>
		  <th>Size</th>
		  <th>Null</th>
		  <th>Default</th>
		  <th>FK Dependencies</th>
	 </tr>
</thead>'

-- *** Display the table data dictionary

PRINT ''
PRINT '<tbody>'

SELECT
	'	<tr class = "entitydatatr">' + 
	'		<td class = "entitydataattnametd">' + REPLACE (CAST(ALLCOL.name AS VARCHAR(50)), '  ', '') + '</td>
			<td>' + REPLACE (SUBSTRING(ISNULL(CAST(EXTPRP.value AS VARCHAR(255)),''), 1,   250), '  ', ''),
				  REPLACE (SUBSTRING(ISNULL(CAST(EXTPRP.value AS VARCHAR(500)),''), 251, 250), '  ', '') + '</td>
			<td>' + REPLACE (ISNULL(CAST(REFTBL.isPKey AS VARCHAR(5)),'N'), '  ', '') + '</td>'
	 ,	  '<td>' + REPLACE (CAST(ISNULL
					 (
						  (
								SELECT TOP 1 1
									 FROM		sys.foreign_key_columns		 FKCOL
									 WHERE	FKCOL.parent_column_id	=	 ALLCOL.column_id
									 AND		FKCOL.parent_object_id	=	 ALLCOL.object_id
							), 0) AS VARCHAR(20)), '  ', '') + '</td>'
	 ,	  '<td>' + REPLACE (CAST(USRTYP.name AS CHAR(20)), '  ', '') + '</td>'	
	 ,	  '<td>' + REPLACE (CAST
					  (
						  CAST
						  (
								CASE 
									 WHEN SYSTYP.name IN (N'nchar', N'nvarchar') 
									 AND	ALLCOL.max_length <> -1
										  THEN ALLCOL.max_length / 2
										  ELSE ALLCOL.max_length 
								END 
								AS INT
							)
						AS VARCHAR(20)), '  ', '') + '</td>'
	 , '<td>' + REPLACE (CAST(ALLCOL.is_nullable AS VARCHAR(20)), '  ', '') + '</td>'
	 , '<td>' + REPLACE (ISNULL(SUBSTRING(CAST(DFCNST.definition AS VARCHAR(50)), 2, LEN(DFCNST.definition)-2),''), '  ', '') + '</td>'
	 , '<td>' + REPLACE (ISNULL(+ '<a href="#'+ REFTBL.nmRefTable + '">' + REFTBL.nmRefTable + '</a></td></tr>','</td></tr>'), '  ', '')  -- Uncomment when Extended Properties scripts are complete


--REPLACE (, '  ', '') 

-- *** Fields to be uncommented for Excel metadata lookup
	--, '<td>' + ISNULL(+ '<a href="#'+ REFTBL.nmRefTable + '">' + REFTBL.nmRefTable + '</a></td>','</td>') -- Delete when Extended Properties scripts are complete
	--, '<td>' + @EntityName + '</td></tr>' -- Delete when Extended Properties scripts are complete

-- *** Fields to be discussed for inclusion
	--, '<td>' + CAST(ISNULL(IDXCOL.index_column_id, 0)AS VARCHAR(20)) + '</td>'
	--, '<td>' + ISNULL(CAST(REFTBL.isFKey AS VARCHAR(5)),'N') + '</td>'
	--, '<td>' + CAST(CAST(ALLCOL.precision AS INT) AS VARCHAR(20)) + '</td>',
	--, '<td>' + CAST(CAST(ALLCOL.scale AS INT) AS VARCHAR(20)) + '</td>',
	--, '<td>' + CAST(ALLCOL.is_computed AS VARCHAR(20)) + '</td>'
	--, '<td>' + CAST(ALLCOL.is_identity AS VARCHAR(20)) + '</td>'


FROM			sys.tables					SYSTBL
INNER JOIN		sys.all_columns				ALLCOL	ON	ALLCOL.object_id		=	SYSTBL.object_id
LEFT OUTER JOIN sys.indexes					IDX		ON	IDX.object_id			=	ALLCOL.object_id
													AND IDX.is_primary_key		=	1
LEFT OUTER JOIN sys.index_columns			IDXCOL	ON	IDXCOL.index_id			=	IDX.index_id
													AND IDXCOL.column_id		=	ALLCOL.column_id
													AND IDXCOL.object_id		=	ALLCOL.object_id
													AND IDXCOL.is_included_column = 0
LEFT OUTER JOIN sys.types					USRTYP	ON	USRTYP.user_type_id		=	ALLCOL.user_type_id
LEFT OUTER JOIN sys.types					SYSTYP	ON	SYSTYP.user_type_id		=	ALLCOL.system_type_id
													AND SYSTYP.user_type_id		=	SYSTYP.system_type_id
LEFT JOIN		sys.default_constraints		DFCNST	ON	DFCNST.object_id		=	ALLCOL.default_object_id
LEFT OUTER JOIN sys.extended_properties		EXTPRP	ON	EXTPRP.major_id			=	ALLCOL.object_id
													AND EXTPRP.minor_id			=	ALLCOL.column_id
													AND EXTPRP.name				=	'MS_Description'
LEFT JOIN #tmpRefTables						REFTBL	ON	REFTBL.nmTable			=	@EntityName
													AND REFTBL.nmAttribute		=	ALLCOL.name
--LEFT JOIN #tmpRefTablesIsFK				 RFISFK	ON	 RFISFK.nmTable			=	@EntityName
WHERE		SYSTBL.name	= @EntityName
GROUP BY	ALLCOL.column_id
			, ALLCOL.object_id
			, ALLCOL.name
			, EXTPRP.value
			, REFTBL.isPKey
			, REFTBL.isFKey
			, USRTYP.name
			, SYSTYP.name
			, ALLCOL.max_length
			, ALLCOL.is_nullable
			, DFCNST.definition
			, REFTBL.nmRefTable
ORDER BY ALLCOL.column_id

PRINT '</tbody>'

-- *** End: Display the table data dictionary

PRINT ''

-- *** Begin: Display ENTITIES dependent on the featured table

PRINT '<tfoot class = "dependencies">'

-- *** Display all TABLES dependent on the featured table

PRINT ' <tr class = "footheader_dep_table">
		  <td colspan = "9"><i> '
PRINT ' <b>Tables</b> in</i> ' + @DatabaseName + ' <i>dependent on </i><b>' + @EntityName + '</b><i>:'

SELECT COALESCE
	((
	SELECT  [CountObj] FROM	  #tmpDependentTablesCount WHERE	  [RefTbl] = @EntityName 
	), 0) 

'</i></td>'

SELECT '	<tr class = "footdetail_dep_table">
		<td colspan = "3"><a href="#' + [ParentTbl] + '">' + [ParentTbl] + '</a></td>
			<td colspan = "3">' + [ParentCol] + '</td>
			<td colspan = "3"><i>[Depends on:] ' + [RefCol] + '</i></td>
		</tr>'
FROM	  #tmpDependentTables
WHERE	  [RefTbl] = @EntityName

-- *** End: Display all TABLES dependent on the featured table


-- *** Begin: Display all VIEWS dependent on the featured table

PRINT ' <tr class = "footheader_dep_view">
		  <td colspan = "9"><i> '
		  
PRINT ' <b>Views</b> in</i> ' + @DatabaseName + ' <i>dependent on </i><b>' + @EntityName + '</b><i>:'

SELECT COALESCE
	((
	SELECT  [CountObj] FROM	  #tmpDependentViewsCount WHERE	  [RefTbl] = @EntityName 
	), 0) 

'</i></td>'

SELECT '	<tr class = "footdetail_dep_view">
		<td colspan = "9"><a href="#' + [ParentObj] + '">' + [ParentObj] + '</a></td>
		</tr>'
FROM	  #tmpDependentViews
WHERE	  [RefTbl] = @EntityName

-- *** End: Display all VIEWS dependent on the featured table

-- *** Begin: Display all FUNCTIONS dependent on the featured table

PRINT ' <tr class = "footheader_dep_function">
		  <td colspan = "9"><i> '
		  
PRINT ' <b>Functions</b> in</i> ' + @DatabaseName + ' <i>dependent on </i><b>' + @EntityName + '</b><i>:'

SELECT COALESCE
	((
	SELECT  [CountObj] FROM	  #tmpDependentFunctionsCount WHERE	  [RefTbl] = @EntityName 
	), 0) 

'</i></td>'

SELECT '	<tr class = "footdetail_dep_function">
		<td colspan = "9"><a href="#' + [ParentObj] + '">' + [ParentObj] + '</a></td>
		</tr>'
FROM	  #tmpDependentFunctions
WHERE	  [RefTbl] = @EntityName

-- *** End: Display all FUNCTIONS dependent on the featured table


PRINT '</tfoot>'

-- *** End: Display all ENTITIES dependent on the featured table

PRINT '</table>'
PRINT ''
PRINT '<span class = "linktop"><a href="#reportlinks">[Top]</a></span>'
PRINT ''
PRINT '<br/>'
PRINT '<br/>'
PRINT '<br/>'

FETCH NEXT 
FROM ObjData
INTO @EntityName
END

-- *** End Loop: Loop to display table data

CLOSE		ObjData
DEALLOCATE	ObjData


-- *** END SECTION: Tables with that are related to another table in the database
-- ****************************************************************************************************


PRINT '</body>'
PRINT '</html>'


-- ****************************************************************************************************
-- *** Drop temp tables

BEGIN	DROP TABLE #tmpRefTables					END
BEGIN	DROP TABLE #tmpRefTablesHasPK				END
BEGIN	DROP TABLE #tmpRefTablesHasFK				END
BEGIN	DROP TABLE #tmpRefTablesNoFK				END
BEGIN	DROP TABLE #tmpRefTablesIsFK				END
BEGIN	DROP TABLE #tmpDependentTables				END
BEGIN	DROP TABLE #tmpDependentTablesCount			END
BEGIN	DROP TABLE #tmpDependentViews				END
BEGIN	DROP TABLE #tmpDependentViewsCount			END
BEGIN	DROP TABLE #tmpDependentFunctions			END
BEGIN	DROP TABLE #tmpDependentFunctionsCount		END
BEGIN	DROP TABLE #tmpDependentStoredProcs			END
BEGIN	DROP TABLE #tmpDependentStoredProcsCount	END

/*
-- ****************************************************************************************************
-- *** SANDBOX

--LEFT JOIN #tmpRefTablesIsFK				 RFISFK	ON	 RFISFK.nmTable			=	@EntityName
 
 .footheader_dep_storedproc	        {background: #FFF3DB; text-align: left; font-size: 13px;}
 .footdetail_dep_storedproc	        {background: #FFFFFF; text-align: left; font-size: 12px;}
 .footdetail_dep_storedproc:hover		{background: #F5F5F5;  color: #161A1D;}

-- *** Dependent views

SELECT
	SO.name AS [Dep_Views]
FROM	sys.objects				SO 
INNER JOIN	sys.sysreferences	SRF	ON SO.object_id = SRF.rkeyid
WHERE	SO.type = 'V' 
AND		SRF.fkeyid = OBJECT_ID('tblStation_sta')

SELECT DISTINCT 
	name
	, SO.type 
FROM		sys.objects						SO 
INNER JOIN	sys.sql_expression_dependencies SXD ON	SO.object_id	= SXD.referencing_id 
WHERE	SXD.referenced_id = OBJECT_ID('tblStation_sta')
AND		SO.type = 'V';

---- *** Display with count in separate right <td>
--PRINT ' <tr class = "footheader_dep_table">
--		  <td colspan = "8"><i><b>Tables</b> dependent on </i><b>' + @EntityName + '</b><i>:</i></td>
--		  <td class = "tblcount">' 
--SELECT COALESCE
--	((
--	SELECT  [CountObj] FROM	  #tmpDependentTablesCount WHERE	  [RefTbl] = @EntityName 
--	), 0)
--PRINT ' table(s)'
--PRINT ' </td></tr>'


--REPLACE (, '  ', '') 

-- *** Fields to be uncommented for Excel metadata lookup
	--, '<td>' + ISNULL(+ '<a href="#'+ REFTBL.nmRefTable + '">' + REFTBL.nmRefTable + '</a></td>','</td>') -- Delete when Extended Properties scripts are complete
	--, '<td>' + @EntityName + '</td></tr>' -- Delete when Extended Properties scripts are complete

-- *** Fields to be discussed for inclusion
	--, '<td>' + CAST(ISNULL(IDXCOL.index_column_id, 0)AS VARCHAR(20)) + '</td>'
	--, '<td>' + ISNULL(CAST(REFTBL.isFKey AS VARCHAR(5)),'N') + '</td>'
	--, '<td>' + CAST(CAST(ALLCOL.precision AS INT) AS VARCHAR(20)) + '</td>',
	--, '<td>' + CAST(CAST(ALLCOL.scale AS INT) AS VARCHAR(20)) + '</td>',
	--, '<td>' + CAST(ALLCOL.is_computed AS VARCHAR(20)) + '</td>'
	--, '<td>' + CAST(ALLCOL.is_identity AS VARCHAR(20)) + '</td>'




 .tblcount, .vwscount, .fnccount, .spcount
	{font-size: 12px; font-style: italic; text-align: right;}



<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/r/dt/jq-2.1.4,jszip-2.5.0,pdfmake-0.1.18,dt-1.10.9,af-2.0.0,b-1.0.3,b-colvis-1.0.3,b-flash-1.0.3,b-html5-1.0.3,b-print-1.0.3,cr-1.2.0,fc-3.1.0,fh-3.0.0,kt-2.0.0,r-1.0.7,rr-1.0.0,sc-1.3.0,se-1.0.1/datatables.min.css"/>
<script type="text/javascript" src="https://cdn.datatables.net/r/dt/jq-2.1.4,jszip-2.5.0,pdfmake-0.1.18,dt-1.10.9,af-2.0.0,b-1.0.3,b-colvis-1.0.3,b-flash-1.0.3,b-html5-1.0.3,b-print-1.0.3,cr-1.2.0,fc-3.1.0,fh-3.0.0,kt-2.0.0,r-1.0.7,rr-1.0.0,sc-1.3.0,se-1.0.1/datatables.min.js"></script>


--*/