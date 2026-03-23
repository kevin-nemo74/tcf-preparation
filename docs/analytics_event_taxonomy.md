# Analytics Event Taxonomy

This file defines the initial analytics events for product funnels.

## Events

- `onboarding_completed`
  - Trigger: user completes or skips onboarding.
- `test_started`
  - Params: `module_type`, `test_id`
  - Trigger: user starts CE/CO test.
- `test_submitted`
  - Params: `module_type`, `test_id`, `score`
  - Trigger: result persistence after attempt submission.
- `review_queue_item_completed`
  - Trigger: review item is marked as done/removed.
- `study_plan_task_toggled`
  - Params: `done`
  - Trigger: user checks/unchecks study plan task.
