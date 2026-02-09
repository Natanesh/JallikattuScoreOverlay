// ===== Configuration =====
const ctx = document.getElementById("contextPath").value;
const eventId = parseInt(document.getElementById("eventId").value);
const totalRounds = parseInt(document.getElementById("totalRounds").value);

// ===== State =====
let state = {
  activeBull: null,
  selectedPlayer: null,
  waitingBulls: [],
  completedBulls: [],
  players: [],
  matchComplete: false,
  currentRound: 1,
};

// ===== Undo Stack =====
// Tracks actions within the current bull session. Cleared on next bull / bull load.
// Each entry: { action: 'score'|'selectPlayer'|'clearPlayer', ...params }
let undoStack = [];

// ===== Init =====
generateScoreButtons();
loadMatchState();

function generateScoreButtons() {
  let html = "";
  for (let i = 1; i <= 10; i++) {
    html +=
      '<button class="score-btn bull-btn" onclick="addScore(\'bullScore\', ' +
      i +
      ')">' +
      i +
      "</button>";
  }
  document.getElementById("bullScoreButtons").innerHTML = html;

  html = "";
  for (let i = 1; i <= 10; i++) {
    html +=
      '<button class="score-btn player-btn" onclick="addScore(\'playerScore\', ' +
      i +
      ')">' +
      i +
      "</button>";
  }
  document.getElementById("playerScoreButtons").innerHTML = html;

  html = "";
  for (let i = 1; i <= 10; i++) {
    html +=
      '<button class="score-btn penalty-btn" onclick="addScore(\'penalty\', ' +
      i +
      ')">' +
      i +
      "</button>";
  }
  document.getElementById("penaltyButtons").innerHTML = html;
}

// ===== Data Loading =====
function loadMatchState() {
  fetch(ctx + "/api/match?eventId=" + eventId)
    .then(function (r) {
      return r.json();
    })
    .then(function (data) {
      if (data.error) {
        console.error(data.error);
        return;
      }

      state.activeBull = data.activeBull || null;
      state.matchComplete = data.matchComplete || false;
      state.waitingBulls = data.waitingBulls || [];
      state.completedBulls = data.completedBulls || [];
      state.players = data.players || [];
      state.selectedPlayer = null;

      if (data.event) {
        state.currentRound = data.event.currentRound;
        document.getElementById("roundSelect").value = data.event.currentRound;
        updateRoundLabel(data.event.currentRound);
      }

      undoStack = []; // Clear undo stack when bull is loaded/reloaded
      renderAll();
    })
    .catch(function (err) {
      console.error("Load error:", err);
    });
}

function renderAll() {
  renderBullList();
  renderPlayerList();
  renderOverlay();
  renderScoreButtons();
  renderCompleted();
  renderUndoButton();

  if (state.matchComplete) {
    disableAll();
  }
}

function renderUndoButton() {
  var btn = document.getElementById("undoBtn");
  if (!state.matchComplete && state.activeBull) {
    btn.style.display = "inline-block";
    if (undoStack.length > 0) {
      btn.disabled = false;
      btn.style.opacity = "1";
      btn.title = "Undo: " + undoStack[undoStack.length - 1].label;
    } else {
      btn.disabled = true;
      btn.style.opacity = "0.4";
      btn.title = "Nothing to undo";
    }
  } else {
    btn.style.display = "none";
  }
}

// ===== Rendering =====
function renderBullList() {
  var el = document.getElementById("bullList");
  if (state.waitingBulls.length === 0) {
    el.innerHTML = '<div class="empty-item">No bulls waiting</div>';
    return;
  }
  var html = "";
  for (var i = 0; i < state.waitingBulls.length; i++) {
    var b = state.waitingBulls[i];
    html +=
      '<div class="list-item' +
      (i === 0 ? " next-up" : "") +
      '">' +
      '<span class="item-name">' +
      escapeHtml(b.bullName) +
      "</span>" +
      '<span class="item-detail">' +
      escapeHtml(b.breed || "") +
      "</span>" +
      "</div>";
  }
  el.innerHTML = html;
}

