-- **************************************************
-- *** Sandbox for Eden MDS Data Dictionary
-- *** Use to determine table purpose
-- **************************************************

USE [EdenMDS-PRD]

SELECT DISTINCT TOP (1) RegCD						FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) LAStaticName				FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) [Works Name]				FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) StationName					FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) MonitoredEntityCode			FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) RBD							FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) RBDStaticName				FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) StationLocalCode			FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) [Application Emission ID]	FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) [GIS Unique ID]				FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) [Emission Type]				FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) CORA_ID						FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) Easting						FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) Northing					FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) SnappedEasting				FROM [EdenMDS-PRD].dbo.UWWDischargeStations
SELECT DISTINCT TOP (1) SnappedNorthing				FROM [EdenMDS-PRD].dbo.UWWDischargeStations

SELECT DISTINCT TOP (1) * FROM [EdenMDS-PRD].dbo.UWWDischargeStations


-- *** Move to 'TABLES-RELATED'
--SELECT DISTINCT * FROM tblDWCompliance_dwc
SELECT DISTINCT * FROM tblInstallation_ins INS
LEFT JOIN tblLimsInstallations_lim LIM ON LIM.InstallationId_lim = INS.InstallationId_INS

--SELECT DISTINCT * FROM tblPosition_pos
--SELECT DISTINCT * FROM tblSection_set

SELECT DISTINCT TOP (100) CMUID_cmu, * FROM tblApprovalSample_aps
SELECT DISTINCT TOP (100) CMUID_cmu, * FROM tblSample_sam
SELECT DISTINCT TOP (100) CMUID_cmu, * FROM tblSampleHistory_sht
 
-- *** Investigate
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.tblLogins_log -- Empty
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.dwSchemes2009 -- SELECT * FROM tblMonitoredEntity_men WHERE NationalCode_men = '0100PRI2015'
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.CWMonitoredEntities
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.FCT_Station
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.FCTCoordinates170214 -- WHERE Eden_StationCode = 'RS15N012140'
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.LWMonitoredEntities -- Lake Water Monitored Entities  
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.RWMonitoredEntities -- River Water Monitored Entities 
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.TWMonitoredEntities -- Transitional Water Monitored Entities 
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.UWWDischargeStations -- Urban Waste Water Discharge Stations
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.UWWInfluentEffluentLinkages -- Urban Waste Water Influent Effluent Linkages
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.UWWInfluentStations -- Urban Waste Water Influent Stations
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.UWWMonitoredEntities -- Urban Waste Water Monitored Entities
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.WFDStationAndWaterBodyCodes2711


-- *** Backups
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.tblEnvironmentalParameter_enp_bkup29092014
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.tblParameterMeasurementUnitMatrix_pmx_bkup13102014
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.tblParameterMeasurementUnitMatrix_pmx_bkup29092014
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.tblStation_sta130214
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.tblStation_sta170214
SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.tblUserOrganisationAccess_uoa_bkup


SELECT DISTINCT TOP (10) * FROM [EdenMDS-PRD].dbo.tblSchemeType_sct


-- *** Fields sent to ESP



