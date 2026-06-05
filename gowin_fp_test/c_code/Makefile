CC = gcc
CFLAGS = -Wall -O2

TARGET = fp
SRCS = fp.c

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET)
