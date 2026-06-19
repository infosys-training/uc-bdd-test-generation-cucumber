# Enterprise Social Media Platform — "ChirpNet"

## 1. Overview

Build an enterprise-grade, Twitter-like social media platform that enables users to register, create profiles, publish and share posts, engage with content, send direct messages, and discover other users. The system must be designed as a cloud-native, microservices-based architecture with high availability, horizontal scalability, and robust security.

---

## 2. Functional Requirements

### 2.1 User Management

| ID | Use Case | Description |
|:---|:---------|:------------|
| UM-01 | User Registration | Users register with email, phone, or SSO (Google, Apple, GitHub). Email/phone verification via OTP. |
| UM-02 | User Login / Authentication | Login with email/password, phone/OTP, or OAuth 2.0. Issue JWT access + refresh tokens. |
| UM-03 | Profile Management | Users can set display name, bio (160 chars), profile picture, banner image, location, website URL, and date of birth. |
| UM-04 | User Handle (@username) | Each user selects a unique handle (e.g., `@johndoe`). Handles are searchable and taggable. |
| UM-05 | Account Settings | Change password, manage 2FA (TOTP/SMS), notification preferences, privacy settings (public/protected account). |
| UM-06 | Account Deactivation/Deletion | Soft-delete with 30-day recovery window, then hard-delete with data purge per GDPR/CCPA. |
| UM-07 | User Verification | Admin-driven or criteria-based verified badge system. |

### 2.2 Posts (Chirps)

| ID | Use Case | Description |
|:---|:---------|:------------|
| PO-01 | Create Post | Publish a text post (280 chars max) with optional media attachments (images, GIFs, video up to 2 min). |
| PO-02 | Delete Post | Author can delete their own post. Cascades removal from feeds and repost chains. |
| PO-03 | Edit Post | Author can edit within a configurable time window. Edit history is preserved and visible. |
| PO-04 | Reply to Post | Threaded replies. Replies are posts linked to a parent post, forming conversation trees. |
| PO-05 | Repost (Retweet) | Share another user's post to your followers. Option for "Quote Repost" with added commentary. |
| PO-06 | Like Post | Toggle like on a post. Like counts are visible. |
| PO-07 | Bookmark Post | Save a post privately for later viewing. Bookmarks are not visible to other users. |
| PO-08 | Media Upload | Upload up to 4 images or 1 video per post. Images are compressed and served via CDN. Alt-text support for accessibility. |
| PO-09 | Polls | Create polls with 2–4 options, configurable duration (1 hour – 7 days). |
| PO-10 | Scheduled Posts | Compose a post and schedule it for future publication. |

### 2.3 Social Graph

| ID | Use Case | Description |
|:---|:---------|:------------|
| SG-01 | Follow User | Follow a public account instantly. Follow requests for protected accounts. |
| SG-02 | Unfollow User | Unfollow at any time. |
| SG-03 | Block User | Blocked users cannot view your profile, posts, or send DMs. Mutual unfollows on block. |
| SG-04 | Mute User | Muted user's posts are hidden from your feed but they can still interact with your content. |
| SG-05 | Followers / Following Lists | Paginated lists of followers and following. |
| SG-06 | Follow Suggestions | Algorithmic suggestions based on mutual connections, interests, and trending accounts. |

### 2.4 Feed & Timeline

| ID | Use Case | Description |
|:---|:---------|:------------|
| FD-01 | Home Timeline | Reverse-chronological feed of posts from followed accounts, with optional algorithmic ranking. |
| FD-02 | For You Feed | AI/ML-curated feed based on engagement signals, interests, and trending content. |
| FD-03 | User Profile Timeline | All posts by a specific user, visible on their profile page. |
| FD-04 | Pull-to-Refresh | Real-time or near-real-time feed updates via WebSocket or SSE. |

### 2.5 Direct Messaging (DM)

