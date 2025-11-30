-- ========================================================
-- COMPLETE SCHEMA SETUP AND STAGING DATA LOAD PROCEDURE
-- ========================================================
IF OBJECT_ID('dbo.sp_SetupSchemasAndLoadStaging', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SetupSchemasAndLoadStaging;
GO

CREATE PROCEDURE dbo.sp_SetupSchemasAndLoadStaging
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '🚀 STARTING COMPLETE SCHEMA SETUP AND STAGING DATA LOAD...';

    -- ========================================================
    -- STEP 1: CREATE ALL SCHEMAS
    -- ========================================================
    PRINT '1. Setting up schemas...';

    -- Create healthcare schema
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'healthcare')
    BEGIN
        EXEC('CREATE SCHEMA healthcare');
        PRINT '   ✅ healthcare schema created';
    END
    ELSE
    BEGIN
        PRINT '   ✅ healthcare schema already exists';
    END

    -- Create audit schema
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'audit')
    BEGIN
        EXEC('CREATE SCHEMA audit');
        PRINT '   ✅ audit schema created';
    END
    ELSE
    BEGIN
        PRINT '   ✅ audit schema already exists';
    END

    -- Create staging schema
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'staging')
    BEGIN
        EXEC('CREATE SCHEMA staging');
        PRINT '   ✅ staging schema created';
    END
    ELSE
    BEGIN
        PRINT '   ✅ staging schema already exists';
    END

    PRINT '   🎉 All schemas ready!';
END;
GO

-- Run the procedure
EXEC dbo.sp_SetupSchemas;
