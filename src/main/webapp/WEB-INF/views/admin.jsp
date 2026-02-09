<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jallikattu Admin - Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-brand">🐂 Jallikattu Admin</div>
        <div class="nav-links">
            <span class="nav-user">Welcome, ${sessionScope.admin}</span>
            <a href="${pageContext.request.contextPath}/overlay" target="_blank" class="btn btn-sm">Live Overlay</a>
            <a href="${pageContext.request.contextPath}/admin?action=logout" class="btn btn-sm btn-danger">Logout</a>
        </div>
    </nav>

    <div class="container">
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <!-- Create Event Form -->
        <div class="card">
            <h2>Create New Event</h2>
            <form method="post" action="${pageContext.request.contextPath}/admin" class="form-inline">
                <input type="hidden" name="action" value="create">
                <div class="form-group">
                    <label>Event Name</label>
                    <input type="text" name="eventName" required placeholder="e.g. Alanganallur Jallikattu 2026">
                </div>
                <div class="form-group">
                    <label>Venue</label>
                    <input type="text" name="venue" required placeholder="e.g. Alanganallur, Madurai">
                </div>
                <div class="form-group">
                    <label>Event Date</label>
                    <input type="date" name="eventDate" required>
                </div>
                <div class="form-group">
                    <label>Total Rounds</label>
                    <input type="number" name="totalRounds" value="3" min="1" max="10" required>
                </div>
                <button type="submit" class="btn btn-primary">+ Create Event</button>
            </form>
        </div>

        <!-- Events Table -->
        <div class="card">
            <h2>All Events</h2>
            <c:choose>
                <c:when test="${empty events}">
                    <p class="empty-msg">No events created yet. Create one above!</p>
                </c:when>
                <c:otherwise>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Event Name</th>
                                <th>Venue</th>
                                <th>Date</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="event" items="${events}" varStatus="loop">
                                <tr>
                                    <td>${loop.count}</td>
                                    <td><strong>${event.eventName}</strong></td>
                                    <td>${event.venue}</td>
                                    <td>${event.eventDate}</td>
                                    <td>
                                        <span class="badge badge-${event.status == 'LIVE' ? 'live' : event.status == 'COMPLETED' ? 'done' : 'wait'}">
                                            ${event.status}
                                        </span>
                                    </td>
                                    <td class="actions">
                                        <a href="${pageContext.request.contextPath}/event?id=${event.id}" class="btn btn-sm btn-primary">Manage</a>
                                        <c:if test="${event.status == 'UPCOMING'}">
                                            <form method="post" action="${pageContext.request.contextPath}/admin" style="display:inline">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="eventId" value="${event.id}">
                                                <input type="hidden" name="status" value="LIVE">
                                                <button type="submit" class="btn btn-sm btn-success">Go Live</button>
                                            </form>
                                        </c:if>
                                        <c:if test="${event.status == 'LIVE'}">
                                            <form method="post" action="${pageContext.request.contextPath}/admin" style="display:inline">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="eventId" value="${event.id}">
                                                <input type="hidden" name="status" value="COMPLETED">
                                                <button type="submit" class="btn btn-sm btn-warning">End Event</button>
                                            </form>
                                        </c:if>
                                        <form method="post" action="${pageContext.request.contextPath}/admin" style="display:inline"
                                              onsubmit="return confirm('Delete this event and all its data?')">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="eventId" value="${event.id}">
                                            <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>
