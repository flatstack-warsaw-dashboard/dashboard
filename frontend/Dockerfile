FROM node:18.1.0-alpine

WORKDIR /usr/src/app

RUN corepack enable && corepack prepare

COPY package.json ./
COPY pnpm-lock.yaml ./

RUN pnpm install

COPY . .

RUN NODE_ENV=production pnpm run build