function renderPlayerList() {
  var el = document.getElementById("playerList");
  if (state.players.length === 0) {
    el.innerHTML = '<div class="empty-item">No players in this round</div>';
    return;
  }
  var html = "";
  for (var i = 0; i < state.players.length; i++) {
    var p = state.players[i];
    var isSelected = state.selectedPlayer && state.selectedPlayer.id === p.id;
    html +=
      '<div class="list-item player-item' +
      (isSelected ? " selected" : "") +
      '" ' +
      'onclick="selectPlayer(' +
      p.id +
      ", '" +
      escapeHtml(p.playerName).replace(/'/g, "\\'") +
      "', " +
      p.totalScore +
      ')">' +
      '<span class="item-name">' +
      escapeHtml(p.playerName) +
      "</span>" +
      '<span class="item-catch-count" title="Bulls caught">' +
      (p.catchCount || 0) +
      " &#x1F402;</span>" +
      '<span class="item-score">' +
      p.totalScore +
      "</span>" +
      "</div>";
  }
  el.innerHTML = html;
}

function renderOverlay() {
  if (state.matchComplete) {
    document.getElementById("ovBullName").textContent = "-";
    document.getElementById("ovBullScore").textContent = "-";
    document.getElementById("ovPlayerName").textContent = "-";
    document.getElementById("ovPlayerScore").textContent = "-";
    return;
  }

  if (state.activeBull) {
    document.getElementById("ovBullName").textContent =
      state.activeBull.bullName;
    document.getElementById("ovBullScore").textContent =
      state.activeBull.totalScore;
  } else {
    document.getElementById("ovBullName").textContent = "-";
    document.getElementById("ovBullScore").textContent = "0";
  }

  if (state.selectedPlayer) {
    document.getElementById("ovPlayerName").textContent =
      state.selectedPlayer.playerName;
    document.getElementById("ovPlayerScore").textContent =
      state.selectedPlayer.totalScore;
    document.getElementById("clearPlayerBtn").style.display = "inline-block";
  } else if (state.activeBull && state.activeBull.caughtByPlayerName) {
    document.getElementById("ovPlayerName").textContent =
      state.activeBull.caughtByPlayerName;
    // Find the player score from the players list
    var foundScore = 0;
    if (state.activeBull.caughtByPlayerId) {
      for (var i = 0; i < state.players.length; i++) {
        if (state.players[i].id === state.activeBull.caughtByPlayerId) {
          foundScore = state.players[i].totalScore;
          break;
        }
      }
    }
    document.getElementById("ovPlayerScore").textContent = foundScore;
    document.getElementById("clearPlayerBtn").style.display = "inline-block";
  } else {
    document.getElementById("ovPlayerName").textContent = "-";
    document.getElementById("ovPlayerScore").textContent = "-";
    document.getElementById("clearPlayerBtn").style.display = "none";
  }
}

function renderScoreButtons() {
  if (state.matchComplete || !state.activeBull) {
    document.getElementById("scoreSection").style.display = "none";
    return;
  }
  document.getElementById("scoreSection").style.display = "block";

  if (state.selectedPlayer) {
    document.getElementById("bullScoreSection").style.display = "none";
    document.getElementById("playerScoreSection").style.display = "block";
    document.getElementById("penaltySection").style.display = "block";
  } else {
    document.getElementById("bullScoreSection").style.display = "block";
    document.getElementById("playerScoreSection").style.display = "none";
    document.getElementById("penaltySection").style.display = "none";
  }
}

function renderCompleted() {
  var el = document.getElementById("completedList");
  if (state.completedBulls.length === 0) {
    el.innerHTML = '<div class="empty-item">No completed bulls yet</div>';
    return;
  }
  var html = "";
  for (var i = 0; i < state.completedBulls.length; i++) {
    var b = state.completedBulls[i];
    html +=
      '<div class="completed-item">' +
      '<div class="completed-bull">' +
      '<span class="item-name">' +
      escapeHtml(b.bullName) +
      "</span>" +
      '<span class="item-score">' +
      b.totalScore +
      "</span>" +
      "</div>" +
      '<div class="completed-detail">' +
      "Caught by: <strong>" +
      escapeHtml(b.caughtByPlayerName || "None") +
      "</strong> | Round " +
      (b.completedInRound || "-") +
      "</div></div>";
  }
  el.innerHTML = html;
}

function updateRoundLabel(round) {
  var offset = round - totalRounds;
  var label;
  if (offset === 1) label = "Quarter Final";
  else if (offset === 2) label = "Semi Final";
  else if (offset >= 3) label = "Final";
  else label = "Round " + round;
  document.getElementById("roundLabel").textContent = "(" + label + ")";
}

// ===== Actions =====
function selectPlayer(playerId, playerName, playerScore) {
  if (state.matchComplete || !state.activeBull) return;

  state.selectedPlayer = {
    id: playerId,
    playerName: playerName,
    totalScore: playerScore,
  };

  // Track previous player for undo
  var prevPlayerId = state.activeBull.caughtByPlayerId || null;
  var prevPlayerName = state.activeBull.caughtByPlayerName || null;

  // Update bull's caught_by in DB
  fetch(ctx + "/api/score", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body:
      "action=selectPlayer&bullId=" +
      state.activeBull.id +
      "&playerId=" +
      playerId,
  })
    .then(function (r) {
      return r.json();
    })
    .then(function (data) {
      if (data.success) {
        undoStack.push({
          action: "selectPlayer",
          bullId: state.activeBull.id,
          prevPlayerId: prevPlayerId,
          prevPlayerName: prevPlayerName,
          label: "Select " + playerName,
        });
        state.activeBull.caughtByPlayerId = playerId;
        state.activeBull.caughtByPlayerName = playerName;
        state.selectedPlayer.totalScore = data.playerScore;
        renderOverlay();
        renderScoreButtons();
        renderPlayerList();
        renderUndoButton();
      }
    });
}

