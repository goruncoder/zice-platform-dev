# F11 — Team Blog: Editor + Admin Management

**Repo:** `goruncoder/zice-frontend`  
**Milestone:** M3  
**Est. Size:** Medium  
**Blocked By:** C14 (blog backend API), F10 (blog feed)

---

## Summary

Build the blog post editor for coaches/admins and the admin blog management page. Includes rich text editing, draft/publish workflow, media uploads, and admin-level post management with bulk actions.

## Scope

### Pages

| Route | Component | Description |
|---|---|---|
| `/blog/new` | `BlogEditor` | Create new post (coach/admin only) |
| `/blog/:slug/edit` | `BlogEditor` | Edit existing post (author/admin only) |
| `/admin/blog` | `AdminBlogList` | Admin view of all posts including drafts/archived, bulk actions |

### Components

- **`BlogEditor`** — Rich text post editor:
  - Title input (required, max 200 chars)
  - Slug auto-generated from title (editable, validated for URL-safety)
  - Markdown body editor with preview toggle (split-pane or tabbed)
  - Excerpt input (optional, auto-generated from body if blank)
  - Category selector (text input with suggestions from existing categories)
  - Tags input (comma-separated or chip-based, free-form)
  - Cover image upload with preview
  - `allow_comments` toggle (default: on)
  - Save as Draft / Publish buttons
  - Unsaved changes warning on navigation
- **`MediaUploader`** — Drag-and-drop media upload:
  - Accept images (JPEG, PNG, WebP), documents (PDF), video (MP4)
  - Progress indicator during upload
  - Thumbnail preview for images
  - Sort order via drag-and-drop reordering
  - File size display
  - Delete attachment button
- **`MarkdownPreview`** — Sanitized HTML rendering of markdown body
- **`AdminBlogList`** — Admin management table:
  - DataTable showing all posts (draft, published, archived, soft-deleted)
  - Columns: title, author, status (color-coded badge), category, published_at, created_at
  - Status filter: draft | published | archived | deleted
  - Bulk actions: publish, archive, soft-delete
  - Individual actions: edit, publish/unpublish, pin/unpin, soft-delete, restore
  - "Show archived/deleted" toggle (same pattern as admin players page)

### API Integration

- `api.createBlogPost(token, orgId, data)` — POST new post
- `api.updateBlogPost(token, orgId, postId, data)` — PUT update post
- `api.deleteBlogPost(token, orgId, postId)` — DELETE (soft) post
- `api.publishBlogPost(token, orgId, postId)` — PUT publish
- `api.pinBlogPost(token, orgId, postId)` — PUT pin/unpin
- `api.restoreBlogPost(token, postId)` — PUT restore
- `api.uploadBlogMedia(token, postId, file)` — POST upload
- `api.deleteBlogMedia(token, mediaId)` — DELETE remove

### Draft/Publish Workflow

```
[New Post] → Draft → [Click Publish] → Published → [Click Archive] → Archived
                ↑                           ↓
                └── [Click Unpublish] ──────┘
                
Any state → [Soft Delete] → Deleted → [Admin Restore] → Previous state
```

### Role Gating

- `/blog/new` and `/blog/:slug/edit` — redirect to `/blog` if user is not coach or admin
- `/admin/blog` — accessible only to admins (in admin dashboard layout)
- Pin/unpin action — only visible to admins

## Acceptance Criteria

- [ ] Blog editor creates posts with title, body (markdown), category, tags
- [ ] Slug auto-generates from title and is editable
- [ ] Markdown preview renders correctly
- [ ] Draft/Publish workflow works (save draft → publish → unpublish)
- [ ] Media upload works for images, PDFs, videos
- [ ] Media can be reordered and deleted
- [ ] Cover image upload with preview
- [ ] Admin blog list shows all posts with status filters
- [ ] Bulk actions (publish, archive, delete) work
- [ ] Pin/unpin limited to admins, max 3 pinned per org
- [ ] Unsaved changes warning on navigation away
- [ ] Role gating redirects non-coach/admin users
- [ ] Unit tests for BlogEditor, AdminBlogList components
