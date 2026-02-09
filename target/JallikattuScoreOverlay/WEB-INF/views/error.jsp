<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Error - Jallikattu</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #1a1a2e; color: #eee; display: flex;
               justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .error-box { text-align: center; padding: 40px; background: #16213e; border-radius: 16px;
                     border: 1px solid #e94560; max-width: 500px; }
        .error-box h1 { color: #e94560; font-size: 3em; margin: 0; }
        .error-box p { color: #aaa; margin: 15px 0; }
        .error-box a { color: #0984e3; text-decoration: none; }
        .error-box a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="error-box">
        <h1>😵 Oops!</h1>
        <p>${not empty error ? error : 'Something went wrong.'}</p>
        <p><a href="${pageContext.request.contextPath}/login">← Go to Login</a></p>
    </div>
</body>
</html>
