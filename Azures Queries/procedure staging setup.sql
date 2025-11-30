-- ========================================================
-- SIMPLE STORED PROCEDURE: Setup and Load Staging Tables
-- ========================================================
IF OBJECT_ID('staging.sp_LoadStagingData', 'P') IS NOT NULL
    DROP PROCEDURE staging.sp_LoadStagingData;
GO

CREATE PROCEDURE staging.sp_LoadStagingData
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Starting staging data load...';

    -- Create staging schema if not exists
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'staging')
        EXEC('CREATE SCHEMA staging');

    -- Create staging tables
    IF OBJECT_ID('staging.Patients_Stg', 'U') IS NOT NULL 
        DROP TABLE staging.Patients_Stg;

    CREATE TABLE staging.Patients_Stg (
        patient_id VARCHAR(50),
        national_id VARCHAR(100),
        first_name VARCHAR(255),
        last_name VARCHAR(255),
        date_of_birth VARCHAR(50),
        gender VARCHAR(50),
        phone VARCHAR(50),
        address VARCHAR(1000),
        blood_type VARCHAR(50),
        allergies VARCHAR(1000),
        chronic_diseases VARCHAR(1000),
        emergency_contact_name VARCHAR(255),
        emergency_contact_phone VARCHAR(50),
        registration_date VARCHAR(50),
        is_active VARCHAR(20)
    );

    IF OBJECT_ID('staging.Doctors_Stg', 'U') IS NOT NULL 
        DROP TABLE staging.Doctors_Stg;

    CREATE TABLE staging.Doctors_Stg (
        doctor_id VARCHAR(50),
        national_id VARCHAR(100),
        first_name VARCHAR(255),
        last_name VARCHAR(255),
        specialization VARCHAR(255),
        license_number VARCHAR(100),
        phone VARCHAR(50),
        years_of_experience VARCHAR(20),
        consultation_fee VARCHAR(50),
        is_active VARCHAR(20),
        registration_date VARCHAR(50),
        service_provider_id INT
    );

    IF OBJECT_ID('staging.Appointments_Stg', 'U') IS NOT NULL 
        DROP TABLE staging.Appointments_Stg;

    CREATE TABLE staging.Appointments_Stg (
        appointment_id VARCHAR(50),
        patient_id VARCHAR(50),
        doctor_id VARCHAR(50),
        appointment_date VARCHAR(50),
        appointment_time VARCHAR(50),
        status VARCHAR(100),
        reason VARCHAR(1000),
        diagnosis VARCHAR(2000),
        prescription VARCHAR(2000),
        notes VARCHAR(2000),
        created_date VARCHAR(50),
        updated_date VARCHAR(50)
    );

    IF OBJECT_ID('staging.Medications_Stg', 'U') IS NOT NULL 
        DROP TABLE staging.Medications_Stg;

    CREATE TABLE staging.Medications_Stg (
        medication_id VARCHAR(50),
        appointment_id VARCHAR(50),
        patient_id VARCHAR(50),
        medication_name VARCHAR(255),
        dosage VARCHAR(100),
        frequency VARCHAR(100),
        duration VARCHAR(100),
        start_date VARCHAR(50),
        end_date VARCHAR(50),
        instructions VARCHAR(2000)
    );

    IF OBJECT_ID('staging.Medical_Readings_Stg', 'U') IS NOT NULL 
        DROP TABLE staging.Medical_Readings_Stg;

    CREATE TABLE staging.Medical_Readings_Stg (
        reading_id VARCHAR(50),
        patient_id VARCHAR(50),
        device_type VARCHAR(100),
        reading_value VARCHAR(50),
        unit VARCHAR(50),
        reading_timestamp VARCHAR(50),
        is_critical VARCHAR(20),
        alert_sent VARCHAR(20),
        notes VARCHAR(1000)
    );

    IF OBJECT_ID('staging.System_Alerts_Stg', 'U') IS NOT NULL 
        DROP TABLE staging.System_Alerts_Stg;

    CREATE TABLE staging.System_Alerts_Stg (
        alert_id VARCHAR(50),
        patient_id VARCHAR(50),
        doctor_id VARCHAR(50),
        alert_type VARCHAR(100),
        alert_message VARCHAR(2000),
        severity VARCHAR(50),
        is_read VARCHAR(20),
        created_date VARCHAR(50)
    );

    IF OBJECT_ID('staging.Disease_Speciality_Stg', 'U') IS NOT NULL 
        DROP TABLE staging.Disease_Speciality_Stg;

    CREATE TABLE staging.Disease_Speciality_Stg (
        disease VARCHAR(225),
        speciality VARCHAR(225)
    );

    IF OBJECT_ID('staging.Service_Providers_Stg', 'U') IS NOT NULL 
        DROP TABLE staging.Service_Providers_Stg;

    CREATE TABLE staging.Service_Providers_Stg (
        service_provider_id INT IDENTITY(1,1),
        governorate VARCHAR(200),
        city VARCHAR(200),
        service_provider_type VARCHAR(200),
        service_provider VARCHAR(500),
        specialty VARCHAR(200),
        address VARCHAR(1000),
        phone_1 VARCHAR(200),
        phone_2 VARCHAR(200)
    );

    PRINT 'Staging tables created. Loading data...';

    -- Load data from Azure Blob Storage
    COPY INTO staging.Patients_Stg 
    FROM 'https://cityhealth01.blob.core.windows.net/cityhealthcontainer/patients.csv'
    WITH (FIRSTROW = 2, CREDENTIAL = (IDENTITY = 'Shared Access Signature', SECRET = 'sv=2024-11-04&ss=bfqt&srt=co&sp=rwdlacupyx&se=2025-12-15T05:16:24Z&st=2025-11-27T21:01:24Z&spr=https&sig=uw8WKfMgr2J%2B7kf3JCOnGkQcs5O5sxny19ZY4US9Yok%3D'));

    COPY INTO staging.Appointments_Stg 
    FROM 'https://cityhealth01.blob.core.windows.net/cityhealthcontainer/appointments.csv'
    WITH (FIRSTROW = 2, CREDENTIAL = (IDENTITY = 'Shared Access Signature', SECRET = 'sv=2024-11-04&ss=bfqt&srt=co&sp=rwdlacupyx&se=2025-12-15T05:16:24Z&st=2025-11-27T21:01:24Z&spr=https&sig=uw8WKfMgr2J%2B7kf3JCOnGkQcs5O5sxny19ZY4US9Yok%3D'));

    COPY INTO staging.Disease_Speciality_Stg 
    FROM 'https://cityhealth01.blob.core.windows.net/cityhealthcontainer/disease_specialty.csv'
    WITH (FIRSTROW = 2, CREDENTIAL = (IDENTITY = 'Shared Access Signature', SECRET = 'sv=2024-11-04&ss=bfqt&srt=co&sp=rwdlacupyx&se=2025-12-15T05:16:24Z&st=2025-11-27T21:01:24Z&spr=https&sig=uw8WKfMgr2J%2B7kf3JCOnGkQcs5O5sxny19ZY4US9Yok%3D'));

    COPY INTO staging.Doctors_Stg 
    FROM 'https://cityhealth01.blob.core.windows.net/cityhealthcontainer/doctors.csv'
    WITH (FIRSTROW = 2, CREDENTIAL = (IDENTITY = 'Shared Access Signature', SECRET = 'sv=2024-11-04&ss=bfqt&srt=co&sp=rwdlacupyx&se=2025-12-15T05:16:24Z&st=2025-11-27T21:01:24Z&spr=https&sig=uw8WKfMgr2J%2B7kf3JCOnGkQcs5O5sxny19ZY4US9Yok%3D'));

    COPY INTO staging.Medical_Readings_Stg 
    FROM 'https://cityhealth01.blob.core.windows.net/cityhealthcontainer/medical_readings.csv'
    WITH (FIRSTROW = 2, CREDENTIAL = (IDENTITY = 'Shared Access Signature', SECRET = 'sv=2024-11-04&ss=bfqt&srt=co&sp=rwdlacupyx&se=2025-12-15T05:16:24Z&st=2025-11-27T21:01:24Z&spr=https&sig=uw8WKfMgr2J%2B7kf3JCOnGkQcs5O5sxny19ZY4US9Yok%3D'));

    COPY INTO staging.Medications_Stg 
    FROM 'https://cityhealth01.blob.core.windows.net/cityhealthcontainer/medications.csv'
    WITH (FIRSTROW = 2, CREDENTIAL = (IDENTITY = 'Shared Access Signature', SECRET = 'sv=2024-11-04&ss=bfqt&srt=co&sp=rwdlacupyx&se=2025-12-15T05:16:24Z&st=2025-11-27T21:01:24Z&spr=https&sig=uw8WKfMgr2J%2B7kf3JCOnGkQcs5O5sxny19ZY4US9Yok%3D'));

    COPY INTO staging.System_Alerts_Stg 
    FROM 'https://cityhealth01.blob.core.windows.net/cityhealthcontainer/system_alerts.csv'
    WITH (FIRSTROW = 2, CREDENTIAL = (IDENTITY = 'Shared Access Signature', SECRET = 'sv=2024-11-04&ss=bfqt&srt=co&sp=rwdlacupyx&se=2025-12-15T05:16:24Z&st=2025-11-27T21:01:24Z&spr=https&sig=uw8WKfMgr2J%2B7kf3JCOnGkQcs5O5sxny19ZY4US9Yok%3D'));

    COPY INTO staging.Service_Providers_Stg (governorate, city, service_provider_type, service_provider, specialty, address, phone_1, phone_2)
    FROM 'https://cityhealth01.blob.core.windows.net/cityhealthcontainer/service_providers.csv'
    WITH (FIRSTROW = 2, CREDENTIAL = (IDENTITY = 'Shared Access Signature', SECRET = 'sv=2024-11-04&ss=bfqt&srt=co&sp=rwdlacupyx&se=2025-12-15T05:16:24Z&st=2025-11-27T21:01:24Z&spr=https&sig=uw8WKfMgr2J%2B7kf3JCOnGkQcs5O5sxny19ZY4US9Yok%3D'), MAXERRORS = 100);

    -- Assign service provider IDs to doctors
    UPDATE staging.Doctors_Stg 
    SET service_provider_id = (ABS(CAST(doctor_id AS INT)) % 100) + 1;

    PRINT 'Data loaded successfully!';

    -- Show record counts
    SELECT 
        'Patients' AS Table_Name, COUNT(*) AS Row_Count FROM staging.Patients_Stg
        UNION ALL SELECT 'Appointments', COUNT(*) FROM staging.Appointments_Stg
        UNION ALL SELECT 'Doctors', COUNT(*) FROM staging.Doctors_Stg
        UNION ALL SELECT 'Medical_Readings', COUNT(*) FROM staging.Medical_Readings_Stg
        UNION ALL SELECT 'Medications', COUNT(*) FROM staging.Medications_Stg
        UNION ALL SELECT 'System_Alerts', COUNT(*) FROM staging.System_Alerts_Stg
        UNION ALL SELECT 'Service_Providers', COUNT(*) FROM staging.Service_Providers_Stg
        UNION ALL SELECT 'Disease_Speciality', COUNT(*) FROM staging.Disease_Speciality_Stg;

    PRINT 'Staging data load completed!';
END;
GO

-- ========================================================
-- Execute the procedure
-- ========================================================
PRINT 'Creating and executing staging procedure...';
EXEC staging.sp_LoadStagingData;
PRINT 'Procedure completed successfully!';

