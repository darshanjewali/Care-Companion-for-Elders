import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class AppApi {
  final ApiClient client;
  AppApi({required this.client});

  Future<Map<String, dynamic>> getDashboard() async {
    return (await client.get('/api/dashboard')) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getHealthLatest() async {
    return (await client.get('/api/health/latest')) as Map<String, dynamic>;
  }

  Future<void> submitHealthRecord({
    required int heartRate,
    required int systolicBp,
    required int diastolicBp,
    required double bloodSugar,
  }) async {
    await client.postJson('/api/health-records', {
      'heartRate': heartRate,
      'systolicBp': systolicBp,
      'diastolicBp': diastolicBp,
      'bloodSugar': bloodSugar,
      'notes': null
    });
  }

  Future<List<dynamic>> getMedicinesToday() async {
    return (await client.get('/api/medicines/today')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createMedicine({
    required String name,
    required String dosage,
    required String reminderTime,
    required String instructions,
  }) async {
    return (await client.postJson('/api/medicines', {
      'name': name,
      'dosage': dosage,
      'reminderTime': reminderTime,
      'instructions': instructions,
      'reminderDate': null,
    })) as Map<String, dynamic>;
  }

  Future<void> markMedicineTaken({required int medicineId}) async {
    await client.postJson('/api/medicines/taken', {'medicineId': medicineId});
  }

  Future<Map<String, dynamic>> emergencySos({
    required double lat,
    required double lng,
    required String healthStatus,
    required String message,
  }) async {
    return (await client.postJson('/api/emergency', {
      'location': {'lat': lat, 'lng': lng},
      'healthStatus': healthStatus,
      'message': message,
    })) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> voiceCommand({required String command, required String lang}) async {
    return (await client.postJson('/api/voice-command', {'command': command, 'lang': lang}))
        as Map<String, dynamic>;
  }

  Future<List<dynamic>> getCaregiverPatientData() async {
    return (await client.get('/api/caregiver/patient-data')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> linkCaregiver({int? elderId, String? elderPhone}) async {
    final body = <String, dynamic>{};
    if (elderId != null) body['elderId'] = elderId;
    if (elderPhone != null && elderPhone.isNotEmpty) body['elderPhone'] = elderPhone;
    return (await client.postJson('/api/profile/link-caregiver', body)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAiHealthPrediction() async {
    return (await client.get('/api/ai/health-prediction')) as Map<String, dynamic>;
  }

  // Appointments
  Future<List<dynamic>> getMyAppointments() async {
    return (await client.get('/api/appointments/me')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createAppointment({
    required int doctorId,
    required String appointmentTime, // ISO string
    required String reason,
  }) async {
    return (await client.postJson('/api/appointments/me', {
      'doctorId': doctorId,
      'appointmentTime': appointmentTime,
      'reason': reason,
      'status': 'BOOKED',
    })) as Map<String, dynamic>;
  }

  Future<void> uploadPrescription({
    required int appointmentId,
    required File file,
    required String fieldName,
  }) async {
    final url = Uri.parse('${client.apiBaseUrl}/api/appointments/$appointmentId/prescription');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer ${client.token}';
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    final response = await request.send().timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final respBody = await response.stream.bytesToString();
      throw Exception('Prescription upload failed: $respBody');
    }
  }
}

