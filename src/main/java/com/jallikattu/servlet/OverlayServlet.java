package com.jallikattu.servlet;

import com.jallikattu.dao.JallikattuDAO;
import com.jallikattu.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/overlay")
public class OverlayServlet extends HttpServlet {
    private final JallikattuDAO dao = new JallikattuDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String eventIdStr = req.getParameter("eventId");
        if (eventIdStr != null && !eventIdStr.isEmpty()) {
            try {
                int eventId = Integer.parseInt(eventIdStr);
                Event event = dao.getEventById(eventId);
                if (event != null) {
                    req.setAttribute("event", event);
                    req.setAttribute("eventId", eventId);
                }
            } catch (Exception e) {
                req.setAttribute("error", e.getMessage());
            }
        }
        req.getRequestDispatcher("/WEB-INF/views/overlay.jsp").forward(req, resp);
    }
}
