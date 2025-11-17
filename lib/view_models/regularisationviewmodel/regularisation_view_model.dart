import 'package:attendanceapp/models/projectmodels/project_models.dart';
import 'package:attendanceapp/models/regularisationmodels/regularisation_model.dart';
import 'package:attendanceapp/services/regularisationservices/regularisation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegularisationViewModel with ChangeNotifier {
  final RegularisationService _service = RegularisationService();

  bool _isLoading = false;
  String? _errorMessage;
  List<RegularisationRequest> _requests = [];
  List<Project> _userProjects = [];
  RegularisationFilter _currentFilter = RegularisationFilter.pending;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RegularisationRequest> get requests => _requests;
  List<Project> get userProjects => _userProjects;
  RegularisationFilter get currentFilter => _currentFilter;

  // Filtered requests
  List<RegularisationRequest> get filteredRequests {
    switch (_currentFilter) {
      case RegularisationFilter.pending:
        return _requests.where((r) => r.isPending).toList();
      case RegularisationFilter.approved:
        return _requests.where((r) => r.isApproved).toList();
      case RegularisationFilter.rejected:
        return _requests.where((r) => r.isRejected).toList();
      case RegularisationFilter.all:
      default:
        return _requests;
    }
  }

  // Statistics
  Map<String, int> get requestStats {
    return {
      'total': _requests.length,
      'pending': _requests.where((r) => r.isPending).length,
      'approved': _requests.where((r) => r.isApproved).length,
      'rejected': _requests.where((r) => r.isRejected).length,
    };
  }

  // Initialize data
  Future<void> initialize() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _loadRegularisationRequests();
      await _loadUserProjects();
      _logSuccess('Regularisation data initialized');
    } catch (e) {
      _errorMessage = 'Failed to load regularisation data: $e';
      _handleError(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadRegularisationRequests() async {
    _requests = await _service.getMyRegularisationRequests();
  }

  Future<void> _loadUserProjects() async {
    _userProjects = await _service.getUserProjects();
  }

  // Filter changes
  void changeFilter(RegularisationFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Create new regularisation request
  Future<bool> createRegularisationRequest(
    RegularisationFormData formData,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final newRequest = await _service.createRequest(formData);
      _requests.insert(0, newRequest);
      _logSuccess('Regularisation request created successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create request: $e';
      _handleError(_errorMessage!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update regularisation request
  Future<bool> updateRegularisationRequest(
    String requestId,
    RegularisationFormData formData,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedRequest = await _service.updateRequest(requestId, formData);
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = updatedRequest;
      }
      _logSuccess('Regularisation request updated successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update request: $e';
      _handleError(_errorMessage!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel regularisation request
  Future<bool> cancelRegularisationRequest(String requestId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _service.cancelRequest(requestId);
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = _requests[index].copyWith(
          status: RegularisationStatus.cancelled,
        );
      }
      _logSuccess('Regularisation request cancelled');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel request: $e';
      _handleError(_errorMessage!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if date can be regularised
  bool canRegulariseDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    // Allow regularisation for dates within last 30 days
    return difference.inDays <= 30 && difference.inDays >= 0;
  }

  // Get project name by ID
  String getProjectName(String projectId) {
    final project = _userProjects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => Project(
        id: '',
        name: 'Unknown Project',
        description: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        status: 'active',
        priority: 'medium',
        progress: 0,
        budget: 0,
        client: '',
        assignedTeam: [],
        tasks: [],
        createdAt: DateTime.now(),
      ),
    );
    return project.name;
  }

  // Utility methods
  String getTypeText(RegularisationType type) {
    switch (type) {
      case RegularisationType.checkIn:
        return 'Check-in Only';
      case RegularisationType.checkOut:
        return 'Check-out Only';
      case RegularisationType.fullDay:
        return 'Full Day';
      case RegularisationType.halfDay:
        return 'Half Day';
    }
  }

  String getStatusText(RegularisationStatus status) {
    switch (status) {
      case RegularisationStatus.pending:
        return 'Pending';
      case RegularisationStatus.approved:
        return 'Approved';
      case RegularisationStatus.rejected:
        return 'Rejected';
      case RegularisationStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color getStatusColor(RegularisationStatus status) {
    switch (status) {
      case RegularisationStatus.pending:
        return Colors.orange;
      case RegularisationStatus.approved:
        return Colors.green;
      case RegularisationStatus.rejected:
        return Colors.red;
      case RegularisationStatus.cancelled:
        return Colors.grey;
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String message) {
    if (kDebugMode) {
      print('❌ RegularisationViewModel: $message');
    }
  }

  void _logSuccess(String message) {
    if (kDebugMode) {
      print('✅ RegularisationViewModel: $message');
    }
  }

  @override
  void dispose() {
    _requests.clear();
    _userProjects.clear();
    super.dispose();
  }
}

enum RegularisationFilter { all, pending, approved, rejected }
