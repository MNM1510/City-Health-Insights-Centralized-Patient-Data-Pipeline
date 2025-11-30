-- ========================================================
-- 1. Patient Risk Analysis
-- ========================================================
SELECT 
    p.patient_id,
    p.first_name + ' ' + p.last_name AS PatientName,
    COUNT(sa.alert_id) AS CriticalAlerts,
    COUNT(mr.reading_id) AS AbnormalReadings,
    CASE 
        WHEN COUNT(sa.alert_id) > 5 OR COUNT(mr.reading_id) > 10 THEN 'High Risk'
        WHEN COUNT(sa.alert_id) > 2 OR COUNT(mr.reading_id) > 5 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskLevel
FROM healthcare.Patients p
LEFT JOIN healthcare.System_Alerts sa ON p.patient_id = sa.patient_id AND sa.severity = 'High'
LEFT JOIN healthcare.Medical_Readings mr ON p.patient_id = mr.patient_id AND mr.is_critical = 1
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY RiskLevel DESC;

-- ========================================================
-- 2. Service Provider Coverage Analysis
-- ========================================================
-- إذا جدول Service_Providers فيه governorate
SELECT 
    COALESCE(governorate, 'Unknown') AS Governorate,
    service_provider_type,
    COUNT(*) AS ProviderCount,
    COUNT(DISTINCT specialty) AS UniqueSpecialties
FROM healthcare.Service_Providers
GROUP BY COALESCE(governorate, 'Unknown'), service_provider_type
ORDER BY Governorate, ProviderCount DESC;

-- ========================================================
-- 3. Patients Analysis
-- ========================================================
-- استخراج المحافظة من العنوان إذا عمود governorate مش موجود
SELECT 
    RIGHT(address, CHARINDEX(',', REVERSE(address)) - 1) AS Governorate,
    COUNT(*) AS PatientCount
FROM healthcare.Patients
GROUP BY RIGHT(address, CHARINDEX(',', REVERSE(address)) - 1)
ORDER BY PatientCount DESC;

SELECT blood_type, COUNT(*) AS PatientCount
FROM healthcare.Patients
GROUP BY blood_type
ORDER BY PatientCount DESC;

-- ========================================================
-- 4. Doctors Analysis
-- ========================================================
SELECT 
    d.doctor_id, 
    d.first_name + ' ' + d.last_name AS DoctorName, 
    COUNT(a.appointment_id) AS AppointmentCount
FROM healthcare.Doctors d
LEFT JOIN healthcare.Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name
ORDER BY AppointmentCount DESC;

-- ========================================================
-- 5. Appointments Analysis
-- ========================================================
SELECT patient_id, COUNT(*) AS AppointmentCount
FROM healthcare.Appointments
GROUP BY patient_id
ORDER BY AppointmentCount DESC;

SELECT status, COUNT(*) AS CountPerStatus
FROM healthcare.Appointments
GROUP BY status
ORDER BY CountPerStatus DESC;

-- ========================================================
-- 6. Medications Analysis
-- ========================================================
SELECT patient_id, COUNT(*) AS MedicationCount
FROM healthcare.Medications
GROUP BY patient_id
ORDER BY MedicationCount DESC;

-- ========================================================
-- 7. Medical Readings Analysis
-- ========================================================
SELECT device_type, AVG(TRY_CAST(reading_value AS DECIMAL(10,2))) AS AvgReading
FROM healthcare.Medical_Readings
GROUP BY device_type
ORDER BY AvgReading DESC;

-- ========================================================
-- 8. System Alerts Analysis
-- ========================================================
SELECT alert_type, COUNT(*) AS AlertCount
FROM healthcare.System_Alerts
GROUP BY alert_type
ORDER BY AlertCount DESC;

SELECT patient_id, COUNT(*) AS AlertCount
FROM healthcare.System_Alerts
GROUP BY patient_id
ORDER BY AlertCount DESC;

-- ========================================================
-- 9. Service Providers Analysis
-- ========================================================
SELECT COALESCE(governorate, 'Unknown') AS Governorate, COUNT(*) AS ProviderCount
FROM healthcare.Service_Providers
GROUP BY COALESCE(governorate, 'Unknown')
ORDER BY ProviderCount DESC;

SELECT service_provider_type, COUNT(*) AS ProviderCount
FROM healthcare.Service_Providers
GROUP BY service_provider_type
ORDER BY ProviderCount DESC;
