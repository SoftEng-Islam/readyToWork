#!/bin/sh

set -u

NODE_MIN_VERSION="20.19.0"
PNPM_MIN_VERSION="10.14.0"
DEFAULT_DATABASE_URL="postgresql://postgres:postgres@localhost:5432/commerce"

pass_count=0
warn_count=0
fail_count=0
env_source=".env"
database_source=".env"

say() {
  printf '%s\n' "$*"
}

pass() {
  pass_count=$((pass_count + 1))
  say "PASS  $*"
}

warn() {
  warn_count=$((warn_count + 1))
  say "WARN  $*"
}

fail() {
  fail_count=$((fail_count + 1))
  say "FAIL  $*"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

version_ge() {
  node -e '
const [found, needed] = process.argv.slice(1)
const parse = (value) => value.replace(/^v/, "").split(".").map((part) => Number(part) || 0)
const left = parse(found)
const right = parse(needed)
const length = Math.max(left.length, right.length)
for (let index = 0; index < length; index += 1) {
  const leftValue = left[index] ?? 0
  const rightValue = right[index] ?? 0
  if (leftValue > rightValue) process.exit(0)
  if (leftValue < rightValue) process.exit(1)
}
process.exit(0)
' "$1" "$2"
}

mask_database_url() {
  if ! has_cmd node; then
    printf '%s\n' '(DATABASE_URL hidden)'
    return
  fi

  node -e '
const raw = process.argv[1]
try {
  const url = new URL(raw)
  if (url.password) url.password = "***"
  console.log(url.toString())
} catch {
  console.log("(invalid DATABASE_URL)")
}
' "$1"
}

check_tcp_database() {
  if ! has_cmd node; then
    return 2
  fi

  node -e '
const raw = process.argv[1]
const net = require("node:net")
let url
try {
  url = new URL(raw)
} catch {
  process.exit(2)
}
const host = url.hostname || "localhost"
const port = Number(url.port || 5432)
const socket = net.createConnection({ host, port })
socket.setTimeout(3000)
socket.on("connect", () => {
  socket.end()
  process.exit(0)
})
socket.on("timeout", () => {
  socket.destroy()
  process.exit(1)
})
socket.on("error", () => process.exit(1))
' "$1"
}

load_env_file() {
  if [ -f ./.env ]; then
    set -a
    # shellcheck disable=SC1091
    . ./.env
    set +a
    pass ".env file found"
  else
    env_source="fallback values"
    warn ".env file not found. Run: cp .env.example .env"
  fi

  if [ -n "${DATABASE_URL-}" ]; then
    database_source="$env_source"
  else
    DATABASE_URL="$DEFAULT_DATABASE_URL"
    database_source="fallback local value"
    warn "DATABASE_URL is not set. Using the local PostgreSQL fallback value"
  fi

  if [ -d ./node_modules ]; then
    pass "node_modules folder found"
  else
    warn "node_modules folder not found. Run: pnpm install"
  fi
}

say "Project doctor"
say "-------------"

if has_cmd git; then
  pass "git is installed: $(git --version | awk '{print $3}')"
else
  warn "git is not installed"
fi

if has_cmd node; then
  node_version=$(node --version)
  pass "node is installed: $node_version"
  if version_ge "$node_version" "$NODE_MIN_VERSION"; then
    pass "node version is new enough (need >= $NODE_MIN_VERSION)"
  else
    fail "node version is too old. Need >= $NODE_MIN_VERSION"
  fi
else
  fail "node is not installed"
fi

if has_cmd pnpm; then
  pnpm_version=$(pnpm --version)
  pass "pnpm is installed: $pnpm_version"
  if has_cmd node && version_ge "$pnpm_version" "$PNPM_MIN_VERSION"; then
    pass "pnpm version is new enough (need >= $PNPM_MIN_VERSION)"
  else
    fail "pnpm version is too old. Need >= $PNPM_MIN_VERSION"
  fi
else
  fail "pnpm is not installed"
fi

if has_cmd psql; then
  pass "psql is installed: $(psql --version | awk '{print $3}')"
else
  warn "psql is not installed. Install PostgreSQL client tools if you want local database commands"
fi

if has_cmd pg_isready; then
  pass "pg_isready is installed"
else
  warn "pg_isready is not installed. The script can still test PostgreSQL with Node.js"
fi

load_env_file

say ""
say "Database source: $database_source"
say "Database target: $(mask_database_url "$DATABASE_URL")"

if check_tcp_database "$DATABASE_URL"; then
  pass "PostgreSQL server port is reachable"
else
  tcp_status=$?
  if [ "$tcp_status" -eq 2 ]; then
    fail "DATABASE_URL is not valid"
  else
    fail "PostgreSQL is not reachable on the host and port from DATABASE_URL"
  fi
fi

if has_cmd psql; then
  if PGCONNECT_TIMEOUT=3 psql "$DATABASE_URL" -c "select 1" >/dev/null 2>&1; then
    pass "PostgreSQL login and database check passed"
  else
    fail "Could not log in to PostgreSQL with DATABASE_URL"
  fi
else
  warn "Database login test skipped because psql is not installed"
fi

say ""
say "Summary"
say "PASS: $pass_count"
say "WARN: $warn_count"
say "FAIL: $fail_count"

if [ "$fail_count" -gt 0 ]; then
  exit 1
fi

exit 0
