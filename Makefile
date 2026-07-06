ASM=as
LD=ld

SRC=src/server.s
OBJ=build/server.o
BIN=build/http-server

all: $(BIN)

$(BIN): $(OBJ)
	$(LD) $(OBJ) -o $(BIN)

$(OBJ): $(SRC)
	mkdir -p build
	$(ASM) --64 $(SRC) -o $(OBJ)

run: all
	./$(BIN)

clean:
	rm -rf build