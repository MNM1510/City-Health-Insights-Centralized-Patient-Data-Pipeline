-- ========================================================
-- MASTER ETL SCRIPT: Complete Healthcare Data Pipeline
-- ========================================================
IF OBJECT_ID('dbo.sp_RunMasterETL', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RunMasterETL;
GO

CREATE PROCEDURE dbo.sp_RunMasterETL
AS
BEGIN
    SET NOCOUNT ON;

    -- ========================================================
    -- STEP 1: EXECUTE ALL STORED PROCEDURES
    -- ========================================================
    PRINT 'Loading data from staging to final tables...';
    EXEC healthcare.sp_LoadPatients;
    PRINT '✅ Patients data loaded.';
    EXEC healthcare.sp_LoadDoctors;
    PRINT '✅ Doctors data loaded.';
    EXEC healthcare.sp_LoadAppointments;
    PRINT '✅ Appointments data loaded.';
    EXEC healthcare.sp_LoadMedications;
    PRINT '✅ Medications data loaded.';
    EXEC healthcare.sp_LoadMedicalReadings;
    PRINT '✅ Medical_Readings data loaded.';
    EXEC healthcare.sp_LoadSystemAlerts;
    PRINT '✅ System_Alerts data loaded.';
    EXEC healthcare.sp_LoadServiceProviders;
    PRINT '✅ Service_Providers data loaded.';
    EXEC healthcare.sp_LoadDiseaseSpeciality;
    PRINT '✅ Disease_Speciality data loaded.';

    -- ========================================================
    -- STEP 2: CREATE PERFORMANCE INDEXES (Only if they don't exist)
    -- ========================================================
    PRINT 'Creating performance indexes...';

    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Appointments_PatientDate' AND object_id = OBJECT_ID('healthcare.Appointments'))
        CREATE INDEX IX_Appointments_PatientDate ON healthcare.Appointments(patient_id, appointment_date);
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MedicalReadings_PatientTime' AND object_id = OBJECT_ID('healthcare.Medical_Readings'))
        CREATE INDEX IX_MedicalReadings_PatientTime ON healthcare.Medical_Readings(patient_id, reading_timestamp);
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Medications_PatientDate' AND object_id = OBJECT_ID('healthcare.Medications'))
        CREATE INDEX IX_Medications_PatientDate ON healthcare.Medications(patient_id, start_date);
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SystemAlerts_PatientSeverity' AND object_id = OBJECT_ID('healthcare.System_Alerts'))
        CREATE INDEX IX_SystemAlerts_PatientSeverity ON healthcare.System_Alerts(patient_id, severity);
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Patients_RegistrationDate' AND object_id = OBJECT_ID('healthcare.Patients'))
        CREATE INDEX IX_Patients_RegistrationDate ON healthcare.Patients(registration_date);

    PRINT '✅ Performance indexes created/verified.';

    -- ========================================================
    -- STEP 3: ADD PRIMARY KEYS (Only if they don't exist)
    -- ========================================================
    PRINT 'Checking and adding primary keys...';

    -- Function to check if primary key exists
    IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = 'Patients' AND schema_id = SCHEMA_ID('healthcare'))
        ALTER TABLE healthcare.Patients ADD PRIMARY KEY NONCLUSTERED (patient_id) NOT ENFORCED;
    ELSE
        PRINT '   ✅ Patients primary key already exists';

    IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = 'Doctors' AND schema_id = SCHEMA_ID('healthcare'))
        ALTER TABLE healthcare.Doctors ADD PRIMARY KEY NONCLUSTERED (doctor_id) NOT ENFORCED;
    ELSE
        PRINT '   ✅ Doctors primary key already exists';

    IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = 'Appointments' AND schema_id = SCHEMA_ID('healthcare'))
        ALTER TABLE healthcare.Appointments ADD PRIMARY KEY NONCLUSTERED (appointment_id) NOT ENFORCED;
    ELSE
        PRINT '   ✅ Appointments primary key already exists';

    IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = 'Medications' AND schema_id = SCHEMA_ID('healthcare'))
        ALTER TABLE healthcare.Medications ADD PRIMARY KEY NONCLUSTERED (medication_id) NOT ENFORCED;
    ELSE
        PRINT '   ✅ Medications primary key already exists';

    IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = 'Medical_Readings' AND schema_id = SCHEMA_ID('healthcare'))
        ALTER TABLE healthcare.Medical_Readings ADD PRIMARY KEY NONCLUSTERED (reading_id) NOT ENFORCED;
    ELSE
        PRINT '   ✅ Medical_Readings primary key already exists';

    IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = 'System_Alerts' AND schema_id = SCHEMA_ID('healthcare'))
        ALTER TABLE healthcare.System_Alerts ADD PRIMARY KEY NONCLUSTERED (alert_id) NOT ENFORCED;
    ELSE
        PRINT '   ✅ System_Alerts primary key already exists';

    IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = 'Service_Providers' AND schema_id = SCHEMA_ID('healthcare'))
        ALTER TABLE healthcare.Service_Providers ADD PRIMARY KEY NONCLUSTERED (service_provider_id) NOT ENFORCED;
    ELSE
        PRINT '   ✅ Service_Providers primary key already exists';

    IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = 'Disease_Speciality' AND schema_id = SCHEMA_ID('healthcare'))
        ALTER TABLE healthcare.Disease_Speciality ADD PRIMARY KEY NONCLUSTERED (disease_id) NOT ENFORCED;
    ELSE
        PRINT '   ✅ Disease_Speciality primary key already exists';

    PRINT '✅ Primary keys checked/added.';

    -- ========================================================
    -- STEP 4: VERIFICATION QUERIES
    -- ========================================================
    PRINT '=== FINAL DATA VERIFICATION ===';

    -- Record Counts
    SELECT 
        'Patients' AS Table_Name, 
        COUNT(*) AS Record_Count 
    FROM healthcare.Patients
    UNION ALL
    SELECT 'Doctors', COUNT(*) FROM healthcare.Doctors
    UNION ALL
    SELECT 'Appointments', COUNT(*) FROM healthcare.Appointments
    UNION ALL
    SELECT 'Medications', COUNT(*) FROM healthcare.Medications
    UNION ALL
    SELECT 'Medical_Readings', COUNT(*) FROM healthcare.Medical_Readings
    UNION ALL
    SELECT 'System_Alerts', COUNT(*) FROM healthcare.System_Alerts
    UNION ALL
    SELECT 'Service_Providers', COUNT(*) FROM healthcare.Service_Providers
    UNION ALL
    SELECT 'Disease_Speciality', COUNT(*) FROM healthcare.Disease_Speciality;

    -- ========================================================
    -- STEP 5: UPDATE PROJECT METADATA
    -- ========================================================
    PRINT 'Updating project metadata...';

    -- Create metadata table only if it doesn't exist
    IF OBJECT_ID('audit.project_metadata', 'U') IS NULL
    BEGIN
        CREATE TABLE audit.project_metadata (
            component_name VARCHAR(100),
            version VARCHAR(20),
            last_updated DATETIME2,
            description VARCHAR(500)
        );
        PRINT '   ✅ Metadata table created';
    END

    -- Clear existing metadata and insert new
    DELETE FROM audit.project_metadata;

    INSERT INTO audit.project_metadata (component_name, version, last_updated, description)
    SELECT 'ETL Pipeline', '1.0', GETDATE(), 'Complete healthcare data pipeline'
    UNION ALL
    SELECT 'Data Quality', '1.0', GETDATE(), 'Automated data quality checks'
    UNION ALL
    SELECT 'Analytics Views', '1.0', GETDATE(), 'Business intelligence views';

    PRINT '✅ Project metadata updated.';
    PRINT '🚀 MASTER ETL PIPELINE COMPLETED SUCCESSFULLY!';
END;
GO

-- ========================================================
-- EXECUTE THE MASTER ETL PIPELINE
-- ========================================================
PRINT 'Executing Master ETL Pipeline...';
EXEC dbo.sp_RunMasterETL;
PRINT 'Master ETL Pipeline execution completed!';