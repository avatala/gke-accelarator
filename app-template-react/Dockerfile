FROM node:14
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY /app/package.json ./
COPY /app/package-lock.json ./
RUN npm install
COPY /app ./
# start app
CMD ["npm", "start"]