| ID | Use Case | Description |
|:---|:---------|:------------|
| DM-01 | Send Direct Message | Send text, images, GIFs, or links to another user in a private 1:1 conversation. |
| DM-02 | Group Conversations | Create group DM threads with up to 50 participants. |
| DM-03 | Message Reactions | React to individual messages with emoji. |
| DM-04 | Read Receipts | Show when a message has been delivered and read (configurable by recipient). |
| DM-05 | Delete Message | Delete a message for yourself or for everyone (within time window). |
| DM-06 | DM Requests | Messages from non-followers go to a "Message Requests" inbox. |
| DM-07 | Media Sharing in DM | Share posts, profiles, and media within DM threads. |
| DM-08 | End-to-End Encryption | Optional E2EE for DM conversations using Signal Protocol or equivalent. |

### 2.6 Mentions, Tags & Hashtags

| ID | Use Case | Description |
|:---|:---------|:------------|
| MT-01 | @Mention Users | Tag users by handle in posts or replies. Mentioned users receive notifications. |
| MT-02 | #Hashtags | Include hashtags in posts. Hashtags are clickable and lead to a search results page. |
| MT-03 | Trending Hashtags | System tracks hashtag velocity and surfaces trending topics by region/globally. |
| MT-04 | Cashtags | Support `$TICKER` tags for financial content linking (optional). |

### 2.7 Search & Discovery

| ID | Use Case | Description |
|:---|:---------|:------------|
| SD-01 | Full-Text Search | Search posts, users, and hashtags. Supports filters: date range, media type, from-user, language. |
| SD-02 | Trending Topics | Algorithmically determined trending topics, filterable by location. |
| SD-03 | Explore Page | Curated categories: News, Sports, Entertainment, Technology, etc. |
| SD-04 | Autocomplete | Typeahead suggestions for @handles, #hashtags, and search queries. |

### 2.8 Notifications

| ID | Use Case | Description |
|:---|:---------|:------------|
| NT-01 | In-App Notifications | Real-time notification bell: likes, replies, reposts, mentions, follows, DMs. |
| NT-02 | Push Notifications | Mobile and web push via FCM/APNs. |
| NT-03 | Email Notifications | Digest emails: daily/weekly summaries, security alerts. |
| NT-04 | Notification Preferences | Granular per-type and per-user mute controls. |

### 2.9 Moderation & Safety

| ID | Use Case | Description |
|:---|:---------|:------------|
| MS-01 | Report Content | Users can report posts, accounts, or DMs for policy violations. |
| MS-02 | Content Moderation Queue | Admin/moderator dashboard to review flagged content. |
| MS-03 | Automated Content Filtering | ML-based detection of spam, hate speech, NSFW content, and misinformation. |
| MS-04 | Account Suspension | Temporary or permanent account suspension by admins. |
| MS-05 | Sensitive Content Warning | Poster or system can mark content as sensitive, requiring click-through to view. |
| MS-06 | Rate Limiting | API-level and action-level rate limiting (e.g., max 300 posts/day, max 1000 follows/day). |

### 2.10 Analytics & Admin

| ID | Use Case | Description |
|:---|:---------|:------------|
| AA-01 | User Analytics | Post impressions, profile visits, follower growth, engagement rate. |
| AA-02 | Admin Dashboard | System health, user growth, content volume, moderation metrics. |
| AA-03 | Audit Logs | Immutable logs of admin actions, account changes, and security events. |

---

## 3. Non-Functional Requirements

| Category | Requirement |
|:---------|:------------|
| **Scalability** | Support 50M+ registered users, 500K+ concurrent connections, 10K+ posts/second. |
| **Availability** | 99.99% uptime SLA. Multi-region active-active deployment. |
| **Latency** | Feed load < 200ms p95. Post publish < 500ms p95. Search < 300ms p95. |
| **Security** | OAuth 2.0 + OIDC, JWT, bcrypt password hashing, TLS 1.3, CSP headers, OWASP Top 10 compliance. |
| **Data Privacy** | GDPR, CCPA compliant. Data export (account takeout), right to erasure. |
| **Observability** | Distributed tracing (OpenTelemetry), structured logging (ELK/Loki), metrics (Prometheus/Grafana). |
| **CI/CD** | Automated build, test, deploy pipelines. Blue-green or canary deployments. |
| **Accessibility** | WCAG 2.1 AA compliance. Screen reader support, keyboard navigation, alt-text on media. |

