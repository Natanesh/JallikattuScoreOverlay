<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Event - ${event.eventName}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/match.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-brand">&#x1F402; ${event.eventName}</div>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/overlay?eventId=${event.id}" target="_blank" class="btn btn-sm" style="background:linear-gradient(135deg,#6c5ce7,#a29bfe);color:#fff;">&#x1F4FA; Watch Live</a>
            <a href="${pageContext.request.contextPath}/admin" class="btn btn-sm">&larr; Dashboard</a>
        </div>
    </nav>

    <div class="container">
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <div class="event-info">
            <span><strong>Venue:</strong> ${event.venue}</span>
            <span><strong>Date:</strong> ${event.eventDate}</span>
            <span><strong>Rounds:</strong> ${event.totalRounds}</span>
            <span class="badge badge-${event.status == 'LIVE' ? 'live' : event.status == 'COMPLETED' ? 'done' : 'wait'}">${event.status}</span>
        </div>

        <!-- Validation -->
        <c:if test="${bullCount > 0 && playerCount > 0}">
            <div class="alert ${bullCount > playerCount ? 'alert-success' : 'alert-danger'}">
                Bulls: ${bullCount} | Players: ${playerCount} &mdash;
                <c:choose>
                    <c:when test="${bullCount > playerCount}">&#x2713; Valid (Bulls &gt; Players)</c:when>
                    <c:otherwise>&#x2717; Invalid! Bull count must exceed total player count</c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <div class="grid-2">
            <!-- BULLS -->
            <div class="card">
                <h2>&#x1F402; Bulls (${bullCount})</h2>
                <c:if test="${event.status == 'UPCOMING'}">
                    <form method="post" action="${pageContext.request.contextPath}/event" class="form-compact">
                        <input type="hidden" name="action" value="addBull">
                        <input type="hidden" name="eventId" value="${event.id}">
                        <input type="text" name="bullName" required placeholder="Bull Name">
                        <input type="text" name="breed" placeholder="Breed">
                        <input type="text" name="ownerName" placeholder="Owner">
                        <button type="submit" class="btn btn-sm btn-primary">+ Add</button>
                    </form>
                </c:if>
                <table class="data-table compact">
                    <thead><tr><th>#</th><th>Name</th><th>Breed</th><th>Owner</th><th></th></tr></thead>
                    <tbody>
                        <c:forEach var="bull" items="${bulls}" varStatus="loop">
                            <tr>
                                <td>${loop.count}</td>
                                <td><strong>${bull.bullName}</strong></td>
                                <td>${bull.breed}</td>
                                <td>${bull.ownerName}</td>
                                <td>
                                    <c:if test="${event.status == 'UPCOMING'}">
                                        <form method="post" action="${pageContext.request.contextPath}/event" style="display:inline">
                                            <input type="hidden" name="action" value="deleteBull">
                                            <input type="hidden" name="eventId" value="${event.id}">
                                            <input type="hidden" name="bullId" value="${bull.id}">
                                            <button type="submit" class="btn btn-xs btn-danger" onclick="return confirm('Delete?')">&#x00D7;</button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- PLAYERS -->
            <div class="card">
                <h2>&#x1F3C3; Players (${playerCount})</h2>
                <c:if test="${event.status == 'UPCOMING'}">
                    <form method="post" action="${pageContext.request.contextPath}/event" class="form-compact">
                        <input type="hidden" name="action" value="addPlayer">
                        <input type="hidden" name="eventId" value="${event.id}">
                        <input type="text" name="playerName" required placeholder="Player Name">
                        <input type="text" name="village" placeholder="Village">
                        <select name="roundNumber" required>
                            <c:forEach var="r" begin="1" end="${event.totalRounds}">
                                <option value="${r}">Round ${r}</option>
                            </c:forEach>
                        </select>
                        <button type="submit" class="btn btn-sm btn-primary">+ Add</button>
                    </form>
                </c:if>

                <c:forEach var="r" begin="1" end="${event.totalRounds}">
                    <h3 style="margin-top:14px; color:#74b9ff; font-size:0.9em;">Round ${r}</h3>
                    <table class="data-table compact">
                        <thead><tr><th>#</th><th>Name</th><th>Village</th><th></th></tr></thead>
                        <tbody>
                            <c:set var="pcount" value="0"/>
                            <c:forEach var="player" items="${players}">
                                <c:if test="${player.roundNumber == r}">
                                    <c:set var="pcount" value="${pcount + 1}"/>
                                    <tr>
                                        <td>${pcount}</td>
                                        <td><strong>${player.playerName}</strong></td>
                                        <td>${player.village}</td>
                                        <td>
                                            <c:if test="${event.status == 'UPCOMING'}">
                                                <form method="post" action="${pageContext.request.contextPath}/event" style="display:inline">
                                                    <input type="hidden" name="action" value="deletePlayer">
                                                    <input type="hidden" name="eventId" value="${event.id}">
                                                    <input type="hidden" name="playerId" value="${player.id}">
                                                    <button type="submit" class="btn btn-xs btn-danger" onclick="return confirm('Delete?')">&#x00D7;</button>
                                                </form>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:if>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:forEach>
            </div>
        </div>

        <!-- Start Match -->
        <c:if test="${event.status == 'UPCOMING' && bullCount > 0 && playerCount > 0 && bullCount > playerCount}">
            <div class="card" style="text-align:center">
                <form method="post" action="${pageContext.request.contextPath}/event">
                    <input type="hidden" name="action" value="startMatch">
                    <input type="hidden" name="eventId" value="${event.id}">
                    <button type="submit" class="btn btn-success" style="font-size:1.2em; padding:15px 40px;"
                            onclick="return confirm('Start the match? No more bulls/players can be added.')">
                        &#x1F402; Start Match
                    </button>
                </form>
            </div>
        </c:if>

        <!-- Go to Match -->
        <c:if test="${event.status == 'LIVE'}">
            <div class="card" style="text-align:center">
                <a href="${pageContext.request.contextPath}/match?eventId=${event.id}"
                   class="btn btn-warning" style="font-size:1.2em; padding:15px 40px;">
                    &#x1F3AE; Go to Match
                </a>
            </div>
        </c:if>
    </div>
</body>
</html>
