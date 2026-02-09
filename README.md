# Jallikattu Score Overlay

A **live score overlay system** for Jallikattu matches — similar to how cricket and football display scoreboards on screen during a broadcast. An admin controls the score by clicking buttons numbered **1 to 10** for both Bull and Player, and the score updates in real-time on the broadcast overlay screen.

---

## Project Architecture

```
┌─────────────────────┐        AJAX POST        ┌──────────────────┐
│   ADMIN PANEL       │ ──────────────────────►  │   SERVLETS       │
│   (scorePanel.jsp)  │  Click buttons 1-10      │   /api/score     │
│   Bull: [1-10]      │                          │   /api/liveScore │
│   Player: [1-10]    │  ◄────── JSON ────────── │                  │
└─────────────────────┘                          └────────┬─────────┘
                                                          │
                                                   JDBC   │
                                                          ▼
┌─────────────────────┐   Polls every 1.5s       ┌──────────────────┐
│   OVERLAY SCREEN    │ ──────────────────────►  │   MySQL DB       │
│   (overlay.jsp)     │  GET /api/liveScore      │   jallikattu_db  │
│   TV Broadcast look │  ◄────── JSON ────────── │                  │
└─────────────────────┘                          └──────────────────┘
```

---

## Features

- **Admin Login** – Secure admin panel with session management
- **Match Management** – Create, start, complete, reset, and delete matches
- **Score Panel** – Buttons 1-10 for both Bull and Player to add scores via AJAX
- **Keyboard Shortcuts** – Press `1-9, 0` for Bull score; `Shift + 1-9, 0` for Player score
- **Live Overlay** – Professional TV-style scoreboard that auto-refreshes every 1.5 seconds
- **Score Flash** – Visual animation when a score updates on the overlay
- **Score History** – Full history of every score entry for each match
- **Responsive Design** – Works on desktop, tablet, and mobile

---

## Tech Stack

| Layer    | Technology                       |
| -------- | -------------------------------- |
| Backend  | Java Servlet (javax.servlet 4.0) |
| Frontend | JSP, HTML5, CSS3, JavaScript     |
| Database | MySQL 8.0                        |
| Build    | Maven                            |
| Server   | Apache Tomcat 9+                 |
| JSON     | Gson                             |

---

## Prerequisites

1. **Java JDK 11+** installed
2. **Apache Tomcat 9+** installed
3. **MySQL 8.0+** installed and running
4. **Maven 3.6+** installed

---

## Setup Instructions

### Step 1: Create the Database

Open MySQL and run the schema file:

```sql
source sql/schema.sql;
```

Or copy-paste the contents of `sql/schema.sql` into MySQL Workbench / CLI.

### Step 2: Configure Database Connection

Edit `src/main/resources/db.properties`:

```properties
db.url=jdbc:mysql://localhost:3306/jallikattu_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
db.username=root
db.password=YOUR_MYSQL_PASSWORD
db.driver=com.mysql.cj.jdbc.Driver
```

### Step 3: Build the Project

```bash
mvn clean package
```

This will create `target/JallikattuScoreOverlay.war`.

### Step 4: Deploy to Tomcat

Copy the WAR file to your Tomcat `webapps` directory:

```bash
cp target/JallikattuScoreOverlay.war /path/to/tomcat/webapps/
```

Start Tomcat:

```bash
# Windows
catalina.bat start

# Linux/Mac
./catalina.sh start
```

### Step 5: Access the Application

| Page                     | URL                                                                 |
| ------------------------ | ------------------------------------------------------------------- |
| Admin Login              | `http://localhost:8080/JallikattuScoreOverlay/login`                |
| Admin Dashboard          | `http://localhost:8080/JallikattuScoreOverlay/admin`                |
| Score Panel              | `http://localhost:8080/JallikattuScoreOverlay/scorePanel?matchId=1` |
| Live Overlay             | `http://localhost:8080/JallikattuScoreOverlay/overlay`              |
| Overlay (specific match) | `http://localhost:8080/JallikattuScoreOverlay/overlay?matchId=1`    |
| Live Score API           | `http://localhost:8080/JallikattuScoreOverlay/api/liveScore`        |

---

## Default Admin Credentials

| Username | Password |
| -------- | -------- |
| admin    | admin123 |