---

## 4. Architecture — Microservices Breakdown

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                          API Gateway / BFF                             │
│                  (Rate Limiting, Auth, Routing)                        │
└──────────┬──────────┬──────────┬──────────┬──────────┬────────────────┘
           │          │          │          │          │
     ┌─────▼──┐ ┌─────▼──┐ ┌────▼───┐ ┌────▼───┐ ┌───▼────┐
     │ User   │ │ Post   │ │ Feed   │ │  DM    │ │ Notif  │
     │Service │ │Service │ │Service │ │Service │ │Service │
     └────────┘ └────────┘ └────────┘ └────────┘ └────────┘
           │          │          │          │          │
     ┌─────▼──┐ ┌─────▼──┐ ┌────▼───┐ ┌────▼───┐ ┌───▼────┐
     │UserDB  │ │PostDB  │ │FeedDB  │ │ DM DB  │ │NotifDB │
     │(Postgres)│(Postgres)│(Redis/ │ │(Cassandra)│(Postgres)│
     │        │ │+Elastic│ │Cassandra)│        │ │        │
     └────────┘ └────────┘ └────────┘ └────────┘ └────────┘
```

### 4.1 Service Catalog

| # | Service | Responsibilities | Tech Stack |
|:--|:--------|:-----------------|:-----------|
| 1 | **API Gateway** | Request routing, rate limiting, authentication, SSL termination, request/response transformation. | Kong / AWS API Gateway / Spring Cloud Gateway |
| 2 | **User Service** | Registration, authentication, profile CRUD, social graph (follow/block/mute), user search, handle management. | Spring Boot, PostgreSQL, Redis (session cache) |
| 3 | **Auth Service** | OAuth 2.0 / OIDC provider, JWT issuance and validation, 2FA, SSO integration. | Spring Authorization Server / Keycloak |
| 4 | **Post Service** | Post CRUD, replies, reposts, likes, bookmarks, polls, scheduled posts, hashtag extraction. | Spring Boot, PostgreSQL, Elasticsearch (full-text search) |
| 5 | **Feed Service** | Home timeline generation (fan-out-on-write for normal users, fan-out-on-read for celebrity users), "For You" ranking. | Spring Boot, Redis (timeline cache), Apache Kafka (fan-out), Cassandra (timeline store) |
| 6 | **Direct Messaging Service** | 1:1 and group conversations, message CRUD, reactions, read receipts, E2EE key exchange. | Spring Boot, Cassandra, WebSocket (STOMP), Redis Pub/Sub |
| 7 | **Notification Service** | In-app, push (FCM/APNs), and email notifications. Preference management, deduplication, batching. | Spring Boot, PostgreSQL, Apache Kafka (event ingestion), Firebase/SES |
| 8 | **Media Service** | Image/video upload, transcoding, thumbnail generation, CDN integration, alt-text storage. | Spring Boot, S3-compatible storage, FFmpeg, CloudFront/Cloudflare CDN |
| 9 | **Search Service** | Full-text search across posts, users, hashtags. Autocomplete, trending computation. | Elasticsearch / OpenSearch |
| 10 | **Moderation Service** | Content flagging, automated ML-based filtering, moderator review queue, account suspension. | Spring Boot, PostgreSQL, ML model serving (TensorFlow Serving / SageMaker) |
| 11 | **Analytics Service** | Post impressions, engagement metrics, user analytics, admin dashboards. | Spring Boot, ClickHouse / Apache Druid, Grafana |
| 12 | **Audit Service** | Immutable event log for compliance, admin actions, security events. | Spring Boot, Apache Kafka, Elasticsearch / S3 (cold storage) |

---

## 5. Data Models (Key Entities)

### 5.1 User
```
User {
  id            : UUID (PK)
  handle        : VARCHAR(30) UNIQUE   -- @username
  email         : VARCHAR(255) UNIQUE
  phone         : VARCHAR(20)
  password_hash : VARCHAR(255)
  display_name  : VARCHAR(50)
  bio           : VARCHAR(160)
  avatar_url    : TEXT
  banner_url    : TEXT
  location      : VARCHAR(100)
  website       : VARCHAR(200)
  dob           : DATE
  is_verified   : BOOLEAN
  is_protected  : BOOLEAN
  status        : ENUM(ACTIVE, SUSPENDED, DEACTIVATED)
  created_at    : TIMESTAMP
  updated_at    : TIMESTAMP
}
```

### 5.2 Post (Chirp)
```
Post {
  id              : BIGINT / Snowflake ID (PK)
  author_id       : UUID (FK -> User)
  content         : VARCHAR(280)
  parent_post_id  : BIGINT (FK -> Post, nullable)  -- for replies
  repost_of_id    : BIGINT (FK -> Post, nullable)  -- for reposts/quotes
  quote_content   : VARCHAR(280)                   -- for quote reposts
  media_urls      : JSONB                          -- array of media references
  poll_id         : UUID (FK -> Poll, nullable)
  is_sensitive    : BOOLEAN
  like_count      : INT
  reply_count     : INT
  repost_count    : INT
  view_count      : BIGINT
  scheduled_at    : TIMESTAMP (nullable)
  published_at    : TIMESTAMP
  created_at      : TIMESTAMP
  updated_at      : TIMESTAMP
}
```

### 5.3 Follow
```
Follow {
  follower_id   : UUID (FK -> User)
  following_id  : UUID (FK -> User)
  status        : ENUM(ACTIVE, PENDING)  -- pending for protected accounts
  created_at    : TIMESTAMP
  PK(follower_id, following_id)
}
```

### 5.4 DirectMessage
```
DirectMessage {
  id              : UUID (PK)
  conversation_id : UUID (FK -> Conversation)
  sender_id       : UUID (FK -> User)
  content         : TEXT (encrypted if E2EE)
  media_url       : TEXT
  is_read         : BOOLEAN
  deleted_for     : UUID[]               -- soft-delete per participant
  created_at      : TIMESTAMP
}