SELECT DISTINCT CMUID_cmu					 FROM [EdenMDS-PRD].dbo.tblApprovalSample_aps
SELECT DISTINCT SubnetID_aps				 FROM [EdenMDS-PRD].dbo.tblApprovalSample_aps
SELECT DISTINCT CrmOptionSetValue_cnt	 FROM [EdenMDS-PRD].dbo.tblCounty_cnt
SELECT DISTINCT Symbol_enp					 FROM [EdenMDS-PRD].dbo.tblEnvironmentalParameter_enp
SELECT DISTINCT AutoAnalisysName_enp	 FROM [EdenMDS-PRD].dbo.tblEnvironmentalParameter_enp
SELECT DISTINCT Mandatory_nod				 FROM [EdenMDS-PRD].dbo.tblNotificationDefinition_nod
SELECT DISTINCT AutoAnalysisName_ptr	 FROM [EdenMDS-PRD].dbo.tblParameterTranslation_ptr
SELECT DISTINCT CMUID_cmu					 FROM [EdenMDS-PRD].dbo.tblSample_sam
SELECT DISTINCT SubnetID_sam				 FROM [EdenMDS-PRD].dbo.tblSample_sam
SELECT DISTINCT CMUID_cmu					 FROM [EdenMDS-PRD].dbo.tblSampleHistory_sht
SELECT DISTINCT SubnetID_sht				 FROM [EdenMDS-PRD].dbo.tblSampleHistory_sht
SELECT DISTINCT IsUnique_slt				 FROM [EdenMDS-PRD].dbo.tblStationLinkType_slt
SELECT DISTINCT Mandatory_slt				 FROM [EdenMDS-PRD].dbo.tblStationLinkType_slt
SELECT DISTINCT Severity_err				 FROM [EdenMDS-PRD].dbo.tblValidationError_err
SELECT DISTINCT InstallationID_ins		 FROM [EdenMDS-PRD].dbo.tblInstallation_ins
SELECT DISTINCT InstallationTypeID_ins	 FROM [EdenMDS-PRD].dbo.tblInstallation_ins
SELECT DISTINCT BaseURL_ins				 FROM [EdenMDS-PRD].dbo.tblInstallation_ins
SELECT DISTINCT LastReloaded_ins			 FROM [EdenMDS-PRD].dbo.tblInstallation_ins
SELECT DISTINCT Username_log				 FROM [EdenMDS-PRD].dbo.tblLogins_log
SELECT DISTINCT fromIP_log					 FROM [EdenMDS-PRD].dbo.tblLogins_log
SELECT DISTINCT LoginDate_log				 FROM [EdenMDS-PRD].dbo.tblLogins_log
SELECT DISTINCT Successful_log			 FROM [EdenMDS-PRD].dbo.tblLogins_log
SELECT DISTINCT CrmOptionSetValue_pos	 FROM [EdenMDS-PRD].dbo.tblPosition_pos
SELECT DISTINCT CrmOptionSetValue_set	 FROM [EdenMDS-PRD].dbo.tblSection_set
--SELECT DISTINCT LowerRange_dwc			 FROM [EdenMDS-PRD].dbo.tblDWCompliance_dwc
--SELECT DISTINCT UpperRange_dwc			 FROM [EdenMDS-PRD].dbo.tblDWCompliance_dwc
--SELECT DISTINCT AuditRequired_dwc		 FROM [EdenMDS-PRD].dbo.tblDWCompliance_dwc
--SELECT DISTINCT CheckRequired_dwc		 FROM [EdenMDS-PRD].dbo.tblDWCompliance_dwc
--SELECT DISTINCT AuditThreshold_dwc		 FROM [EdenMDS-PRD].dbo.tblDWCompliance_dwc
--SELECT DISTINCT CheckThreshold_dwc		 FROM [EdenMDS-PRD].dbo.tblDWCompliance_dwc
--SELECT DISTINCT AuditIncrease_dwc		 FROM [EdenMDS-PRD].dbo.tblDWCompliance_dwc
--SELECT DISTINCT CheckIncrease_dwc		 FROM [EdenMDS-PRD].dbo.tblDWCompliance_dwc




-- ******************
-- Views
SELECT * FROM		INFORMATION_SCHEMA.VIEWS
WHERE		TABLE_NAME	= 'vwDWMonitoringShortfall'


SELECT 
TABLE_CATALOG 
, TABLE_SCHEMA
, TABLE_NAME
, VIEW_DEFINITION
, CHECK_OPTION
, IS_UPDATABLE
FROM  INFORMATION_SCHEMA.VIEWS



/*
SELECT DISTINCT * FROM tblMeasurement_mea 
WHERE	LimitOfQuantification_mea IS NOT NULL
AND		ConfidenceInterval_mea <> ''

SELECT TOP 50 * FROM tblUserInOrganisation_uio
WHERE UserID_Usr = '1179'
SELECT * FROM tblUser_usr WHERE UserID_usr = '1148'

SELECT * FROM tblRoleDefinition_rld

SELECT DISTINCT State_uld FROM tblUpload_uld ORDER BY State_uld

SELECT TOP 50 * FROM tblUser_usr WHERE UserCrmID_usr IS NOT NULL

SELECT DISTINCT Active_usr FROM tblUser_usr

SELECT * FROM tblUser_usr WHERE UserID_usr = '95'

*/








