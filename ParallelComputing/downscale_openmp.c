/* File:     downscale_openmp.c
 * Purpose:  Read the given im.pgm grayscale image, repeat the blurring process
 *           20 times, then output the blurry image to im-blur.pgm parallelized
 *           by Openmp.
 *
 * Input:    An image name, in this case, it is fixed as "im.pgm"
 *
 * Output:   An image named "im-blur.pgm" after 20 times blurring processing in
 *           the parallel way
 *
 * Compile:  make o/ gcc -Wall -g  -fopenmp -o downscale_openmp
 * downscale_openmp.c Run:      ./downscale_openmp <number of threads>
 *
 * Algorithm:
 *    The algorithm adopts a blurring strategy that ignores the edges but keeps
 *    the original image size unchanged.
 *
 *    1. Function receives a PGMData structure which contains PGM file
 *       information and t as times of image blurring processing
 *    2. The "buffer" copies the data in the original PGMData structure,
 *       "out" is the data after blurring. Each pixel will find its surrounding
 *       pixel values in the buffer and average them to get the blurred value.
 *       The separation of the original values from the output data allows the
 *       algorithm to cooperate as well in multiple threads as it does in single
 *       threads.
 *    3. For iterations, the input of the next iteration is the output of the
 *       previous iteration. Just like: buffer = out
 *            More parallel detail in blur_image section
 */

#include <ctype.h>
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>

/*
 * The macro HI for handle max_gray > 255, but not necessary in this case
 * The macro LO is the low 8 bit of num
 */
#define HI(num) (((num)&0x0000FF00) << 8)
#define LO(num) ((num)&0x000000FF)

/* The argument now should be a double (not a pointer to a double)
 * The macro Timer is aims at calculating the time of image blurring processing
 */
#define GET_TIME(now)                                                          \
  {                                                                            \
    struct timeval t;                                                          \
    gettimeofday(&t, NULL);                                                    \
    now = t.tv_sec + t.tv_usec / 1000000.0;                                    \
  }

/*
 * Handle PGM file information as a structure
 */
typedef struct _PGMData {
  int row;
  int col;
  int max_gray;
  int *matrix;
} PGMData;

/*
 * Get arguments such as number of threads
 */
void Get_args(int argc, char *argv[]);
/*
 * Explaining usage if any error occurs
 */
void Usage(char *input);

/*
 * Read and write PGM file
 */
PGMData *readPGM(const char *file_name, PGMData *data);
void writePGM(const char *filename, const PGMData *data);

/*
 * Help readPGM Function work correctly
 */
void SkipComments(FILE *fp);

/*
 * Alloc and deallocate memory
 */
int *allocate_dynamic_matrix(int row, int col);
void deallocate_dynamic_matrix(int *matrix);

/*
 * blur image for t times
 */
int *blur_image(PGMData *data, int t);

/*
 * number of threads in use
 */
int num_threads;

int main(int argc, char *argv[]) {

  /*get arguments*/
  Get_args(argc, argv);

  PGMData *pgmData;

  /*Read PGM file*/
  pgmData = (PGMData *)malloc(1 * sizeof(PGMData));
  pgmData = readPGM("im.pgm", pgmData);
  if (pgmData->matrix == NULL) {
    perror("memory allocation failure");
    exit(EXIT_FAILURE);
  } // error checking

  double start, end;
  GET_TIME(start);
  // times for blur processing
  int t = 20;
  pgmData->matrix = blur_image(pgmData, t);
  GET_TIME(end);

  /*Write blurred image to specific file*/
  writePGM("im-blur.pgm", pgmData);

  /*free memory*/
  deallocate_dynamic_matrix(pgmData->matrix);
  free(pgmData);

  /*Report execute time*/
  printf("Elapsed time for %d times blur = %e seconds \n", t, end - start);
  return 0;
}
/*  main  */

/*--------------------------------------------
 * Function:    Get_args
 * Purpose:     Get the command line args
 * In args:     argc, argv
 * Globals out: num_threads
 */
