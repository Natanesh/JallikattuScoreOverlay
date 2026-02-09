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
    video_url       VARCHAR(500) DEFAULT NULL,
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
-- Sample Data - Multiple Jallikattu Events 2026
-- ============================================================

-- -----------------------------------------------------------
-- Event 1: Alanganallur Jallikattu 2026
-- 10 bulls, 9 players (3 per round × 3 rounds)
-- -----------------------------------------------------------
INSERT INTO events (event_name, venue, event_date, status, total_rounds, video_url)
VALUES ('Alanganallur Jallikattu 2026', 'Alanganallur Arena, Madurai', '2026-01-15', 'UPCOMING', 3,
        'https://youtu.be/pYMzESmWnVs?si=URueWwqCfVGmAroR');

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

INSERT INTO players (event_id, player_name, village, round_number) VALUES
(1, 'Raju',    'Palamedu',      1),
(1, 'Vignesh', 'Alanganallur',  1),
(1, 'Surya',   'Avaniapuram',   1),
(1, 'Karthik', 'Sivagangai',    2),
(1, 'Dinesh',  'Palamedu',      2),
(1, 'Manoj',   'Alanganallur',  2),
(1, 'Arun',    'Madurai',       3),
(1, 'Bala',    'Tiruchuli',     3),
(1, 'Chandru', 'Sivagangai',    3);

-- -----------------------------------------------------------
-- Event 2: Palamedu Jallikattu 2026
-- 8 bulls, 9 players (3 per round × 3 rounds)
-- -----------------------------------------------------------
INSERT INTO events (event_name, venue, event_date, status, total_rounds, video_url)
VALUES ('Palamedu Jallikattu 2026', 'Palamedu Ground, Madurai', '2026-01-16', 'UPCOMING', 3,
        'https://youtu.be/YpE2MpAmBVI?si=Pv8YbN2S19Q9hil4');

INSERT INTO bulls (event_id, bull_name, breed, owner_name, display_order) VALUES
(2, 'Veerapan',  'Kangayam',    'Suresh',   1),
(2, 'Sevalai',   'Pulikulam',   'Ganesan',  2),
(2, 'Karuppan',  'Umbalachery', 'Mani',     3),
(2, 'Arjunan',   'Kangayam',    'Raj',      4),
(2, 'Pandi',     'Barugur',     'Selvam',   5),
(2, 'Murugan',   'Pulikulam',   'Hari',     6),
(2, 'Chinni',    'Kangayam',    'Saravanan',7),
(2, 'Vetri',     'Umbalachery', 'Vijay',    8);

INSERT INTO players (event_id, player_name, village, round_number) VALUES
(2, 'Saravanan', 'Palamedu',      1),
(2, 'Gopal',     'Alanganallur',  1),
(2, 'Ravi',      'Madurai',       1),
(2, 'Senthil',   'Avaniapuram',   2),
(2, 'Praveen',   'Sivagangai',    2),
(2, 'Naveen',    'Tiruchuli',     2),
(2, 'Tharun',    'Palamedu',      3),
(2, 'Harish',    'Madurai',       3),
(2, 'Vikram',    'Alanganallur',  3);

-- -----------------------------------------------------------
-- Event 3: Avaniapuram Jallikattu 2026
-- 12 bulls, 12 players (4 per round × 3 rounds)
-- -----------------------------------------------------------
INSERT INTO events (event_name, venue, event_date, status, total_rounds, video_url)
VALUES ('Avaniapuram Jallikattu 2026', 'Avaniapuram Stadium, Madurai', '2026-01-17', 'UPCOMING', 3,
        'https://youtu.be/nR4i6ShxjA8?si=ipnABLTJZweNGZ1K');

INSERT INTO bulls (event_id, bull_name, breed, owner_name, display_order) VALUES
(3, 'Thunder',   'Kangayam',    'Ashok',     1),
(3, 'Storm',     'Pulikulam',   'Balaji',    2),
(3, 'Blaze',     'Kangayam',    'Chandran',  3),
(3, 'Shadow',    'Umbalachery', 'Deepak',    4),
(3, 'Rocket',    'Barugur',     'Ezhil',     5),
(3, 'Sultan',    'Kangayam',    'Feroz',     6),
(3, 'Danger',    'Pulikulam',   'Ganesh',    7),
(3, 'Tiger',     'Kangayam',    'Hari',      8),
(3, 'Bullet',    'Umbalachery', 'Ilango',    9),
(3, 'Cyclone',   'Pulikulam',   'Jagan',    10),
(3, 'Tornado',   'Barugur',     'Karan',    11),
(3, 'Flash',     'Kangayam',    'Lokesh',   12);

