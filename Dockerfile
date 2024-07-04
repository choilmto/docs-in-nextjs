FROM node:20-slim AS base
ENV COREPACK_HOME=/var/cache/corepack
ENV COREPACK_DEFAULT_TO_LATEST=0
ENV COREPACK_ENABLE_AUTO_PIN=0
RUN corepack pack pnpm@9.x
WORKDIR /app

FROM base AS build
# the --frozen-lockfile flag is for when the container is run outside of CI
COPY . /app
RUN corepack pnpm install --frozen-lockfile
RUN corepack pnpm run build

FROM base AS prod
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.3 /lambda-adapter /opt/extensions/lambda-adapter
COPY package.json /app/package.json
COPY --from=build /app/.next/ /app/.next/
COPY --from=build /app/node_modules /app/node_modules/
CMD [ "corepack", "pnpm", "start", "--port", "8080" ]

FROM build AS test-jest
CMD [ "npm", "run", "test" ]

FROM build AS test-playwright
RUN npx playwright install
RUN npx playwright install-deps
CMD [ "npx", "playwright", "test" ]