function clearPlayer() {
  if (state.matchComplete || !state.activeBull) return;

  var prevPlayerId =
    state.activeBull.caughtByPlayerId ||
    (state.selectedPlayer ? state.selectedPlayer.id : null);
  var prevPlayerName =
    state.activeBull.caughtByPlayerName ||
    (state.selectedPlayer ? state.selectedPlayer.playerName : null);

  fetch(ctx + "/api/score", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: "action=clearPlayer&bullId=" + state.activeBull.id,
  })
    .then(function (r) {
      return r.json();
    })
    .then(function (data) {
      if (data.success) {
        undoStack.push({
          action: "clearPlayer",
          bullId: state.activeBull.id,
          prevPlayerId: prevPlayerId,
          prevPlayerName: prevPlayerName,
          label: "Clear " + (prevPlayerName || "player"),
        });
        state.selectedPlayer = null;
        state.activeBull.caughtByPlayerId = null;
        state.activeBull.caughtByPlayerName = null;
        renderOverlay();
        renderScoreButtons();
        renderPlayerList();
        renderUndoButton();
      }
    });
}

function addScore(type, value) {
  if (state.matchComplete || !state.activeBull) return;

  var round = document.getElementById("roundSelect").value;
  var params =
    "action=" +
    type +
    "&bullId=" +
    state.activeBull.id +
    "&eventId=" +
    eventId +
    "&round=" +
    round +
    "&value=" +
    value;

  if (type === "playerScore" || type === "penalty") {
    if (!state.selectedPlayer) return;
    params += "&playerId=" + state.selectedPlayer.id;
  }

  fetch(ctx + "/api/score", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: params,
  })
    .then(function (r) {
      return r.json();
    })
    .then(function (data) {
      if (data.success) {
        var undoLabel = "";
        if (type === "bullScore") {
          state.activeBull.totalScore = data.bullScore;
          undoLabel = "Bull +" + value;
        } else if (type === "playerScore") {
          state.selectedPlayer.totalScore = data.playerScore;
          updatePlayerInList(state.selectedPlayer.id, data.playerScore);
          undoLabel = "Player +" + value;
        } else if (type === "penalty") {
          state.selectedPlayer.totalScore = data.playerScore;
          updatePlayerInList(state.selectedPlayer.id, data.playerScore);
          undoLabel = "Penalty -" + value;
        }
        undoStack.push({
          action: "score",
          scoreType: type,
          bullId: state.activeBull.id,
          playerId: state.selectedPlayer ? state.selectedPlayer.id : null,
          value: value,
          label: undoLabel,
        });
        renderOverlay();
        renderPlayerList();
        renderUndoButton();
      }
    });
}

