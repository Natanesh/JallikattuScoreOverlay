package com.jallikattu.model;

public class Player {
    private int id;
    private int eventId;
    private String playerName;
    private String village;
    private int roundNumber;
    private int totalScore;
    private int catchCount;

    public Player() { this.roundNumber = 1; }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }
    public String getPlayerName() { return playerName; }
    public void setPlayerName(String playerName) { this.playerName = playerName; }
    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }
    public int getRoundNumber() { return roundNumber; }
    public void setRoundNumber(int roundNumber) { this.roundNumber = roundNumber; }
    public int getTotalScore() { return totalScore; }
    public void setTotalScore(int totalScore) { this.totalScore = totalScore; }
    public int getCatchCount() { return catchCount; }
    public void setCatchCount(int catchCount) { this.catchCount = catchCount; }
}
