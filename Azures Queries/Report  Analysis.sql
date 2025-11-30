
-- ========================================================
--  Patients Report View
-- ========================================================
IF OBJECT_ID('dbo.vw_Patients_Report', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Patients_Report;
GO

CREATE VIEW dbo.vw_Patients_Report
AS
SELECT 
    p.patient_id,
    p.first_name + ' ' + p.last_name AS PatientName,
    p.gender,
    p.blood_type,
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX(',', REVERSE(p.address)) > 0 
            THEN RIGHT(p.address, CHARINDEX(',', REVERSE(p.address)) - 1)
            ELSE p.address
        END
    )) AS Governorate,
    COUNT(a.appointment_id) AS TotalAppointments
FROM dbo.Patients p
LEFT JOIN dbo.Appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name, p.gender, p.blood_type, p.address;
GO

-- ========================================================
-- 2️⃣ Doctors Report View
-- ========================================================
IF OBJECT_ID('dbo.vw_Doctors_Report', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Doctors_Report;
GO

CREATE VIEW dbo.vw_Doctors_Report
AS
SELECT 
    d.doctor_id,
    d.first_name + ' ' + d.last_name AS DoctorName,
    d.specialization,
    COUNT(a.appointment_id) AS TotalAppointments
FROM dbo.Doctors d
LEFT JOIN dbo.Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization;
GO

-- ========================================================
-- 3️⃣ Appointments Report View
-- ========================================================
IF OBJECT_ID('dbo.vw_Appointments_Report', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Appointments_Report;
GO

CREATE VIEW dbo.vw_Appointments_Report
AS
SELECT 
    a.appointment_id,
    a.patient_id,
    p.first_name + ' ' + p.last_name AS PatientName,
    a.doctor_id,
    d.first_name + ' ' + d.last_name AS DoctorName,
    a.appointment_date,
    a.status
FROM dbo.Appointments a
LEFT JOIN dbo.Patients p ON a.patient_id = p.patient_id
LEFT JOIN dbo.Doctors d ON a.doctor_id = d.doctor_id;
GO

-- ========================================================
-- 4️⃣ Medications Report View
-- ========================================================
IF OBJECT_ID('dbo.vw_Medications_Report', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Medications_Report;
GO

CREATE VIEW dbo.vw_Medications_Report
AS
SELECT 
    m.medication_id,
    m.patient_id,
    p.first_name + ' ' + p.last_name AS PatientName,
    m.appointment_id,
    m.medication_name,
    m.dosage,
    m.frequency,
    m.start_date,
    m.end_date
FROM dbo.Medications m
LEFT JOIN dbo.Patients p ON m.patient_id = p.patient_id;
GO

-- ========================================================
-- 5️⃣ Medical Readings Report View
-- ========================================================
IF OBJECT_ID('dbo.vw_MedicalReadings_Report', 'V') IS NOT NULL
    DROP VIEW dbo.vw_MedicalReadings_Report;
GO

CREATE VIEW dbo.vw_MedicalReadings_Report
AS
SELECT 
    r.reading_id,
    r.patient_id,
    p.first_name + ' ' + p.last_name AS PatientName,
    r.device_type,
    TRY_CAST(r.reading_value AS DECIMAL(10,2)) AS ReadingValue,
    r.unit,
    r.reading_timestamp,
    r.is_critical
FROM dbo.Medical_Readings r
LEFT JOIN dbo.Patients p ON r.patient_id = p.patient_id;
GO

-- ========================================================
-- System Alerts Report View
-- ========================================================
IF OBJECT_ID('dbo.vw_SystemAlerts_Report', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SystemAlerts_Report;
GO

CREATE VIEW dbo.vw_SystemAlerts_Report
AS
SELECT 
    s.alert_id,
    s.patient_id,
    p.first_name + ' ' + p.last_name AS PatientName,
    s.doctor_id,
    d.first_name + ' ' + d.last_name AS DoctorName,
    s.alert_type,
    s.severity,
    s.is_read,
    s.created_date
FROM dbo.System_Alerts s
LEFT JOIN dbo.Patients p ON s.patient_id = p.patient_id
LEFT JOIN dbo.Doctors d ON s.doctor_id = d.doctor_id;
GO


-- ========================================================
--  Service Providers Report View
-- ========================================================
IF OBJECT_ID('dbo.vw_ServiceProviders_Report', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ServiceProviders_Report;
GO

CREATE VIEW dbo.vw_ServiceProviders_Report
AS
SELECT 
    sp.Service_Provider,
    sp.Service_Provider_Type,
    sp.Specialty,
    sp.Address,
    sp.Governorate,
    sp.City,
    sp.Phone_1,
    sp.Phone_2
FROM dbo.Service_Providers sp;
GO

-- عرض أول 20 سجل من الـ Patients View
SELECT TOP 20 * 
FROM dbo.vw_Patients_Report;

-- ========================================================
-- عرض أول 20 سجل من كل View / Report
-- ========================================================

--  Patients Report
SELECT TOP 20 * 
FROM dbo.vw_Patients_Report;



-- 3️ Appointments Report
SELECT TOP 20 *
FROM dbo.Appointments;

--  Medications Report
SELECT TOP 20 *
FROM dbo.Medications;

--  Medical Readings Report
SELECT TOP 20 *
FROM dbo.Medical_Readings;

--  System Alerts Report
SELECT TOP 20 *
FROM dbo.System_Alerts;

--  Service Providers Report
SELECT TOP 20 *
FROM dbo.Service_Providers;