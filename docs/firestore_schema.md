# NanheNest — Firestore Database Schema

## Data Requirements

NanheNest is a social community app. The data it needs to store:

| # | Data | Notes |
|---|------|-------|
| 1 | User profiles | Auth UID, name, email, avatar, bio, stats |
| 2 | Posts / feed | Text + optional image, likes, comments counter |
| 3 | Community events | Location, date, attendee list |
| 4 | Post comments | Subcollection under each post |
| 5 | Post likes | Subcollection under each post (prevents double-like) |
| 6 | FCM tokens | Stored on user doc for push notifications |

---

## Schema

```
Firestore Root
│
├── users/                          ← top-level collection
│   └── {uid}/                      ← document ID = Firebase Auth UID
│       ├── email          : string
│       ├── displayName    : string
│       ├── avatarUrl      : string
│       ├── bio            : string
│       ├── postCount      : number
│       ├── followerCount  : number
│       ├── followingCount : number
│       ├── fcmToken       : string
│       ├── createdAt      : timestamp
│       └── lastActive     : timestamp
│
├── posts/                          ← top-level collection
│   └── {postId}/                   ← auto-generated document ID
│       ├── uid            : string  (creator's Auth UID)
│       ├── displayName    : string  (denormalized for feed display)
│       ├── content        : string
│       ├── imageUrl       : string  (optional, Firebase Storage URL)
│       ├── likes          : number  (counter)
│       ├── comments       : number  (counter)
│       ├── createdAt      : timestamp
│       ├── updatedAt      : timestamp
│       │
│       ├── comments/               ← subcollection
│       │   └── {commentId}/
│       │       ├── uid        : string
│       │       ├── displayName: string
│       │       ├── text       : string
│       │       └── createdAt  : timestamp
│       │
│       └── likes/                  ← subcollection
│           └── {uid}/              ← document ID = liker's UID (prevents duplicates)
│               └── createdAt  : timestamp
│
└── events/                         ← top-level collection
    └── {eventId}/                  ← auto-generated document ID
        ├── creatorUid     : string
        ├── title          : string
        ├── description    : string
        ├── location       : GeoPoint  (latitude, longitude)
        ├── address        : string
        ├── eventDateTime  : timestamp
        ├── imageUrl       : string?
        ├── attendees      : array<string>  (list of UIDs)
        ├── isActive       : boolean
        └── createdAt      : timestamp
```

---

## Sample Documents

### `users/{uid}`
```json
{
  "email": "asha@example.com",
  "displayName": "Asha Sharma",
  "avatarUrl": "https://storage.googleapis.com/nanhenest/avatars/uid123/profile.jpg",
  "bio": "Flutter developer & community builder",
  "postCount": 12,
  "followerCount": 48,
  "followingCount": 35,
  "fcmToken": "dGhpcyBpcyBhIHRva2Vu...",
  "createdAt": "2026-01-15T10:30:00Z",
  "lastActive": "2026-03-27T09:00:00Z"
}
```

### `posts/{postId}`
```json
{
  "uid": "uid123",
  "displayName": "Asha Sharma",
  "content": "Excited to share my first Flutter project!",
  "imageUrl": "https://storage.googleapis.com/nanhenest/posts/post456/image.jpg",
  "likes": 14,
  "comments": 3,
  "createdAt": "2026-03-20T14:00:00Z",
  "updatedAt": "2026-03-20T14:00:00Z"
}
```

### `posts/{postId}/comments/{commentId}`
```json
{
  "uid": "uid789",
  "displayName": "Ravi Kumar",
  "text": "Great work! Keep it up.",
  "createdAt": "2026-03-20T14:15:00Z"
}
```

### `posts/{postId}/likes/{uid}`
```json
{
  "createdAt": "2026-03-20T14:10:00Z"
}
```

### `events/{eventId}`
```json
{
  "creatorUid": "uid123",
  "title": "Flutter Meetup — Pune",
  "description": "Monthly community meetup for Flutter developers.",
  "location": { "latitude": 18.5204, "longitude": 73.8567 },
  "address": "Koregaon Park, Pune, Maharashtra",
  "eventDateTime": "2026-04-05T18:00:00Z",
  "imageUrl": "https://storage.googleapis.com/nanhenest/events/evt001/banner.jpg",
  "attendees": ["uid123", "uid789", "uid456"],
  "isActive": true,
  "createdAt": "2026-03-25T10:00:00Z"
}
```

---

## Schema Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        FIRESTORE ROOT                           │
└──────────┬──────────────────┬───────────────────────────────────┘
           │                  │                    │
    ┌──────▼──────┐   ┌───────▼──────┐   ┌────────▼────────┐
    │   users/    │   │   posts/     │   │    events/      │
    └──────┬──────┘   └───────┬──────┘   └────────┬────────┘
           │                  │                    │
    ┌──────▼──────┐   ┌───────▼──────┐   ┌────────▼────────┐
    │  {uid}      │   │  {postId}    │   │  {eventId}      │
    │─────────────│   │──────────────│   │─────────────────│
    │ email       │   │ uid          │   │ creatorUid      │
    │ displayName │   │ displayName  │   │ title           │
    │ avatarUrl   │   │ content      │   │ description     │
    │ bio         │   │ imageUrl     │   │ location        │
    │ postCount   │   │ likes        │   │ address         │
    │ follower-   │   │ comments     │   │ eventDateTime   │
    │   Count     │   │ createdAt    │   │ attendees[]     │
    │ following-  │   │ updatedAt    │   │ isActive        │
    │   Count     │   └──────┬───────┘   │ createdAt       │
    │ fcmToken    │          │           └─────────────────┘
    │ createdAt   │   ┌──────┴────────┐
    │ lastActive  │   │               │
    └─────────────┘   │               │
               ┌──────▼──────┐ ┌──────▼──────┐
               │  comments/  │ │   likes/    │
               └──────┬──────┘ └──────┬──────┘
                      │               │
               ┌──────▼──────┐ ┌──────▼──────┐
               │{commentId}  │ │   {uid}     │
               │─────────────│ │─────────────│
               │ uid         │ │ createdAt   │
               │ displayName │ └─────────────┘
               │ text        │
               │ createdAt   │
               └─────────────┘
```

---

## Design Decisions

### Why top-level `posts/` instead of `users/{uid}/posts/`?
A top-level `posts/` collection allows querying the global feed across all users with a single query. A subcollection under each user would require fetching from multiple paths to build a feed.

### Why subcollections for `comments/` and `likes/`?
- Comments can grow to thousands per post — keeping them in a subcollection avoids loading them when rendering the feed card.
- Using `likes/{uid}` as the document ID naturally prevents a user from liking the same post twice (Firestore document IDs are unique).

### Why denormalize `displayName` in posts?
Firestore doesn't support joins. Storing `displayName` directly on the post document avoids a second read to the `users/` collection every time a post is rendered in the feed.

### Why `attendees` as an array in `events/`?
Events typically have a bounded number of attendees (hundreds, not millions). An array is simpler to query and update for this scale. If the app scales to very large events, this would move to a subcollection.

---

## Firestore Security Rules (Summary)

| Collection | Read | Write |
|------------|------|-------|
| `users/{uid}` | Any authenticated user | Owner only |
| `posts/{postId}` | Any authenticated user | Create: authenticated; Update/Delete: author only |
| `posts/{id}/comments` | Any authenticated user | Create: authenticated; Delete: comment author |
| `posts/{id}/likes` | Any authenticated user | Authenticated (own UID as doc ID) |
| `events/{eventId}` | Any authenticated user | Create: authenticated; Update/Delete: creator |
