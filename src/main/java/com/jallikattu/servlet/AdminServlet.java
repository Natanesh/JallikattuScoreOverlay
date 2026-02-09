package com.jallikattu.servlet;

import com.jallikattu.dao.JallikattuDAO;
import com.jallikattu.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    private final JallikattuDAO dao = new JallikattuDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        // Handle logout
        if ("logout".equals(req.getParameter("action"))) {
            req.getSession().invalidate();
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Event> events = dao.getAllEvents();
            req.setAttribute("events", events);
        } catch (Exception e) {
            req.setAttribute("error", "Error loading events: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");
        try {
            if ("create".equals(action)) {
                Event event = new Event();
                event.setEventName(req.getParameter("eventName"));
                event.setVenue(req.getParameter("venue"));
                event.setEventDate(req.getParameter("eventDate"));
                String rounds = req.getParameter("totalRounds");
                event.setTotalRounds(rounds != null && !rounds.isEmpty() ? Integer.parseInt(rounds) : 3);
                dao.createEvent(event);
            } else if ("updateStatus".equals(action)) {
                int eventId = Integer.parseInt(req.getParameter("eventId"));
                String status = req.getParameter("status");
                dao.updateEventStatus(eventId, status);
            } else if ("delete".equals(action)) {
                int eventId = Integer.parseInt(req.getParameter("eventId"));
                dao.deleteEvent(eventId);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Operation failed: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin");
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("admin") != null;
    }
}
