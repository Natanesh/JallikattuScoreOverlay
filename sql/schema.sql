-- ============================================================
-- Jallikattu Score Overlay - Database Schema (Authentic Rules)
--
-- Bull enters from Vaadivasal, players try to catch.
-- If caught → player gets score. If not → bull gets score.
-- Players are divided into rounds. Bulls are shared across all.
-- ============================================================

CREATE DATABASE IF NOT EXISTS jallikattu_db;
USE jallikattu_db;

-- Drop old tables for clean setup
DROP TABLE IF EXISTS score_history;
DROP TABLE IF EXISTS rounds;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS bulls;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS admin_users;

-- -----------------------------------------------------------
-- Table: events (Tournament / Match Day)
-- -----------------------------------------------------------
CREATE TABLE events (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    event_name      VARCHAR(200) NOT NULL,
    venue           VARCHAR(200) NOT NULL,
    event_date      DATE,
    status          ENUM('UPCOMING', 'LIVE', 'COMPLETED') DEFAULT 'UPCOMING',
    total_rounds    INT DEFAULT 3,
    current_round   INT DEFAULT 1,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Table: bulls (Each bull plays ONCE in the match)
-- -----------------------------------------------------------
CREATE TABLE bulls (
    id                   INT AUTO_INCREMENT PRIMARY KEY,
    event_id             INT NOT NULL,
    bull_name            VARCHAR(100) NOT NULL,
    breed                VARCHAR(100) DEFAULT '',
    owner_name           VARCHAR(100) DEFAULT '',
    total_score          INT DEFAULT 0,
    status               ENUM('WAITING','ACTIVE','COMPLETED') DEFAULT 'WAITING',
    caught_by_player_id  INT DEFAULT NULL,
    completed_in_round   INT DEFAULT NULL,
    display_order        INT DEFAULT 0,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Table: players (Assigned to specific rounds)
-- -----------------------------------------------------------
CREATE TABLE players (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    event_id        INT NOT NULL,
    player_name     VARCHAR(100) NOT NULL,
    village         VARCHAR(100) DEFAULT '',
    round_number    INT NOT NULL DEFAULT 1,
    total_score     INT DEFAULT 0,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Table: score_history (Every score action logged)
-- -----------------------------------------------------------
CREATE TABLE score_history (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    event_id        INT NOT NULL,
    bull_id         INT NOT NULL,
    player_id       INT DEFAULT NULL,
    score_type      ENUM('BULL', 'PLAYER', 'PENALTY') NOT NULL,
    score_value     INT NOT NULL,
    round_number    INT DEFAULT 1,
    recorded_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (bull_id) REFERENCES bulls(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Table: admin_users
-- -----------------------------------------------------------
CREATE TABLE admin_users (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(50) NOT NULL UNIQUE,
    password        VARCHAR(255) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO admin_users (username, password) VALUES ('admin', 'admin123');

-- ============================================================
-- Sample Data - Alanganallur Jallikattu 2026
-- 10 bulls, 9 players (3 per round × 3 rounds)
-- Rule: bulls (10) > total players (9) ✓
-- ============================================================
INSERT INTO events (event_name, venue, event_date, status, total_rounds)
VALUES ('Alanganallur Jallikattu 2026', 'Alanganallur Arena, Madurai', '2026-01-15', 'UPCOMING', 3);

INSERT INTO bulls (event_id, bull_name, breed, owner_name, display_order) VALUES
(1, 'Nandi',   'Kangayam',    'Murugan',  1),
(1, 'Kaari',   'Pulikulam',   'Senthil',  2),
(1, 'Theri',   'Kangayam',    'Rajan',    3),
(1, 'Kaalai',  'Umbalachery', 'Kumar',    4),
(1, 'Veeran',  'Pulikulam',   'Durai',    5),
(1, 'Komban',  'Kangayam',    'Arjun',    6),
(1, 'Mani',    'Barugur',     'Pandian',  7),
(1, 'Raja',    'Pulikulam',   'Velu',     8),
(1, 'Selvam',  'Kangayam',    'Muthu',    9),
(1, 'Dhoni',   'Umbalachery', 'Karthik', 10);

-- Round 1 players
INSERT INTO players (event_id, player_name, village, round_number) VALUES
(1, 'Raju',    'Palamedu',      1),
(1, 'Vignesh', 'Alanganallur',  1),
(1, 'Surya',   'Avaniapuram',   1);

-- Round 2 players
INSERT INTO players (event_id, player_name, village, round_number) VALUES
(1, 'Karthik', 'Sivagangai',  2),
(1, 'Dinesh',  'Palamedu',    2),
(1, 'Manoj',   'Alanganallur', 2);

-- Round 3 players
INSERT INTO players (event_id, player_name, village, round_number) VALUES
(1, 'Arun',    'Madurai',     3),
(1, 'Bala',    'Tiruchuli',   3),
(1, 'Chandru', 'Sivagangai',  3);
