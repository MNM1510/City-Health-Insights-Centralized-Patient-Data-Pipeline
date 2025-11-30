-- ========================================================
--  COMPREHENSIVE SCRIPT: Create Final Tables & Load Data
--  Azure Synapse Compatible Version
-- ========================================================

-- Create schema if it doesn't exist
IF SCHEMA_ID('healthcare') IS NULL
    EXEC('CREATE SCHEMA healthcare');

-- ========================================================
--  STEP 1: DROP AND RECREATE FINAL TABLES
-- ========================================================
PRINT 'Dropping and recreating final tables...';

-- Drop tables if they exist
IF OBJECT_ID('healthcare.Patients', 'U') IS NOT NULL
    DROP TABLE healthcare.Patients;

IF OBJECT_ID('healthcare.Doctors', 'U') IS NOT NULL
    DROP TABLE healthcare.Doctors;

IF OBJECT_ID('healthcare.Appointments', 'U') IS NOT NULL
    DROP TABLE healthcare.Appointments;

IF OBJECT_ID('healthcare.Medications', 'U') IS NOT NULL
    DROP TABLE healthcare.Medications;

IF OBJECT_ID('healthcare.Medical_Readings', 'U') IS NOT NULL
    DROP TABLE healthcare.Medical_Readings;

IF OBJECT_ID('healthcare.System_Alerts', 'U') IS NOT NULL
    DROP TABLE healthcare.System_Alerts;

IF OBJECT_ID('healthcare.Service_Providers', 'U') IS NOT NULL
    DROP TABLE healthcare.Service_Providers;

IF OBJECT_ID('healthcare.Disease_Speciality', 'U') IS NOT NULL
    DROP TABLE healthcare.Disease_Speciality;

-- ========================================================
--  STEP 2: CREATE FINAL TABLES (Azure Synapse Compatible)
-- ========================================================
PRINT 'Creating final tables...';

-- Patients
CREATE TABLE healthcare.Patients (
    patient_id INT NOT NULL,
    national_id VARCHAR(200),
    first_name VARCHAR(500),
    last_name VARCHAR(500),
    date_of_birth DATE,
    gender VARCHAR(100),
    phone VARCHAR(100),
    address VARCHAR(2000),
    blood_type VARCHAR(100),
    allergies VARCHAR(2000),
    chronic_diseases VARCHAR(2000),
    emergency_contact_name VARCHAR(500),
    emergency_contact_phone VARCHAR(100),
    registration_date DATETIME2,
    is_active BIT
);
PRINT '✅ Patients table created.';

-- Doctors
CREATE TABLE healthcare.Doctors (
    doctor_id INT NOT NULL,
    national_id VARCHAR(200),
    first_name VARCHAR(500),
    last_name VARCHAR(500),
    specialization VARCHAR(500),
    license_number VARCHAR(200),
    phone VARCHAR(100),
    years_of_experience INT,
    consultation_fee FLOAT,
    is_active BIT,
    registration_date DATETIME2,
    service_provider_id INT   
);
PRINT '✅ Doctors table created.';

-- Appointments
CREATE TABLE healthcare.Appointments (
    appointment_id INT NOT NULL,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    appointment_time TIME,
    status VARCHAR(200),
    reason VARCHAR(2000),
    diagnosis VARCHAR(4000),
    prescription VARCHAR(4000),
    notes VARCHAR(4000),
    created_date DATETIME2,
    updated_date DATETIME2
);
PRINT '✅ Appointments table created.';

-- Medications
CREATE TABLE healthcare.Medications (
    medication_id INT NOT NULL,
    appointment_id INT,
    patient_id INT,
    medication_name VARCHAR(500),
    dosage VARCHAR(200),
    frequency VARCHAR(200),
    duration VARCHAR(200),
    start_date DATE,
    end_date DATE,
    instructions VARCHAR(4000)
);
PRINT '✅ Medications table created.';

-- Medical_Readings
CREATE TABLE healthcare.Medical_Readings (
    reading_id INT NOT NULL,
    patient_id INT,
    device_type VARCHAR(200),
    reading_value FLOAT,
    unit VARCHAR(100),
    reading_timestamp DATETIME2,
    is_critical BIT,
    alert_sent BIT,
    notes VARCHAR(2000)
);
PRINT '✅ Medical_Readings table created.';

-- System_Alerts
CREATE TABLE healthcare.System_Alerts (
    alert_id INT NOT NULL,
    patient_id INT,
    doctor_id INT,
    alert_type VARCHAR(200),
    alert_message VARCHAR(4000),
    severity VARCHAR(100),
    is_read BIT,
    created_date DATETIME2
);
PRINT '✅ System_Alerts table created.';

