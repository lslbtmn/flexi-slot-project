# FlexiSlot Project Overview

Here is an overview of the **FlexiSlot** project, broken down into its functionality, structure, and core concepts based on the project documentation.

## 1. Functionality
FlexiSlot is a SaaS MVP (Minimum Viable Product) designed to facilitate **slot-based scheduling and booking**. It acts as a bridge between service providers (businesses) and clients (customers). 

**Key Features:**
*   **Role-Based Access:** 
    *   **Businesses** can set up profiles, define the services they offer (e.g., a "30-min Consultation"), and manage their availability (time slots).
    *   **Customers** can browse available services, view open time slots, and make bookings.
*   **Dynamic Pricing:** The system automatically adjusts the price of a time slot based on demand. If a service is highly booked (>80%), the price increases by 1.3x. If demand is low (<40%), the price drops to 0.7x of the base rate.
*   **Auto Slot Generation:** Businesses can automatically generate an entire day's schedule of slots based on their operating hours and the duration of the service, avoiding manual entry.
*   **Concurrency-Safe Booking:** The system prevents "double booking" where two users might try to reserve the same time slot at the exact same millisecond.
*   **Payments Module:** Includes infrastructure for handling payment initiation and status updates (Success/Fail) for bookings.

---

## 2. Structure
The project uses a modern monolithic, decoupled architecture separated into a backend API and a frontend client.

**Backend (Java + Spring Boot 3.x + MySQL)**
The backend follows a standard layered architecture:
*   **Domain Layer:** Contains the core entities mapped to database tables (e.g., `User`, `Business`, `Service`, `Slot`, `Booking`).
*   **Repository Layer:** Uses Spring Data JPA to interface with the MySQL database.
*   **Service Layer:** Contains the heavy business logic (e.g., the `PricingService` for dynamic pricing, or `SlotService` for bulk-generating slots).
*   **Controller Layer:** Exposes RESTful API endpoints for the frontend to consume.
*   **Security Layer:** Uses Spring Security and JWTs (JSON Web Tokens) to verify that requests are authenticated and authorized. 

**Frontend (React + Vite)**
The frontend is a Single Page Application (SPA):
*   **Pages:** Separated into public views (Login, Home, Public Services) and protected views (Business Dashboard, Customer Dashboard, Slot Picker).
*   **API Client:** Uses Axios with interceptors to automatically attach the JWT token to outgoing API requests.

---

## 3. Concept Comprehension
To truly understand how FlexiSlot is built, here are the underlying concepts and design decisions driving the code:

*   **Entity Relationships (The Workflow):** Everything revolves around a `User`. A User can have a `Business` profile or a `Customer` profile. A Business offers multiple `Services`. A Service has multiple available `Slots`. A Customer reserves a Slot, which creates a `Booking` and triggers a `Payment`.
*   **ULIDs over Auto-Increment IDs:** Instead of standard integers (1, 2, 3), the database uses **ULIDs** (Universally Unique Lexicographically Sortable Identifiers) for primary keys (e.g., `01ARZ3NDEKTSV4RRFFQ69G5FAV`). This ensures IDs are completely unique across distributed systems, unguessable, but still sortable by the time they were created.
*   **Pessimistic Locking:** To solve the concurrency issue of double-booking, the backend uses "pessimistic locking" on the database. When a user attempts to book a slot, the database literally locks that specific row until the transaction is complete, forcing any simultaneous requests to wait in line.
*   **DTO Pattern:** The API never exposes the raw database entities directly. Instead, it maps data to DTOs (Data Transfer Objects). This adds a layer of security and ensures the frontend only receives the data it actually needs to see.
*   **Multi-tenant Security:** When a business attempts to update a service or slot, the backend explicitly verifies the logged-in JWT to ensure that the user actually owns that business. It never blindly trusts IDs sent from the client.
