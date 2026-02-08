# Variáveis
CXX := g++
CXXFLAGS := -std=c++20 -O3 -Wall -Wextra -pthread
LDFLAGS := -lrt -lasio
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