-- Service_Providers
CREATE TABLE healthcare.Service_Providers (
    service_provider_id INT IDENTITY(1,1) NOT NULL,
    governorate VARCHAR(500),
    city VARCHAR(500),
    service_provider_type VARCHAR(500),
    service_provider VARCHAR(500),
    specialty VARCHAR(500),
    address VARCHAR(2000),
    phone_1 VARCHAR(100),
    phone_2 VARCHAR(100)
);
PRINT '✅ Service_Providers table created.';

-- Disease_Speciality
CREATE TABLE healthcare.Disease_Speciality (
    disease_id INT IDENTITY(1,1) NOT NULL,
    disease VARCHAR(225),
    speciality VARCHAR(225)
);
PRINT '✅ Disease_Speciality table created.';

-- ========================================================
--  STEP 3: DIRECT DATA LOADING (With Safe String Handling)
-- ========================================================

-- ========================================================
--  Stored Procedures for Loading Data from Staging to Final Tables
-- ========================================================

-- -------- Patients --------
IF OBJECT_ID('healthcare.sp_LoadPatients', 'P') IS NOT NULL
    DROP PROCEDURE healthcare.sp_LoadPatients;
GO

CREATE PROCEDURE healthcare.sp_LoadPatients
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO healthcare.Patients (
        patient_id, national_id, first_name, last_name, date_of_birth, gender, phone, address,
        blood_type, allergies, chronic_diseases, emergency_contact_name, emergency_contact_phone,
        registration_date, is_active
    )
    SELECT
        TRY_CAST(patient_id AS BIGINT), national_id, first_name, last_name,
        TRY_CAST(date_of_birth AS DATE), gender, phone, address,
        blood_type, allergies, chronic_diseases, emergency_contact_name, emergency_contact_phone,
        TRY_CAST(registration_date AS DATETIME),
        CASE WHEN is_active IN ('1','true') THEN 1 ELSE 0 END
    FROM staging.Patients_Stg;
END;
GO

-- -------- Doctors --------
IF OBJECT_ID('healthcare.sp_LoadDoctors', 'P') IS NOT NULL
    DROP PROCEDURE healthcare.sp_LoadDoctors;
GO

CREATE PROCEDURE healthcare.sp_LoadDoctors
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO healthcare.Doctors (
        doctor_id, national_id, first_name, last_name, specialization, license_number, phone,
        years_of_experience, consultation_fee, is_active, registration_date, service_provider_id 
    )
    SELECT
        TRY_CAST(doctor_id AS BIGINT), national_id, first_name, last_name, specialization,
        license_number, phone, TRY_CAST(years_of_experience AS INT),
        TRY_CAST(consultation_fee AS DECIMAL(10,2)),
        CASE WHEN is_active IN ('1','true') THEN 1 ELSE 0 END,
        TRY_CAST(registration_date AS DATETIME),
        TRY_CAST(service_provider_id AS INT)
    FROM staging.Doctors_Stg;
END;
GO

-- -------- Appointments --------
IF OBJECT_ID('healthcare.sp_LoadAppointments', 'P') IS NOT NULL
    DROP PROCEDURE healthcare.sp_LoadAppointments;
GO

CREATE PROCEDURE healthcare.sp_LoadAppointments
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO healthcare.Appointments (
        appointment_id, patient_id, doctor_id, appointment_date, appointment_time,
        status, reason, diagnosis, prescription, notes, created_date, updated_date
    )
    SELECT
        TRY_CAST(appointment_id AS BIGINT), TRY_CAST(patient_id AS BIGINT),
        TRY_CAST(doctor_id AS BIGINT), TRY_CAST(appointment_date AS DATE),
        TRY_CAST(appointment_time AS TIME), status, reason, diagnosis, prescription, notes,
        TRY_CAST(created_date AS DATETIME), TRY_CAST(updated_date AS DATETIME)
    FROM staging.Appointments_Stg;
END;
GO

-- -------- Medications --------
IF OBJECT_ID('healthcare.sp_LoadMedications', 'P') IS NOT NULL
    DROP PROCEDURE healthcare.sp_LoadMedications;
GO

CREATE PROCEDURE healthcare.sp_LoadMedications
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO healthcare.Medications (
        medication_id, appointment_id, patient_id, medication_name, dosage, frequency,
        duration, start_date, end_date, instructions
    )
    SELECT
        TRY_CAST(medication_id AS BIGINT), TRY_CAST(appointment_id AS BIGINT),
        TRY_CAST(patient_id AS BIGINT), medication_name, dosage, frequency, duration,
        TRY_CAST(start_date AS DATE), TRY_CAST(end_date AS DATE), instructions
    FROM staging.Medications_Stg;
END;
GO

-- -------- Medical_Readings --------
IF OBJECT_ID('healthcare.sp_LoadMedicalReadings', 'P') IS NOT NULL
    DROP PROCEDURE healthcare.sp_LoadMedicalReadings;
GO

