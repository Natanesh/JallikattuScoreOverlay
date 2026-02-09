<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ taglib
prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>
      Jallikattu Live - ${event != null ? event.eventName : 'Watch Live'}
    </title>
    <link
      rel="stylesheet"
      href="${pageContext.request.contextPath}/css/overlay.css"
    />
  </head>
  <body>
    <!-- No-Live waiting screen -->
    <div id="noLive" class="no-live">
      <div class="waiting-box">
        <div class="waiting-icon">&#x1F402;</div>
        <h1>Jallikattu Live</h1>
        <p id="waitMsg">Waiting for match to begin...</p>
        <div class="pulse-dot"></div>
      </div>
    </div>

    <!-- Main Live Page -->
    <div id="livePage" class="live-page" style="display: none">
      <!-- ===== Main Viewport (fills screen) ===== -->
      <div class="main-viewport">
        <!-- Top Header Bar -->
        <div class="top-bar">
          <div class="top-bar-left">
            <span class="event-icon">&#x1F402;</span>
            <div class="event-info-bar">
              <div class="event-title" id="eventTitle">Event Name</div>
              <div class="event-meta" id="eventMeta">Venue &bull; Date</div>
            </div>
          </div>
          <div class="top-bar-right">
            <div class="live-indicator">&#x25CF; LIVE</div>
            <button
              id="analyticsBtn"
              class="btn-analytics-nav"
              onclick="toggleAnalytics()"
            >
              &#x1F4CA; Analytics
            </button>
            <div class="round-badge" id="roundBadge">Round 1</div>
          </div>
        </div>

        <!-- Video Section -->
        <div class="video-section" id="videoSection">
          <div class="video-container" id="videoContainer">
            <div class="no-video-placeholder" id="noVideoPlaceholder">
              <span>&#x1F3AC;</span>
              <p>Live video not available</p>
            </div>
          </div>
        </div>

        <!-- Score Overlay Section -->
        <div class="score-overlay-section">
          <div class="overlay-card">
            <table class="overlay-table">
              <thead>
                <tr>
                  <th class="bull-col">Bull Name</th>
                  <th class="bull-col">Bull Score</th>
                  <th class="player-col">Player Name</th>
                  <th class="player-col">Player Score</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="bull-col">
                    <div id="bullName">-</div>
                    <div id="bullBreed" class="breed-text"></div>
                  </td>
                  <td id="bullScore" class="bull-col score-val">0</td>
                  <td id="playerName" class="player-col">-</td>
                  <td id="playerScore" class="player-col score-val">0</td>
                </tr>
              </tbody>
            </table>
            <div id="catcherBar" class="catcher-bar">
              <span id="catcherText">Waiting for catch...</span>
            </div>
          </div>
        </div>
      </div>
      <!-- ===== END Main Viewport ===== -->

      <!-- Completed Bulls Ticker (below fold - scroll to see) -->
      <div class="completed-section" id="completedSection">
        <div class="ticker-label">&#x2705; Completed</div>
        <div class="ticker-items" id="tickerItems"></div>
      </div>

      <!-- Analytics Panel -->
      <div id="analyticsPanel" class="analytics-panel" style="display: none">
        <div class="analytics-header">
          <h2>&#x1F4CA; Match Analytics</h2>
          <button class="btn-close-analytics" onclick="toggleAnalytics()">
            &#x2715; Close
          </button>
        </div>
        <div class="analytics-content">
          <div class="analytics-grid">
            <div class="analytics-card">
              <h3>&#x1F402; Bull Leaderboard</h3>
              <table class="analytics-table">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Bull</th>
                    <th>Breed</th>
                    <th>Score</th>
                    <th>Caught By</th>
                    <th>Round</th>
                  </tr>
                </thead>
                <tbody id="bullAnalyticsBody"></tbody>
              </table>
            </div>
            <div class="analytics-card">
              <h3>&#x1F3C3; Player Leaderboard</h3>
              <table class="analytics-table">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Player</th>
                    <th>Village</th>
                    <th>Score</th>
                    <th>Catches</th>
                    <th>Round</th>
                  </tr>
                </thead>
                <tbody id="playerAnalyticsBody"></tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <input
      type="hidden"
      id="contextPath"
      value="${pageContext.request.contextPath}"
    />
    <input
      type="hidden"
      id="eventIdParam"
      value="${eventId != null ? eventId : ''}"
    />
    <input
      type="hidden"
      id="eventVideoUrl"
      value="${event != null && event.videoUrl != null ? event.videoUrl : ''}"
    />

    <script>
      var ctx = document.getElementById("contextPath").value;
      var eventIdParam = document.getElementById("eventIdParam").value;
      var prevBullScore = -1,
        prevPlayerScore = -1;
      var analyticsOpen = false;
      var videoLoaded = false;

      function extractYouTubeId(url) {
        if (!url) return null;
        var match = url.match(
          /(?:youtube\.com\/(?:watch\?v=|embed\/|v\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/,
        );
        return match ? match[1] : null;
      }

      function loadVideo(videoUrl) {
        if (videoLoaded) return;
        var container = document.getElementById("videoContainer");
        var videoId = extractYouTubeId(videoUrl);
        if (videoId) {
          container.innerHTML =
            '<iframe id="ytPlayer" ' +
            'src="https://www.youtube.com/embed/' +
            videoId +
            "?autoplay=1&mute=1&loop=1&playlist=" +
            videoId +
            '&controls=1&modestbranding=1&rel=0&playsinline=1" ' +
            'style="position:absolute;top:0;left:0;width:100%;height:100%;" ' +
            'frameborder="0" loading="eager" ' +
            'referrerpolicy="no-referrer-when-downgrade" ' +
            'allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" ' +
            "allowfullscreen></iframe>";
          videoLoaded = true;
        }
      }

      function fetchScores() {
        var url = ctx + "/api/liveScore";
        if (eventIdParam) url += "?eventId=" + eventIdParam;

        fetch(url)
          .then(function (r) {
            return r.json();
          })
          .then(function (data) {
            if (!data.live) {
              document.getElementById("noLive").style.display = "flex";
              document.getElementById("livePage").style.display = "none";
              document.getElementById("waitMsg").textContent =
                data.message === "No active bull"
                  ? "Match paused - waiting for next bull..."
                  : "Waiting for match to begin...";
              return;
            }

            document.getElementById("noLive").style.display = "none";
            document.getElementById("livePage").style.display = "block";

            if (!eventIdParam && data.eventId) eventIdParam = data.eventId;

            // Event info
            document.getElementById("eventTitle").textContent = data.eventName;
            document.getElementById("eventMeta").textContent =
              (data.venue || "") + " \u2022 " + (data.eventDate || "");

            // Round
            var roundNum = data.currentRound || 1;
            var totalRounds = data.totalRounds || 3;
            var roundText;
            var offset = roundNum - totalRounds;
            if (offset === 1) roundText = "Quarter Final";
            else if (offset === 2) roundText = "Semi Final";
            else if (offset >= 3) roundText = "Final";
            else roundText = "Round " + roundNum + " / " + totalRounds;
            document.getElementById("roundBadge").textContent = roundText;

            // Video - only load after page is visible
            if (!videoLoaded) {
              var vUrl =
                data.videoUrl || document.getElementById("eventVideoUrl").value;
              if (vUrl) loadVideo(vUrl);
            }

            // Bull
            document.getElementById("bullName").textContent = data.bullName;
            var breedEl = document.getElementById("bullBreed");
            if (breedEl) breedEl.textContent = data.bullBreed || "";

            var bsEl = document.getElementById("bullScore");
            if (data.bullScore !== prevBullScore) {
              bsEl.textContent = data.bullScore;
              bsEl.classList.add("score-flash");
              setTimeout(function () {
                bsEl.classList.remove("score-flash");
              }, 600);
              prevBullScore = data.bullScore;
            }

            // Player
            var psEl = document.getElementById("playerScore");
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
              document.getElementById("catcherBar").className =
                "catcher-bar caught";
            } else {
              document.getElementById("playerName").textContent = "-";
              psEl.textContent = "-";
              document.getElementById("catcherText").textContent =
                "Waiting for catch...";
              document.getElementById("catcherBar").className = "catcher-bar";
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
                (b.caughtBy || "None") +
                " | R" +
                b.round +
                "</span>";
            }
            document.getElementById("tickerItems").innerHTML = tickerHtml;

            if (analyticsOpen) fetchAnalytics();
          })
          .catch(function (err) {
            console.error("Fetch error:", err);
          });
      }

      function toggleAnalytics() {
        analyticsOpen = !analyticsOpen;
        var panel = document.getElementById("analyticsPanel");
        panel.style.display = analyticsOpen ? "block" : "none";
        document.getElementById("analyticsBtn").innerHTML = analyticsOpen
          ? "&#x2715; Close"
          : "&#x1F4CA; Analytics";
        if (analyticsOpen) {
          fetchAnalytics();
          panel.scrollIntoView({ behavior: "smooth" });
        }
      }

      function fetchAnalytics() {
        var eid = eventIdParam;
        if (!eid) return;
        fetch(ctx + "/api/match?eventId=" + eid + "&action=analytics")
          .then(function (r) {
            return r.json();
          })
          .then(function (data) {
            var bulls = data.bulls || [];
            var bullHtml = "";
            for (var i = 0; i < bulls.length; i++) {
              var b = bulls[i];
              bullHtml +=
                "<tr><td>" +
                (i + 1) +
                "</td>" +
                "<td><strong>" +
                b.bullName +
                "</strong></td>" +
                "<td>" +
                (b.breed || "") +
                "</td>" +
                '<td class="score-col">' +
                b.totalScore +
                "</td>" +
                "<td>" +
                (b.caughtByPlayerName || "-") +
                "</td>" +
                "<td>R" +
                (b.completedInRound || "-") +
                "</td></tr>";
            }
            document.getElementById("bullAnalyticsBody").innerHTML =
              bullHtml || '<tr><td colspan="6">No data</td></tr>';

            var players = data.players || [];
            var playerHtml = "";
            for (var i = 0; i < players.length; i++) {
              var p = players[i];
              playerHtml +=
                "<tr><td>" +
                (i + 1) +
                "</td>" +
                "<td><strong>" +
                p.playerName +
                "</strong></td>" +
                "<td>" +
                (p.village || "") +
                "</td>" +
                '<td class="score-col">' +
                p.totalScore +
                "</td>" +
                "<td>" +
                (p.catchCount || 0) +
                "</td>" +
                "<td>R" +
                p.roundNumber +
                "</td></tr>";
            }
            document.getElementById("playerAnalyticsBody").innerHTML =
              playerHtml || '<tr><td colspan="6">No data</td></tr>';
          })
          .catch(function (err) {
            console.error("Analytics error:", err);
          });
      }

      // Don't preload video while page is hidden (breaks autoplay).
      // Video will be loaded once fetchScores detects LIVE status.

      fetchScores();
      setInterval(fetchScores, 2000);
    </script>
  </body>
</html>
