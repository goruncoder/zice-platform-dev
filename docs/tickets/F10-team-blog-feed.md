# F10 — Team Blog: Feed + Post Viewer

**Repo:** `goruncoder/zice-frontend`  
**Milestone:** M3  
**Est. Size:** Medium  
**Blocked By:** C14 (blog backend API)

---

## Summary

Build the public-facing blog feed and single post viewer pages. All org members can browse published posts, filter by category/tag, and read full articles with comments.

## Scope

### Pages

| Route | Component | Description |
|---|---|---|
| `/blog` | `BlogFeed` | Paginated list of published posts, pinned posts first, category/tag filters, search |
| `/blog/:slug` | `BlogPost` | Full post view with rendered markdown body, media gallery, comments section |

### Components

- **`BlogCard`** — Preview card showing title, excerpt, author, published date, category, tags, cover image thumbnail
- **`BlogFeed`** — Grid/list of BlogCards with:
  - Category filter dropdown
  - Tag filter (multi-select chips)
  - Search by title/body
  - Pagination (page/per_page)
  - Pinned posts always appear first with visual indicator
- **`BlogPost`** — Full article view:
  - Rendered markdown body (sanitized HTML)
  - Cover image hero
  - Author name + avatar + published date
  - Category badge + tag chips
  - Media gallery (images, documents, embedded video)
- **`CommentSection`** — Threaded comments:
  - Top-level comments with one level of replies
  - Comment form (textarea + submit)
  - Author name + timestamp
  - Soft-delete own comment (or admin can delete any)
  - Empty state when no comments
- **`CommentForm`** — Text input for new comments/replies

### API Integration

- `api.listBlogPosts(token, orgId, params)` — GET posts with filters
- `api.getBlogPost(token, orgId, slug)` — GET single post
- `api.listComments(token, postId)` — GET threaded comments
- `api.createComment(token, postId, body, parentId?)` — POST new comment
- `api.deleteComment(token, commentId)` — DELETE (soft) comment

### UX Details

- Empty state: "No posts yet. Check back later!" with illustration
- Loading skeleton cards while fetching
- Responsive: single column on mobile, 2-3 columns on desktop
- Pinned post badge (pin icon + "Pinned")
- Time-relative dates ("2 hours ago", "Yesterday", "Mar 15")

## Acceptance Criteria

- [ ] Blog feed shows paginated published posts with pinned posts first
- [ ] Category and tag filters work correctly
- [ ] Search filters posts by title/body content
- [ ] Single post page renders markdown body safely
- [ ] Comments section shows threaded comments
- [ ] Users can add comments and reply to existing comments
- [ ] Users can soft-delete own comments
- [ ] Responsive layout on mobile and desktop
- [ ] Loading states and empty states handled
- [ ] Unit tests for BlogCard, CommentSection components
