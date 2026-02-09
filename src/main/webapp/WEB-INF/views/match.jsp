<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Match - ${event.eventName}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/match.css">
</head>
<body>
    <input type="hidden" id="eventId" value="${event.id}">
    <input type="hidden" id="totalRounds" value="${event.totalRounds}">
    <input type="hidden" id="contextPath" value="${pageContext.request.contextPath}">

    <!-- Header -->
    <nav class="navbar">
        <div class="nav-brand">&#x1F402; ${event.eventName}</div>
        <div class="nav-links">
            <div class="round-selector">
                <label>Round:</label>
                <select id="roundSelect" onchange="changeRound(this.value)">
                    <c:forEach var="r" begin="1" end="${event.totalRounds}">
                        <option value="${r}" ${r == event.currentRound ? 'selected' : ''}>Round ${r}</option>
                    </c:forEach>
                    <option value="${event.totalRounds + 1}" ${event.currentRound > event.totalRounds ? 'selected' : ''}>Final</option>
                </select>
            </div>
            <button onclick="viewAnalytics()" class="btn btn-sm btn-primary">View Analytics</button>
            <a href="${pageContext.request.contextPath}/event?id=${event.id}" class="btn btn-sm">&larr; Back</a>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="match-layout">
        <!-- Left sidebar -->
        <div class="sidebar-left">
            <div class="card">
                <h3>&#x1F402; Waiting Bulls</h3>
                <div id="bullList" class="entity-list"></div>
            </div>
            <div class="card">
                <h3>&#x1F3C3; Players <small id="roundLabel">(Round 1)</small></h3>
                <div id="playerList" class="entity-list"></div>
            </div>
        </div>

        <!-- Center -->
        <div class="center-panel">
            <!-- Overlay Card -->
            <div class="overlay-card" id="overlayCard">
                <table class="overlay-table">
                    <thead>
                        <tr>
                            <th class="bull-col">Bull Name</th>
                            <th class="bull-col">Bull Score</th>
                            <th class="player-col">Player Name</th>
                            <th class="player-col">Player Score</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td id="ovBullName" class="bull-col">-</td>
                            <td id="ovBullScore" class="bull-col score-val">0</td>
                            <td id="ovPlayerName" class="player-col">-</td>
                            <td id="ovPlayerScore" class="player-col score-val">0</td>
                        </tr>
                    </tbody>
                </table>
                <div class="overlay-actions">
                    <button id="clearPlayerBtn" onclick="clearPlayer()" class="btn btn-sm btn-danger" style="display:none">&#x2715; Clear Player</button>
                    <button id="nextBtn" onclick="nextBull()" class="btn btn-warning btn-next">Next &rarr;</button>
                </div>
            </div>

            <!-- Score Buttons -->
            <div id="scoreSection" class="score-section">
                <!-- Bull Score Buttons (default) -->
                <div id="bullScoreSection" class="score-group">
                    <h4>&#x1F402; Bull Score</h4>
                    <div class="score-buttons" id="bullScoreButtons"></div>
                </div>
                <!-- Player Score Buttons (when player selected) -->
                <div id="playerScoreSection" class="score-group" style="display:none">
                    <h4>&#x1F3C3; Player Score</h4>
                    <div class="score-buttons" id="playerScoreButtons"></div>
                </div>
                <!-- Penalty Buttons (when player selected) -->
                <div id="penaltySection" class="score-group" style="display:none">
                    <h4>&#x26A0; Penalty</h4>
                    <div class="score-buttons penalty-buttons" id="penaltyButtons"></div>
                </div>
            </div>

            <!-- Match Complete Banner -->
            <div id="matchCompleteBanner" class="match-complete" style="display:none">
                <h2>&#x1F3C6; Match Complete!</h2>
                <p>All bulls have been processed.</p>
                <button onclick="viewAnalytics()" class="btn btn-primary">View Final Analytics</button>
            </div>
        </div>

        <!-- Right sidebar - Completed -->
        <div class="sidebar-right">
            <div class="card">
                <h3>&#x2705; Completed</h3>
                <div id="completedList" class="completed-list"></div>
            </div>
        </div>
    </div>

    <!-- Analytics Modal -->
    <div id="analyticsModal" class="modal" style="display:none">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Match Analytics</h2>
                <button onclick="closeAnalytics()" class="btn btn-sm btn-danger">&#x2715;</button>
            </div>
            <div class="analytics-grid">
                <div class="card">
                    <h3>&#x1F3C3; Player Rankings</h3>
                    <table class="data-table" id="playerAnalyticsTable">
                        <thead><tr><th>#</th><th>Player</th><th>Village</th><th>Round</th><th>Score</th></tr></thead>
                        <tbody></tbody>
                    </table>
                </div>
                <div class="card">
                    <h3>&#x1F402; Bull Rankings</h3>
                    <table class="data-table" id="bullAnalyticsTable">
                        <thead><tr><th>#</th><th>Bull</th><th>Breed</th><th>Score</th><th>Caught By</th></tr></thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/match.js"></script>
</body>
</html>
