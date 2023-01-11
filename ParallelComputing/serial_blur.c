/* File:     serial_blur.c
 * Purpose:  Read the given im.pgm grayscale image, repeat
 *           the blurring process 20 times, then output the
 *           blurry image to im-blur.pgm.
 * Input:    An image name, in this case, it is fixed as "im.pgm"
 *
 * Output:   An image named "im-blur.pgm" after 20 times blurring processing
 *
 * Compile:  make s / gcc -g -Wall -o serial_blur serial_blur.c
 * Run:      ./serial_blur
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
 * Read and write PGM file
 */
PGMData *readPGM(const char *file_name, PGMData *data);
void writePGM(const char *filename, const PGMData *data, const int *out);

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

int main(int argc, char *argv[]) {
  PGMData *pgmData;

  /*Read PGM file*/
  pgmData = (PGMData *)malloc(1 * sizeof(PGMData));
  pgmData = readPGM("im.pgm", pgmData);
  if (pgmData->matrix == NULL) {
    perror("memory allocation failure");
    exit(EXIT_FAILURE);
  } // error checking

  int *out = NULL;
  double start, end;
  GET_TIME(start);
  // times for blur processing
  int t = 20;
  out = blur_image(pgmData, t);
  GET_TIME(end);

  /*Write blurred image to specific file*/
  writePGM("im-blur.pgm", pgmData, out);

  /*free memory*/
  deallocate_dynamic_matrix(pgmData->matrix);
  free(pgmData);
  free(out);

  /*Report execute time*/
  printf("Elapsed time for %d times blur = %e seconds \n", t, end - start);
  return 0;
}
/*  main  */

/*---------------------------------------------
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

/*---------------------------------------------
 * Function:     write
 * Purpose:      write blurred image to a specific PGM file
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

/*---------------------------------------------
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

/*---------------------------------------------
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

/*---------------------------------------------
 * Function:     deallocate_dynamic_matrix
 * Purpose:      allocate memory for row * col size buffer
 * Input args:   matrix: pointer of A row * col size buffer
 */
void deallocate_dynamic_matrix(int *matrix) { free(matrix); }

/*---------------------------------------------
 * Function:     blur_image
 * Purpose:      blur image for t times
 * Input args:   data: PGMData contains PGM image information
 *               t: times for image blurring
 * Return val:   pointer of A matrix after t times image blurring processing
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
int *blur_image(PGMData *data, int t) {
  int cols = data->col, rows = data->row;
  int size = cols * rows;
  int *buffer;
  buffer = allocate_dynamic_matrix(data->col, data->row);
  int *out;
  out = allocate_dynamic_matrix(data->col, data->row);
  int times, i, x, y, k = 0;
  int col_1, col_2, col_3;
  int index_1, index_2, index_3;

  for (i = 0; i < size; i++) {
    buffer[k] = data->matrix[i];
    k++;
  }

  for (times = 0; times < t; times++) {
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
