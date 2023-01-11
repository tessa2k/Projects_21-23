/* File:     downscale_pthread.c
 * Purpose:  Read the given im.pgm grayscale image, repeat the blurring process
 *           20 times, then output the blurry image to im-blur.pgm.
 * Input:    An image name, in this case, it is fixed as "im.pgm"
 *
 * Output:   An image named "im-blur.pgm" after 20 times blurring processing
 *
 * Compile:  make p/ gcc -g -Wall -o downscale_pthread downscale_pthread.c
 * -lpthread Run:      ./downscale_pthread <num_threads>
 *
 * Algorithm:
 *    The algorithm adopts a blurring strategy that ignores the edges but keeps
 * the original image size unchanged.
 *
 *    1. Function receives a PGMData structure which contains PGM file
 *       information and t as times of image blurring processing
 *    2. The "buffer" copies the data in the original PGMData structure and
 *       call blur_no_border function to blur image, and the result is
 *       received by out.
 *    3. For iterations, the input of the next iteration is the output of the
 *       previous iteration: buffer = out
 */
#include <ctype.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>

#define LO(num) ((num)&0x000000FF)
#define GET_TIME(now)                                                          \
  {                                                                            \
    struct timeval t;                                                          \
    gettimeofday(&t, NULL);                                                    \
    now = t.tv_sec + t.tv_usec / 1000000.0;                                    \
  }

typedef struct _PGMData {
  int row;
  int col;
  int max_gray;
  int *matrix;
} PGMData;

long thread_count;
int *buffer;
int rows, cols;
int *out;

PGMData *readPGM(const char *file_name, PGMData *data);
void writePGM(const char *filename, const PGMData *data, const int *out);
void Get_args(int argc, char *argv[]);
void Usage(char *input);
void SkipComments(FILE *fp);
int *allocate_dynamic_matrix(int row, int col);
void deallocate_dynamic_matrix(int *matrix);
void *blur_image(void *rank);
void *blur_no_border(long long a, long long b, long long c);

/*  main  */
int main(int argc, char *argv[]) {
  long thread;
  pthread_t *thread_handles;
  double start, end;
  int i = 0;

  Get_args(argc, argv); // obtain the number of threads
  printf("Start to reading image ....\n");
  PGMData *pgmData;
  pgmData = (PGMData *)malloc(1 * sizeof(PGMData));
  pgmData = readPGM("im.pgm", pgmData);

  if (pgmData->matrix == NULL) {
    perror("memory allocation failure");
    exit(EXIT_FAILURE);
  } // error checking
  rows = pgmData->row;
  cols = pgmData->col;
  out = allocate_dynamic_matrix(cols, rows);
  buffer = allocate_dynamic_matrix(cols, rows);
  for (i = 0; i < rows * cols; i++) {
    buffer[i] = pgmData->matrix[i];
  } // load the pixel value into the buffer
  printf("Finish loading image\n");

  printf("Start blurring process....\n");
  thread_handles = (pthread_t *)malloc(thread_count * sizeof(pthread_t));
  GET_TIME(start);

  // times for blur processing
  for (i = 0; i < 20; i++) {
    for (thread = 0; thread < thread_count; thread++)
      pthread_create(&thread_handles[thread], NULL, blur_image, (void *)thread);

    for (thread = 0; thread < thread_count; thread++)
      pthread_join(thread_handles[thread], NULL);

    buffer = out; // change the pointer
  }
  GET_TIME(end);
  printf("Blurring finished\n");

  printf("Elapsed time for blurring = %e seconds \n", end - start);
  writePGM("im-blur.pgm", pgmData, buffer);

  deallocate_dynamic_matrix(pgmData->matrix);
  free(pgmData);
  free(out);

  return 0;
}

/*------------------------------------------------------------------
 * Function:    Get_args
 * Purpose:     Get the command line args
 * In args:     argc, argv
 * Globals out: num_threads
 */
