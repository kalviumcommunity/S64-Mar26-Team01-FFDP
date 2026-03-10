import 'package:cloud_firestore/cloud_firestore.dart';

/// Booking/Event model for community events in NanheNest
class BookingModel {
  final String eventId;
  final String creatorUid;
  final String title;
  final String description;
  final GeoPoint location;
  final String address;
  final DateTime eventDateTime;
  final String? imageUrl;
  final List<String> attendees;
  final int attendeeCount;
  final DateTime createdAt;
  final bool isActive;

  BookingModel({
    required this.eventId,
    required this.creatorUid,
    required this.title,
    required this.description,
    required this.location,
    required this.address,
    required this.eventDateTime,
    this.imageUrl,
    required this.attendees,
    required this.attendeeCount,
    required this.createdAt,
    this.isActive = true,
  });

  /// Convert Firestore document to BookingModel
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final attendees = List<String>.from(data['attendees'] ?? []);
    return BookingModel(
      eventId: doc.id,
      creatorUid: data['creatorUid'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] as GeoPoint,
      address: data['address'] ?? '',
      eventDateTime: (data['eventDateTime'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      attendees: attendees,
      attendeeCount: attendees.length,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convert BookingModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'creatorUid': creatorUid,
      'title': title,
      'description': description,
      'location': location,
      'address': address,
      'eventDateTime': Timestamp.fromDate(eventDateTime),
      'imageUrl': imageUrl,
      'attendees': attendees,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  /// Check if user is attending the event
  bool userIsAttending(String uid) {
    return attendees.contains(uid);
  }

  /// Check if event is in the future
  bool isUpcoming() {
    return eventDateTime.isAfter(DateTime.now());
  }

  /// Create a copy with some fields replaced
  BookingModel copyWith({
    String? title,
    String? description,
    String? address,
    List<String>? attendees,
    String? imageUrl,
    bool? isActive,
  }) {
    final newAttendees = attendees ?? this.attendees;
    return BookingModel(
      eventId: eventId,
      creatorUid: creatorUid,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location,
      address: address ?? this.address,
      eventDateTime: eventDateTime,
      imageUrl: imageUrl ?? this.imageUrl,
      attendees: newAttendees,
      attendeeCount: newAttendees.length,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
