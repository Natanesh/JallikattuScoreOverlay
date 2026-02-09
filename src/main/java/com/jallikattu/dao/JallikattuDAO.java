package com.jallikattu.dao;

import com.jallikattu.model.*;
import com.jallikattu.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JallikattuDAO {

    // ======================== ADMIN AUTH ========================
    public boolean validateAdmin(String username, String password) throws SQLException {
        String sql = "SELECT COUNT(*) FROM admin_users WHERE username = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    // ======================== EVENT CRUD ========================
    public int createEvent(Event event) throws SQLException {
        String sql = "INSERT INTO events (event_name, venue, event_date, status, total_rounds) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, event.getEventName());
            ps.setString(2, event.getVenue());
            ps.setString(3, event.getEventDate());
            ps.setString(4, event.getStatus() != null ? event.getStatus() : "UPCOMING");
            ps.setInt(5, event.getTotalRounds() > 0 ? event.getTotalRounds() : 3);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            return rs.next() ? rs.getInt(1) : -1;
        }
    }

    public Event getEventById(int id) throws SQLException {
        String sql = "SELECT * FROM events WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapEvent(rs);
            return null;
        }
    }

    public List<Event> getAllEvents() throws SQLException {
        String sql = "SELECT * FROM events ORDER BY created_at DESC";
        List<Event> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapEvent(rs));
        }
        return list;
    }

    public boolean updateEventStatus(int eventId, String status) throws SQLException {
        String sql = "UPDATE events SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, eventId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateCurrentRound(int eventId, int round) throws SQLException {
        String sql = "UPDATE events SET current_round = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, round);
            ps.setInt(2, eventId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteEvent(int eventId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM events WHERE id = ?")) {
            ps.setInt(1, eventId);
            return ps.executeUpdate() > 0;
        }
    }

    // ======================== BULL OPERATIONS ========================
    public int addBull(Bull bull) throws SQLException {
        int order = 1;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT COALESCE(MAX(display_order), 0) + 1 FROM bulls WHERE event_id = ?")) {
            ps.setInt(1, bull.getEventId());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) order = rs.getInt(1);
        }
        String sql = "INSERT INTO bulls (event_id, bull_name, breed, owner_name, display_order) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, bull.getEventId());
            ps.setString(2, bull.getBullName());
            ps.setString(3, bull.getBreed());
            ps.setString(4, bull.getOwnerName());
            ps.setInt(5, order);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            return rs.next() ? rs.getInt(1) : -1;
        }
    }

    public List<Bull> getBullsByEvent(int eventId) throws SQLException {
        String sql = "SELECT b.*, p.player_name AS caught_by_name FROM bulls b " +
                     "LEFT JOIN players p ON b.caught_by_player_id = p.id " +
                     "WHERE b.event_id = ? ORDER BY b.display_order";
        List<Bull> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapBullWithCaughtBy(rs));
        }
        return list;
    }

    public List<Bull> getWaitingBulls(int eventId) throws SQLException {
        String sql = "SELECT * FROM bulls WHERE event_id = ? AND status = 'WAITING' ORDER BY display_order";
        List<Bull> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapBull(rs));
        }
        return list;
    }

    public Bull getActiveBull(int eventId) throws SQLException {
        String sql = "SELECT b.*, p.player_name AS caught_by_name FROM bulls b " +
                     "LEFT JOIN players p ON b.caught_by_player_id = p.id " +
                     "WHERE b.event_id = ? AND b.status = 'ACTIVE' LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapBullWithCaughtBy(rs);
            return null;
        }
    }

    public List<Bull> getCompletedBulls(int eventId) throws SQLException {
        String sql = "SELECT b.*, p.player_name AS caught_by_name FROM bulls b " +
                     "LEFT JOIN players p ON b.caught_by_player_id = p.id " +
                     "WHERE b.event_id = ? AND b.status = 'COMPLETED' ORDER BY b.display_order";
        List<Bull> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapBullWithCaughtBy(rs));
        }
        return list;
    }

    public Bull activateNextBull(int eventId) throws SQLException {
        String sql = "SELECT id FROM bulls WHERE event_id = ? AND status = 'WAITING' ORDER BY display_order LIMIT 1";
        int bullId = -1;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) bullId = rs.getInt("id");
            else return null;
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE bulls SET status = 'ACTIVE' WHERE id = ?")) {
            ps.setInt(1, bullId);
            ps.executeUpdate();
        }
        return getActiveBull(eventId);
    }

    public boolean completeBull(int bullId, Integer playerId, int roundNumber) throws SQLException {
        String sql = "UPDATE bulls SET status = 'COMPLETED', caught_by_player_id = ?, completed_in_round = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (playerId != null) ps.setInt(1, playerId);
            else ps.setNull(1, Types.INTEGER);
            ps.setInt(2, roundNumber);
            ps.setInt(3, bullId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean selectCatcher(int bullId, int playerId) throws SQLException {
        String sql = "UPDATE bulls SET caught_by_player_id = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, playerId);
            ps.setInt(2, bullId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean clearCatcher(int bullId) throws SQLException {
        String sql = "UPDATE bulls SET caught_by_player_id = NULL WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bullId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateBullScore(int bullId, int scoreToAdd) throws SQLException {
        String sql = "UPDATE bulls SET total_score = total_score + ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scoreToAdd);
            ps.setInt(2, bullId);
            return ps.executeUpdate() > 0;
        }
    }

    public Bull getBullById(int bullId) throws SQLException {
        String sql = "SELECT b.*, p.player_name AS caught_by_name FROM bulls b " +
                     "LEFT JOIN players p ON b.caught_by_player_id = p.id WHERE b.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bullId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapBullWithCaughtBy(rs);
            return null;
        }
    }

    public boolean deleteBull(int bullId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM bulls WHERE id = ?")) {
            ps.setInt(1, bullId);
            return ps.executeUpdate() > 0;
        }
    }

    public int getBullCount(int eventId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bulls WHERE event_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ======================== PLAYER OPERATIONS ========================
    public int addPlayer(Player player) throws SQLException {
        String sql = "INSERT INTO players (event_id, player_name, village, round_number) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, player.getEventId());
            ps.setString(2, player.getPlayerName());
            ps.setString(3, player.getVillage());
            ps.setInt(4, player.getRoundNumber());
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            return rs.next() ? rs.getInt(1) : -1;
        }
    }

    public List<Player> getPlayersByRound(int eventId, int roundNumber) throws SQLException {
        String sql = "SELECT * FROM players WHERE event_id = ? AND round_number = ? ORDER BY id";
        List<Player> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, roundNumber);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapPlayer(rs));
        }
        return list;
    }

    public List<Player> getAllPlayersByEvent(int eventId) throws SQLException {
        String sql = "SELECT * FROM players WHERE event_id = ? ORDER BY round_number, id";
        List<Player> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapPlayer(rs));
        }
        return list;
    }

    public List<Player> getFinalRoundPlayers(int eventId, int topPerRound) throws SQLException {
        String sql = "SELECT * FROM (" +
                     "  SELECT *, ROW_NUMBER() OVER (PARTITION BY round_number ORDER BY total_score DESC) as rn " +
                     "  FROM players WHERE event_id = ?" +
                     ") sub WHERE rn <= ? ORDER BY total_score DESC";
        List<Player> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, topPerRound);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapPlayer(rs));
        }
        return list;
    }

    public boolean updatePlayerScore(int playerId, int scoreChange) throws SQLException {
        String sql = "UPDATE players SET total_score = total_score + ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scoreChange);
            ps.setInt(2, playerId);
            return ps.executeUpdate() > 0;
        }
    }

    public Player getPlayerById(int playerId) throws SQLException {
        String sql = "SELECT * FROM players WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, playerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapPlayer(rs);
            return null;
        }
    }

    public boolean deletePlayer(int playerId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM players WHERE id = ?")) {
            ps.setInt(1, playerId);
            return ps.executeUpdate() > 0;
        }
    }

    public int getTotalPlayerCount(int eventId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM players WHERE event_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ======================== SCORE HISTORY ========================
    public void addScoreEntry(int eventId, int bullId, Integer playerId, String scoreType, int scoreValue, int roundNumber) throws SQLException {
        String sql = "INSERT INTO score_history (event_id, bull_id, player_id, score_type, score_value, round_number) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, bullId);
            if (playerId != null) ps.setInt(3, playerId);
            else ps.setNull(3, Types.INTEGER);
            ps.setString(4, scoreType);
            ps.setInt(5, scoreValue);
            ps.setInt(6, roundNumber);
            ps.executeUpdate();
        }
    }

    // ======================== ANALYTICS ========================
    public List<Bull> getBullAnalytics(int eventId) throws SQLException {
        String sql = "SELECT b.*, p.player_name AS caught_by_name FROM bulls b " +
                     "LEFT JOIN players p ON b.caught_by_player_id = p.id " +
                     "WHERE b.event_id = ? ORDER BY b.total_score DESC";
        List<Bull> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapBullWithCaughtBy(rs));
        }
        return list;
    }

    public List<Player> getPlayerAnalytics(int eventId) throws SQLException {
        String sql = "SELECT * FROM players WHERE event_id = ? ORDER BY total_score DESC";
        List<Player> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapPlayer(rs));
        }
        return list;
    }

    // ======================== MAPPERS ========================
    private Event mapEvent(ResultSet rs) throws SQLException {
        Event e = new Event();
        e.setId(rs.getInt("id"));
        e.setEventName(rs.getString("event_name"));
        e.setVenue(rs.getString("venue"));
        Date d = rs.getDate("event_date");
        e.setEventDate(d != null ? d.toString() : "");
        e.setStatus(rs.getString("status"));
        e.setTotalRounds(rs.getInt("total_rounds"));
        e.setCurrentRound(rs.getInt("current_round"));
        e.setCreatedAt(rs.getTimestamp("created_at"));
        e.setUpdatedAt(rs.getTimestamp("updated_at"));
        return e;
    }

    private Bull mapBull(ResultSet rs) throws SQLException {
        Bull b = new Bull();
        b.setId(rs.getInt("id"));
        b.setEventId(rs.getInt("event_id"));
        b.setBullName(rs.getString("bull_name"));
        b.setBreed(rs.getString("breed"));
        b.setOwnerName(rs.getString("owner_name"));
        b.setTotalScore(rs.getInt("total_score"));
        b.setStatus(rs.getString("status"));
        b.setCaughtByPlayerId(rs.getObject("caught_by_player_id") != null ? rs.getInt("caught_by_player_id") : null);
        b.setCompletedInRound(rs.getObject("completed_in_round") != null ? rs.getInt("completed_in_round") : null);
        b.setDisplayOrder(rs.getInt("display_order"));
        return b;
    }

    private Bull mapBullWithCaughtBy(ResultSet rs) throws SQLException {
        Bull b = mapBull(rs);
        try { b.setCaughtByPlayerName(rs.getString("caught_by_name")); } catch (SQLException ignored) {}
        return b;
    }

    private Player mapPlayer(ResultSet rs) throws SQLException {
        Player p = new Player();
        p.setId(rs.getInt("id"));
        p.setEventId(rs.getInt("event_id"));
        p.setPlayerName(rs.getString("player_name"));
        p.setVillage(rs.getString("village"));
        p.setRoundNumber(rs.getInt("round_number"));
        p.setTotalScore(rs.getInt("total_score"));
        return p;
    }
}