---

## How It Works

### For the Admin (Score Controller):

1. **Login** at `/login` with admin credentials
2. **Create a match** from the dashboard with bull name, player name, and venue
3. **Start the match** (changes status to LIVE)
4. **Open Score Panel** for the live match
5. **Click buttons 1-10** under Bull section to add bull score
6. **Click buttons 1-10** under Player section to add player score
7. Each click sends an AJAX request → updates MySQL → returns updated totals
8. **Complete the match** when done

### For the Broadcast Screen (Overlay):

1. Open `/overlay` on the broadcast/display computer
2. The overlay auto-polls the server every 1.5 seconds
3. When scores change, the overlay updates with animations
4. Score flash notifications appear in the center of screen
5. The overlay has a transparent background — can be used with OBS or similar software

### Keyboard Shortcuts (Score Panel):

| Key           | Action               |
| ------------- | -------------------- |
| `1` - `9`     | Add Bull score 1-9   |
| `0`           | Add Bull score 10    |
| `Shift + 1-9` | Add Player score 1-9 |
| `Shift + 0`   | Add Player score 10  |

---

## Project Structure

```
JallikattuScoreOverlay/
├── pom.xml                           # Maven build file
├── sql/
│   └── schema.sql                    # Database schema + sample data
├── src/main/
│   ├── java/com/jallikattu/
│   │   ├── model/
│   │   │   ├── Match.java            # Match entity
│   │   │   └── ScoreEntry.java       # Score history entity
│   │   ├── dao/
│   │   │   └── MatchDAO.java         # All database operations
│   │   ├── servlet/
│   │   │   ├── LoginServlet.java     # Admin login/logout
│   │   │   ├── AdminServlet.java     # Dashboard page
│   │   │   ├── MatchServlet.java     # Create/start/complete/delete match
│   │   │   ├── ScorePanelServlet.java# Score control panel page
│   │   │   ├── ScoreUpdateServlet.java# AJAX score update API
│   │   │   ├── LiveScoreAPIServlet.java# Public live score JSON API
│   │   │   └── OverlayServlet.java   # Overlay display page
│   │   └── util/
│   │       └── DBConnection.java     # JDBC connection utility
│   ├── resources/
│   │   └── db.properties             # Database config
│   └── webapp/
│       ├── WEB-INF/web.xml           # Deployment descriptor
│       ├── login.jsp                 # Login page
│       ├── admin.jsp                 # Admin dashboard
│       ├── scorePanel.jsp            # Score buttons panel
│       ├── overlay.jsp               # Broadcast overlay
│       ├── error.jsp                 # Error page
│       ├── css/
│       │   ├── admin.css             # Admin panel styles
│       │   └── overlay.css           # Broadcast overlay styles
│       └── js/
│           └── scorePanel.js         # Score panel AJAX logic
└── README.md
```

---

## API Endpoints

### POST `/api/score` (Requires admin session)

Add score for bull or player.

**Parameters:**

- `matchId` (int) – Match ID
- `scoreType` (string) – `BULL` or `PLAYER`
- `scoreValue` (int) – Score value 1-10

**Response:**

```json
{
  "success": true,
  "message": "BULL scored 5 points!",
  "bullScore": 15,
  "playerScore": 10,
  "bullName": "Kaalai Raja",
  "playerName": "Muthu Kumar"
}
```

### GET `/api/liveScore` (Public, no auth)

Get live score data.

**Parameters (optional):**

- `matchId` (int) – Specific match ID

**Response (single match):**

```json
{
  "id": 1,
  "matchName": "Round 1 - Alanganallur",
  "bullName": "Kaalai Raja",
  "playerName": "Muthu Kumar",
  "bullScore": 15,
  "playerScore": 10,
  "roundNumber": 1,
  "venue": "Alanganallur Arena",
  "status": "LIVE"
}
```

---

## Using with OBS Studio (for Broadcasting)

1. Open the overlay URL in a browser
2. In OBS, add a **Browser Source**
3. Set the URL to `http://localhost:8080/JallikattuScoreOverlay/overlay?matchId=1`
4. Set width/height to your stream resolution
5. The transparent background will overlay on your video feed

---

## License

This project is for educational purposes. Built for Jallikattu event management.
