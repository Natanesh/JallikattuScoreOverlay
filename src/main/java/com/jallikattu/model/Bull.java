package com.jallikattu.model;

public class Bull {
    private int id;
    private int eventId;
    private String bullName;
    private String breed;
    private String ownerName;
    private int totalScore;
    private String status; // WAITING, ACTIVE, COMPLETED
    private Integer caughtByPlayerId;
    private Integer completedInRound;
    private int displayOrder;
    // Transient join field
    private String caughtByPlayerName;

    public Bull() { this.status = "WAITING"; }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }
    public String getBullName() { return bullName; }
    public void setBullName(String bullName) { this.bullName = bullName; }
    public String getBreed() { return breed; }
    public void setBreed(String breed) { this.breed = breed; }
    public String getOwnerName() { return ownerName; }
    public void setOwnerName(String ownerName) { this.ownerName = ownerName; }
    public int getTotalScore() { return totalScore; }
    public void setTotalScore(int totalScore) { this.totalScore = totalScore; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getCaughtByPlayerId() { return caughtByPlayerId; }
    public void setCaughtByPlayerId(Integer caughtByPlayerId) { this.caughtByPlayerId = caughtByPlayerId; }
    public Integer getCompletedInRound() { return completedInRound; }
    public void setCompletedInRound(Integer completedInRound) { this.completedInRound = completedInRound; }
    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }
    public String getCaughtByPlayerName() { return caughtByPlayerName; }
    public void setCaughtByPlayerName(String caughtByPlayerName) { this.caughtByPlayerName = caughtByPlayerName; }
}
