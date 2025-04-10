import 'package:flutter/material.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/providers/admin/space_admin_services.dart';

class SpaceAdminViewmodel extends ChangeNotifier {
  SpaceAdminServices admin = SpaceAdminServices();
  bool _isLoading = false;
  List<ParkingSpacePostModel> _mySpaces = [];
  List<BookingWithUser> _mySpaceBookings = [];
  List<BookingWithUser> _approvedBookings = [];

  bool get isLoading => _isLoading;
  List<ParkingSpacePostModel> get mySpaces => _mySpaces;
  List<BookingWithUser> get mySpaceBookings => _mySpaceBookings;
  List<BookingWithUser> get approvedBookings => _approvedBookings;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> getMySpaces() async {
    try {
      _setLoading(true);
      _mySpaces = await admin.fetchMySpaces();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint('getMySpaces() $e');
    }
  }

  Future<void> getParkingBookings(String spaceId) async {
    try {
      _setLoading(true);
      _mySpaceBookings = await admin.fetchParkingBookings(spaceId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
    }
  }

  Future<void> confirmBooking(String bookingId, String docId) async {
    try {
      _setLoading(true);
      await admin.confirmBooking(bookingId, docId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
    }
  }

  Future<void> rejectBooking(String bookingId, String docId) async {
    try {
      _setLoading(true);
      await admin.rejectBooking(bookingId, docId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
    }
  }

  Future<void> getConfirmedBookings(String docId) async {
    try {
      _setLoading(true);
      _approvedBookings = await admin.fetchConfirmedBookings(docId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
    }
  }
}
