# NanheNest Database Schema Analysis

Based on the Flutter models (in `lib/models/`) and the Firestore Security Rules (`firestore.rules`), here is the comprehensive breakdown of the Firestore database schema, relationships, and structural issues.

## 🗄️ Collections & Schema

### 1. `users` (Collection)
Stores user profile and account details.
- **Document ID:** `uid` (String) - Matches Firebase Auth UID
- `email`: String
- `displayName`: String
- `avatarUrl`: String
- `bio`: String
- `postCount`: int
- `followerCount`: int
- `followingCount`: int
- `fcmToken`: String
- `createdAt`: Timestamp
- `lastActive`: Timestamp
#### Subcollections:
- **`items/{itemId}`**: Allowed in `firestore.rules` (full CRUD for owner). No Flutter model found for this.

### 2. `posts` (Collection)
Stores user-generated posts for the feed.
- **Document ID:** `postId` (String)
- `uid`: String (Foreign Key -> `users.uid`)
- `displayName`: String
- `content`: String
- `imageUrl`: String (Optional)
- `likes`: int (Counter)
- `comments`: int (Counter)
- `createdAt`: Timestamp
- `updatedAt`: Timestamp
- `tags`: List<String>
#### Subcollections:
- **`comments/{commentId}`**: Stores individual comments for the post.
- **`likes/{likerUid}`**: Stores likes. Document ID naturally prevents duplicate likes.

### 3. `events` (Collection) - *Modeled as BookingModel*
Stores community events/bookings.
- **Document ID:** `eventId` (String)
- `creatorUid`: String (Foreign Key -> `users.uid`)
- `title`: String
- `description`: String
- `location`: GeoPoint
- `address`: String
- `eventDateTime`: Timestamp
- `imageUrl`: String (Optional)
- `attendees`: List<String> (Array of Foreign Keys -> `users.uid`)
- `attendeeCount`: int
- `createdAt`: Timestamp
- `isActive`: bool

### 4. `messages` (Collection)
Stores chat messages between users.
- **Document ID:** `messageId` (String)
- `senderId`: String (Foreign Key -> `users.uid`)
- `receiverId`: String (Foreign Key -> `users.uid`)
- `content`: String
- `timestamp`: Timestamp
- `isRead`: bool

### 5. `tasks` (Collection)
Mentioned in `firestore.rules` for "Firestore Write/Query demo screens".
- **Document ID:** `taskId` (String)
- `uid`: String (Foreign Key -> `users.uid`)

---

## 🔗 Relationships

- **1-to-Many:** `users` to `posts` (A user can have many posts)
- **1-to-Many:** `users` to `events` (A user can create many events)
- **Many-to-Many:** `users` to `events` (Users attend events via the `attendees` list)
- **1-to-Many:** `posts` to `comments`/`likes` (A post contains multiple comments and likes in subcollections)
- **1-to-Many:** `users` to `messages` (A user can send/receive many messages)

---

## ⚠️ Redundancies Identified

1. **`displayName` in `posts` collection:**
   The `PostModel` stores the `displayName` directly. This duplicates the `displayName` from the `users` collection.
   - *Issue:* If a user updates their display name in their profile, their old posts will still show the old name unless there's a Cloud Function running to batch-update all their past posts.

2. **Counter Fields (`likes` & `comments` in `posts`, `attendeeCount` in `events`):**
   - The `PostModel` holds `likes` and `comments` integer counters, but the actual likes and comments exist in subcollections.
   - The `BookingModel` holds both an `attendees` array and an `attendeeCount` integer.
   - *Acceptable Tradeoff:* This is technically redundant, but it's a very common NoSQL optimization to avoid reading the entire subcollection/array just to get a count. However, it requires strict Cloud Functions triggers or transactions to ensure the counts stay synced with the actual data.

---

## 🚨 Security & Architecture Issues 

1. **`messages` Collection is Blocked in Security Rules! (CRITICAL)**
   - The `MessageModel` exists, but `firestore.rules` does not include a `match /messages/{messageId}` rule.
   - Because the rules end with a default `deny everything else` (`match /{document=**} { allow read, write: if false; }`), **all read/write attempts to the `messages` collection will fail in production.**

2. **Dangerous Update Rule on `events` (CRITICAL)**
   - In `firestore.rules`: `allow update: if isAuthenticated(); // allows RSVP by any user`
   - *Issue:* This allows *any* logged-in user to completely overwrite the event. A malicious user could change the `title`, `location`, or even take ownership by changing the `creatorUid`. 
   - *Fix:* Ensure the rule strictly limits updates to *only* the `attendees` and `attendeeCount` fields using `request.resource.data.diff(resource.data).affectedKeys()`.

3. **Scalability Flaw in `events` / `BookingModel`**
   - The `attendees` field is an array of UIDs on the document.
   - *Issue:* Firestore documents have a 1 MiB size limit. If an event gets thousands of attendees, the document will hit the size limit and crash/fail to update. Additionally, concurrent RSVPs will cause write conflicts.
   - *Fix:* Move RSVPs to an `attendees/{uid}` subcollection, similar to how `likes` are handled on `posts`.

4. **Missing Models:**
   - `firestore.rules` defines `tasks/{taskId}` and subcollection `users/{uid}/items/{itemId}`, but there are no corresponding Dart models for them. They may be dead code or leftover demo snippets.
