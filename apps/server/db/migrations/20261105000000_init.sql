-- migrate:up
-- Khung ban đầu (docs/tech/01 mục 5–6). Bảng nghiệp vụ (task, series, timebox…)
-- thêm theo từng nhóm tính năng.

CREATE TABLE users (
  id            uuid PRIMARY KEY,
  email         text NOT NULL UNIQUE,
  timezone      text NOT NULL DEFAULT 'Asia/Ho_Chi_Minh',
  day_start     interval NOT NULL DEFAULT '04:00'
                CHECK (day_start >= '00:00' AND day_start <= '06:00'),
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- Phiên đăng nhập, thu hồi được (session.revoked, "Không phải tôi").
CREATE TABLE sessions (
  id                 uuid PRIMARY KEY,
  user_id            uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  refresh_token_hash bytea NOT NULL,
  created_at         timestamptz NOT NULL DEFAULT now(),
  last_used_at       timestamptz NOT NULL DEFAULT now(),
  revoked_at         timestamptz
);
CREATE INDEX sessions_user_idx ON sessions (user_id) WHERE revoked_at IS NULL;

-- Nhật ký thay đổi: số thứ tự toàn cục do server gán (QC-08 mục 1).
-- Client kéo bằng GET /v1/changes?cursor=<seq>.
CREATE TABLE change_log (
  seq          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id      uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  entity_type  text NOT NULL,
  entity_id    uuid NOT NULL,
  version      integer NOT NULL,
  actor        text NOT NULL CHECK (actor IN ('user', 'ai', 'system')),
  ai_turn_id   uuid,
  data         jsonb NOT NULL,
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX change_log_user_seq_idx ON change_log (user_id, seq);
CREATE INDEX change_log_ai_turn_idx ON change_log (ai_turn_id) WHERE ai_turn_id IS NOT NULL;

-- Idempotency: kết quả của từng commandId, giữ 30 ngày.
CREATE TABLE processed_commands (
  command_id   uuid PRIMARY KEY,
  user_id      uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  result       jsonb NOT NULL,
  processed_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX processed_commands_age_idx ON processed_commands (processed_at);

-- Job nền: lease bằng SELECT … FOR UPDATE SKIP LOCKED (docs/tech/01 mục 5).
CREATE TABLE jobs (
  id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  kind          text NOT NULL,
  user_id       uuid REFERENCES users (id) ON DELETE CASCADE,
  payload       jsonb NOT NULL DEFAULT '{}',
  run_at        timestamptz NOT NULL,
  attempts      integer NOT NULL DEFAULT 0,
  status        text NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'running', 'done', 'failed')),
  leased_until  timestamptz,
  last_error    text,
  created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX jobs_due_idx ON jobs (run_at) WHERE status IN ('pending', 'running');
CREATE UNIQUE INDEX jobs_once_idx ON jobs (kind, user_id, (payload ->> 'workday'))
  WHERE kind = 'rollover';

-- migrate:down
DROP TABLE jobs;
DROP TABLE processed_commands;
DROP TABLE change_log;
DROP TABLE sessions;
DROP TABLE users;
