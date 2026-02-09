package com.jallikattu.servlet;

import com.jallikattu.dao.JallikattuDAO;
import com.jallikattu.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/event")
public class EventServlet extends HttpServlet {
    private final JallikattuDAO dao = new JallikattuDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String idStr = req.getParameter("id");
        if (idStr == null) { resp.sendRedirect(req.getContextPath() + "/admin"); return; }

        try {
            int eventId = Integer.parseInt(idStr);
            Event event = dao.getEventById(eventId);
            if (event == null) { resp.sendRedirect(req.getContextPath() + "/admin"); return; }

            List<Bull> bulls = dao.getBullsByEvent(eventId);
            List<Player> players = dao.getAllPlayersByEvent(eventId);
            int bullCount = dao.getBullCount(eventId);
            int playerCount = dao.getTotalPlayerCount(eventId);

            req.setAttribute("event", event);
            req.setAttribute("bulls", bulls);
            req.setAttribute("players", players);
            req.setAttribute("bullCount", bullCount);
            req.setAttribute("playerCount", playerCount);
        } catch (Exception e) {
            req.setAttribute("error", "Error: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/event.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");
        int eventId = Integer.parseInt(req.getParameter("eventId"));

        try {
            switch (action) {
                case "addBull":
                    Bull bull = new Bull();
                    bull.setEventId(eventId);
                    bull.setBullName(req.getParameter("bullName"));
                    bull.setBreed(req.getParameter("breed"));
                    bull.setOwnerName(req.getParameter("ownerName"));
                    dao.addBull(bull);
                    break;
                case "deleteBull":
                    dao.deleteBull(Integer.parseInt(req.getParameter("bullId")));
                    break;
                case "addPlayer":
                    Player player = new Player();
                    player.setEventId(eventId);
                    player.setPlayerName(req.getParameter("playerName"));
                    player.setVillage(req.getParameter("village"));
                    player.setRoundNumber(Integer.parseInt(req.getParameter("roundNumber")));
                    dao.addPlayer(player);
                    break;
                case "deletePlayer":
                    dao.deletePlayer(Integer.parseInt(req.getParameter("playerId")));
                    break;
                case "startMatch":
                    dao.updateEventStatus(eventId, "LIVE");
                    resp.sendRedirect(req.getContextPath() + "/match?eventId=" + eventId);
                    return;
            }
        } catch (Exception e) {
            req.getSession().setAttribute("error", "Operation failed: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/event?id=" + eventId);
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("admin") != null;
    }
}