/*


SELECT * FROM tblApprovalSample_aps
ORDER BY LastUpdateDate_apm DESC

SELECT TOP (100) * FROM tblNotification_not WHERE Attachment_not IS NOT NULL

SELECT TOP (100) TBL.*, STD.* 
FROM		tblNotificationDefinition_nod	TBL
LEFT JOIN	tblStringDefinition_std			STD	ON	STD.StringID_stg = TBL.Name_stg

WHERE Mandatory_nod = '1'

SELECT DISTINCT UrlTemplate_nod FROM tblNotificationDefinition_nod WHERE UrlTemplate_nod IS NOT NULL

SELECT TOP (10) * FROM tblOrganisationAccessRequest_oar OAR
INNER JOIN tblUser_usr	USR ON USR.UserID_usr = OAR.RequestedBy_usr
INNER JOIN tblMonitoredEntityType_met MET ON MET.MonitoredEntityTypeID_met = OAR.DataType_met

SELECT MET.Name_met, AUP.StaticName_aup, STD1.Content_std AS [Giving], STD2.Content_std AS [Receiving]
FROM tblOrganisationPermission_per		PER
INNER JOIN	tblMonitoredEntityType_met	MET		ON	MET.MonitoredEntityTypeID_met	= PER.DataType_gla
INNER JOIN	tblAuthorizationPurpose_aup	AUP		ON	AUP.AuthorizationPurposeID_aup	= PER.AuthorizationPurposeID_aup
INNER JOIN	tblOrganisation_org			ORG1	ON	ORG1.OrganisationId_org			= PER.GivingOrganisationId_gen
INNER JOIN	tblStringDefinition_std		STD1	ON	STD1.StringID_stg				= ORG1.Name_stg
INNER JOIN	tblOrganisation_org			ORG2	ON	ORG2.OrganisationId_org			= PER.ReceivingOrganisationId_gen
INNER JOIN	tblStringDefinition_std		STD2	ON	STD2.StringID_stg				= ORG2.Name_stg

SELECT TOP (10) * 
FROM		tblOrganisation_org		ORG
INNER JOIN	tblStringDefinition_std	STD	ON	STD.StringID_stg	= ORG.Name_stg


SELECT TOP (10) * 
FROM		tblOrganisation_org		ORG
INNER JOIN	tblStringDefinition_std	STD	ON	STD.StringID_stg	= ORG.Name_stg
INNER JOIN	tblOrganisationType_ort	ORT ON	ORT.OrganisationTypeId_ort	= ORG.OrganisationTypeId_ort

SELECT DISTINCT STD1.Content_std, * 
FROM		tblOrganisation_org		ORG
INNER JOIN	tblStringDefinition_std	STD1	ON	STD1.StringID_stg			= ORG.Name_stg
INNER JOIN	tblOrganisationType_ort	ORT		ON	ORT.OrganisationTypeId_ort	= ORG.OrganisationTypeId_ort
INNER JOIN	tblGeoEntity_gen		GEN		ON	GEN.ObjectID_gen			= ORG.OrganisationId_org
INNER JOIN	tblGeoLayer_gla			GLA		ON	GLA.LayerID_gla				= GEN.LayerID_gla
INNER JOIN	tblGeoLayerType_glt		GLT		ON	GLT.LayerTypeID_glt			= GLA.LayerTypeID_glt
INNER JOIN	tblStringDefinition_std	STD2	ON	STD2.StringID_stg			= GLT.Name_stg



SELECT DISTINCT * FROM tblOrganisation_org


SELECT TOP (1000) * FROM sys.objects
WHERE type_desc = 'USER_TABLE'

-- ****************************************************************************************************
-- *** Sandbox Miscellaneous



-- *************************************************************************************
-- *** Source: http://www.tech-recipes.com/rx/24343/sql-server-useful-metadata-queries/

-- Find the list of tables created in the given database.
/*
SELECT *
FROM	INFORMATION_SCHEMA.TABLES
WHERE	TABLE_TYPE = 'BASE TABLE';

-- List the views created in the given database.

SELECT *
FROM	INFORMATION_SCHEMA.TABLES
WHERE	TABLE_TYPE = 'VIEW'
ORDER BY TABLE_NAME;

-- List the column names, data types, whether the column allows null or not, and the maximum allowed characters in the row.

SELECT
		 column_name
	  , data_type
	  , is_nullable
	  , character_maximum_length
FROM information_schema.columns
WHERE table_name = 'tblUser_usr'

;

-- Show the table name, object id, table creation date, and the last table modified time.

SELECT
		 name
	  , object_id
	  , create_date
	  , modify_date
FROM sys.tables

;

-- List the created indexes for a table with the column names is frequently required. In this query a.name is the table name for which you are listing the indexes. By removing the a.name condition, you can see all the created indexes in your database.

SELECT
		 a.name table_name
	  , b.name index_name
	  , d.name column_name
FROM sys.tables a,
	  sys.indexes b,
	  sys.index_columns c,
	  sys.columns d
WHERE a.object_id = b.object_id
  AND b.object_id = c.object_id
  AND b.index_id = c.index_id
  AND c.object_id = d.object_id
  AND c.column_id = d.column_id
  AND a.name = 'tblUser_usr'

;

-- List the defined constraints on tables with the column names. In thie example, we can see the emp table’s unique, primary or foreign key constraints.

SELECT
		 a.table_name
	  , a.constraint_name
	  , b.column_name
	  , a.constraint_type
FROM information_schema.table_constraints a,
	  information_schema.key_column_usage b
WHERE a.table_name = 'EMP'
  AND a.table_name = b.table_name
  AND a.table_schema = b.table_schema
  AND a.constraint_name = b.constraint_name

;

-- To write a ‘select count(1) from table_name’ query for each table in the database

SELECT
		 'SELECT COUNT(1) FROM [' + table_name + '];'
FROM information_schema.tables;


SELECT    TBLCNST.table_name
          , TBLCNST.constraint_name
          , KEYCOLU.column_name
          , TBLCNST.constraint_type
FROM      information_schema.table_constraints	TBLCNST,
          information_schema.key_column_usage	KEYCOLU
WHERE     TBLCNST.table_name			= 'tblUser_usr'
AND       TBLCNST.table_name			= KEYCOLU.table_name
AND       TBLCNST.table_schema		= KEYCOLU.table_schema
AND       TBLCNST.constraint_name	= KEYCOLU.constraint_name;

--*/