Conversation {
  id            : UUID (PK)
  type          : ENUM(ONE_TO_ONE, GROUP)
  participant_ids : UUID[]
  created_at    : TIMESTAMP
  updated_at    : TIMESTAMP
}
```

### 5.5 Notification
```
Notification {
  id          : UUID (PK)
  user_id     : UUID (FK -> User)
  type        : ENUM(LIKE, REPLY, REPOST, MENTION, FOLLOW, DM, SYSTEM)
  actor_id    : UUID (FK -> User)
  target_id   : VARCHAR            -- polymorphic: post ID, DM ID, etc.
  target_type : ENUM(POST, DM, USER)
  is_read     : BOOLEAN
  created_at  : TIMESTAMP
}
```

---

## 6. API Design (Key Endpoints)

All endpoints are RESTful, versioned (`/api/v1/`), and return JSON.

### 6.1 User Service
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
GET    /api/v1/users/{handle}
PUT    /api/v1/users/me
DELETE /api/v1/users/me
POST   /api/v1/users/{handle}/follow
DELETE /api/v1/users/{handle}/follow
POST   /api/v1/users/{handle}/block
DELETE /api/v1/users/{handle}/block
POST   /api/v1/users/{handle}/mute
DELETE /api/v1/users/{handle}/mute
GET    /api/v1/users/{handle}/followers?page=&size=
GET    /api/v1/users/{handle}/following?page=&size=
```

