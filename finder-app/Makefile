# Overriden by arg
CROSS_COMPILE=

TARGET=writer

CFLAGS_COMMON = -Wall -Werror -g  -std=c99 -v

CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld

CFLAGS = $(CFLAGS_COMMON)


$(TARGET): $(TARGET).c
	$(CC) -o $@ $(CFLAGS) $^


.PHONY: clean
clean:
	@echo cleaning
	@rm x $(TARGET) || echo "No clean!"