INSERT INTO players (event_id, player_name, village, round_number) VALUES
(3, 'Ashwin',    'Avaniapuram',  1),
(3, 'Bharath',   'Palamedu',     1),
(3, 'Deepan',    'Madurai',      1),
(3, 'Eswaran',   'Sivagangai',   1),
(3, 'Ganesh',    'Alanganallur', 2),
(3, 'Hafiz',     'Tiruchuli',    2),
(3, 'Inba',      'Palamedu',     2),
(3, 'Jayaraj',   'Avaniapuram',  2),
(3, 'Kathir',    'Madurai',      3),
(3, 'Lokesh',    'Sivagangai',   3),
(3, 'Mohan',     'Alanganallur', 3),
(3, 'Nithish',   'Tiruchuli',    3);

-- -----------------------------------------------------------
-- Event 4: Sivagangai Jallikattu 2026
-- 6 bulls, 6 players (3 per round × 2 rounds)
-- -----------------------------------------------------------
INSERT INTO events (event_name, venue, event_date, status, total_rounds, video_url)
VALUES ('Sivagangai Jallikattu 2026', 'Sivagangai Maidan', '2026-02-10', 'UPCOMING', 2,
        'https://youtu.be/7Is_Nrpt-5w?si=Bzjhy0X3nL5d3KiB');

INSERT INTO bulls (event_id, bull_name, breed, owner_name, display_order) VALUES
(4, 'Raaja',     'Kangayam',    'Pandian',   1),
(4, 'Velan',     'Pulikulam',   'Rajesh',    2),
(4, 'Thanga',    'Umbalachery', 'Shankar',   3),
(4, 'Ponni',     'Barugur',     'Thaniga',   4),
(4, 'Karuppu',   'Kangayam',    'Uma',       5),
(4, 'Velli',     'Pulikulam',   'Vinoth',    6);

INSERT INTO players (event_id, player_name, village, round_number) VALUES
(4, 'Pandi',      'Sivagangai',   1),
(4, 'Rajkumar',   'Palamedu',     1),
(4, 'Silamban',   'Madurai',      1),
(4, 'Thiru',      'Alanganallur', 2),
(4, 'Udayan',     'Avaniapuram',  2),
(4, 'Vetrivel',   'Sivagangai',   2);

-- -----------------------------------------------------------
-- Event 5: Madurai Pongal Jallikattu 2026
-- 15 bulls, 12 players (4 per round × 3 rounds)
-- -----------------------------------------------------------
INSERT INTO events (event_name, venue, event_date, status, total_rounds, video_url)
VALUES ('Madurai Pongal Jallikattu 2026', 'Tamukkam Grounds, Madurai', '2026-01-14', 'UPCOMING', 3,
        'https://youtu.be/bEXOEs0sNn8?si=l-3YQWbaYjJmbeei');

INSERT INTO bulls (event_id, bull_name, breed, owner_name, display_order) VALUES
(5, 'Champion',  'Kangayam',    'Anand',      1),
(5, 'Warrior',   'Pulikulam',   'Bhaskar',    2),
(5, 'Titan',     'Kangayam',    'Chellan',    3),
(5, 'Legend',    'Umbalachery', 'Dharma',     4),
(5, 'Phoenix',   'Barugur',     'Elango',     5),
(5, 'Dragon',    'Kangayam',    'Faisal',     6),
(5, 'Hercules',  'Pulikulam',   'Guru',       7),
(5, 'Maximus',   'Kangayam',    'Hari',       8),
(5, 'Spartacus', 'Umbalachery', 'Ishwar',     9),
(5, 'Zeus',      'Pulikulam',   'Jai',       10),
(5, 'Apollo',    'Barugur',     'Kalai',     11),
(5, 'Nero',      'Kangayam',    'Laxman',    12),
(5, 'Atlas',     'Pulikulam',   'Mahesh',    13),
(5, 'Spartan',   'Kangayam',    'Naveen',    14),
(5, 'Goliath',   'Umbalachery', 'Om',        15);

INSERT INTO players (event_id, player_name, village, round_number) VALUES
(5, 'Aadhi',     'Madurai',       1),
(5, 'Boopathi',  'Palamedu',      1),
(5, 'Chellamuthu','Alanganallur', 1),
(5, 'Durairaj',  'Avaniapuram',   1),
(5, 'Elavarasan','Sivagangai',    2),
(5, 'Feroz',     'Tiruchuli',     2),
(5, 'Gowtham',   'Palamedu',      2),
(5, 'Hari',      'Madurai',       2),
(5, 'Ilayaraja', 'Alanganallur',  3),
(5, 'Jagadish',  'Avaniapuram',   3),
(5, 'Kabilar',   'Sivagangai',    3),
(5, 'Lakshmanan','Madurai',       3);