### 6.2 Post Service
```
POST   /api/v1/posts
GET    /api/v1/posts/{id}
PUT    /api/v1/posts/{id}
DELETE /api/v1/posts/{id}
POST   /api/v1/posts/{id}/like
DELETE /api/v1/posts/{id}/like
POST   /api/v1/posts/{id}/repost
POST   /api/v1/posts/{id}/reply
POST   /api/v1/posts/{id}/bookmark
DELETE /api/v1/posts/{id}/bookmark
GET    /api/v1/posts/{id}/replies?page=&size=
GET    /api/v1/users/{handle}/posts?page=&size=
```

### 6.3 Feed Service
```
GET    /api/v1/feed/home?cursor=&size=
GET    /api/v1/feed/foryou?cursor=&size=
```

### 6.4 DM Service
```
GET    /api/v1/conversations?page=&size=
POST   /api/v1/conversations
GET    /api/v1/conversations/{id}/messages?cursor=&size=
POST   /api/v1/conversations/{id}/messages
DELETE /api/v1/conversations/{id}/messages/{msgId}
PUT    /api/v1/conversations/{id}/messages/{msgId}/read
```

### 6.5 Search Service
```
GET    /api/v1/search?q=&type=posts|users|hashtags&page=&size=
GET    /api/v1/trending?region=
GET    /api/v1/search/autocomplete?q=
```

### 6.6 Notification Service
```
GET    /api/v1/notifications?page=&size=
PUT    /api/v1/notifications/read-all
PUT    /api/v1/notifications/{id}/read
GET    /api/v1/notifications/preferences
PUT    /api/v1/notifications/preferences
```

### 6.7 Media Service
```
POST   /api/v1/media/upload          (multipart)
GET    /api/v1/media/{id}
DELETE /api/v1/media/{id}
```

---

## 7. Event-Driven Communication

Inter-service communication uses Apache Kafka topics:

| Topic | Producer | Consumer(s) | Payload |
|:------|:---------|:------------|:--------|
| `post.created` | Post Service | Feed Service, Search Service, Notification Service | `{ postId, authorId, content, mentions[], hashtags[] }` |
| `post.deleted` | Post Service | Feed Service, Search Service | `{ postId, authorId }` |
| `post.liked` | Post Service | Notification Service, Analytics Service | `{ postId, likerId }` |
| `user.followed` | User Service | Notification Service, Feed Service | `{ followerId, followingId }` |
| `user.registered` | User Service | Notification Service (welcome), Analytics Service | `{ userId, handle }` |
| `dm.sent` | DM Service | Notification Service | `{ conversationId, senderId, recipientIds[] }` |
| `content.flagged` | Moderation Service | Moderation Service (ML pipeline) | `{ contentId, contentType, reason }` |
| `post.viewed` | Feed Service | Analytics Service | `{ postId, viewerId, timestamp }` |

---

## 8. Infrastructure & DevOps

| Component | Technology |
|:----------|:-----------|
| Container Orchestration | Kubernetes (EKS/GKE/AKS) |
| Service Mesh | Istio / Linkerd |
| CI/CD | GitHub Actions / Jenkins / ArgoCD |
| Container Registry | ECR / GCR / Harbor |
| Secret Management | HashiCorp Vault / AWS Secrets Manager |
| Configuration | Spring Cloud Config / Consul |
| Logging | ELK Stack (Elasticsearch, Logstash, Kibana) / Loki + Grafana |
| Metrics | Prometheus + Grafana |
| Tracing | OpenTelemetry + Jaeger / Zipkin |
| CDN | CloudFront / Cloudflare |
| Object Storage | AWS S3 / MinIO |
| Message Broker | Apache Kafka (with Schema Registry) |
| Cache | Redis Cluster |
| Databases | PostgreSQL (OLTP), Cassandra (timelines, DMs), Elasticsearch (search), ClickHouse (analytics) |

---

## 9. Security Considerations