CREATE PROCEDURE healthcare.sp_LoadMedicalReadings
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO healthcare.Medical_Readings (
        reading_id, patient_id, device_type, reading_value, unit, reading_timestamp,
        is_critical, alert_sent, notes
    )
    SELECT
        TRY_CAST(reading_id AS BIGINT), TRY_CAST(patient_id AS BIGINT),
        device_type, TRY_CAST(reading_value AS DECIMAL(10,2)), unit,
        TRY_CAST(reading_timestamp AS DATETIME),
        CASE WHEN is_critical IN ('1','true') THEN 1 ELSE 0 END,
        CASE WHEN alert_sent IN ('1','true') THEN 1 ELSE 0 END,
        notes
    FROM staging.Medical_Readings_Stg;
END;
GO

-- -------- System_Alerts --------
IF OBJECT_ID('healthcare.sp_LoadSystemAlerts', 'P') IS NOT NULL
    DROP PROCEDURE healthcare.sp_LoadSystemAlerts;
GO

CREATE PROCEDURE healthcare.sp_LoadSystemAlerts
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO healthcare.System_Alerts (
        alert_id, patient_id, doctor_id, alert_type, alert_message, severity, is_read, created_date
    )
    SELECT
        TRY_CAST(alert_id AS BIGINT), TRY_CAST(patient_id AS BIGINT),
        TRY_CAST(doctor_id AS BIGINT), alert_type, alert_message, severity,
        CASE WHEN is_read IN ('1','true') THEN 1 ELSE 0 END,
        TRY_CAST(created_date AS DATETIME)
    FROM staging.System_Alerts_Stg;
END;
GO

-- -------- Service_Providers --------
IF OBJECT_ID('healthcare.sp_LoadServiceProviders', 'P') IS NOT NULL
    DROP PROCEDURE healthcare.sp_LoadServiceProviders;
GO

CREATE PROCEDURE healthcare.sp_LoadServiceProviders
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO healthcare.Service_Providers (
        Governorate, City, Service_Provider_Type, Service_Provider, Specialty,
        Address, Phone_1, Phone_2
    )
    SELECT
        governorate, city, service_provider_type, service_provider,
        specialty, address, phone_1, phone_2
    FROM staging.Service_Providers_Stg;  
END;
GO

-- -------- Disease_Speciality --------
IF OBJECT_ID('healthcare.sp_LoadDiseaseSpeciality', 'P') IS NOT NULL
    DROP PROCEDURE healthcare.sp_LoadDiseaseSpeciality;
GO

CREATE PROCEDURE healthcare.sp_LoadDiseaseSpeciality
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO healthcare.Disease_Speciality (
        disease, speciality
    )
    SELECT
        disease, speciality
    FROM staging.Disease_Speciality_Stg;  
END;
GO

-- ========================================================
--  Execute All Stored Procedures
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
--  STEP 4: ADD PRIMARY KEYS TO EXISTING TABLES (Azure Synapse Compatible)
-- ========================================================
PRINT 'Adding primary keys to existing tables...';

-- Add primary keys directly to the existing tables
ALTER TABLE healthcare.Patients ADD PRIMARY KEY NONCLUSTERED (patient_id) NOT ENFORCED;
ALTER TABLE healthcare.Doctors ADD PRIMARY KEY NONCLUSTERED (doctor_id) NOT ENFORCED;
ALTER TABLE healthcare.Appointments ADD PRIMARY KEY NONCLUSTERED (appointment_id) NOT ENFORCED;
ALTER TABLE healthcare.Medications ADD PRIMARY KEY NONCLUSTERED (medication_id) NOT ENFORCED;
ALTER TABLE healthcare.Medical_Readings ADD PRIMARY KEY NONCLUSTERED (reading_id) NOT ENFORCED;
ALTER TABLE healthcare.System_Alerts ADD PRIMARY KEY NONCLUSTERED (alert_id) NOT ENFORCED;
ALTER TABLE healthcare.Service_Providers ADD PRIMARY KEY NONCLUSTERED (service_provider_id) NOT ENFORCED;
ALTER TABLE healthcare.Disease_Speciality ADD PRIMARY KEY NONCLUSTERED (disease_id) NOT ENFORCED;

PRINT '✅ Primary keys added to existing tables (NOT ENFORCED in Synapse).';


-- ========================================================
--  STEP 4: VERIFICATION QUERIES
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

-- Sample Data Preview
PRINT '=== SAMPLE DATA PREVIEW ===';
SELECT TOP 5 * FROM healthcare.Patients;
SELECT TOP 5 * FROM healthcare.Doctors;
SELECT TOP 5 * FROM healthcare.Appointments;
SELECT TOP 5 * FROM healthcare.Medications;
SELECT TOP 5 * FROM healthcare.Medical_Readings;
SELECT TOP 5 * FROM healthcare.System_Alerts;
SELECT TOP 5 * FROM healthcare.Service_Providers;
SELECT TOP 5 * FROM healthcare.Disease_Speciality;

PRINT '🚀 SCRIPT EXECUTION COMPLETED SUCCESSFULLY!';