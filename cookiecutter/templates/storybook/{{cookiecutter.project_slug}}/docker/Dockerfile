FROM node:20-alpine

WORKDIR /app

# Install dependencies first for caching
COPY package.json ./
RUN npm install

# Copy source code
COPY . .

# Expose port (can be overridden but good for doc)
EXPOSE 6006

# Start storybook
CMD ["npm", "run", "storybook"]
