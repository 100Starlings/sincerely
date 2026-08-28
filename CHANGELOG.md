# Changelog

All notable changes to this project will be documented in this file.

## [1.1.1] - 2026-08-28

### Changed
- Email delivery now sends a raw MIME message with images embedded inline (via `cid:`) instead of linking to an externally hosted URL, when attachments are provided. Removes the dependency on a publicly reachable host to render images in emails.

### Added
- `mail` gem dependency, used to build the raw MIME message for inline attachments
- `Notification#render_content` accepts extra template variables, used to inject the generated `cid:` references before rendering

## [1.1.0] - 2026-08-28

### Added
- Mountable notifications dashboard engine: overview stats, delivery/engagement timeline charts, notifications-by-status chart, and configurable time period filters
- Templates CRUD with live preview (tabbed HTML/text preview, sample data input, Liquid variable extraction including filter syntax e.g. `name | upcase`)
- Notifications index and detail views with clickable rows, keyboard navigation, template/notification-type/date-range filters, and pagination
- Delivery and engagement events views with filtering and timelines
- Manual notification sending from the dashboard ("send" feature)
- Dark theme with mobile-friendly nav
- Configurable `return_url`, `return_label`, and `logout_*` options (via YAML or ENV)
- CI workflow to publish the gem to RubyGems automatically on tag push
- arm64-darwin platform support

### Changed
- Dropped the `sincerely.` prefix from view/helper references across dashboard, notifications, templates, delivery/engagement, nav, and send views
- Moved inline JS/CSS/SVGs out of views into the asset pipeline (Sprockets manifest, dedicated JS/CSS files, icon partials) and replaced inline `onclick`/`style` attributes with `data-*` attributes and CSS classes for CSP compatibility
- Extracted controller responsibilities into concerns (pagination, periods, event filtering, delivery metrics/timeline)
- Replaced `pluck`-based `IN` queries with subqueries and added eager loading to avoid N+1 queries; aggregated timeline counts in SQL instead of iterating in Ruby

### Fixed
- Guarded AASM state transitions (`may_*?`) to handle duplicate or out-of-order webhook events
- Corrected timeline bucket boundaries, pagination clamping, invalid date-range handling, and donut chart segment math at 100%
- Returned a 422 (instead of 500) on invalid Liquid template syntax during preview, and generic client errors with full server-side logging on delivery exceptions
- Replaced the logout anchor with `button_to` so it works without Turbo
- Assorted nil/default handling fixes for template subjects, content, and `template_data` across param types

### Security
- Guarded the inline SVG helper against path traversal
- Sandboxed the template preview iframe and added a CSP
- Restricted `template_data` to known Liquid variables instead of permitting arbitrary params

## [1.0.0] - 2024-07-31

### Added
- Initial release
- Amazon SES email sending
- Amazon SES email sending events
- liquid email templates
- notification statuses
