# Design: Skip 0-Publication Users in Google Scholar Discovery

**Date:** 2026-06-08
**Branch:** add/google-scholar-integration

## Problem

`GoogleScholarProfileImporter#discover_profile` calls `scraper.search_profiles` (25 ScraperAPI credits) for every user who has no known `google_scholar_id` and no `ai_google_scholar` URL. For users with 0 publications in the local database, the subsequent `GoogleScholarProfileMatcher` will always return 0 DOI matches and 0 title matches — matching can never succeed. These credits are wasted.

Example: Zhou Sha (user 18803) has 0 publications and no Scholar ID. Every import run spends 25 credits on a search that has no chance of producing a valid match.

## Scope

Change is limited to `app/importers/google_scholar_profile_importer.rb`. No other files in this branch are affected.

## Design

Add an early-return guard as the first statement in `discover_profile`:

```ruby
def discover_profile(user)
  if user.publications.none?
    Rails.logger.info("GoogleScholarProfileImporter: skipping user #{user.id} — 0 publications, cannot match")
    return nil
  end
  # existing search + match loop
end
```

### Why `discover_profile` and not `import_user`

`import_user` has three paths:
1. Known `google_scholar_id` → `scraper.fetch_profile` (no matching needed)
2. ID from `ai_google_scholar` URL → `scraper.fetch_profile` (no matching needed)
3. No known ID → `discover_profile` (name search + matcher)

Paths 1 and 2 never call `discover_profile`. A user with 0 publications but a known Scholar ID or AI URL should still have their profile fetched and their h-index/citation count updated. Placing the guard inside `discover_profile` keeps that correct — paths 1 and 2 are unaffected.

## Testing

Add one spec case to the `GoogleScholarProfileImporter` spec:

- When a user has 0 publications and no `google_scholar_id` / `ai_google_scholar` URL, `scraper.search_profiles` must not be called and the user record must not be updated.

Existing specs for paths 1 and 2 (known ID) need no changes.

## Credits saved

Per skipped user: 25 credits (search call avoided). For a faculty roster with many researchers who have no publication record in the local DB, this compounds across every import run.