- **Authentication**: OAuth 2.0 + OIDC with PKCE for public clients.
- **Authorization**: RBAC (roles: USER, MODERATOR, ADMIN) + ABAC for fine-grained resource-level policies.
- **API Security**: Rate limiting per user/IP, input validation, parameterized queries, CORS policies.
- **Data at Rest**: AES-256 encryption for sensitive fields, encrypted database volumes.
- **Data in Transit**: TLS 1.3 for all inter-service and external communication.
- **DM Encryption**: Optional end-to-end encryption using Signal Protocol (X3DH + Double Ratchet).
- **Vulnerability Management**: Automated dependency scanning (Snyk/Dependabot), SAST/DAST in CI pipeline.
- **Abuse Prevention**: CAPTCHA on registration, IP-based throttling, account lockout after failed login attempts.

---

## 10. Testing Strategy

| Level | Scope | Tools |
|:------|:------|:------|
| Unit Tests | Individual service logic, domain models | JUnit 5, Mockito |
| Integration Tests | Service + database, service + Kafka | Testcontainers, Spring Boot Test |
| BDD / Acceptance Tests | End-to-end API scenarios in Gherkin | Cucumber, cucumber-restapi (this repo), WireMock |
| Contract Tests | Inter-service API compatibility | Spring Cloud Contract / Pact |
| Performance Tests | Load, stress, spike testing | Gatling / k6 / JMeter |
| Security Tests | OWASP scans, pen testing | OWASP ZAP, Burp Suite |
| Chaos Engineering | Resilience under failure conditions | Chaos Monkey / Litmus |

---

## 11. Deployment Topology

```text
                    ┌──────────────┐
                    │   CloudFlare  │
                    │     CDN       │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │  Load        │
                    │  Balancer    │
                    └──────┬───────┘
                           │
              ┌────────────▼────────────┐
              │     API Gateway          │
              │  (Auth + Rate Limiting)  │
              └────────────┬────────────┘
                           │
        ┌──────┬──────┬────┴────┬──────┬──────┐
        │      │      │         │      │      │
      User   Post   Feed      DM   Notif  Media
      Svc    Svc    Svc       Svc   Svc    Svc
        │      │      │         │      │      │
     Postgres Postgres Redis  Cassandra Postgres S3
              +ES    +Cassandra
                           │
                     ┌─────▼──────┐
                     │   Kafka    │
                     │  Cluster   │
                     └────────────┘
```

Multi-region: Deploy in at least 2 regions (e.g., us-east-1, eu-west-1) with active-active replication and global DNS routing.

---

## 12. Milestones

| Phase | Scope | Key Deliverables |
|:------|:------|:-----------------|
| **Phase 1 — MVP** | User registration/login, post CRUD, follow/unfollow, home feed, basic search. | Deployable monolith or 3-service split. |
| **Phase 2 — Social** | DM (1:1), @mentions, #hashtags, notifications (in-app), likes, reposts. | Event-driven architecture, Kafka integration. |
| **Phase 3 — Scale** | Feed ranking, trending topics, media uploads, CDN, full-text search, analytics. | Elasticsearch, Redis caching, media pipeline. |
| **Phase 4 — Trust & Safety** | Content moderation (ML), reporting, account suspension, rate limiting, audit logs. | ML pipeline, moderation dashboard. |
| **Phase 5 — Polish** | Group DMs, E2EE, polls, scheduled posts, user verification, explore page, mobile push. | Full feature parity. |

---

## 13. Glossary

| Term | Definition |
|:-----|:-----------|
| **Chirp** | A post on the platform (equivalent to a Tweet). |
| **Handle** | A unique username prefixed with `@` (e.g., `@johndoe`). |
| **Repost** | Sharing another user's chirp to your followers. |
| **Quote Repost** | A repost with added commentary. |
| **Fan-out-on-write** | Pre-computing feed entries into each follower's timeline cache at post-creation time. |
| **Fan-out-on-read** | Computing the feed at read time by merging posts from followed accounts. |
| **Snowflake ID** | A time-sortable, globally unique 64-bit ID (inspired by Twitter Snowflake). |
