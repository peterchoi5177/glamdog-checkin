# 글램독 자동화 → iMac 이전 가이드

## 순서 요약
1. iMac IP 확인
2. 노트북에서 파일 rsync로 복사
3. iMac에서 imac_setup.sh 실행

---

## Step 1. iMac IP 주소 확인
**iMac 터미널에서:**
```bash
ipconfig getifaddr en0
```
예: `192.168.0.5`

---

## Step 2. 노트북 → iMac 파일 복사
**노트북 터미널에서** (iMac IP와 계정명 바꿔서):
```bash
# 판대데이터 폴더 전체 복사
rsync -av --progress \
  ~/Downloads/판대데이터/ \
  [iMac계정]@[iMac_IP]:~/Downloads/판대데이터/

# 자동실행 스크립트 복사
scp ~/Downloads/glamdog_auto_update.sh \
    [iMac계정]@[iMac_IP]:~/Downloads/

# 예시 (계정: peter, IP: 192.168.0.5)
# rsync -av ~/Downloads/판대데이터/ peter@192.168.0.5:~/Downloads/판대데이터/
```

> **같은 와이파이**에 있어야 합니다. iMac에서 시스템 설정 → 일반 → 공유 → "원격 로그인" 켜기 필요.

---

## Step 3. iMac에서 세팅 스크립트 실행
**iMac 터미널에서:**
```bash
bash ~/Downloads/glamdog-checkin-repo/imac_setup.sh
```
또는 glamdog-checkin-repo가 없으면:
```bash
# GitHub에서 직접 받기
curl -O https://raw.githubusercontent.com/peterchoi5177/glamdog-checkin/main/imac_setup.sh
bash imac_setup.sh
```

---

## Step 4. iMac 설정 (중요!)
- **시스템 설정 → 절전** → "절전 모드 방지" ON (항상 켜두기)
- **시스템 설정 → 일반 → 공유** → "원격 로그인" ON (원격 접속용)

---

## 완료 후 확인
```bash
launchctl list | grep glamdog   # 등록 확인
tail -f ~/Downloads/glamdog_update.log  # 실시간 로그
```
