<div align="center">

# ClaudeCode AI Agent Setup

### Claude Code를 수동적 코드 편집기에서 완전한 인지 사이클을 갖춘 자율 지능형 엔지니어로 전환

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green.svg)]()

[中文](./README.md) | [English](./README.en.md) | [日本語](./README.ja.md)

**저자: Tangdan / 汤旦**

</div>

---

## 핵심 혁신

> **당신은 수동적인 코드 편집기가 아닙니다. 완전한 인지 사이클을 갖춘 지능형 엔지니어입니다.**

본 프로젝트는 **순수 설정**(코드 수정 제로)을 통해 Claude Code에 완전한 자율 에이전트 시스템을 주입합니다:

| 기능 | 설명 | 기존 Claude Code |
|------|------|-----------------|
| **7단계 인지 사이클** | 인식→사고→계획→실행→검증→반성→진화 | 수신→실행→완료 |
| **8층 심층 방어** | 하드 차단 + 모니터링 + 소프트 제약, AI 우회 불가 | 프롬프트만의 제약 |
| **자기 학습 진화** | 오류 추적→전역 감사→규칙 강화→자동화 | 학습 메커니즘 없음 |
| **삼성육부 거버넌스** | 의사결정/심사/실행 분리, 거부권 포함 | 거버넌스 프레임워크 없음 |
| **증거 기반 검증** | 테스트/빌드/lint 실제 출력 필수 | "문제없을 것" |
| **무인 실행** | 자동 라우팅 + 자동 감독 + 자동 서킷 브레이커 | 지속적 인력 개입 필요 |

---

## 아키텍처 개요

```
┌──────────────────────────────────────────────────────────────┐
│                Claude Code 에이전트 시스템                      │
├──────────────────────────────────────────────────────────────┤
│  ┌─ 하드 보안 레이어 ───────────────────────────────────┐    │
│  │  Layer 0-2: settings.json deny + safety-guard.sh     │    │
│  │             + sensitive-filter.sh [exit 2 하드 차단]   │   │
│  └──────────────────────────────────────────────────────┘    │
│  ┌─ 보조 모니터링 레이어 ───────────────────────────────┐   │
│  │  Layer 3-6: 상태 저장 + 컨텍스트 복구 + 편집 감사     │   │
│  │             + 서킷 브레이커 + 완료 전 검사             │   │
│  └──────────────────────────────────────────────────────┘    │
│  ┌─ 동작 지시 레이어 (CLAUDE.md) ───────────────────────┐   │
│  │  Layer 7: 지능형 OS v1                                │   │
│  │  ├─ 7단계 인지 사이클                                  │   │
│  │  ├─ 삼성육부 거버넌스 프레임워크                        │   │
│  │  ├─ 의사결정 트리 라우팅                               │   │
│  │  └─ 4층 자기 학습 모델                                 │   │
│  └──────────────────────────────────────────────────────┘    │
│  ┌─ 메모리 지속성 레이어 ───────────────────────────────┐   │
│  │  MEMORY.md + recurring-patterns.md + compact-state.md │   │
│  └──────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

---

## 주요 혁신 포인트

### 1. 7단계 인지 사이클 — "실행기"에서 "엔지니어"로

모든 작업이 완전한 인지 루프를 거칩니다: **인식**(의도 인식 + 컨텍스트 인식 + 메모리 호출 + 리스크 예측) → **사고**(전문 에이전트 능동적 호출) → **계획**(의사결정 트리로 최적 실행 경로 라우팅) → **실행**(실행하며 테스트 + 3단계마다 보고) → **검증**(테스트/빌드 실제 출력 필수) → **반성**(패턴 검출 + 유추 적용) → **진화**(수정 업그레이드 체인: 1회→기록, 2회→규칙, 3회→자동화).

### 2. 8층 심층 방어

- **Layer 0-2 (하드 차단)**: `settings.json` deny 규칙 + `safety-guard.sh`(메타 커맨드 감지, L4 절대 금지, L3 고위험, 자격 증명 유출) + `sensitive-filter.sh`(15종 민감 정보 패턴). `exit 2` 사용 — **AI가 우회할 수 없습니다**.
- **Layer 3-6 (보조)**: 상태 보존, 컨텍스트 복구, 서킷 브레이커 포함 편집 감사(5회 경고/8회 위험), 완료 전 4점 검사.
- **Layer 7 (소프트 제약)**: CLAUDE.md 동작 지시, L1-L4 보안 분류.

### 3. 삼성육부 거버넌스 (三省六部)

고대 중국 거버넌스 시스템에서 영감:
- **중서성 (의사결정)**: planner, architect, analyst — 방안 기초만
- **문하성 (심사)**: critic, verifier, reviewers — **거부권(봉박)** 보유
- **상서성 (실행)**: executor — 승인된 계획만 실행
- **어사대 (독립 감사)**: safety-guard + sensitive-filter + post-edit-audit + verify-before-stop

### 4. 4층 자기 학습 모델

| 레이어 | 트리거 | 액션 |
|--------|--------|------|
| 수정 즉 감사 | 버그 수정 시 | 같은 파일/모듈에서 유사 문제 검색 |
| 전역 감사 | 동일 패턴 ≥2회 | 전체 프로젝트 Grep + 방어 규칙 생성 |
| 깊은 반성 | 동일 패턴 ≥3회 | 근본 원인 분석 + 규칙 강화 + 자동화 제안 |
| 유추 적용 | 패턴 성숙 | 유추 추론 + 프로젝트 간 이전 |

---

## 실제 시나리오 비교: Before vs After

### 시나리오 1: API 버그 수정

**일반 Claude Code:**
```
사용자: "/api/users의 500 에러를 수정해줘"
Claude: 파일 열기 → 에러 발견 → 한 줄 수정 → "완료, 문제없을 거예요"
결과: 테스트 미실행, 새 버그 도입; /api/orders에도 같은 문제가 있지만 아무도 발견하지 못함
```

**이 설정을 적용한 Claude Code:**
```
사용자: "/api/users의 500 에러를 수정해줘"
Claude:
  [인식] recurring-patterns.md 읽기 → API 레이어에서 P003 패턴 발견
  [사고] explore agent로 관련 파일 탐색 + debugger로 근본 원인 분석
  [계획] "3개 파일 관련, 중간 경로" → 사용자에게 계획 제시
  [실행] executor 수정 + 변경마다 테스트 → quality-reviewer 감사
  [검증] ✅ npm test 통과 ✅ tsc 클린 ✅ reviewer 승인
  [반성] 프로젝트 전체 Grep → /api/orders에서 동일 문제 발견 → 함께 수정
  [진화] recurring-patterns.md + 지식 그래프에 기록, 다음에 자동 경고
