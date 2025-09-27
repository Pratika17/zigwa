import 'package:flutter/material.dart';
import '../models/trash_report_model.dart';
import '../models/user_model.dart';
import '../services/trash_service.dart';

class TrashProvider extends ChangeNotifier {
  List<TrashReportModel> _trashReports = [];
  List<TrashReportModel> _myReports = [];
  List<TrashReportModel> _assignedReports = [];
  bool _isLoading = false;

  List<TrashReportModel> get trashReports => _trashReports;
  List<TrashReportModel> get myReports => _myReports;
  List<TrashReportModel> get assignedReports => _assignedReports;
  bool get isLoading => _isLoading;

  final TrashService _trashService = TrashService();

  // Get all trash reports (for collection workers and dealers)
  Future<void> fetchTrashReports({TrashStatus? status}) async {
    _setLoading(true);
    try {
      _trashReports = await _trashService.getAllTrashReports(status: status);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching trash reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get user's own reports
  Future<void> fetchMyReports(String userId) async {
    _setLoading(true);
    try {
      _myReports = await _trashService.getUserReports(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching my reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get assigned reports (for collection workers)
  Future<void> fetchAssignedReports(String collectorId) async {
    _setLoading(true);
    try {
      _assignedReports = await _trashService.getAssignedReports(collectorId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching assigned reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new trash report (for users)
  Future<bool> createTrashReport({
    required String userId,
    required String userName,
    required List<String> imageUrls,
    required LocationModel location,
    required String description,
    required TrashType trashType,
  }) async {
    _setLoading(true);
    try {
      final report = await _trashService.createTrashReport(
        userId: userId,
        userName: userName,
        imageUrls: imageUrls,
        location: location,
        description: description,
        trashType: trashType,
      );

      if (report != null) {
        _myReports.insert(0, report);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating trash report: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Assign trash report to collection worker
  Future<bool> assignTrashReport(String reportId, String collectorId, String collectorName) async {
    _setLoading(true);
    try {
      final success = await _trashService.assignTrashReport(reportId, collectorId, collectorName);
      if (success) {
        // Update local data
        final reportIndex = _trashReports.indexWhere((r) => r.id == reportId);
        if (reportIndex != -1) {
          _trashReports[reportIndex] = TrashReportModel(
            id: _trashReports[reportIndex].id,
            userId: _trashReports[reportIndex].userId,
            userName: _trashReports[reportIndex].userName,
            imageUrls: _trashReports[reportIndex].imageUrls,
            location: _trashReports[reportIndex].location,
            description: _trashReports[reportIndex].description,
            trashType: _trashReports[reportIndex].trashType,
            status: TrashStatus.assigned,
            reportedAt: _trashReports[reportIndex].reportedAt,
            collectorId: collectorId,
            collectorName: collectorName,
            dealerId: _trashReports[reportIndex].dealerId,
            dealerName: _trashReports[reportIndex].dealerName,
            estimatedValue: _trashReports[reportIndex].estimatedValue,
            actualValue: _trashReports[reportIndex].actualValue,
            payment: _trashReports[reportIndex].payment,
          );
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error assigning trash report: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mark trash as collected (for collection workers)
  Future<bool> markAsCollected(String reportId) async {
    _setLoading(true);
    try {
      final success = await _trashService.markAsCollected(reportId);
      if (success) {
        _updateReportStatus(reportId, TrashStatus.collected);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error marking as collected: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Process trash and set value (for dealers)
  Future<bool> processTrash(String reportId, String dealerId, String dealerName, double value) async {
    _setLoading(true);
    try {
      final success = await _trashService.processTrash(reportId, dealerId, dealerName, value);
      if (success) {
        _updateReportStatus(reportId, TrashStatus.processed);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error processing trash: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Process payment (for dealers)
  Future<bool> processPayment(String reportId, double totalAmount) async {
    _setLoading(true);
    try {
      final success = await _trashService.processPayment(reportId, totalAmount);
      if (success) {
        _updateReportStatus(reportId, TrashStatus.paid);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _updateReportStatus(String reportId, TrashStatus newStatus) {
    // Update in all relevant lists
    final reportIndex = _trashReports.indexWhere((r) => r.id == reportId);
    if (reportIndex != -1) {
      final report = _trashReports[reportIndex];
      _trashReports[reportIndex] = TrashReportModel(
        id: report.id,
        userId: report.userId,
        userName: report.userName,
        imageUrls: report.imageUrls,
        location: report.location,
        description: report.description,
        trashType: report.trashType,
        status: newStatus,
        reportedAt: report.reportedAt,
        collectedAt: newStatus == TrashStatus.collected ? DateTime.now() : report.collectedAt,
        processedAt: newStatus == TrashStatus.processed ? DateTime.now() : report.processedAt,
        collectorId: report.collectorId,
        collectorName: report.collectorName,
        dealerId: report.dealerId,
        dealerName: report.dealerName,
        estimatedValue: report.estimatedValue,
        actualValue: report.actualValue,
        payment: report.payment,
      );
    }

    // Update in myReports if applicable
    final myReportIndex = _myReports.indexWhere((r) => r.id == reportId);
    if (myReportIndex != -1) {
      final report = _myReports[myReportIndex];
      _myReports[myReportIndex] = TrashReportModel(
        id: report.id,
        userId: report.userId,
        userName: report.userName,
        imageUrls: report.imageUrls,
        location: report.location,
        description: report.description,
        trashType: report.trashType,
        status: newStatus,
        reportedAt: report.reportedAt,
        collectedAt: newStatus == TrashStatus.collected ? DateTime.now() : report.collectedAt,
        processedAt: newStatus == TrashStatus.processed ? DateTime.now() : report.processedAt,
        collectorId: report.collectorId,
        collectorName: report.collectorName,
        dealerId: report.dealerId,
        dealerName: report.dealerName,
        estimatedValue: report.estimatedValue,
        actualValue: report.actualValue,
        payment: report.payment,
      );
    }

    // Update in assignedReports if applicable
    final assignedReportIndex = _assignedReports.indexWhere((r) => r.id == reportId);
    if (assignedReportIndex != -1) {
      final report = _assignedReports[assignedReportIndex];
      _assignedReports[assignedReportIndex] = TrashReportModel(
        id: report.id,
        userId: report.userId,
        userName: report.userName,
        imageUrls: report.imageUrls,
        location: report.location,
        description: report.description,
        trashType: report.trashType,
        status: newStatus,
        reportedAt: report.reportedAt,
        collectedAt: newStatus == TrashStatus.collected ? DateTime.now() : report.collectedAt,
        processedAt: newStatus == TrashStatus.processed ? DateTime.now() : report.processedAt,
        collectorId: report.collectorId,
        collectorName: report.collectorName,
        dealerId: report.dealerId,
        dealerName: report.dealerName,
        estimatedValue: report.estimatedValue,
        actualValue: report.actualValue,
        payment: report.payment,
      );
    }

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
