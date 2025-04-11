import 'package:flutter/material.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/providers/admin/space_admin_services.dart';

class SpaceAdminViewmodel extends ChangeNotifier {
  final SpaceAdminServices _admin = SpaceAdminServices();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Stream<List<ParkingSpacePostModel>> getMySpacesStream() {
    return _admin.getMySpacesStream();
  }

  Stream<List<BookingWithUser>> getParkingBookingsStream(String spaceId) {
    return _admin.getParkingBookingsStream(spaceId);
  }

  Stream<List<BookingWithUser>> getConfirmedBookingsStream(String docId) {
    return _admin.getConfirmedBookingsStream(docId);
  }

  Future<void> confirmBooking(String bookingId, String docId) async {
    try {
      _setLoading(true);
      await _admin.confirmBooking(bookingId, docId);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> rejectBooking(String bookingId, String docId) async {
    try {
      _setLoading(true);
      await _admin.rejectBooking(bookingId, docId);
    } finally {
      _setLoading(false);
    }
  }
}
