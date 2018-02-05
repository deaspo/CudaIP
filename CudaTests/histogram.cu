//#pragma warning(disable:4996)
//
//
//#include <device_functions.h>
//#include "cuda_runtime.h"
//#include "device_launch_parameters.h"
//
//#include "common\book.h"
//
//
//#include <stdio.h>
//#include <stdlib.h>
//#include <math.h> // math functions
//#include <string.h> // functions such as strcmp
//#include <iostream>
//#include <time.h>
//
//
///* a header file with common structure to for pgm file*/
//#include "src/pgm.h" // common header for common pgm functions
//
//
//#define MAX_FILE_LENGTH 256
//
//#define p 0
//
////memb1.pgm -binary
//#define  n1 199   //height of the image -1-rows
//#define  n2 199  //width of the image -1-collumns
//
//
//typedef  int    array2d[n1 + 2 * p + 1][n2 + 2 * p + 1];//def new type array2d
//														//we define new type array2d
//static array2d v;//array for image
//
//PGMImage *image; // image struct with the propertes: width, height, maxvalue
//char *name, *name_ending, *name_beg, *file_path, *rmode;
//int height = 0, width = 0; //height, width for input image
//int option, prd, off;
//FILE *in_file, *tmp_file;
//
///*functions for reading and writing*/
///*
//* reads the image data into a 2d array
//* img_array contains the image data
//*/
//
//void load_ascii()
//{
//	int ll, i, j;
//	//reading the image data - ascii_format
//	for (i = p; i <= height + p; i++)
//	{
//		for (j = p; j <= width + p; j++)
//		{
//			fscanf(in_file, "%d", &ll);
//			v[i][j] = ll;
//		}
//	}
//	fclose(in_file);
//}
//
//void load_binary()
//{
//	int ll, i, j;
//	//reading the image data- binary format
//	for (i = p; i <= height + p; i++)
//	{
//		for (j = p; j <= width + p; j++)
//		{
//			ll = getc(in_file);
//			v[i][j] = ll;
//
//		}
//	}
//
//	fclose(in_file);
//}
//
//
//void write_new_image_data(array2d v)
//{
//	int i, j;
//	// Add the path to the name
//	strcat(file_path, name); // images/option/name_option.pgm
//
//	in_file = fopen(file_path, "wb");
//	fprintf(in_file, "P5\n");
//	fprintf(in_file, "#Created by Visual Studio - Polycarp\n");
//	fprintf(in_file, "%3d %3d\n", n2 + 1, n2 + 1);
//	fprintf(in_file, "255\n");
//	for (i = p; i <= n1 + p; i++)
//		for (j = p; j <= n2 + p; j++)
//		{
//			putc(v[i][j], in_file);
//		}
//	printf("\nSuccessfully saved the new image.\n");
//}
//
///**********************file i/o functions*******************************/
///***********************************************************************/
//
///*gets a pgm image file.*/
//void getpgmfile(char filename[], PGMImage *img, char mode[])
//{
//	char ch;
//	int type;
//
//	in_file = fopen(file_path, mode);
//	tmp_file = fopen(file_path, mode);
//	if (tmp_file == NULL)
//	{
//		fprintf(stderr, "error: unable to open file %s\n\n", file_path);
//		exit(8);
//	}
//
//	printf("\nreading image file: %s\n", filename);
//
//	/*determine pgm image type (only type three can be used)*/
//	ch = getc(tmp_file);
//	if (ch != 'P')
//	{
//		printf("error(1): not valid pgm/ppm file type\n");
//		exit(1);
//	}
//	ch = getc(tmp_file);
//	/*convert the one digit integer currently represented as a character to
//	an integer(48 == '0')*/
//	type = ch - 48;
//	if ((type != 2) && (type != 3) && (type != 5) && (type != 6))
//	{
//		printf("error(2): not valid pgm/ppm file type\n");
//		exit(1);
//	}
//
//	while (getc(tmp_file) != '\n');             /* skip to end of line*/
//
//	while (getc(tmp_file) == '#')              /* skip comment lines */
//	{
//		while (getc(tmp_file) != '\n');          /* skip to end of comment line */
//	}
//
//
//	/*there seems to be a difference between color and b/w.  this line is needed
//	by b/w but doesn't effect color reading...*/
//	fseek(tmp_file, -3, SEEK_CUR);             /* backup *three characters*/
//
//	fscanf(tmp_file, "%d", &((*image).width));
//	fscanf(tmp_file, "%d", &((*image).height));
//	fscanf(tmp_file, "%d", &((*image).maxVal));
//	fclose(tmp_file);
//
//
//
//	if (((*img).width  > MAX) || ((*img).height  > MAX))
//	{
//		printf("\n\n***error - image too big for current image structure***\n\n");
//		exit(1);
//	}
//
//
//	height = (*image).height - 1;
//	width = (*image).width - 1;
//	// write the image data
//	char pom1[5], line[80];
//
//	//reading the headers
//	fgets(pom1, 10, in_file);
//	do {
//		fgets(line, 80, in_file);
//	} while (line[0] == '#');
//	fgets(line, 10, in_file);
//
//	// load appropriate reading mode
//	if (strcmp(mode, "r") == 0)
//	{
//		//read_image_ascii();
//		load_ascii();
//	}
//	else if (strcmp(mode, "rb") == 0)
//	{
//		load_binary();
//	}
//	printf("\ndone reading file.\n");
//}
//
//void printimageinfo(void)
//{
//	printf("\nimage properties:\n");
//	printf("\n file name: %s", (*image).name);
//	printf("\n width  = %d", (*image).width);
//	printf("\n height = %d", (*image).height);
//	printf("\n maxval = %d", (*image).maxVal);
//	printf("\n\n");
//}
//
//
///*Specific to Histogram Functions*/
//__global__ void histo_kernel(unsigned int *image, long size, unsigned int *histo)
//{
//	int i = threadIdx.x + blockIdx.x * blockDim.x;
//	int stride = blockDim.x * gridDim.x;
//
//	while (i < size) {
//		atomicAdd( &(histo[image[i]]), 1);
//		i += stride;
//	}
//
//	
//}
//
//
//
//
//int main() 
//{
//	int i,j;
//	/*capture time events gou*/
//	//gpu
//	cudaEvent_t start_gpu, stop_gpu;
//	HANDLE_ERROR(cudaEventCreate(&start_gpu));
//	HANDLE_ERROR(cudaEventCreate(&stop_gpu));
//	HANDLE_ERROR(cudaEventRecord(start_gpu, 0));
//
//	/*end capture*/
//	/* memory allocation*/
//	name = (char*)malloc(sizeof(PGMImage));
//	name_ending = (char*)malloc(sizeof(PGMImage));
//	file_path = (char*)malloc(sizeof(PGMImage));
//	rmode = (char*)malloc(sizeof(PGMImage));
//
//
//	/*
//	* read in image file. - note: sets our global values, too.
//	* ----------------------------------------------------------------- */
//
//	image = (PGMImage*)malloc(sizeof(PGMImage));
//
//	strcpy(file_path, "images/");
//
//	//prompt for a name without extension
//	printf("enter pgm file name without extension:\n");
//	scanf("%s", &(*image).name);
//	/*
//	* get the mode of the file from the user
//	*/
//	printf("enter the mode for the file that you want to read e.g r, rb: ");
//	scanf("%s", rmode);
//	strcpy(name, (*image).name);//construct a name of the file
//	sprintf(name_ending, ".pgm");
//	strcat(name, name_ending);
//	strcat(file_path, name);
//	getpgmfile(name, image, rmode);
//	printimageinfo();
//
//	//Get image size
//	int img_size = (n1+2*p + 1)*(n2+2*p + 1);
//
//
//	/*GPU variables*/
//	unsigned int *dev_image;
//	unsigned int *dev_histogram;
//
//	double *d_hist;
//	HANDLE_ERROR(cudaMalloc((void**)&d_hist, 256 * sizeof(double)));
//
//
//
//	// allocate memory on the GPU for the file's data
//	HANDLE_ERROR(cudaMalloc((void **)&dev_image, img_size * sizeof(int)));
//	HANDLE_ERROR(cudaMemcpy(dev_image, v, img_size * sizeof(int), cudaMemcpyHostToDevice));
//
//
//	HANDLE_ERROR(cudaMalloc((void**)&dev_histogram,256 * sizeof(long)));
//	HANDLE_ERROR(cudaMemset(dev_histogram, 0,256 * sizeof(int)));
//
//
//
//	// GEt the Device property and Processor count
//	cudaDeviceProp  prop;
//	HANDLE_ERROR(cudaGetDeviceProperties(&prop, 0));
//	int blocks = prop.multiProcessorCount;
//
//
//	histo_kernel << <blocks * 2, 256 >> > (dev_image, img_size, dev_histogram);
//	unsigned int    histogram[256];
//
//	HANDLE_ERROR(cudaMemcpy(histogram, dev_histogram, 256 * sizeof(int), cudaMemcpyDeviceToHost));
//
//
//
//	// get stop time, and display the timing results
//	HANDLE_ERROR(cudaEventRecord(stop_gpu, 0));
//	HANDLE_ERROR(cudaEventSynchronize(stop_gpu));
//	float   elapsedTime;
//	HANDLE_ERROR(cudaEventElapsedTime(&elapsedTime, start_gpu, stop_gpu));
//	printf("Time to generate:  %3.1f ms\n", elapsedTime);
//
//	long histoCount = 0;
//	for (int i = 0; i<256; i++) {
//		histoCount += histogram[i];
//	}
//
//	printf("h[0]:%d \n", histogram[0]);
//	printf("Histogram Sum:  %ld\n", histoCount);
//
//
//	
//
//	// Normalization
//	double hist_d[256];
//	for (int i = 0; i<256; i++) {
//		hist_d[i] = histogram[i]/(double)img_size;
//	}
//	printf("h[0]/n*m:%lf \n\n", hist_d[0]);
//	
//
//	fclose(in_file);
//	// free more memory
//	free((void*)name);
//	// Destroy time
//	HANDLE_ERROR(cudaEventDestroy(start_gpu));
//	HANDLE_ERROR(cudaEventDestroy(stop_gpu));
//	/*gpu free memory*/
//	cudaFree(d_hist);
//	cudaFree(dev_image);
//	cudaFree(dev_histogram);
//
//	return 0;
//
//}