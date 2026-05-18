# C14 — Team Blog: Schema, RLS, API Endpoints

**Repo:** `goruncoder/zice-core`  
**Milestone:** M3  
**Est. Size:** Medium  
**Blocked By:** C10 (soft-delete migration), C11 (audit log)

---

## Summary

Add org-scoped team blog with full CRUD for posts, threaded comments, and media attachments. Coaches and admins can publish articles and announcements; all org members can read and comment.

## Scope

### Database Schema
- `blog_posts` table — org-scoped, with title, slug, body (markdown), excerpt, status (draft/published/archived), pinned flag, category, tags array, cover image URL, allow_comments flag, soft-delete
- `blog_comments` table — threaded (parent_comment_id), author-attributed, soft-delete
- `blog_media` table — file attachments (image/video/document) linked to posts, stored in Supabase Storage
- Indexes: org+status, org+published_at DESC, pinned posts, comments by post, media by post

### RLS Policies
- `blog_posts_read` — org members can read published posts; authors can see own drafts; admins can see all
- `blog_posts_insert` — coaches + admins can create posts
- `blog_posts_update` — author or admin can update
- `blog_comments_read` — org members can read comments on published posts
- `blog_comments_insert` — any org member can comment (if `allow_comments = true`)
- `blog_comments_update` — author or admin can edit/soft-delete

### API Endpoints (16 total)

**Posts:**
- `GET /api/v1/orgs/:org_id/blog/posts` — list published posts (paginated, filterable by category/tag)
- `GET /api/v1/orgs/:org_id/blog/posts/:slug` — get single post by slug
- `POST /api/v1/orgs/:org_id/blog/posts` — create post (coach/admin)
- `PUT /api/v1/orgs/:org_id/blog/posts/:id` — update post (author/admin)
- `DELETE /api/v1/orgs/:org_id/blog/posts/:id` — soft-delete post (author/admin)
- `PUT /api/v1/orgs/:org_id/blog/posts/:id/publish` — publish draft
- `PUT /api/v1/orgs/:org_id/blog/posts/:id/pin` — pin/unpin post (admin)
- `PUT /api/v1/admin/blog/posts/:id/restore` — restore soft-deleted post (admin)

**Comments:**
- `GET /api/v1/blog/posts/:post_id/comments` — list comments (threaded)
- `POST /api/v1/blog/posts/:post_id/comments` — add comment
- `PUT /api/v1/blog/comments/:id` — edit comment
- `DELETE /api/v1/blog/comments/:id` — soft-delete comment

**Media:**
- `POST /api/v1/blog/posts/:post_id/media` — upload attachment
- `DELETE /api/v1/blog/media/:id` — remove attachment

### Domain Models
- `BlogPost` struct with all fields
- `BlogComment` struct with threading
- `BlogMedia` struct for attachments

### Audit Integration
- All blog CRUD operations logged to `audit_log` with action types: `blog_create`, `blog_update`, `blog_delete`, `blog_publish`, `comment_create`, `comment_delete`

## Acceptance Criteria

- [ ] Migration creates all 3 tables with correct constraints and indexes
- [ ] RLS policies enforce role-based access (coach/admin publish, all members read/comment)
- [ ] All 16 API endpoints return standard `{data, error, meta}` envelope
- [ ] Soft-delete works on posts and comments
- [ ] Admin restore endpoint works
- [ ] Pinned posts limited to 3 per org
- [ ] Slug auto-generated from title, unique per org
- [ ] Excerpt auto-generated if not provided (first 200 chars of body)
- [ ] All mutations logged to audit_log
- [ ] Unit tests for handlers, domain validation, and RLS policies
