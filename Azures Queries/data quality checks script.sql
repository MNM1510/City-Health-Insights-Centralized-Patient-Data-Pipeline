
-- ===================================================================
--          Data Quality Checks Script (Final Optimized Version)
-- ===================================================================

-- Data Quality Monitoring View
CREATE VIEW healthcare.vw_Data_Quality_Metrics AS
SELECT 
    'Patients' AS Table_Name,
    COUNT(*) AS TotalRecords,
    SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS NullPatientIDs,
    SUM(CASE WHEN first_name IS NULL OR first_name = '' THEN 1 ELSE 0 END) AS NullFirstNames
FROM healthcare.Patients

UNION ALL

SELECT 
    'Appointments',
    COUNT(*),
    SUM(CASE WHEN appointment_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END)
FROM healthcare.Appointments;

-- 1. Create the 'audit' schema (if not exists)
IF SCHEMA_ID('audit') IS NULL
    EXEC('CREATE SCHEMA audit');
GO

-- Drop and recreate the 'etl_data_quality_errors' table to ensure its integrity
IF OBJECT_ID('audit.etl_data_quality_errors', 'U') IS NOT NULL
    DROP TABLE audit.etl_data_quality_errors;
GO

-- Create the 'etl_data_quality_errors' table
CREATE TABLE audit.etl_data_quality_errors (
    error_id INT IDENTITY(1,1),
    check_name VARCHAR(255),
    entity_name VARCHAR(100),
    record_id VARCHAR(100),
    error_description VARCHAR(1000),
    detected_at DATETIME2
) WITH (HEAP);
GO

-- ===================================================================
--          Start executing data quality checks
-- ===================================================================

-- 1. Orphaned Appointments (Missing Patient)
INSERT INTO audit.etl_data_quality_errors (check_name, entity_name, record_id, error_description, detected_at)
SELECT
    'Orphaned Appointments (Patient)' AS check_name,
    'Appointments' AS entity_name,
    CAST(a.appointment_id AS VARCHAR(100)) AS record_id,
    CONCAT('Patient ID ', a.patient_id, ' not found in Patients table') AS error_description,
    SYSUTCDATETIME() AS detected_at
FROM healthcare.Appointments a
LEFT JOIN healthcare.Patients p ON a.patient_id = p.patient_id
WHERE p.patient_id IS NULL;

-- 2. Orphaned Appointments (Missing Doctor)
INSERT INTO audit.etl_data_quality_errors (check_name, entity_name, record_id, error_description, detected_at)
SELECT
    'Orphaned Appointments (Doctor)' AS check_name,
    'Appointments' AS entity_name,
    CAST(a.appointment_id AS VARCHAR(100)) AS record_id,
    CONCAT('Doctor ID ', a.doctor_id, ' not found in Doctors table') AS error_description,
    SYSUTCDATETIME() AS detected_at
FROM healthcare.Appointments a
LEFT JOIN healthcare.Doctors d ON a.doctor_id = d.doctor_id
WHERE d.doctor_id IS NULL;

-- 3. Future Date of Birth
INSERT INTO audit.etl_data_quality_errors (check_name, entity_name, record_id, error_description, detected_at)
SELECT
    'Invalid Dates (Future DOB)' AS check_name,
    'Patients' AS entity_name,
    CAST(p.patient_id AS VARCHAR(100)) AS record_id,
    CONCAT('Date of birth ', CONVERT(VARCHAR, p.date_of_birth, 23), ' is in the future') AS error_description,
    SYSUTCDATETIME() AS detected_at
FROM healthcare.Patients p
WHERE p.date_of_birth > CAST(GETDATE() AS DATE);

-- 4. Duplicate patient IDs
INSERT INTO audit.etl_data_quality_errors (check_name, entity_name, record_id, error_description, detected_at)
SELECT
    'Duplicate Patient ID' AS check_name,
    'Patients' AS entity_name,
    p.patient_id AS record_id,
    CONCAT('Duplicate patient ID ', p.patient_id, ' found ') AS error_description,
    SYSUTCDATETIME() AS detected_at
FROM healthcare.Patients p
GROUP BY p.patient_id HAVING COUNT(*) > 1;

-- 5. Invalid phone numbers (too short)
INSERT INTO audit.etl_data_quality_errors (check_name, entity_name, record_id, error_description, detected_at)
SELECT
    'Invalid Phone (Patient)' AS check_name,
    'Patients' AS entity_name,
    p.patient_id AS record_id,
    CONCAT('Phone number ', p.phone, ' is too short (', LEN(TRIM(p.phone)), ')') AS error_description,
    SYSUTCDATETIME() AS detected_at
FROM healthcare.Patients p
WHERE p.phone IS NOT NULL AND LEN(TRIM(p.phone)) < 8;

-- 6. Invalid phone numbers (non-numeric)
INSERT INTO audit.etl_data_quality_errors (check_name, entity_name, record_id, error_description, detected_at)
SELECT
    'Invalid Phone (Non-Numeric)' AS check_name,
    'Patients' AS entity_name,
    p.patient_id AS record_id,
    CONCAT('Phone number ', p.phone, ' contains non-numeric characters') AS error_description,
    SYSUTCDATETIME() AS detected_at
FROM healthcare.Patients p
WHERE p.phone IS NOT NULL AND PATINDEX('%[^0-9]%', p.phone) > 0;


-- 7. Appointment time in the past (if only future appointments allowed)
INSERT INTO audit.etl_data_quality_errors (check_name, entity_name, record_id, error_description, detected_at)
SELECT
    'Past Appointment' AS check_name,
    'Appointments' AS entity_name,
    CAST(a.appointment_id AS VARCHAR(100)) AS record_id,
    CONCAT('Appointment ID ', a.appointment_id, ' has a past appointment time (', a.appointment_time, ')') AS error_description,
    SYSUTCDATETIME() AS detected_at
FROM healthcare.Appointments a
WHERE a.appointment_date < CAST(GETDATE() AS DATE);

-- 8. Appointments without a reason (if required)
INSERT INTO audit.etl_data_quality_errors (check_name, entity_name, record_id, error_description, detected_at)
SELECT
    'Missing Appointment Reason' AS check_name,
    'Appointments' AS entity_name,
    CAST(a.appointment_id AS VARCHAR(100)) AS record_id,
    'Reason is required but missing' AS error_description,
    SYSUTCDATETIME() AS detected_at
FROM healthcare.Appointments a
WHERE a.reason IS NULL OR TRIM(a.reason) = '';

-- 9. Null prescriptions (if not allowed)
INSERT INTO audit.etl_data_quality_errors (check_name, entity_name, record_id, error_description, detected_at)
SELECT
    'Null Prescription (Not Allowed)' AS check_name,
    'Appointments' AS entity_name,
    CAST(a.appointment_id AS VARCHAR(100)) AS record_id,
    'Prescription cannot be null' AS error_description,
    SYSUTCDATETIME() AS detected_at
FROM healthcare.Appointments a
WHERE a.prescription IS NULL;

-- Add more checks as needed...

-- Fail if any critical errors exist
IF EXISTS (SELECT 1 FROM audit.etl_data_quality_errors WHERE check_name IN ('Orphaned Appointments (Patient)', 'Orphaned Appointments (Doctor)', 'Invalid Dates (Future DOB)'))
BEGIN
    RAISERROR('Data quality validation failed. See audit.etl_data_quality_errors for details.', 16, 1);
END

-- ===================================================================
--          Display Results
-- ===================================================================

-- After running the script, execute this query to view the detected errors
SELECT * FROM audit.etl_data_quality_errors;