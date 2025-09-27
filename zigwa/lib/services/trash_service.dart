import 'package:uuid/uuid.dart';
import '../models/trash_report_model.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class TrashService {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  // Create new trash report
  Future<TrashReportModel?> createTrashReport({
    required String userId,
    required String userName,
    required List<String> imageUrls,
    required LocationModel location,
    required String description,
    required TrashType trashType,
  }) async {
    try {
      final report = TrashReportModel(
        id: _uuid.v4(),
        userId: userId,
        userName: userName,
        imageUrls: imageUrls,
        location: location,
        description: description,
        trashType: trashType,
        status: TrashStatus.reported,
        reportedAt: DateTime.now(),
        estimatedValue: _calculateEstimatedValue(trashType),
      );

      await _databaseService.saveTrashReport(report);
      return report;
    } catch (e) {
      throw Exception('Failed to create trash report: $e');
    }
  }

  // Get all trash reports with optional status filter
  Future<List<TrashReportModel>> getAllTrashReports({TrashStatus? status}) async {
    try {
      return await _databaseService.getTrashReports(status: status);
    } catch (e) {
      throw Exception('Failed to fetch trash reports: $e');
    }
  }

  // Get user's own reports
  Future<List<TrashReportModel>> getUserReports(String userId) async {
    try {
      return await _databaseService.getTrashReports(userId: userId);
    } catch (e) {
      throw Exception('Failed to fetch user reports: $e');
    }
  }

  // Get reports assigned to a collection worker
  Future<List<TrashReportModel>> getAssignedReports(String collectorId) async {
    try {
      return await _databaseService.getTrashReports(collectorId: collectorId);
    } catch (e) {
      throw Exception('Failed to fetch assigned reports: $e');
    }
  }

  // Assign trash report to collection worker
  Future<bool> assignTrashReport(String reportId, String collectorId, String collectorName) async {
    try {
      final reports = await _databaseService.getTrashReports();
      final report = reports.firstWhere((r) => r.id == reportId);

      final updatedReport = TrashReportModel(
        id: report.id,
        userId: report.userId,
        userName: report.userName,
        imageUrls: report.imageUrls,
        location: report.location,
        description: report.description,
        trashType: report.trashType,
        status: TrashStatus.assigned,
        reportedAt: report.reportedAt,
        collectorId: collectorId,
        collectorName: collectorName,
        dealerId: report.dealerId,
        dealerName: report.dealerName,
        estimatedValue: report.estimatedValue,
        actualValue: report.actualValue,
        payment: report.payment,
      );

      await _databaseService.updateTrashReport(updatedReport);
      return true;
    } catch (e) {
      throw Exception('Failed to assign trash report: $e');
    }
  }

  // Mark trash as collected
  Future<bool> markAsCollected(String reportId) async {
    try {
      final reports = await _databaseService.getTrashReports();
      final report = reports.firstWhere((r) => r.id == reportId);

      final updatedReport = TrashReportModel(
        id: report.id,
        userId: report.userId,
        userName: report.userName,
        imageUrls: report.imageUrls,
        location: report.location,
        description: report.description,
        trashType: report.trashType,
        status: TrashStatus.collected,
        reportedAt: report.reportedAt,
        collectedAt: DateTime.now(),
        processedAt: report.processedAt,
        collectorId: report.collectorId,
        collectorName: report.collectorName,
        dealerId: report.dealerId,
        dealerName: report.dealerName,
        estimatedValue: report.estimatedValue,
        actualValue: report.actualValue,
        payment: report.payment,
      );

      await _databaseService.updateTrashReport(updatedReport);
      return true;
    } catch (e) {
      throw Exception('Failed to mark as collected: $e');
    }
  }

  // Process trash and set actual value
  Future<bool> processTrash(String reportId, String dealerId, String dealerName, double actualValue) async {
    try {
      final reports = await _databaseService.getTrashReports();
      final report = reports.firstWhere((r) => r.id == reportId);

      final updatedReport = TrashReportModel(
        id: report.id,
        userId: report.userId,
        userName: report.userName,
        imageUrls: report.imageUrls,
        location: report.location,
        description: report.description,
        trashType: report.trashType,
        status: TrashStatus.processed,
        reportedAt: report.reportedAt,
        collectedAt: report.collectedAt,
        processedAt: DateTime.now(),
        collectorId: report.collectorId,
        collectorName: report.collectorName,
        dealerId: dealerId,
        dealerName: dealerName,
        estimatedValue: report.estimatedValue,
        actualValue: actualValue,
        payment: report.payment,
      );

      await _databaseService.updateTrashReport(updatedReport);
      return true;
    } catch (e) {
      throw Exception('Failed to process trash: $e');
    }
  }

  // Process payment with 65%-25%-10% distribution
  Future<bool> processPayment(String reportId, double totalAmount) async {
    try {
      final reports = await _databaseService.getTrashReports();
      final report = reports.firstWhere((r) => r.id == reportId);

      // Calculate payment distribution
      final collectorAmount = totalAmount * 0.65; // 65% to collection worker
      final userAmount = totalAmount * 0.25; // 25% to user
      final platformFee = totalAmount * 0.10; // 10% platform fee

      final payment = PaymentModel(
        id: _uuid.v4(),
        totalAmount: totalAmount,
        userAmount: userAmount,
        collectorAmount: collectorAmount,
        platformFee: platformFee,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
        paidAt: DateTime.now(),
      );

      final updatedReport = TrashReportModel(
        id: report.id,
        userId: report.userId,
        userName: report.userName,
        imageUrls: report.imageUrls,
        location: report.location,
        description: report.description,
        trashType: report.trashType,
        status: TrashStatus.paid,
        reportedAt: report.reportedAt,
        collectedAt: report.collectedAt,
        processedAt: report.processedAt,
        collectorId: report.collectorId,
        collectorName: report.collectorName,
        dealerId: report.dealerId,
        dealerName: report.dealerName,
        estimatedValue: report.estimatedValue,
        actualValue: report.actualValue,
        payment: payment,
      );

      await _databaseService.updateTrashReport(updatedReport);
      
      // Update user and collector earnings
      await _updateUserEarnings(report.userId, userAmount);
      if (report.collectorId != null) {
        await _updateUserEarnings(report.collectorId!, collectorAmount);
      }

      return true;
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  // Update user earnings
  Future<void> _updateUserEarnings(String userId, double amount) async {
    try {
      final users = await _databaseService.getUsers();
      final user = users.firstWhere((u) => u.id == userId);
      
      final updatedUser = user.copyWith(
        totalEarnings: (user.totalEarnings ?? 0.0) + amount,
        completedTasks: (user.completedTasks ?? 0) + 1,
      );

      await _databaseService.updateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to update user earnings: $e');
    }
  }

  // Calculate estimated value based on trash type
  double _calculateEstimatedValue(TrashType trashType) {
    switch (trashType) {
      case TrashType.plastic:
        return 15.0;
      case TrashType.paper:
        return 10.0;
      case TrashType.metal:
        return 25.0;
      case TrashType.glass:
        return 8.0;
      case TrashType.organic:
        return 5.0;
      case TrashType.electronic:
        return 50.0;
      case TrashType.mixed:
        return 12.0;
    }
  }

  // Get available collection workers for assignment
  Future<List<UserModel>> getAvailableCollectors() async {
    try {
      final users = await _databaseService.getUsers();
      return users.where((u) => u.userType == UserType.collectionWorker && u.isActive).toList();
    } catch (e) {
      throw Exception('Failed to fetch available collectors: $e');
    }
  }

  // Get available dealers for processing
  Future<List<UserModel>> getAvailableDealers() async {
    try {
      final users = await _databaseService.getUsers();
      return users.where((u) => u.userType == UserType.dealer && u.isActive).toList();
    } catch (e) {
      throw Exception('Failed to fetch available dealers: $e');
    }
  }

  // Get statistics for dashboard
  Future<Map<String, dynamic>> getStatistics({String? userId, UserType? userType}) async {
    try {
      List<TrashReportModel> reports;
      
      if (userId != null) {
        if (userType == UserType.user) {
          reports = await getUserReports(userId);
        } else if (userType == UserType.collectionWorker) {
          reports = await getAssignedReports(userId);
        } else {
          reports = await getAllTrashReports();
        }
      } else {
        reports = await getAllTrashReports();
      }

      final totalReports = reports.length;
      final completedReports = reports.where((r) => r.status == TrashStatus.paid).length;
      final pendingReports = reports.where((r) => r.status == TrashStatus.reported).length;
      final inProgressReports = reports.where((r) => 
        r.status == TrashStatus.assigned || 
        r.status == TrashStatus.collected || 
        r.status == TrashStatus.processed
      ).length;

      final totalEarnings = reports
          .where((r) => r.payment != null)
          .fold(0.0, (sum, r) => sum + (userType == UserType.user 
              ? r.payment!.userAmount 
              : userType == UserType.collectionWorker 
                  ? r.payment!.collectorAmount 
                  : r.payment!.totalAmount));

      return {
        'totalReports': totalReports,
        'completedReports': completedReports,
        'pendingReports': pendingReports,
        'inProgressReports': inProgressReports,
        'totalEarnings': totalEarnings,
        'completionRate': totalReports > 0 ? (completedReports / totalReports * 100).round() : 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }
}
