# Supabase database design

The executable migration is
[`supabase/migrations/202606290001_initial_schema.sql`](../supabase/migrations/202606290001_initial_schema.sql).

```mermaid
erDiagram
  AUTH_USERS ||--|| PROFILES : owns
  ROLES ||--o{ PROFILES : assigns
  DIVISIONS ||--o{ PROFILES : groups
  ROLES ||--o{ ROLE_PERMISSIONS : grants
  FEATURES ||--o{ ROLE_PERMISSIONS : controls
  PROFILES ||--o{ USER_PERMISSIONS : overrides
  FEATURES ||--o{ USER_PERMISSIONS : controls
  PROFILES ||--o{ ZODIAC_RECORDS : owns
  PROFILES ||--o{ QUIZ_ATTEMPTS : completes
  PROFILES ||--o{ POLL_VOTES : casts
  POLLS ||--o{ POLL_OPTIONS : contains
  POLLS ||--o{ POLL_VOTES : receives
  POLL_OPTIONS ||--o{ POLL_VOTES : selected
```

Key decisions:

- Passwords and sessions belong only to Supabase Auth. `profiles` never stores a
  password.
- `profiles.user_id` is the Auth UUID; `legacy_id` keeps compatibility with the
  existing integer-based Flutter model.
- Permissions are normalized by role, with optional per-user overrides.
- RLS restricts profiles, permissions, zodiac rows, quiz attempts, votes, and
  private profile media. Admin capability is evaluated server-side by
  `has_feature()`.
- Zodiac IDs use integer identities to interoperate with the existing Drift data
  class. Each record is still isolated by Auth UUID.
- Admin account creation is an Edge Function operation. Its service-role secret
  is never exposed to Flutter.

Currently connected from Flutter: Auth/session, account creation and listing,
profiles, role permissions, and real-time zodiac history. Quiz attempts, polls,
and Storage tables/policies are ready for a later UI persistence pass.
