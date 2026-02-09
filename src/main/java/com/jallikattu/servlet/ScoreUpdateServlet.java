package com.jallikattu.servlet;

import com.jallikattu.dao.JallikattuDAO;
import com.jallikattu.model.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/score")
public class ScoreUpdateServlet extends HttpServlet {
    private final JallikattuDAO dao = new JallikattuDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        JsonObject json = new JsonObject();

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            resp.setStatus(401);
            json.addProperty("error", "Unauthorized");
            resp.getWriter().write(json.toString());
            return;
        }

        try {
            String action = req.getParameter("action");
            switch (action) {
                case "selectPlayer": {
                    int bullId = Integer.parseInt(req.getParameter("bullId"));
                    int playerId = Integer.parseInt(req.getParameter("playerId"));
                    dao.selectCatcher(bullId, playerId);
                    Player p = dao.getPlayerById(playerId);
                    json.addProperty("success", true);
                    json.addProperty("playerName", p.getPlayerName());
                    json.addProperty("playerScore", p.getTotalScore());
                    break;
                }
                case "clearPlayer": {
                    int bullId = Integer.parseInt(req.getParameter("bullId"));
                    dao.clearCatcher(bullId);
                    json.addProperty("success", true);
                    break;
                }
                case "bullScore": {
                    int bullId = Integer.parseInt(req.getParameter("bullId"));
                    int value = Integer.parseInt(req.getParameter("value"));
                    int eventId = Integer.parseInt(req.getParameter("eventId"));
                    int round = Integer.parseInt(req.getParameter("round"));
                    dao.updateBullScore(bullId, value);
                    dao.addScoreEntry(eventId, bullId, null, "BULL", value, round);
                    Bull b = dao.getBullById(bullId);
                    json.addProperty("success", true);
                    json.addProperty("bullScore", b.getTotalScore());
                    break;
                }
                case "playerScore": {
                    int bullId = Integer.parseInt(req.getParameter("bullId"));
                    int playerId = Integer.parseInt(req.getParameter("playerId"));
                    int value = Integer.parseInt(req.getParameter("value"));
                    int eventId = Integer.parseInt(req.getParameter("eventId"));
                    int round = Integer.parseInt(req.getParameter("round"));
                    dao.updatePlayerScore(playerId, value);
                    dao.addScoreEntry(eventId, bullId, playerId, "PLAYER", value, round);
                    Player p = dao.getPlayerById(playerId);
                    json.addProperty("success", true);
                    json.addProperty("playerScore", p.getTotalScore());
                    break;
                }
                case "penalty": {
                    int bullId = Integer.parseInt(req.getParameter("bullId"));
                    int playerId = Integer.parseInt(req.getParameter("playerId"));
                    int value = Integer.parseInt(req.getParameter("value"));
                    int eventId = Integer.parseInt(req.getParameter("eventId"));
                    int round = Integer.parseInt(req.getParameter("round"));
                    dao.updatePlayerScore(playerId, -value);
                    dao.updateBullScore(bullId, 10);
                    dao.addScoreEntry(eventId, bullId, playerId, "PENALTY", value, round);
                    Player p = dao.getPlayerById(playerId);
                    Bull b = dao.getBullById(bullId);
                    json.addProperty("success", true);
                    json.addProperty("playerScore", p.getTotalScore());
                    json.addProperty("bullScore", b.getTotalScore());
                    break;
                }
                case "next": {
                    int bullId = Integer.parseInt(req.getParameter("bullId"));
                    int eventId = Integer.parseInt(req.getParameter("eventId"));
                    int round = Integer.parseInt(req.getParameter("round"));
                    Bull currentBull = dao.getBullById(bullId);
                    Integer playerId = currentBull.getCaughtByPlayerId();
                    dao.completeBull(bullId, playerId, round);
                    Bull nextBull = dao.activateNextBull(eventId);
                    json.addProperty("success", true);
                    if (nextBull != null) {
                        json.addProperty("matchComplete", false);
                        json.add("activeBull", gson.toJsonTree(nextBull));
                    } else {
                        dao.updateEventStatus(eventId, "COMPLETED");
                        json.addProperty("matchComplete", true);
                    }
                    // Return updated completed list
                    List<Bull> completed = dao.getCompletedBulls(eventId);
                    json.add("completedBulls", gson.toJsonTree(completed));
                    List<Bull> waiting = dao.getWaitingBulls(eventId);
                    json.add("waitingBulls", gson.toJsonTree(waiting));
                    break;
                }
                case "changeRound": {
                    int eventId = Integer.parseInt(req.getParameter("eventId"));
                    int round = Integer.parseInt(req.getParameter("round"));
                    dao.updateCurrentRound(eventId, round);
                    List<Player> players;
                    Event event = dao.getEventById(eventId);
                    if (round > event.getTotalRounds()) {
                        players = dao.getFinalRoundPlayers(eventId, 3);
                    } else {
                        players = dao.getPlayersByRound(eventId, round);
                    }
                    json.addProperty("success", true);
                    json.addProperty("currentRound", round);
                    json.add("players", gson.toJsonTree(players));
                    break;
                }
                default:
                    json.addProperty("error", "Unknown action: " + action);
            }
        } catch (Exception e) {
            json.addProperty("error", "Failed: " + e.getMessage());
        }
        resp.getWriter().write(json.toString());
    }
}