void Get_args(int argc, char *argv[]) {
  if (argc != 2)
    Usage(argv[0]);
  thread_count = strtol(argv[1], NULL, 10);
  if (thread_count <= 0)
    Usage(argv[0]);
}

/*------------------------------------------------------------------
 * Function:  Usage
 * Purpose:   Print a message explaining how to run the program
 * In arg:    prog_name
 */
void Usage(char *prog_name) {
  fprintf(stderr, "usage: %s <number of threads>\n", prog_name);
  fprintf(stderr,
          "   thread_count is the number of threads and should be >= 1\n");
  exit(0);
} /* Usage */

/*----------------------------------------------------
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

/*-----------------------------------------------------
 * Function:     writePGM
 * Purpose:      write blurred image with black borders
 *               to a specific PGM file
 * Input args:   filename: destination file name
 *               data: PGMData contains PGM image information
 *               out: output of blur_image function
 */
/* for writing*/
void writePGM(const char *filename, const PGMData *data, const int *out) {
  FILE *pgmFile;
  int i, j, k = 0;
  int lo;

  pgmFile = fopen(filename, "w");
  if (pgmFile == NULL) {
    perror("cannot open file to write");
    exit(EXIT_FAILURE);
  } // error checking

  fprintf(pgmFile, "P2\n");
  fprintf(pgmFile, "%d %d\n", data->col, data->row);
  fprintf(pgmFile, "%d\n", data->max_gray);

  if (data->max_gray > 255) {
    // do not care in this case
  } else {
    for (i = 0; i < data->row; i++) {
      for (j = 0; j < data->col; j++) {
        lo = LO(out[k]);
        if (i == 0 || i == (data->row - 1) || j == 0 || j == (data->col - 1)) {
          lo = 0;
        }
        fprintf(pgmFile, "%d ", lo);
        k++;
      }
      fprintf(pgmFile, "\n");
    }
  }
  fclose(pgmFile);
}

/*----------------------------------------------------
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

/*-------------------------------------------------------
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

/*-------------------------------------------------------
 * Function:     deallocate_dynamic_matrix
 * Purpose:      allocate memory for row * col size buffer
 * Input args:   matrix: pointer of A row * col size buffer
 */
void deallocate_dynamic_matrix(int *matrix) { free(matrix); }

/*-------------------------------------------------------
 * Function:     blur_no_border
 * Purpose:      blur image with no borders
 * Input args:   a: the start row
 *               b: the ending row
 *               c: columns-2
 */
void *blur_no_border(long long a, long long b, long long c) {
  int col_1, col_2, col_3;
  int index_1, index_2, index_3, x, y;
  for (x = a; x <= b; x++) {

    col_1 = (x - 1) * cols;
    col_2 = col_1 + cols;
    col_3 = col_2 + cols;
    for (y = 1; y <= c; y++) {
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
  return NULL;
}

/*-----------------------------------------------------
 * Function:     blur_image
 * Purpose:      blur image for by using pthreads
 * Input args:   rank: a void pointer represents process
 * Return val:   void *
 * Algorithm:
 *    The algorithm adopts a blurring strategy that ignores the edges but keeps
 * the original image size unchanged.
 *
 *    1. Function receives a PGMData structure which contains PGM file
 *       information and t as times of image blurring processing
 *    2. The "buffer" copies the data in the original PGMData structure and
 *       call blur_no_border function to blur image, and the result is
 *       received by out.
 *    3. For iterations, the input of the next iteration is the output of the
 *       previous iteration: buffer = out
 */
void *blur_image(void *rank) {
  long my_rank = (long)rank;
  int c = rows - 2;
  long long my_n = c / thread_count;
  long long my_first_i = 1 + my_n * my_rank;
  long long my_last_i = my_first_i + my_n - 1;
  long long remainder_first;

  blur_no_border(my_first_i, my_last_i, c);

  if (c % thread_count != 0) {
    remainder_first = thread_count * my_n + 1;
    if (my_rank == 0) {
      blur_no_border(remainder_first, rows - 2, c);
    }
  }
  return NULL;
}