function nextBull() {
  if (state.matchComplete || !state.activeBull) return;

  var round = document.getElementById("roundSelect").value;

  fetch(ctx + "/api/score", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body:
      "action=next&bullId=" +
      state.activeBull.id +
      "&eventId=" +
      eventId +
      "&round=" +
      round,
  })
    .then(function (r) {
      return r.json();
    })
    .then(function (data) {
      if (data.success) {
        state.selectedPlayer = null;
        undoStack = []; // Clear undo stack on next bull
        loadMatchState();
      }
    });
}

function changeRound(round) {
  if (!round) return;

  fetch(ctx + "/api/score", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: "action=changeRound&eventId=" + eventId + "&round=" + round,
  })
    .then(function (r) {
      return r.json();
    })
    .then(function (data) {
      if (data.success) {
        state.selectedPlayer = null;
        state.currentRound = parseInt(round);
        state.players = data.players || [];
        updateRoundLabel(parseInt(round));
        renderPlayerList();
        renderOverlay();
        renderScoreButtons();
      }
    });
}

function viewAnalytics() {
  fetch(ctx + "/api/match?eventId=" + eventId + "&action=analytics")
    .then(function (r) {
      return r.json();
    })
    .then(function (data) {
      // Render player analytics
      var ptbody = document.querySelector("#playerAnalyticsTable tbody");
      var phtml = "";
      var players = data.players || [];
      for (var i = 0; i < players.length; i++) {
        var p = players[i];
        phtml +=
          "<tr><td>" +
          (i + 1) +
          "</td><td><strong>" +
          escapeHtml(p.playerName) +
          "</strong></td>" +
          "<td>" +
          escapeHtml(p.village || "") +
          "</td><td>Round " +
          p.roundNumber +
          "</td>" +
          '<td class="score-cell">' +
          (p.catchCount || 0) +
          "</td>" +
          '<td class="score-cell">' +
          p.totalScore +
          "</td></tr>";
      }
      ptbody.innerHTML = phtml;

      // Render bull analytics
      var btbody = document.querySelector("#bullAnalyticsTable tbody");
      var bhtml = "";
      var bulls = data.bulls || [];
      for (var i = 0; i < bulls.length; i++) {
        var b = bulls[i];
        bhtml +=
          "<tr><td>" +
          (i + 1) +
          "</td><td><strong>" +
          escapeHtml(b.bullName) +
          "</strong></td>" +
          "<td>" +
          escapeHtml(b.breed || "") +
          '</td><td class="score-cell">' +
          b.totalScore +
          "</td>" +
          "<td>" +
          escapeHtml(b.caughtByPlayerName || "None") +
          "</td></tr>";
      }
      btbody.innerHTML = bhtml;

      document.getElementById("analyticsModal").style.display = "flex";
    });
}

function closeAnalytics() {
  document.getElementById("analyticsModal").style.display = "none";
}