```

### 시나리오 2: 인증 모듈 리팩토링

**일반 Claude Code:**
```
사용자: "인증 모듈을 리팩토링해줘"
Claude: 대규모 변경 시작 → 15개 파일 변경 → 빌드 실패 → 반복 수정 → 악화
     → SSH 키가 로그에 실수로 노출됨 → 보안 사고
```

**이 설정을 적용한 Claude Code:**
```
사용자: "인증 모듈을 리팩토링해줘"
Claude:
  [계획] >10 파일 → 복잡 경로 → ralplan 합의 계획
         → planner + architect + critic 삼자 검토
         → 드라이런 검증: executor 시뮬레이션 + debugger 리스크 예측
  [실행] 병렬 디스패치: executor(핵심) ∥ test-engineer(테스트) ∥ security-reviewer
         → 3단계마다 진행 보고 → 5단계: 키 유출 위험 감지
         → sensitive-filter.sh 하드 블록 (exit 2) → 쓰기 방지
  [검증] 전체 테스트 + 빌드 + ReACT 심층 검토 (5라운드)
  [반성] Agent 인터뷰 → 테스트 커버리지 사각지대 발견 → 경계 테스트 추가
```

---

## 빠른 시작

```bash
git clone https://github.com/tangdan2204/claudecode-ai-agent-setup.git
cd claudecode-ai-agent-setup
chmod +x install.sh && ./install.sh
```

필수 조건: macOS/Linux, Claude Code CLI, `jq` (`brew install jq`)

자세한 단계는 [QUICK-START.md](./QUICK-START.md)를 참조하세요.

---

## 라이선스

[MIT License](./LICENSE)

---

<div align="center">

**설계 및 유지관리: [Tangdan / 汤旦](https://github.com/tangdan2204)**

*모든 Claude Code를 진정한 지능형 엔지니어로*

</div>
