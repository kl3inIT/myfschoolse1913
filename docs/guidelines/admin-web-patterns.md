# Admin Web Patterns

Reusable UI/UX pattern for every admin-web page so all resources look and
behave the same. Evidence comes from established admin frameworks and
enterprise UX research (see Sources); current facts about built pages live in
`docs/specs/domains/admin-web.md`.

## Resource Model

Follow the react-admin/Refine convention: each business entity is a
"resource" with up to four surfaces — List, Detail (show), Edit, Create. Omit
what a resource does not need yet.

Routes:

- `/` — the dashboard (landing page): stat cards reusing resource stats
  endpoints plus "needs attention" panels linking into resources.
- `/<resource>` — list page (e.g. `/students`, `/classes`,
  `/notifications`, `/grades`, `/timetable`, `/applications`, `/ai`).
- `/<resource>/:id` — detail page when a row has enough data to justify one
  (students). Row click navigates here.
- Create/Edit do not get separate routes yet: create lives on the list page,
  edit lives on the detail page.

Sidebar: one entry per resource, real links with route-based active state.
Placeholders stay disabled until the page exists.

## Page Anatomy

Every page renders inside `AdminShell` and follows this order (Jmix list-view
composition — one title, filter and buttons in a single toolbar row above the
grid):

1. Shell header: breadcrumb `Quản trị > <Section> > <Page>` + page `h1`. This
   is the only title — do not repeat it as an `h2`/panel heading below.
2. Optional stat cards row (system-wide numbers from a dedicated stats
   endpoint, never computed from the current page of data).
3. Toolbar row (Jmix `genericFilter` + `buttonsPanel` merged): search box on
   the left, action buttons on the right ("Tải mẫu CSV", "Nhập CSV",
   "Thêm năm học", …). Sits below the stat cards, directly above the grid.
4. Main content: the bordered grid panel filling the remaining height.

## List Pattern (Jmix-style dataGrid)

Mirrors the Jmix list view: filter on top, the grid expands to fill the
remaining space, pagination stays fixed at the bottom.

- Tables render through the shared `DataTable` component
  (`src/components/data-table.tsx`, built on `@tanstack/react-table`):
  `ColumnDef` files per resource (`features/<resource>/columns.tsx`),
  `DataTableColumnHeader` for sortable headers (client-side, current page),
  `flexRender` body, row click/Enter opens the detail route.
- Bordered panel: grid, then `DataTablePagination` (`N <đơn vị>` left,
  `Trước / Trang x/y / Sau` right). No panel-level title — the shell `h1` is
  the only title.
- Row actions are inline ghost icon buttons in a trailing column (`Eye` =
  view detail, `Pencil` = open detail in edit mode via `?edit=true`), with
  `stopPropagation` so they coexist with row-click navigation. Soft actions
  like recall keep icon + label.
- The page container is capped to the viewport
  (`h-[calc(100svh-8rem)]`) and the panel is `flex-1 min-h-0`, so the grid
  scrolls internally and the pagination bar is always visible at the bottom —
  the Jmix `simplePagination` convention.
- Search is server-side, debounced 300 ms, resets to page 0.
- Paging is server-side, 20 rows default; responses use
  `{page, size, totalItems, totalPages, items}`.
- States: skeleton while loading, empty state (`Empty` component) with a
  primary action when the list is empty, distinct copy when a search has no
  hits.
- A resource may add an alternate read-only visualization next to the list
  (OpenEduCat-style multi-view: list + calendar/kanban of the same data) via
  a small toolbar toggle — e.g. the timetable's per-class weekly grid. Build
  such views with plain CSS grid; only reach for a calendar library when
  continuous-time events or drag-drop editing are actually needed.

## Edit Pattern (Jmix-style in-place)

Per enterprise UX guidance, choose the lightest editing surface that fits the
data:

- **Detail-page in-place edit** (default for entities with a detail page):
  "Chỉnh sửa" switches the detail cards into edit mode — the same fields
  render as inputs in the same layout, `Lưu thay đổi`/`Hủy` appear in the
  page header. No drawer, no navigation. (Students use this.)
