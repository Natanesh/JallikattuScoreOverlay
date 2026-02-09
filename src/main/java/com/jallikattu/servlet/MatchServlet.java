package com.jallikattu.servlet;

import com.jallikattu.dao.JallikattuDAO;
import com.jallikattu.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/match")
public class MatchServlet extends HttpServlet {
    private final JallikattuDAO dao = new JallikattuDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String eventIdStr = req.getParameter("eventId");
        if (eventIdStr == null) { resp.sendRedirect(req.getContextPath() + "/admin"); return; }

        try {
            int eventId = Integer.parseInt(eventIdStr);
            Event event = dao.getEventById(eventId);
            if (event == null) { resp.sendRedirect(req.getContextPath() + "/admin"); return; }
            req.setAttribute("event", event);
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/match.jsp").forward(req, resp);
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("admin") != null;
    }
}
