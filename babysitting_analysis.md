ch# Babysitter vs Parents Marketplace Analysis

Based on the latest business requirement (a two-sided marketplace for Parents and Babysitters), **the current system design and architecture do NOT support this.** 

Currently, the application is structured as a generic Social/Community App (like Twitter or Facebook Groups) rather than a service-booking marketplace. Here is a breakdown of what is currently missing across the design elements:

## 1. User Roles & Identity (Missing)
**Current State:** The `UserModel` only has generic fields (`displayName`, `avatarUrl`, `bio`, `postCount`, `followerCount`). The `SignUpScreen` only asks for Name, Email, and Password.
**What is missing:**
* **Role Distinction:** There needs to be a `role` field (e.g., `parent` or `babysitter`).
* **Babysitter Specifics:** Fields for `hourlyRate`, `yearsOfExperience`, `certifications` (CPR, first aid), `backgroundCheckStatus`, and `availabilitySchedule`.
* **Parent Specifics:** Number of children, special needs requirements, and address/location.
* **Signup Flow:** The UI needs a step during onboarding to ask "Are you here to find a babysitter or to work as one?"

## 2. Booking Mechanism (Missing)
**Current State:** The `BookingModel` is designed for community events or meetups. It uses an `attendees: List<String>` array for group RSVPs and has `title` / `description`.
**What is missing:**
* A true `Job` or `ServiceBooking` model that supports a 1-to-1 contractual relationship.
* **Fields required:** `parentId`, `babysitterId`, `startTime`, `endTime`, `jobStatus` (Pending, Accepted, Active, Completed, Cancelled), `hourlyRateApplied`, and `totalCost`.
* **Booking Flow:** The UI needs a flow where a Parent proposes a time on a Babysitter's profile, and the Babysitter can accept/reject the request.

## 3. Search and Discovery (Missing)
**Current State:** The `SearchScreen` and `MapScreen` currently fetch generic users, posts, or group events.
**What is missing:**
* Parents need to search specifically for Babysitters within a certain radius.
* Filters for price, rating, experience, and availability.

## 4. Ratings and Reviews (Missing)
**Current State:** Users can `like` posts and accrue `followers`.
**What is missing:**
* A `ReviewModel` allowing Parents to rate and review Babysitters after a completed booking (1-5 stars, written feedback). Babysitters' average rating must be calculated and displayed on their profile.

## Summary 
To transition to this new system, the database models need an overhaul (adding Roles, Service Bookings, and Reviews) and the UI flows (Signup, Profiles, and Dashboard) need to be conditionally rendered based on whether the logged-in user is a Parent or a Babysitter.
