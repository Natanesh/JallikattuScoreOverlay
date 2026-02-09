<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Jallikattu Live Overlay</title>
    <link
      rel="stylesheet"
      href="${pageContext.request.contextPath}/css/overlay.css"
    />
  </head>
  <body>
    <!-- No-Live message -->
    <div id="noLive" class="no-live">
      <div class="waiting-box">
        <div class="waiting-icon">&#x1F402;</div>
        <h1>Jallikattu Live</h1>
        <p>Waiting for match to begin...</p>
        <div class="pulse-dot"></div>
      </div>
    </div>

    <!-- Main Score Overlay -->
    <div id="overlayMain" class="overlay-main" style="display: none">
      <!-- Top Bar -->
      <div class="top-bar">
        <div class="event-title" id="eventTitle">Event Name</div>
        <div class="live-indicator">&#x25CF; LIVE</div>
      </div>

      <!-- Active Bull Scoreboard -->
      <div class="scoreboard">
        <div class="team bull-team">
          <div class="team-label">&#x1F402; BULL</div>
          <div class="team-name" id="bullName">-</div>
          <div class="team-score" id="bullScore">0</div>
        </div>
        <div class="vs-center">
          <div class="vs-text">VS</div>
        </div>
        <div class="team player-team">
          <div class="team-label">&#x1F3C3; PLAYER</div>
          <div class="team-name" id="playerName">-</div>
          <div class="team-score" id="playerScore">0</div>
        </div>
      </div>

      <!-- Catcher Status -->
      <div class="catcher-status" id="catcherStatus">
        <span id="catcherText">Waiting for catch...</span>
      </div>

      <!-- Completed Bulls Ticker -->
      <div class="completed-ticker" id="completedTicker">
        <div class="ticker-label">Completed:</div>
        <div class="ticker-items" id="tickerItems"></div>
      </div>
    </div>

    <input
      type="hidden"
      id="contextPath"
      value="${pageContext.request.contextPath}"
    />
    <script>
      var ctx = document.getElementById("contextPath").value;
      var prevBullScore = -1,
        prevPlayerScore = -1;

      function fetchScores() {
        fetch(ctx + "/api/liveScore")
          .then(function (r) {
            return r.json();
          })
          .then(function (data) {
            if (!data.live) {
              document.getElementById("noLive").style.display = "flex";
              document.getElementById("overlayMain").style.display = "none";
              return;
            }
            document.getElementById("noLive").style.display = "none";
            document.getElementById("overlayMain").style.display = "block";

            document.getElementById("eventTitle").textContent = data.eventName;
            document.getElementById("bullName").textContent = data.bullName;

            var bsEl = document.getElementById("bullScore");
            var psEl = document.getElementById("playerScore");

            if (data.bullScore !== prevBullScore) {
              bsEl.textContent = data.bullScore;
              bsEl.classList.add("score-flash");
              setTimeout(function () {
                bsEl.classList.remove("score-flash");
              }, 600);
              prevBullScore = data.bullScore;
            }

            if (data.playerName && data.playerName !== "") {
              document.getElementById("playerName").textContent =
                data.playerName;
              if (data.playerScore !== prevPlayerScore) {
                psEl.textContent = data.playerScore;
                psEl.classList.add("score-flash");
                setTimeout(function () {
                  psEl.classList.remove("score-flash");
                }, 600);
                prevPlayerScore = data.playerScore;
              }
              document.getElementById("catcherText").textContent =
                "Caught by " + data.playerName + "!";
              document.getElementById("catcherStatus").className =
                "catcher-status caught";
            } else {
              document.getElementById("playerName").textContent = "-";
              psEl.textContent = "-";
              document.getElementById("catcherText").textContent =
                "Waiting for catch...";
              document.getElementById("catcherStatus").className =
                "catcher-status";
            }

            // Completed ticker
            var items = data.completedBulls || [];
            var tickerHtml = "";
            for (var i = 0; i < items.length; i++) {
              var b = items[i];
              tickerHtml +=
                '<span class="tick-item">' +
                "<strong>" +
                b.bullName +
                "</strong> (" +
                b.bullScore +
                ") - " +
                b.caughtBy +
                " | R" +
                b.round +
                "</span>";
            }
            document.getElementById("tickerItems").innerHTML = tickerHtml;
          })
          .catch(function (err) {
            console.error("Fetch error:", err);
          });
      }

      fetchScores();
      setInterval(fetchScores, 1500);
    </script>
  </body>
</html>