/*

/*
SELECT DISTINCT SCHEMA_NAME(schema_id) FROM sys.objects

DECLARE @body VARCHAR(MAX)

SET @body = CAST(
	 (SELECT
				td = dbtable + '</td><td>' + CAST(entities AS VARCHAR(30)) + '</td><td>' + CAST(rows AS VARCHAR(30))
	  FROM
			 (
			  SELECT
						dbtable = OBJECT_NAME(object_id)
					 , entities = COUNT(DISTINCT name)
					 , rows = COUNT(*)
			  FROM sys.columns
			  GROUP BY
						  OBJECT_NAME(object_id)
			 ) AS d
	  FOR
	  XML PATH
			('tr'
			), TYPE
	 ) AS VARCHAR(MAX))

SET @body = '<table cellpadding = "2" cellspacing = "2" border = "1">' 
				+ '<tr><th>Database Table</th><th>Entity Count</th><th>Total Rows</th></tr>' 
				+ REPLACE(REPLACE(@body, '&lt;', '<'), '&gt;', '>') 
				+ '<table>'

PRINT @body

*/

--*/



/*

SELECT TOP 1000 [TABLE_CATALOG]
      ,[TABLE_SCHEMA]
      ,[TABLE_NAME]
      ,[COLUMN_NAME]
      ,[ORDINAL_POSITION]
      ,[COLUMN_DEFAULT]
      ,[IS_NULLABLE]
      ,[DATA_TYPE]
      ,[CHARACTER_MAXIMUM_LENGTH]
      ,[CHARACTER_OCTET_LENGTH]
      ,[NUMERIC_PRECISION]
      ,[NUMERIC_PRECISION_RADIX]
      ,[NUMERIC_SCALE]
      ,[DATETIME_PRECISION]
      ,[CHARACTER_SET_CATALOG]
      ,[CHARACTER_SET_SCHEMA]
      ,[CHARACTER_SET_NAME]
      ,[COLLATION_CATALOG]
      ,[COLLATION_SCHEMA]
      ,[COLLATION_NAME]
      ,[DOMAIN_CATALOG]
      ,[DOMAIN_SCHEMA]
      ,[DOMAIN_NAME]
  FROM [EdenMDS-TST].[INFORMATION_SCHEMA].[COLUMNS]


--*/


