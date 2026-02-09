package com.jallikattu.servlet;

import com.jallikattu.dao.JallikattuDAO;
import com.jallikattu.model.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/match")
public class MatchAPIServlet extends HttpServlet {
    private final JallikattuDAO dao = new JallikattuDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        JsonObject result = new JsonObject();

        try {
            int eventId = Integer.parseInt(req.getParameter("eventId"));
            String action = req.getParameter("action");

            if ("analytics".equals(action)) {
                List<Bull> bulls = dao.getBullAnalytics(eventId);
                List<Player> players = dao.getPlayerAnalytics(eventId);
                result.add("bulls", gson.toJsonTree(bulls));
                result.add("players", gson.toJsonTree(players));
            } else {
                Event event = dao.getEventById(eventId);

                // Ensure there's an active bull if LIVE
                Bull activeBull = dao.getActiveBull(eventId);
                if (activeBull == null && "LIVE".equals(event.getStatus())) {
                    activeBull = dao.activateNextBull(eventId);
                }

                List<Bull> waitingBulls = dao.getWaitingBulls(eventId);
                List<Bull> completedBulls = dao.getCompletedBulls(eventId);

                // Players based on current round
                List<Player> players;
                if (event.getCurrentRound() > event.getTotalRounds()) {
                    players = dao.getFinalRoundPlayers(eventId, 3);
                } else {
                    players = dao.getPlayersByRound(eventId, event.getCurrentRound());
                }

                boolean matchComplete = activeBull == null && waitingBulls.isEmpty();
                if (matchComplete && "LIVE".equals(event.getStatus())) {
                    dao.updateEventStatus(eventId, "COMPLETED");
                    event.setStatus("COMPLETED");
                }

                result.add("event", gson.toJsonTree(event));
                if (activeBull != null) result.add("activeBull", gson.toJsonTree(activeBull));
                result.add("waitingBulls", gson.toJsonTree(waitingBulls));
                result.add("completedBulls", gson.toJsonTree(completedBulls));
                result.add("players", gson.toJsonTree(players));
                result.addProperty("matchComplete", matchComplete);
            }
        } catch (Exception e) {
            result.addProperty("error", e.getMessage());
        }
        resp.getWriter().write(result.toString());
    }
}
