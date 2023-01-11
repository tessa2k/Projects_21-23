all: p o s

p:
	gcc -g -Wall -o downscale_pthread downscale_pthread.c -lpthread
o:
	gcc -Wall -g  -fopenmp -o downscale_openmp downscale_openmp.c
s:
	gcc -g -Wall -o serial_blur serial_blur.c
clean:
	rm downscale_openmp
	rm downscale_pthread
	rm serial_blur
