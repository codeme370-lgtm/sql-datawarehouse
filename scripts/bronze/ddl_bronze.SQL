use master;
Go

IF EXISTS (SELECT 1 FROM sys.databases where name='DataWarehouse')
BEGIN
     ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
     DROP DATABASE DataWarehouse;
END

GO

create database DataWarehouse;
GO

use DataWarehouse;
GO

create schema bronze;
Go
create schema silver;
Go
create schema gold;

IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
   DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_material_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_data DATE
);
IF OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL
   DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

IF OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL
   DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

IF OBJECT_ID ('bronze.erp_LOC_A101','U') IS NOT NULL
   DROP TABLE bronze.erp_LOC_A101;
CREATE TABLE bronze.erp_LOC_A101(
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
);

IF OBJECT_ID ('bronze.erp_PX_CAT_G1V2','U') IS NOT NULL
   DROP TABLE bronze.erp_PX_CAT_G1V2;
CREATE TABLE bronze.erp_PX_CAT_G1V2(
    id  NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_CUST_AZ12','U') IS NOT NULL
   DROP TABLE bronze.erp_CUST_AZ12;
CREATE TABLE bronze.erp_CUST_AZ12(
    cid NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50),
);


--Creating a store procedure
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
     DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
     BEGIN TRY
            set @batch_start_time = GETDATE();
            print '===================================================================';
            print 'Loading The Bronze Data';
            print '===================================================================';

            print'---------------------------------------------------------------------';
            print 'Loading the Customer Information Data';
            print'---------------------------------------------------------------------';
            SET @start_time = GETDATE();
            TRUNCATE TABLE bronze.crm_cust_info;
            BULK INSERT bronze.crm_cust_info
            FROM 'C:\Users\KA\Desktop\DATAWAREHOUSE\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
            WITH (
                 FIRSTROW=2,
                 FIELDTERMINATOR= ',',
                 TABLOCK
            );
            SET @end_time = GETDATE();
            PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR) + ' seconds';

            --SELECT * FROM bronze.crm_cust_info;

            --SELECT COUNT (*) FROM bronze.crm_cust_info;
            print'---------------------------------------------------------------------';
            print 'Loading the Product Information Data';
            print'---------------------------------------------------------------------';
            set @start_time= GETDATE();
            TRUNCATE TABLE bronze.crm_prd_info;
            BULK INSERT bronze.crm_prd_info
            FROM 'C:\Users\KA\Desktop\DATAWAREHOUSE\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
            WITH (
               FIRSTROW=2,
               FIELDTERMINATOR=',',
               TABLOCK
            );
            set @end_time = GETDATE();
            print '>> Load Duration: ' + cast(datediff(second, @start_time,@end_time) AS NVARCHAR) + ' seconds'
            --select * from bronze.crm_prd_info;
            --select count (*) from bronze.crm_prd_info;
            print'---------------------------------------------------------------------';
            print 'Loading the Sales Details Data';
            print'---------------------------------------------------------------------';
            set @start_time = GETDATE();
            truncate table bronze.crm_sales_details;
            bulk insert bronze.crm_sales_details
            from 'C:\Users\KA\Desktop\DATAWAREHOUSE\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
            with (
               firstrow=2,
               fieldterminator=',',
               tablock
            );
            set @end_time = GETDATE();
            print '>> Load Duration: ' + cast(datediff(second,@start_time,@end_time) as NVARCHAR) + 'seconds';

            --select * from bronze.crm_sales_details;

            print'---------------------------------------------------------------------';
            print 'Loading the Customer Information Data';
            print'---------------------------------------------------------------------';

            set @start_time=GETDATE();
            truncate table bronze.erp_CUST_AZ12;
            bulk insert bronze.erp_CUST_AZ12
            from 'C:\Users\KA\Desktop\DATAWAREHOUSE\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
            with (
                firstrow=2,
                fieldterminator=',',
                tablock
            );
            set @end_time = GETDATE();
            print '>> Load Duration: ' + cast(datediff(second, @start_time,@end_time) AS NVARCHAR) + ' SECONDS';
            --select * from bronze.erp_CUST_AZ12;


            set @start_time=GETDATE();
            truncate table bronze.erp_LOC_A101;
            bulk insert bronze.erp_LOC_A101
            from 'C:\Users\KA\Desktop\DATAWAREHOUSE\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
            with (
                firstrow=2,
                fieldterminator=',',
                tablock
            );
            set @end_time = GETDATE();
            print '>> Load Duration: ' + cast(datediff(second, @start_time,@end_time) AS NVARCHAR) + ' SECONDS';
            --select * from bronze.erp_LOC_A101;

            set @start_time=GETDATE();
            truncate table bronze.erp_PX_CAT_G1V2;
            bulk insert bronze.erp_PX_CAT_G1V2
            from 'C:\Users\KA\Desktop\DATAWAREHOUSE\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
            with (
                firstrow=2,
                fieldterminator=',',
                tablock
            );
            set @end_time = GETDATE();
            print '>> Load Duration: ' + cast(datediff(second, @start_time,@end_time) AS NVARCHAR) + ' SECONDS';
            --select * from bronze.erp_PX_CAT_G1V2;
            set @batch_end_time = GETDATE();
            print '>> Load Duration: ' + cast(datediff(second, @batch_start_time,@batch_end_time) AS NVARCHAR) + ' SECONDS';
   END TRY
   BEGIN CATCH
   PRINT '=============================================================================';
   PRINT 'ERROR OCCURED DURING THE LOADING OF THE BRONZE LAYER';
   PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
   PRINT 'ERROR MESSAGE' + CAST (ERROR_NUMBER() AS NVARCHAR);
   PRINT 'ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
   PRINT '=============================================================================';
   END CATCH
END;

EXEC bronze.load_bronze;

