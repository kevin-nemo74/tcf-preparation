# MapleTcf launch test plan

## Auth & onboarding (FR + EN)

- Register with valid credentials.
- Login with valid credentials.
- Logout from settings.
- Password reset email flow.
- Onboarding completion persistence.
- Authenticated return-to-app flow after app restart.

## CE + CO exam end-to-end

- Start test, answer subset, let timer expire (auto-submit).
- Start test, manually submit before timer expiry.
- Verify score persistence in Firestore user attempts.
- Verify review queue item creation for missed/flagged.
- Reopen review items from review queue and complete one item.
- Verify study plan refresh on next day (`planDateKey` changes).

## Media/network resilience

- Broken image URLs should render fallback UI.
- Broken audio URLs should render playback error with safe recovery.
- Low-bandwidth behavior across CE/CO/PDF screens.
- Missing/denied storage assets should fail gracefully.

## Release platform checks

- Signed Android release install on a real Android device.
- Hosted web checks:
  - Chrome Android
  - Safari iPhone
  - Desktop Chrome
  - Narrow mobile viewport width

## Analytics verification (staging)

Verify events are emitted:

- `landing_cta_clicked`
- `signup_started`
- `signup_success`
- `test_started` (first test)
- `test_submitted` (first submit)
- `review_queue_item_completed`
- `study_plan_created`
- `pdf_opened`

## Crashlytics staging check

- Trigger a non-fatal test event and verify it appears before public launch.