-- *** Fields to be discussed for inclusion
	 --<th>Table Name (TEMP Field)</th>
	 --<th>IDX</th>
	 --<th>Numeric Precision</th>
	 --<th>Numeric Scale</th>
	 --<th>Computed</th>
	 --<th>Identity</th>

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

--PRINT '		 <tr>'	  
--PRINT	  	 '		<td colspan = "3">' 
--				EXEC sp_depends '@EntityName' ; 
--PRINT	  '</i></td>' 
--PRINT	 ' </tr>' 


--EXEC sp_depends @EntityName = N'[ObjDataampleAuthorization_aut]' ;

-- *** Style 1 CSS (Blue/Orange)

--PRINT '	body	{background-color: #FFFFFF;}' -- Style 1
--PRINT '	th		{background: #BFEFFF; text-align: left;}' -- Style 1
--PRINT '	tr		{background: #FDFCDC;}' -- Style 1
--PRINT '	tr.entitydata {border: 1px solid #A5A5A5; padding: 4px;}' -- Commented before style change
--PRINT '	td.entitydata {border: 1px solid #A5A5A5; padding: 4px;}' -- Commented before style change
--PRINT '	tfoot tr.footheader_dep_table	 {background: #BFEFFF; text-align: left; font-weight: bold;}' -- Style 1
--PRINT '	table.entitytoc {width: auto; border:1px solid #A5A5A5; padding: 3px;}'
--PRINT '	table.entitytoc {font-size: 12px;}' -- Style 2
--PRINT '	tr.entitytoctr	{width: auto; border:1px dotted #161A1D; padding: 3px;}'
--PRINT '	td.entitytoctd	{width: auto; border:1px dotted #161A1D; padding: 3px;}'
--PRINT '	div#entityhasfk	{border:1px dotted #161A1D; padding: 4px; display: inline-block;}' -- Style 1
--PRINT '	table	{width:100%;}' -- Commented before style change
--PRINT '	table#entityhasfk	{width: auto; border:1px dotted #161A1D; padding: 4px;}' -- Commented before style change
--PRINT '	table#entityhasfk td, tr {border: 0}' -- Commented before style change
--PRINT '	table#entitynofk	{width: auto; border:1px dotted #161A1D; padding: 4px;}' -- Commented before style change
--PRINT '	table#entitynofk td, tr {border: 0}' -- Commented before style change
--PRINT '	.fixed			{top:0;  position:fixed;  width:auto;  display:none;  border:none;}' -- Update Javascript
--PRINT '	.scrollMore	{margin-top:600px;}' -- Update Javascript
--PRINT '	.up					{cursor:pointer;}' -- Update Javascript
-- #entitynofk		  {border: 1px dotted #161A1D; padding: 4px; display: inline-block;}




/* =CONCATENATE("EXEC sys.sp_updateextendedproperty @name  = N'MS_Description', @value = N'",B16,"', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'",J16,"', @level2type = N'COLUMN',@level2name = N'",A16,"'; ")*/



--*/

