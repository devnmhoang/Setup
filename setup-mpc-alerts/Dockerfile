FROM aztec/setup-mpc-common:latest

FROM node:10
WORKDIR /usr/src/setup-mpc-common
COPY --from=0 /usr/src/setup-mpc-common .
RUN yarn link
WORKDIR /usr/src/setup-mpc-client
COPY package.json yarn.lock ./
RUN yarn install
COPY . .
RUN yarn build
CMD ["yarn", "--silent", "start"]