
GO
EXECUTE sp_addlinkedserver @server = N'CloudAzure', @srvproduct = N'SQLDW', @provider = N'SQLNCLI11', @datasrc = N'yellow.database.windows.net', @provstr = N'Server=yellow.database.windows.net;Database=DataPlatform;Pooling=False', @catalog = N'DataPlatform';


GO
EXECUTE sp_serveroption @server = N'CloudAzure', @optname = N'lazy schema validation', @optvalue = N'TRUE';


GO
EXECUTE sp_serveroption @server = N'CloudAzure', @optname = N'rpc', @optvalue = N'TRUE';


GO
EXECUTE sp_serveroption @server = N'CloudAzure', @optname = N'rpc out', @optvalue = N'TRUE';


GO
EXECUTE sp_serveroption @server = N'CloudAzure', @optname = N'remote proc transaction promotion', @optvalue = N'FALSE';


GO
EXECUTE sp_addlinkedserver @server = N'SiteReviewUser', @srvproduct = N'SQLDW', @provider = N'SQLNCLI11', @datasrc = N'yellow.database.windows.net', @provstr = N'Server=yellow.database.windows.net;Database=SiteReviewUser;Pooling=False', @catalog = N'SiteReviewUser';


GO
EXECUTE sp_serveroption @server = N'SiteReviewUser', @optname = N'lazy schema validation', @optvalue = N'TRUE';


GO
EXECUTE sp_serveroption @server = N'SiteReviewUser', @optname = N'rpc', @optvalue = N'TRUE';


GO
EXECUTE sp_serveroption @server = N'SiteReviewUser', @optname = N'rpc out', @optvalue = N'TRUE';


GO
EXECUTE sp_serveroption @server = N'SiteReviewUser', @optname = N'remote proc transaction promotion', @optvalue = N'FALSE';


GO
EXECUTE sp_addlinkedserver @server = N'MyAzureDb1', @srvproduct = N'Azure SQL Db', @provider = N'SQLNCLI', @datasrc = N'yellow.database.windows.net,1433', @catalog = N'DataPlatform';