// ===== Undo =====
function undoAction() {
  if (undoStack.length === 0 || state.matchComplete || !state.activeBull)
    return;

  var entry = undoStack.pop();

  if (entry.action === "score") {
    fetch(ctx + "/api/score", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body:
        "action=undoScore&bullId=" +
        state.activeBull.id +
        "&eventId=" +
        eventId,
    })
      .then(function (r) {
        return r.json();
      })
      .then(function (data) {
        if (data.success) {
          state.activeBull.totalScore = data.bullScore;
          if (
            data.playerId &&
            state.selectedPlayer &&
            state.selectedPlayer.id === data.playerId
          ) {
            state.selectedPlayer.totalScore = data.playerScore;
          }
          // Refresh full player list from server
          if (data.players) {
            state.players = data.players;
          }
          renderOverlay();
          renderPlayerList();
          renderUndoButton();
        } else {
          undoStack.push(entry);
          renderUndoButton();
        }
      })
      .catch(function () {
        undoStack.push(entry);
        renderUndoButton();
      });
  } else if (entry.action === "selectPlayer") {
    fetch(ctx + "/api/score", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body:
        "action=undoSelectPlayer&bullId=" +
        state.activeBull.id +
        "&eventId=" +
        eventId +
        "&prevPlayerId=" +
        (entry.prevPlayerId || ""),
    })
      .then(function (r) {
        return r.json();
      })
      .then(function (data) {
        if (data.success) {
          if (data.cleared) {
            state.selectedPlayer = null;
            state.activeBull.caughtByPlayerId = null;
            state.activeBull.caughtByPlayerName = null;
          } else {
            state.activeBull.caughtByPlayerId = data.restoredPlayerId;
            state.activeBull.caughtByPlayerName = data.restoredPlayerName;
            state.selectedPlayer = {
              id: data.restoredPlayerId,
              playerName: data.restoredPlayerName,
              totalScore: data.restoredPlayerScore,
            };
          }
          if (data.players) {
            state.players = data.players;
          }
          renderOverlay();
          renderScoreButtons();
          renderPlayerList();
          renderUndoButton();
        } else {
          undoStack.push(entry);
          renderUndoButton();
        }
      })
      .catch(function () {
        undoStack.push(entry);
        renderUndoButton();
      });
  } else if (entry.action === "clearPlayer") {
    if (entry.prevPlayerId) {
      fetch(ctx + "/api/score", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body:
          "action=selectPlayer&bullId=" +
          state.activeBull.id +
          "&playerId=" +
          entry.prevPlayerId,
      })
        .then(function (r) {
          return r.json();
        })
        .then(function (data) {
          if (data.success) {
            state.activeBull.caughtByPlayerId = entry.prevPlayerId;
            state.activeBull.caughtByPlayerName = entry.prevPlayerName;
            state.selectedPlayer = {
              id: entry.prevPlayerId,
              playerName: entry.prevPlayerName || data.playerName,
              totalScore: data.playerScore,
            };
            renderOverlay();
            renderScoreButtons();
            renderPlayerList();
            renderUndoButton();
          } else {
            undoStack.push(entry);
            renderUndoButton();
          }
        })
        .catch(function () {
          undoStack.push(entry);
          renderUndoButton();
        });
    }
  }
}

// ===== Helpers =====
function disableAll() {
  document.getElementById("scoreSection").style.display = "none";
  document.getElementById("nextBtn").disabled = true;
  document.getElementById("nextBtn").style.opacity = "0.5";
  document.getElementById("matchCompleteBanner").style.display = "block";
  document.getElementById("overlayCard").classList.add("disabled");
}

function updatePlayerInList(playerId, newScore) {
  for (var i = 0; i < state.players.length; i++) {
    if (state.players[i].id === playerId) {
      state.players[i].totalScore = newScore;
      break;
    }
  }
}

function escapeHtml(text) {
  if (!text) return "";
  var div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}
