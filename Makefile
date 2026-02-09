# Variáveis
CXX := g++
CXXFLAGS := -std=c++20 -O3 -Wall -Wextra -pthread -I./asio-asio-1-28-0/asio/include
LDFLAGS := -lrt -pthread
TARGET := aivora_core
SRC := src/aivora_core/main.cpp

# Alvo principal
all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) $(SRC) -o $(TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET)

# Build focado em Docker
docker-build:
	docker build -t aivora/core-cpp:latest .
