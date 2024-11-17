CREATE TABLE IF NOT EXISTS go_links (
    id BIGINT NOT NULL PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    short TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    long TEXT NOT NULL
);

CREATE UNIQUE INDEX idx_golinks_short
ON go_links(short);