void Get_args(int argc, char *argv[]) {
  if (argc != 2)
    Usage(argv[0]);
  num_threads = strtol(argv[1], NULL, 10);
  if (num_threads <= 0)
    Usage(argv[0]);
}

/*--------------------------------------------
 * Function:  Usage
 * Purpose:   Print a message explaining how to run the program
 * In arg:    prog_name
 */
void Usage(char *prog_name) {
  fprintf(stderr, "usage: %s <number of threads>\n", prog_name);
  fprintf(stderr,
          "   num_threads is the number of threads and should be >= 1\n");
  exit(0);
} /* Usage */

/*--------------------------------------------
 * Function:     readPGM
 * Purpose:      read PGM file information to PGMData structure
 * Input args:   file_name: name of PGM file need to read
 * Output args: data: PGMData structure need to write
 */
/*for reading:*/
PGMData *readPGM(const char *file_name, PGMData *data) {
  FILE *pgmFile;
  char version[3];
  int i;
  pgmFile = fopen(file_name, "r");
  if (pgmFile == NULL) {
    perror("cannot open file to read");
    exit(EXIT_FAILURE);
  } // error checking
  fgets(version, sizeof(version), pgmFile);
  if (strcmp(version, "P2")) {
    fprintf(stderr, "Wrong file type!\n");
    exit(EXIT_FAILURE);
  } // error checking

  /*Read PGM information and reporting*/
  printf("version: %s \n", version);
  SkipComments(pgmFile);
  fscanf(pgmFile, "%d", &data->col);
  printf("col: %d\n", data->col);
  SkipComments(pgmFile);
  fscanf(pgmFile, "%d", &data->row);
  printf("row: %d\n", data->row);
  SkipComments(pgmFile);
  fscanf(pgmFile, "%d", &data->max_gray);
  printf("max_gray: %d\n", data->max_gray);

  data->matrix = allocate_dynamic_matrix(data->row, data->col);

  int *buffer;
  buffer = allocate_dynamic_matrix(data->row, data->col);

  /*Read PGM image data*/
  if (data->max_gray > 255) {
    // do not care in this case
  } else {
    int size = data->col * data->row;
    for (i = 0; i < size; ++i) {
      fscanf(pgmFile, "%d", &buffer[i]);
    }
  }

  data->matrix = buffer;

  fclose(pgmFile);
  return data;
}

/*--------------------------------------------
 * Function:     writePGM
 * Purpose:      write blurred image to a specific PGM file
 * Input args:   filename: destination file name
 *               data: PGMData contains PGM image information
 */
/* for writing*/
void writePGM(const char *filename, const PGMData *data) {
  FILE *pgmFile;
  int i;
  int lo;
  int rows = data->row, cols = data->col;

  pgmFile = fopen(filename, "w");
  if (pgmFile == NULL) {
    perror("cannot open file to write");
    exit(EXIT_FAILURE);
  }

  fprintf(pgmFile, "P2\n");
  fprintf(pgmFile, "%d %d\n", cols, rows);
  fprintf(pgmFile, "%d\n", data->max_gray);

  if (data->max_gray > 255) {
    // do not care in this case
  } else {
    int size = cols * rows;
    for (i = 0; i < size; ++i) {
      lo = LO(data->matrix[i]);
      fprintf(pgmFile, "%d ", lo);
      if ((i + 1) % rows == 0) {
        fprintf(pgmFile, "\n");
      }
    }
  }

  fclose(pgmFile);
}

/*--------------------------------------------
 * Function:     SkipComments
 * Purpose:      skip comments in PGM file, ensure that readPGM function work
 *               correctly
 * Input args:   fp: file pointer
 */
void SkipComments(FILE *fp) {
  int ch;
  char line[100];
  while ((ch = fgetc(fp)) != EOF && isspace(ch)) {
    ;
  }

  if (ch == '#') {
    fgets(line, sizeof(line), fp);
    SkipComments(fp);
  } else {
    fseek(fp, -1, SEEK_CUR);
  }
}

