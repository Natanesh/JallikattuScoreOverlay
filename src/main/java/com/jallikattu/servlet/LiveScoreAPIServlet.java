package com.jallikattu.servlet;

import com.jallikattu.dao.JallikattuDAO;
import com.jallikattu.model.*;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/liveScore")
public class LiveScoreAPIServlet extends HttpServlet {
    private final JallikattuDAO dao = new JallikattuDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Access-Control-Allow-Origin", "*");

        JsonObject result = new JsonObject();
        try {
            String eventIdStr = req.getParameter("eventId");

            // Find a LIVE event
            Event liveEvent = null;
            if (eventIdStr != null && !eventIdStr.isEmpty()) {
                Event e = dao.getEventById(Integer.parseInt(eventIdStr));
                if (e != null && "LIVE".equals(e.getStatus())) liveEvent = e;
            } else {
                for (Event e : dao.getAllEvents()) {
                    if ("LIVE".equals(e.getStatus())) { liveEvent = e; break; }
                }
            }

            if (liveEvent == null) {
                result.addProperty("live", false);
                result.addProperty("message", "No live event");
                resp.getWriter().write(result.toString());
                return;
            }

            Bull activeBull = dao.getActiveBull(liveEvent.getId());
            if (activeBull == null) {
                result.addProperty("live", false);
                result.addProperty("message", "No active bull");
                resp.getWriter().write(result.toString());
                return;
            }

            result.addProperty("live", true);
            result.addProperty("eventId", liveEvent.getId());
            result.addProperty("eventName", liveEvent.getEventName());
            result.addProperty("venue", liveEvent.getVenue());
            result.addProperty("eventDate", liveEvent.getEventDate());
            result.addProperty("currentRound", liveEvent.getCurrentRound());
            result.addProperty("totalRounds", liveEvent.getTotalRounds());
            result.addProperty("videoUrl", liveEvent.getVideoUrl() != null ? liveEvent.getVideoUrl() : "");
            result.addProperty("bullName", activeBull.getBullName());
            result.addProperty("bullBreed", activeBull.getBreed() != null ? activeBull.getBreed() : "");
            result.addProperty("bullScore", activeBull.getTotalScore());

            if (activeBull.getCaughtByPlayerId() != null) {
                result.addProperty("playerName", activeBull.getCaughtByPlayerName() != null ?
                    activeBull.getCaughtByPlayerName() : "");
                Player p = dao.getPlayerById(activeBull.getCaughtByPlayerId());
                result.addProperty("playerScore", p != null ? p.getTotalScore() : 0);
                result.addProperty("hasCatcher", true);
            } else {
                result.addProperty("playerName", "");
                result.addProperty("playerScore", 0);
                result.addProperty("hasCatcher", false);
            }

            // Completed bulls
            List<Bull> completed = dao.getCompletedBulls(liveEvent.getId());
            JsonArray compArr = new JsonArray();
            for (Bull b : completed) {
                JsonObject bo = new JsonObject();
                bo.addProperty("bullName", b.getBullName());
                bo.addProperty("bullScore", b.getTotalScore());
                bo.addProperty("caughtBy", b.getCaughtByPlayerName() != null ? b.getCaughtByPlayerName() : "None");
                bo.addProperty("round", b.getCompletedInRound() != null ? b.getCompletedInRound() : 0);
                compArr.add(bo);
            }
            result.add("completedBulls", compArr);

        } catch (Exception e) {
            result.addProperty("error", e.getMessage());
        }
        resp.getWriter().write(result.toString());
    }
}
