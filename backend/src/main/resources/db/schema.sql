-- FlexiSlot SaaS - MySQL Schema
-- All tables use ULID VARCHAR(26) as primary key, InnoDB engine

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table: users
-- ----------------------------
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(26) NOT NULL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin','business_owner','customer') NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_email (email),
    INDEX idx_users_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table: business
-- ----------------------------
CREATE TABLE IF NOT EXISTS business (
    id VARCHAR(26) NOT NULL PRIMARY KEY,
    owner_user_id VARCHAR(26) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    location VARCHAR(500),
    service_type VARCHAR(100),
    operating_hours LONGTEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_business_owner FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_business_owner (owner_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table: customer
-- ----------------------------
CREATE TABLE IF NOT EXISTS customer (
    id VARCHAR(26) NOT NULL PRIMARY KEY,
    user_id VARCHAR(26) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_customer_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_customer_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table: services
-- ----------------------------
CREATE TABLE IF NOT EXISTS services (
    id VARCHAR(26) NOT NULL PRIMARY KEY,
    business_id VARCHAR(26) NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    base_price DECIMAL(12,2) NOT NULL,
    duration_minutes INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_services_business FOREIGN KEY (business_id) REFERENCES business(id) ON DELETE CASCADE,
    INDEX idx_services_business (business_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table: slot
-- ----------------------------
CREATE TABLE IF NOT EXISTS slot (
    id VARCHAR(26) NOT NULL PRIMARY KEY,
    service_id VARCHAR(26) NOT NULL,
    slot_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    status ENUM('available','booked','cancelled') NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_slot_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX idx_slot_service (service_id),
    INDEX idx_slot_date (slot_date),
    INDEX idx_slot_service_date (service_id, slot_date),
    INDEX idx_slot_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table: bookings
-- ----------------------------
CREATE TABLE IF NOT EXISTS bookings (
    id VARCHAR(26) NOT NULL PRIMARY KEY,
    customer_id VARCHAR(26) NOT NULL,
    slot_id VARCHAR(26) NOT NULL,
    booking_status ENUM('confirmed','cancelled','completed') NOT NULL,
    payment_status ENUM('initiated','success','failed') NOT NULL,
    booking_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bookings_customer FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE,
    CONSTRAINT fk_bookings_slot FOREIGN KEY (slot_id) REFERENCES slot(id) ON DELETE CASCADE,
    INDEX idx_bookings_customer (customer_id),
    INDEX idx_bookings_slot (slot_id),
    INDEX idx_bookings_customer_status (customer_id, booking_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table: payments
-- ----------------------------
CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(26) NOT NULL PRIMARY KEY,
    booking_id VARCHAR(26) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'GHS',
    provider VARCHAR(100) NOT NULL,
    provider_reference VARCHAR(255),
    status ENUM('initiated','success','failed') NOT NULL,
    paid_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_payments_booking (booking_id),
    INDEX idx_payments_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
