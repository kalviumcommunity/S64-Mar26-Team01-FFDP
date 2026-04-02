# Redesigned Babysitter Marketplace DB Schema

This schema transitions the application from a generic social network to a robust, two-sided marketplace connecting Parents and Babysitters. It includes the mandatory Aadhaar verification components for babysitters as requested.

---

## 1. `users` (Collection)
This collection stores all users but uses a `role` field to conditionally require different data.

**Base fields (All Users):**
* `uid` (String) - Document ID
* `email` (String)
* `displayName` (String)
* `avatarUrl` (String)
* `phoneNumber` (String) - *Crucial for marketplaces*
* `role` (String) - Enum: `'parent'` or `'babysitter'`
* `fcmToken` (String) - For push notifications
* `createdAt` (Timestamp)
* `lastActive` (Timestamp)
* `location` (GeoPoint) - Geolocation for map search
* `address` (String)

### 👶 If `role == 'parent'`
* `childrenCount` (int)
* `specialRequirements` (String) - E.g., allergies, medical needs.

### 🍼 If `role == 'babysitter'`
* `bio` (String) - Pitch to parents
* `hourlyRate` (double)
* `yearsOfExperience` (int)
* `certifications` (List<String>) - E.g., ["CPR", "First Aid"]
* `averageRating` (double) - Calculated centrally via Cloud Functions
* `totalJobsCompleted` (int)

**Aadhaar Verification Node (Babysitter only):**
* `verification` (Map):
  * `aadhaarNumber` (String) - *Highly recommended to encrypt or only store last 4 digits if sending to third-party verification API.*
  * `documentFrontUrl` (String) - Firebase Storage path to Aadhaar front
  * `documentBackUrl` (String) - Firebase Storage path to Aadhaar back
  * `status` (String) - Enum: `'pending'`, `'approved'`, `'rejected'`
  * `submittedAt` (Timestamp)
  * `verifiedAt` (Timestamp?) 

---

## 2. `jobs` (Collection)
Replaces the old `BookingModel` (which was built for group events). This represents a 1-on-1 contractual booking.

* **Document ID:** `jobId` (String)
* `parentId` (String) - Foreign Key -> `users.uid`
* `babysitterId` (String) - Foreign Key -> `users.uid`
* `status` (String) - Enum: `'pending'`, `'accepted'`, `'rejected'`, `'in_progress'`, `'completed'`, `'cancelled'`
* `startTime` (Timestamp)
* `endTime` (Timestamp)
* `hourlyRateApplied` (double) - Locked in at time of booking
* `totalEstimatedCost` (double) 
* `jobAddress` (String)
* `jobLocation` (GeoPoint)
* `specialInstructions` (String)
* `createdAt` (Timestamp)
* `updatedAt` (Timestamp)

---

## 3. `reviews` (Collection)
Allows parents to rate babysitters after a job is completed. A Firebase Cloud Function should listen to this collection to update the Babysitter's `averageRating` on their user document.

* **Document ID:** `reviewId` (String)
* `jobId` (String) - Foreign Key -> `jobs.jobId`
* `parentId` (String) - Foreign Key -> `users.uid` (Reviewer)
* `babysitterId` (String) - Foreign Key -> `users.uid` (Reviewee)
* `rating` (int or double) - 1 to 5 stars
* `feedback` (String)
* `createdAt` (Timestamp)

---

## 4. `messages` (Collection)
Remains the same as your current chat setup, allowing Parents and Babysitters to communicate before and during a job.

* **Document ID:** `messageId` (String)
* `jobId` (String?) - Optional link to the job they are discussing
* `senderId` (String)
* `receiverId` (String)
* `content` (String)
* `timestamp` (Timestamp)
* `isRead` (bool)

---

## 🚀 Key Rules & Security Changes Needed
If we implement this schema, the `firestore.rules` must be updated significantly:
1. **Aadhaar Protection:** The `users` collection rules must ensure that a Babysitter's `verification` map (especially the Aadhaar number) is **only readable by the Babysitter themselves and Admin/Cloud Functions**, NOT by other users (Parents). Parents should only rely on the public `status: 'approved'` flag.
2. **Review Integrity:** Users can only create a review if the `jobStatus` is `completed` and they were part of that `jobId`.
3. **Job Access:** A job document is only readable/writable by the specific `parentId` and `babysitterId` attached to it.
