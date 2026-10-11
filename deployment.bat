@echo off
REM ====================================================================
REM AI ORBIT — Windows Local Build & Vercel Deploy Script
REM ====================================================================

echo 🚀 [AI Orbit] Starting Local Build for Vercel...

echo 📦 [AI Orbit] Running Flutter Pub Get...
call flutter pub get

echo ⚡ [AI Orbit] Building Flutter Web (Release)...
call flutter build web --release --no-tree-shake-icons

echo 🌌 [AI Orbit] Syncing universe.html asset...
if exist "web\universe.html" (
    copy /Y "web\universe.html" "build\web\universe.html" >nul
    echo ✅ [AI Orbit] universe.html synced to build/web/.
)

echo.
echo 🎉 [AI Orbit] Build ready in build/web!
echo 🚀 If you have Vercel CLI installed, deploy with:
echo    vercel --prod
echo.
pause
