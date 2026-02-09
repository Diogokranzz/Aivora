# Estágio 1: Build
FROM arm64v8/ubuntu:24.04 AS builder
RUN apt-get update && apt-get install -y g++ cmake libasio-dev
COPY . /app
WORKDIR /app
RUN g++ -O3 src/aivora_core/main.cpp -lpthread -o aivora_core

# Estágio 2: Runtime
FROM arm64v8/ubuntu:24.04
COPY --from=builder /app/aivora_core /usr/local/bin/aivora_core
EXPOSE 8080
CMD ["aivora_core"]
