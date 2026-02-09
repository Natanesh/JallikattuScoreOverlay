package com.jallikattu.model;

import java.sql.Timestamp;

public class ScoreEntry {
    private int id;
    private int eventId;
    private int bullId;
    private Integer playerId;
    private String scoreType; // BULL, PLAYER, PENALTY
    private int scoreValue;
    private int roundNumber;
    private Timestamp recordedAt;

    public ScoreEntry() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }
    public int getBullId() { return bullId; }
    public void setBullId(int bullId) { this.bullId = bullId; }
    public Integer getPlayerId() { return playerId; }
    public void setPlayerId(Integer playerId) { this.playerId = playerId; }
    public String getScoreType() { return scoreType; }
    public void setScoreType(String scoreType) { this.scoreType = scoreType; }
    public int getScoreValue() { return scoreValue; }
    public void setScoreValue(int scoreValue) { this.scoreValue = scoreValue; }
    public int getRoundNumber() { return roundNumber; }
    public void setRoundNumber(int roundNumber) { this.roundNumber = roundNumber; }
    public Timestamp getRecordedAt() { return recordedAt; }
    public void setRecordedAt(Timestamp recordedAt) { this.recordedAt = recordedAt; }
}