/*--------------------------------------------
 * Function:     allocate_dynamic_matrix
 * Purpose:      allocate memory for row * col size buffer
 * Input args:   row
 *               col
 * Return val:   pointer of A row * col size buffer
 */
int *allocate_dynamic_matrix(int row, int col) {
  int *ret_val;
  int size = row * col;

  ret_val = (int *)malloc(sizeof(int) * size);
  if (ret_val == NULL) {
    perror("memory allocation failure");
    exit(EXIT_FAILURE);
  }
  return ret_val;
}

/*--------------------------------------------
 * Function:     deallocate_dynamic_matrix
 * Purpose:      allocate memory for row * col size buffer
 * Input args:   matrix: pointer of A row * col size buffer
 */
void deallocate_dynamic_matrix(int *matrix) { free(matrix); }

/*--------------------------------------------
 * Function:     blur_image
 * Purpose:      blur image for t times in the parallel way
 * Input args:   data: PGMData contains PGM image information
 *               t: times for image blurring
 * Return val:   pointer of A matrix after t times image blurring processing
 * Algorithm:
 *    The algorithm adopts a blurring strategy that ignores the edges but keeps
 *    the original image size unchanged.
 *
 *    1. Function receives a PGMData structure which contains PGM file
 *       information and t as times of image blurring processing
 *    2. The "buffer" copies the data in the original PGMData structure,
 *       "out" is the data after blurring. Each pixel will find its surrounding
 *       pixel values in the buffer and average them to get the blurred value.
 *       The separation of the original values from the output data allows the
 *       algorithm to cooperate as well in multiple threads as it does in single
 *       threads.
 *    3. For iterations, the input of the next iteration is the output of the
 *       previous iteration. Just like: buffer = out
 *
 * Palatalization:
 *       This algorithm uses "omp parallel for" for parallel acceleration.
 *       The "omp parallel for" internally coordinates the workload of each
 *       process based on num_threads and the number of "for" executions in the
 *       serial program. Each process has private and shared variables and works
 *       like a serial program.
 *
 * Tricks section:
 *
 *          out[k] = data->matrix[i]; // committed for 0 pixel border section
 *
 *      This line is introduced so that the final output image has the original
 *      edge pixel values. Thus, after blurring, there is a huge violation with
 *      other blurred parts.
 *
 *      leaving it alone is a better decision to ignore edges. After
 *      initializing the size of "out", positions that are not assigned a value
 *      will be initialized to 0 -- A black pixels. Having a one pixel black
 *      border is more coherent than an unblurred border.
 *
 */
int *blur_image(PGMData *data, int t) {
  int cols = data->col, rows = data->row;
  int size = cols * rows;
  int *buffer;
  buffer = allocate_dynamic_matrix(cols, rows);
  int *out;
  out = allocate_dynamic_matrix(cols, rows);
  int times, i, x, y, k = 0;

  int col_1, col_2, col_3;
  int index_1, index_2, index_3;

  for (i = 0; i < size; i++) {
    buffer[k] = data->matrix[i];
    /*out[k] = data->matrix[i];*/ // committed for 0 pixel border section
    k++;
  }

  for (times = 0; times < t; times++) {
#pragma omp parallel for num_threads(num_threads) default(none)                \
    firstprivate(rows, cols) private(i, x, y, col_1, col_2, col_3, index_1,    \
                                     index_2, index_3) shared(out, buffer)
    for (x = 1; x < rows - 1; x++) {
      col_1 = (x - 1) * cols;
      col_2 = col_1 + cols;
      col_3 = col_2 + cols;
      for (y = 1; y < cols - 1; y++) {
        index_1 = col_1 + y;
        index_2 = col_2 + y;
        index_3 = col_3 + y;
        out[index_2] =
            (buffer[index_1 - 1] + buffer[index_1] + buffer[index_1 + 1] +
             buffer[index_2 - 1] + buffer[index_2 + 1] + buffer[index_3 - 1] +
             buffer[index_3] + buffer[index_3 + 1]) /
            8;
      }
    }
    buffer = out;
  }
  return out;
}
