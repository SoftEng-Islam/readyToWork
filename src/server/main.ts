import type { Server } from 'node:http';
import { networkInterfaces } from 'node:os';
import ViteExpress from 'vite-express';
import { createApp } from './app';
import { env } from './config/env';
import { logger } from './config/logger';
import { pool } from './db/client';
import { connectMongo, disconnectMongo } from './db/mongo';

function closeServer(server: Server) {
	return new Promise<void>((resolve, reject) => {
		server.close((error) => {
			if (error) {
				reject(error);
				return;
			}

			resolve();
		});
	});
}

function normalizeRoutePrefix(pathname: string) {
	const normalized = pathname.startsWith('/') ? pathname : `/${pathname}`;

	return normalized === '/' ? normalized : normalized.replace(/\/$/, '');
}

function matchesMountedPath(requestPath: string, mountedPath: string) {
	return requestPath === mountedPath || requestPath.startsWith(`${mountedPath}/`);
}

function normalizeHostForUrl(host: string) {
	if (host === '0.0.0.0' || host === '::' || host === '127.0.0.1' || host === '::1') {
		return 'localhost';
	}

	return host.includes(':') ? `[${host}]` : host;
}

function createOrigin(host: string, port: number) {
	return `http://${normalizeHostForUrl(host)}:${port}`;
}

function createUrl(origin: string, pathname: string) {
	return new URL(pathname, `${origin}/`).toString();
}

function getNetworkOrigins(port: number) {
	const interfaces = networkInterfaces();
	const origins = new Set<string>();

	for (const networkGroup of Object.values(interfaces)) {
		for (const network of networkGroup ?? []) {
			if (network.family !== 'IPv4' || network.internal) {
				continue;
			}

			origins.add(`http://${network.address}:${port}`);
		}
	}

	return [...origins];
}

async function bootstrap() {
	const mongoConnection = await connectMongo();
	const app = await createApp();
	const apiPrefix = normalizeRoutePrefix(env.API_PREFIX);
	const graphqlPath = normalizeRoutePrefix(env.GRAPHQL_PATH);
	const appOrigin = createOrigin(env.HOST, env.PORT);
	const healthUrl = createUrl(appOrigin, `${apiPrefix}/health`);
	const graphqlUrl = createUrl(appOrigin, graphqlPath);
	const networkOrigins =
		env.HOST === '0.0.0.0' || env.HOST === '::' ? getNetworkOrigins(env.PORT) : [];

	ViteExpress.config({
		mode: env.NODE_ENV === 'production' ? 'production' : 'development',
		ignorePaths: (path) =>
			matchesMountedPath(path, apiPrefix) || matchesMountedPath(path, graphqlPath),
	});

	const server = app.listen(env.PORT, env.HOST, () => {
		logger.info(
			{
				port: env.PORT,
				host: env.HOST,
				mongo: mongoConnection
					? {
							host: mongoConnection.host,
							name: mongoConnection.name,
						}
					: {
							enabled: false,
						},
			},
			'server started',
		);
		logger.info(
			{
				app: appOrigin,
				health: healthUrl,
				graphqlApi: graphqlUrl,
				graphqlUiEmbedded: graphqlUrl,
				...(networkOrigins.length > 0
					? {
							network: networkOrigins,
						}
					: {}),
			},
			'open these app URLs in your browser',
		);
	});

	await ViteExpress.bind(app, server);

	let isShuttingDown = false;

	const shutdown = async (signal: NodeJS.Signals) => {
		if (isShuttingDown) {
			return;
		}

		isShuttingDown = true;
		logger.info({ signal }, 'shutdown requested');

		try {
			await closeServer(server);
			await Promise.allSettled([pool.end(), disconnectMongo()]);
			process.exit(0);
		} catch (error) {
			logger.error(error, 'graceful shutdown failed');
			process.exit(1);
		}
	};

	process.once('SIGINT', () => {
		void shutdown('SIGINT');
	});

	process.once('SIGTERM', () => {
		void shutdown('SIGTERM');
	});
}

void bootstrap().catch((error) => {
	logger.error(error, 'failed to start server');
	process.exit(1);
});
