FROM node:10.17.0 AS dep
COPY . /app
WORKDIR /app
RUN npm install --production

FROM gcr.io/distroless/nodejs
COPY --from=dep /app /app
WORKDIR /app
EXPOSE 3000
CMD ["index.js"]