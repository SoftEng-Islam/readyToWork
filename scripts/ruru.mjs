import { spawn } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';
import { config as loadEnv } from 'dotenv';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDir, '..');
const pnpmCommand = process.platform === 'win32' ? 'pnpm.cmd' : 'pnpm';
const args = new Set(process.argv.slice(2));
const optional = args.has('--optional');
const dryRun = args.has('--dry-run');

loadEnv({ path: resolve(projectRoot, '.env'), quiet: true, override: true });

function normalizeHostForUrl(host) {
  if (host === '0.0.0.0' || host === '::' || host === '127.0.0.1' || host === '::1') {
    return 'localhost';
  }

  return host.includes(':') ? `[${host}]` : host;
}

function normalizeRoutePrefix(pathname) {
  const normalized = pathname.startsWith('/') ? pathname : `/${pathname}`;

  return normalized === '/' ? normalized : normalized.replace(/\/$/, '');
}

function getMajorNodeVersion() {
  return Number.parseInt(process.versions.node.split('.')[0] ?? '', 10);
}

const host = normalizeHostForUrl(process.env.HOST ?? '0.0.0.0');
const port = Number.parseInt(process.env.PORT ?? '3000', 10);
const graphqlPath = normalizeRoutePrefix(process.env.GRAPHQL_PATH ?? '/graphql');
const ruruPort = process.env.RURU_PORT ?? '1337';
const endpoint =
  process.env.RURU_GRAPHQL_ENDPOINT ?? new URL(graphqlPath, `http://${host}:${port}/`).toString();

if (getMajorNodeVersion() < 22) {
  const message = `Standalone Ruru CLI requires Node 22+. Current runtime: ${process.version}.`;

  if (optional) {
    console.warn(`[ruru] ${message} Skipping the standalone Ruru sidecar.`);
    process.exit(0);
  }

  console.error(`[ruru] ${message}`);
  process.exit(1);
}

const cliArgs = ['exec', 'ruru', '-p', ruruPort, '-P', '-e', endpoint];

if (dryRun) {
  console.log(`ui=http://localhost:${ruruPort}`);
  console.log(`endpoint=${endpoint}`);
  console.log(`${pnpmCommand} ${cliArgs.join(' ')}`);
  process.exit(0);
}

console.log(`[ruru] Standalone UI: http://localhost:${ruruPort}`);
console.log(`[ruru] Proxy target: ${endpoint}`);

const child = spawn(pnpmCommand, cliArgs, {
  cwd: projectRoot,
  env: process.env,
  stdio: 'inherit',
});

function forwardSignal(signal) {
  if (child.exitCode !== null || child.signalCode !== null) {
    return;
  }

  child.kill(signal);
}

process.on('SIGINT', () => {
  forwardSignal('SIGINT');
});

process.on('SIGTERM', () => {
  forwardSignal('SIGTERM');
});

child.on('error', (error) => {
  console.error(`[ruru] Failed to start: ${error.message}`);
  process.exit(1);
});

child.on('exit', (code, signal) => {
  if (signal) {
    process.exit(1);
  }

  process.exit(code ?? 0);
});