- **Create = header action button + centered dialog** (default): the page
  header holds a primary action ("Thêm năm học", "Đăng thông báo") that opens
  a `Dialog` with the form; footer is `Hủy` + submit. Never park a permanent
  create-form card next to the list. Inline mini-forms remain fine for
  one-field children (add class to a year).
- **Sheet (side drawer)** only for heavy, self-contained input that needs
  width — bulk CSV/Excel import.
- Separate wizard pages are reserved for future multi-step flows; do not
  introduce them casually.

## Bulk Import Pattern

Shared by student and grade import:

- Dropzone accepts CSV and Excel (`.xlsx`/`.xls`); Excel's first sheet is
  converted to CSV client-side (`lib/spreadsheet.ts`) and reuses the CSV
  parser (`lib/csv.ts`).
- Editable CSV textarea + downloadable template + required-columns hint.
- Client-side parse → validation alert → preview table before submit.
- Server responds per-row `{rowNumber, status CREATED|UPDATED|SKIPPED,
  message}` plus summary counts; UI shows summary tiles + per-row table.
- Imports are idempotent upserts; duplicates and unresolvable rows are
  SKIPPED with a Vietnamese reason, never a hard failure.

## Branding

The admin web shares the mobile app's FPT brand color: shadcn `--primary`
(and ring/sidebar-primary) is FPT orange — `#C2410C`
(`oklch(0.553 0.195 38.402)`, seed `FptColors.orangeDeep` in
`lib/vn/edu/fpt/core/theme/app_colors.dart`); dark mode uses the lighter
brand orange (`oklch(0.705 0.213 47.604)` ≈ `#F97316`). Neutral grays stay
shadcn defaults.

## Data And Feedback Conventions

- Query keys: `['admin-<resource>', 'list' | 'stats' | 'detail', ...params]`;
  after any mutation invalidate the `['admin-<resource>']` prefix so list,
  stats, and detail refresh together.
- Mutations: `sonner` toast on success (what happened, with numbers) and on
  error (surface the backend's Vietnamese `message` directly).
- Forms: react-hook-form + zod, Vietnamese validation messages, submit
  disabled while pending with a spinner.
- Destructive-ish actions are soft (recall/deactivate, lock account), shown
  as muted rows/badges, not hard deletes.

## Backend API Conventions

- Admin endpoints live under `/api/admin/<resource>` and require
  `ROLE_ADMIN` (`SecurityConfig`).
- List: `GET ?search=&page=&size=` with clamped size. Stats: `GET /stats`.
  Detail: `GET /{id}`. Update: `PUT /{id}`. Soft delete: `DELETE /{id}`.
- Errors: `ResponseStatusException` with Vietnamese reason — 404 unknown id,
  409 uniqueness conflicts; bean validation messages are Vietnamese.

## Known Deviations To Align

- Classes page uses year cards instead of the standard list panel; acceptable
  as a master-detail composition, revisit if it grows.

## Sources

- [react-admin CRUD pages](https://marmelab.com/react-admin/CRUD.html) —
  resource = list/show/edit/create, routing and toolbar conventions.
- [Refine resource pattern](https://github.com/refinedev/refine) — headless
  resource pages, omit unneeded surfaces.
- [Jmix MasterDetailScreen](https://docs.jmix.io/api/1.0/ui/io/jmix/ui/screen/MasterDetailScreen.html)
  — in-place editor enabled by Edit/Create, cancel restores view mode.
- [PatternFly inline edit guidelines](https://www.patternfly.org/components/inline-edit/design-guidelines/)
  and [Pencil & Paper data-table UX](https://www.pencilandpaper.io/articles/ux-pattern-analysis-enterprise-data-tables)
  — inline edit keeps context; use it for small field sets.
- [Smashing Magazine: modal vs separate page](https://www.smashingmagazine.com/2026/03/modal-separate-page-ux-decision-tree/)
  — drawers/dialogs for self-contained tasks, pages for multi-step flows.
