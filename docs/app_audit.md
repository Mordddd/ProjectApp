# App audit

## Major findings

- Local authentication stored plaintext passwords and a forgeable username
  session in `SharedPreferences`. Supabase builds now use Supabase Auth; the
  local implementation remains only as an explicit offline/demo fallback.
- Accounts and permission edits were device-local, so different devices could
  disagree and users could modify local state. Supabase repositories plus RLS
  now make the server authoritative when configured.
- Secure admin account creation was missing. It now uses an authenticated Edge
  Function that verifies the caller is an active admin before using Admin Auth.
- Profile preference keys were shared by every logged-in user. They are now
  scoped by profile ID.

## Minor findings fixed

- Controllers on Bilangan, Discount, Sorting, and Max/Min pages were not
  disposed.
- Several profile async callbacks could call `setState` after the widget was
  removed.
- Discount values outside 0-100 produced nonsensical negative totals.
- Max/Min history mutated after rendering without notifying the UI.
- Startup backend errors had no visible recovery screen.

## Remaining limitations

- Profile images and videos still use device file paths. The private Supabase
  Storage bucket and policies exist, but upload/download UI is not connected.
- Quiz attempts and polling are still in-memory UI flows; their server schema is
  ready but not yet used.
- Live Supabase behavior must be smoke-tested against the target project after
  applying the migration and deploying the function.
- Automated coverage is currently narrow: authentication/permissions widgets
  and local zodiac CRUD are covered, but calculators and remote repositories
  need dedicated tests.
