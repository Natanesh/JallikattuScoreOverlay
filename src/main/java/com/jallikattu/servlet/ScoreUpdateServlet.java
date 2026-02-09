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
                    dao.addScoreEntry(eventId, bullId, playerId, "PENALTY", value, round);
                    Player p = dao.getPlayerById(playerId);
                    json.addProperty("success", true);
                    json.addProperty("playerScore", p.getTotalScore());
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
                    Event event = dao.getEventById(eventId);
                    List<Player> players = getPlayersForRound(eventId, round, event.getTotalRounds());
                    json.addProperty("success", true);
                    json.addProperty("currentRound", round);
                    json.add("players", gson.toJsonTree(players));
                    break;
                }
                case "undoScore": {
                    int bullId = Integer.parseInt(req.getParameter("bullId"));
                    int eventId = Integer.parseInt(req.getParameter("eventId"));
                    ScoreEntry lastEntry = dao.getLastScoreEntryForBull(bullId);
                    if (lastEntry != null) {
                        switch (lastEntry.getScoreType()) {
                            case "BULL":
                                dao.updateBullScore(bullId, -lastEntry.getScoreValue());
                                break;
                            case "PLAYER":
                                if (lastEntry.getPlayerId() != null)
                                    dao.updatePlayerScore(lastEntry.getPlayerId(), -lastEntry.getScoreValue());
                                break;
                            case "PENALTY":
                                if (lastEntry.getPlayerId() != null)
                                    dao.updatePlayerScore(lastEntry.getPlayerId(), lastEntry.getScoreValue());
                                break;
                        }
                        dao.deleteScoreEntry(lastEntry.getId());
                        Bull b = dao.getBullById(bullId);
                        json.addProperty("success", true);
                        json.addProperty("bullScore", b.getTotalScore());
                        json.addProperty("undoneType", lastEntry.getScoreType());
                        if (lastEntry.getPlayerId() != null) {
                            Player p = dao.getPlayerById(lastEntry.getPlayerId());
                            json.addProperty("playerScore", p.getTotalScore());
                            json.addProperty("playerId", lastEntry.getPlayerId());
                        }
                        // Return refreshed player list for UI sync
                        Event event = dao.getEventById(eventId);
                        List<Player> players = getPlayersForRound(eventId, event.getCurrentRound(), event.getTotalRounds());
                        json.add("players", gson.toJsonTree(players));
                    } else {
                        json.addProperty("success", false);
                        json.addProperty("error", "Nothing to undo");
                    }
                    break;
                }
                case "undoSelectPlayer": {
                    int bullId = Integer.parseInt(req.getParameter("bullId"));
                    int eventId = Integer.parseInt(req.getParameter("eventId"));
                    String prevPlayerIdStr = req.getParameter("prevPlayerId");
                    if (prevPlayerIdStr != null && !prevPlayerIdStr.isEmpty() && !"null".equals(prevPlayerIdStr)) {
                        int prevPlayerId = Integer.parseInt(prevPlayerIdStr);
                        dao.selectCatcher(bullId, prevPlayerId);
                        Player p = dao.getPlayerById(prevPlayerId);
                        json.addProperty("success", true);
                        json.addProperty("restoredPlayerId", prevPlayerId);
                        json.addProperty("restoredPlayerName", p.getPlayerName());
                        json.addProperty("restoredPlayerScore", p.getTotalScore());
                    } else {
                        dao.clearCatcher(bullId);
                        json.addProperty("success", true);
                        json.addProperty("cleared", true);
                    }
                    // Return refreshed player list
                    Event ev = dao.getEventById(eventId);
                    List<Player> plrs = getPlayersForRound(eventId, ev.getCurrentRound(), ev.getTotalRounds());
                    json.add("players", gson.toJsonTree(plrs));
                    break;
                }
                default:
                    json.addProperty("error", "Unknown action: " + action);
            }
        } catch (Exception e) {
            json.addProperty("error", e.getMessage());
        }
        resp.getWriter().write(json.toString());
    }

    /** Helper: get players for the given round, handling QF/SF/Final */
    private List<Player> getPlayersForRound(int eventId, int round, int totalRounds) throws Exception {
        int offset = round - totalRounds;
        if (offset == 1) {         // Quarter Final – top 6
            return dao.getTopPlayersOverall(eventId, 6);
        } else if (offset == 2) {  // Semi Final – top 4
            return dao.getTopPlayersOverall(eventId, 4);
        } else if (offset >= 3) {  // Final – top 2
            return dao.getTopPlayersOverall(eventId, 2);
        } else {
            return dao.getPlayersByRound(eventId, round);
        }
    }
}
