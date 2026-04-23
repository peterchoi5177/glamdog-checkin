#!/bin/bash
# ============================================================
# 글램독 자동화 시스템 — iMac 최초 세팅 스크립트
# iMac 터미널에서 한 번만 실행하면 끝!
# ============================================================

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  글램독 자동화 시스템 iMac 세팅 시작"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Step 1. Homebrew 확인 / 설치 ─────────────────────────────
echo ""
echo "▶ [1/7] Homebrew 확인..."
if ! command -v brew &>/dev/null; then
    echo "  Homebrew 설치 중..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "  ✅ Homebrew 이미 설치됨"
fi

# ── Step 2. Python3 확인 ─────────────────────────────────────
echo ""
echo "▶ [2/7] Python3 확인..."
if ! command -v python3 &>/dev/null; then
    echo "  Python3 설치 중..."
    brew install python3
else
    PY_VER=$(python3 --version)
    echo "  ✅ $PY_VER 이미 설치됨"
fi

# ── Step 3. Python 패키지 설치 ───────────────────────────────
echo ""
echo "▶ [3/7] Python 패키지 설치..."
pip3 install --quiet --break-system-packages \
    playwright \
    openpyxl \
    msoffcrypto-tool \
    requests \
    slack_sdk \
    python-dateutil \
    beautifulsoup4 \
    lxml 2>/dev/null || \
pip3 install --quiet \
    playwright \
    openpyxl \
    msoffcrypto-tool \
    requests \
    slack_sdk \
    python-dateutil \
    beautifulsoup4 \
    lxml
echo "  ✅ Python 패키지 설치 완료"

# ── Step 4. Playwright Chromium 설치 ─────────────────────────
echo ""
echo "▶ [4/7] Playwright Chromium 설치..."
python3 -m playwright install chromium
echo "  ✅ Chromium 설치 완료"

# ── Step 5. 판대데이터 폴더 확인 ─────────────────────────────
echo ""
echo "▶ [5/7] 판대데이터 폴더 확인..."
PANDE_DIR="$HOME/Downloads/판대데이터"

# NFD 경로 찾기
ACTUAL_PANDE=""
for d in "$HOME/Downloads"/*/; do
    if [ -f "${d}nol_auto_download.py" ]; then
        ACTUAL_PANDE="$d"
        break
    fi
done

if [ -z "$ACTUAL_PANDE" ]; then
    echo ""
    echo "  ⚠️  판대데이터 폴더가 없습니다!"
    echo "  노트북에서 다음 명령으로 복사해주세요:"
    echo ""
    echo "  # 노트북 터미널에서 실행 (iMac IP 주소 확인 후):"
    echo "  rsync -av ~/Downloads/판대데이터/ imac_username@[iMac_IP]:~/Downloads/판대데이터/"
    echo ""
    echo "  복사 후 이 스크립트를 다시 실행하세요."
    exit 1
else
    echo "  ✅ 판대데이터 폴더 확인: $ACTUAL_PANDE"
fi

# ── Step 6. launchd plist 등록 ───────────────────────────────
echo ""
echo "▶ [6/7] launchd 자동 실행 등록..."

SCRIPT_PATH="$HOME/Downloads/glamdog_auto_update.sh"
PLIST_PATH="$HOME/Library/LaunchAgents/com.glamdog.dashboard.plist"
LOG_PATH="$HOME/Downloads/glamdog_update.log"

# 실행 스크립트 확인
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "  glamdog_auto_update.sh 생성 중..."
    cat > "$SCRIPT_PATH" << 'SHEOF'
#!/bin/bash
cd ~/Downloads/판대데이터 2>/dev/null || \
    cd "$(python3 -c "import os; [print(os.path.join(os.path.expanduser('~/Downloads'), d)) for d in os.listdir(os.path.expanduser('~/Downloads')) if os.path.exists(os.path.join(os.path.expanduser('~/Downloads'), d, 'nol_auto_download.py'))]" 2>/dev/null | head -1)"
echo "━━━ 자동 실행: $(date '+%Y-%m-%d %H:%M') ━━━" >> ~/Downloads/glamdog_update.log
python3 nol_auto_download.py >> ~/Downloads/glamdog_update.log 2>&1
SHEOF
    chmod +x "$SCRIPT_PATH"
fi

# launchd plist 생성 (없으면)
if [ ! -f "$PLIST_PATH" ]; then
    cat > "$PLIST_PATH" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.glamdog.dashboard</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>StartCalendarInterval</key>
    <array>
        <dict><key>Hour</key><integer>0</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>8</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>9</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>10</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>12</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>14</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>16</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>18</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>20</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>22</integer><key>Minute</key><integer>0</integer></dict>
    </array>
    <key>StandardOutPath</key>
    <string>$LOG_PATH</string>
    <key>StandardErrorPath</key>
    <string>$LOG_PATH</string>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
PLISTEOF
    echo "  ✅ plist 생성: $PLIST_PATH"
fi

# launchd 로드
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"
echo "  ✅ launchd 등록 완료 (0,8,9,10,12,14,16,18,20,22시)"

# ── Step 7. pmset 자동 깨우기 ────────────────────────────────
echo ""
echo "▶ [7/7] 자동 깨우기 설정 (sudo 비밀번호 필요)..."
echo "  iMac은 항상 켜두는 경우 이 단계는 선택사항입니다."
echo "  매일 8:58에 자동 깨우기를 설정합니다..."
sudo pmset repeat wake MTWRFSU 08:58:00
echo "  ✅ 자동 깨우기 등록: 매일 8:58"

# ── 완료 ─────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎉 iMac 세팅 완료!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ✅ Python 패키지 & Playwright 설치"
echo "  ✅ launchd 자동 실행 등록 (매일 0~22시)"
echo "  ✅ pmset 자동 깨우기 (매일 8:58)"
echo ""
echo "  📋 다음 확인 명령:"
echo "  launchctl list | grep glamdog   # 등록 확인"
echo "  tail -f ~/Downloads/glamdog_update.log  # 실행 로그"
echo ""
echo "  ⚠️  iMac 시스템 설정 → 절전 → '절전 모드 방지' 켜기 권장"
