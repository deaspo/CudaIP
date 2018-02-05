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
////nucleia.pgm ascii
//#define  n1 511  //height of the image -1-rows
//#define  n2 511  //width of the image -1-columns
//
//
///* Definitions*/
//#define  h      0.01
//#define  tau    0.00025
//#define  sigma  0.000025
//#define  ni  100        /* a number of the iterations */
//#define  tol    1.0e-10   /* toleration for accuracy gauss-seidel */
//#define kk     10        /* a number of the diffusion steps */
//#define  iz     1         /* density of writing */
//#define  p     1   
//#define  omega_c     1.3      /*  SOR for the convolution   */
//#define  omega_s     1.4      /* SOR for the system */
//#define coeff 1   /* a konstant K of the function g(s) */
//
//
//double *partial_error;
//
//
//typedef  double pole1[n1 + 16 * p + 1][n2 + 16 * p + 1];
//typedef  int    pole2[n1 + 16 * p + 1][n2 + 16 * p + 1];
//
////pole--array
//static pole1 u, u0, uq, ap, ae,an,aw,as;
//static pole2 v;
//
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
//			u[i][j] = ll / 255.;
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
//			u[i][j] = ll / 255.;
//		}
//	}
//
//	fclose(in_file);
//}
//
//
//void write_new_image_data()
//{
//	int i, j;
//	// Add the path to the name
//	strcat(file_path, name); // images/option/name_option.pgm
//
//	in_file = fopen(file_path, "w");
//	fprintf(in_file, "P2\n");
//	fprintf(in_file, "#Created by Visual Studio - Polycarp\n");
//	fprintf(in_file, "%3d %3d\n", n2 + 1, n2 + 1);
//	fprintf(in_file, "255\n");
//	for (i = p; i <= n1 + p; i++)
//	{
//		for (j = p; j <= n2 + p; j++)
//		{
//			v[i][j] = (int)(u[i][j] * 255.0 + 0.5);
//			fprintf(in_file, "%4d ", v[i][j]);
//		}
//		fprintf(in_file, "\n");
//	}
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
///*Specific to Heat Functions*/
//
////==============================================================================
//
//__global__ void picaod_kernel(unsigned int *dev_v, long size, unsigned int *temp)
//{
//	int x = threadIdx.x + blockIdx.x * blockDim.x;
//	int y = threadIdx.y + blockIdx.y * blockDim.y;
//
//	int offset = x + y * blockDim.x * gridDim.x;
//
//	atomicAdd(&(temp[0]), dev_v[offset]);
//
//}
//
//
//void reflexia(pole1 u)
//{
//	int i, j, k, n11, n22;
//	n11 = n1 + p; n22 = n2 + p;
//	for (i = p; i <= n1 + p; i++)
//		for (k = 0; k<p; k++)
//		{
//			u[i][p - k - 1] = u[i][p + k];
//			u[i][n22 + p + k] = u[i][n22 + p - k - 1];
//		}
//
//	for (j = 0; j <= n2 + 2*p; j++)
//		for (k = 0; k<p; k++)
//		{
//			u[p - k - 1][j] = u[p + k][j];
//			u[n11 + p + k][j] = u[n11 + p - k - 1][j];
//		}
//}
//
////==============================================================================
//
////Kernel functions
//
////======================================
//double gradient(double ux, double uy)
//{
//	double gn = pow(ux, 2) + pow(uy, 2);
//	double grad = 1 / (1.0 + coeff*gn);
//	return grad;
//}
//
////==============================================================================
//__global__ void gauss_seidel_kernel(double *dev_u0, double *dev_u, double *dev_ap, double *dev_ae, double *dev_an, double *dev_aw, double *dev_as)
//{
//	int x = threadIdx.x + (blockIdx.x) * blockDim.x;
//	int y = threadIdx.y + (blockIdx.y) * blockDim.y;
//
//	int offset = x + y * blockDim.x * gridDim.x;
//
//	//Set the dimension - square image expected
//	int DIM = n1 + 16*p + 1;
//
//	int west = offset - p;
//	int east = offset + p;
//
//	if (x == 0) west++;
//	if (x == DIM - p) east--;
//
//	int north = offset - DIM;
//	int south = offset + DIM;
//	if (y == 0) north += DIM;
//	if (y == DIM - p) south -= DIM;
//
//	double sor;
//
//	//Evaluate
//	sor = (dev_aw[offset] * dev_u[west] + dev_ae[offset] * dev_u[east] + dev_as[offset] * dev_u[south] + dev_an[offset] * dev_u[north] + dev_u0[offset] * (h*h / tau)) / dev_ap[offset];
//	dev_u[offset] = dev_u[offset] + omega_s*(sor - dev_u[offset]);
//	if (dev_u[offset] < 0.0) dev_u[offset] = 0.0;
//	if (dev_u[offset] > 1.0) dev_u[offset] = 1.0;
//}
//
////==============================================================================
//void gauss() 
//{
//	double y;
//	int i, j;
//
//	for (i = p; i <= n1 + p; i++)
//	{
//		for (j = p; j <= n2 + p; j++)
//		{
//			y = (aw[i][j] * u[i][j - 1] + ae[i][j] * u[i][j + 1] + as[i][j] * u[i + 1][j] + an[i][j] * u[i - 1][j] + u0[i][j] * (h*h / tau)) / ap[i][j];
//			u[i][j] = u[i][j] + omega_s*(y - u[i][j]);
//		}
//	}
//}
////==============================================================================
//
//void Convolution()
//{
//	int i, j, z;
//	double y, error;
//
//	z = 0;
//	do
//	{
//		z = z + 1;
//		for (i = p; i <= n1 + 1; i++)
//		{
//			for (j = p; j <= n2 + 1; j++)
//			{
//				y = (uq[i + 1][j] + uq[i - 1][j] + uq[i][j + 1] + uq[i][j - 1] + (h*h / sigma)*u0[i][j]) / ((h*h / sigma) + 4.0);
//				uq[i][j] = uq[i][j] + omega_c*(y - uq[i][j]);
//			}
//		}
//
//		error = 0.0;
//		for (i = p; i <= n1 + 1; i++)
//		{
//			for (j = p; j <= n2 + 1; j++)
//			{
//				error += pow(uq[i][j] * ((h*h / sigma) + 4.0) - (uq[i + 1][j] + uq[i - 1][j] + uq[i][j + 1] + uq[i][j - 1] + u0[i][j] * (h*h / sigma)), 2);
//			}
//		}
//	} while ((error>tol) && (z<ni));
//	printf("A number of convolution iterations is %d\n", z);
//	printf("Error is %e\n", error);
//}
////==============================================================================
//void ap_s() 
//{
//	int i, j;
//	double uqx, uqy;
//
//	for (i = p; i <= n1 + 1; i++)
//	{
//		for (j = p; j <= n2 + 1; j++)
//		{
//			uqx = (uq[i][j] - uq[i][j - 1]) / h;
//			uqy = (uq[i - 1][j + 1] - uq[i - 1][j - 1] + uq[i][j + 1] - uq[i][j - 1]) / (4 * h);
//			aw[i][j] = gradient(uqx, uqy);
//
//			uqx = (uq[i][j + 1] - uq[i][j]) / h;
//			uqy = (uq[i][j + 1] - uq[i][j - 1] + uq[i + 1][j + 1] - uq[i + 1][j - 1]) / (4 * h);
//			ae[i][j] = gradient(uqx, uqy);
//
//			uqx = (uq[i + 1][j] - uq[i - 1][j] + uq[i + 1][j - 1] - uq[i - 1][j - 1]) / (4 * h);
//			uqy = (uq[i][j] - uq[i + 1][j]) / h;
//			as[i][j] = gradient(uqx, uqy);
//
//			uqx = (uq[i + 1][j + 1] - uq[i - 1][j + 1] + uq[i + 1][j] - uq[i - 1][j]) / (4 * h);
//			uqy = (uq[i - 1][j] - uq[i][j]) / h;
//			an[i][j] = gradient(uqx, uqy);
//
//			ap[i][j] = (h*h / tau) + aw[i][j] + ae[i][j] + as[i][j] + an[i][j];
//		}
//	}
//}
//
////==============================================================================
//// Main Function
//
//int main()
//{
//	int i,j,l,s;
//	double error_s;
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
//	/*printf("enter the mode for the file that you want to read e.g r, rb: ");
//	scanf("%s", rmode);*/
//	/* Manual enter file name and mode*/
//	rmode = "r";
//	strcpy(name, (*image).name);//construct a name of the file
//	sprintf(name_ending, ".pgm");
//	strcat(name, name_ending);
//	strcat(file_path, name);
//	getpgmfile(name, image, rmode);
//	printimageinfo();
//
//	//Get image size
//	int img_size = (n1 + 16 * p + 1)*(n2 + 16 * p + 1);
//
//	/*capture time events gou*/
//	cudaEvent_t start_gpu, stop_gpu;
//
//
//	/*GPU variables*/
//	double *d_u0, *d_u, *d_uq, *d_error, *d_ae, *d_an, *d_aw, *d_as, *d_ap;
//	unsigned int *d_v, *d_tmp;
//
//	/* Important!
//	* Dim % Sqrt(threads) == 0
//	* Target atleast 256 threads
//	*/
//	dim3 blocks((n1 + 16 * p + 1) / 16, (n2 + 16 * p + 1) / 16);
//	dim3 threads(16, 16);
//
//
//	// allocate memory on the GPU for the variables
//	HANDLE_ERROR(cudaMalloc((void **)&d_u0, img_size * sizeof(double)));
//	HANDLE_ERROR(cudaMalloc((void **)&d_u, img_size * sizeof(double)));
//	HANDLE_ERROR(cudaMalloc((void **)&d_uq, img_size * sizeof(double)));
//	HANDLE_ERROR(cudaMalloc((void **)&d_error, img_size * sizeof(double)));
//
//	// Gradients
//	HANDLE_ERROR(cudaMalloc((void **)&d_ae, img_size * sizeof(double)));
//	HANDLE_ERROR(cudaMalloc((void **)&d_an, img_size * sizeof(double)));
//	HANDLE_ERROR(cudaMalloc((void **)&d_aw, img_size * sizeof(double)));
//	HANDLE_ERROR(cudaMalloc((void **)&d_as, img_size * sizeof(double)));
//	// ap
//	HANDLE_ERROR(cudaMalloc((void **)&d_ap, img_size * sizeof(double)));
//	//
//	HANDLE_ERROR(cudaMalloc((void **)&d_tmp, 1 * sizeof(long)));
//	HANDLE_ERROR(cudaMemset(d_tmp, 0, 1 * sizeof(int)));
//
//	HANDLE_ERROR(cudaMalloc((void **)&d_v, img_size * sizeof(int)));
//	HANDLE_ERROR(cudaMemcpy(d_v, v, img_size * sizeof(int), cudaMemcpyHostToDevice));
//
//	// AOD - Function
//	unsigned int tmp[1];
//
//	picaod_kernel << <blocks, threads >> > (d_v, img_size, d_tmp);
//	// Copy tmp from Device to Host
//	HANDLE_ERROR(cudaMemcpy(tmp, d_tmp, 1 * sizeof(int), cudaMemcpyDeviceToHost));
//
//	printf("AOD of the picture before the heat is: %lf \n", tmp[0] / ((double)(n1 + 1)*(n2 + 1)));
//
//	/*Perform PM-Implicit*/
//	partial_error = (double *)malloc(sizeof(double)*img_size);
//
//	reflexia(u);
//	for (l = 1; l <= kk; l++)
//	{
//		HANDLE_ERROR(cudaEventCreate(&start_gpu));
//		HANDLE_ERROR(cudaEventCreate(&stop_gpu));
//		HANDLE_ERROR(cudaEventRecord(start_gpu, 0));
//
//		printf("%d-th step\n", l);
//		/*Begin of Coefficient function*/
//
//		//Copy from u to uq - Can use Memcopy instead
//		memcpy(uq, u, sizeof(u));
//
//		/*Begin of Convolution function*/
//		//Copy from uq to u0
//		memcpy(u0, uq, sizeof(uq));
//		// Reflection uq - CPU function
//		reflexia(uq);
//
//		Convolution();
//		/*Calculate the ap*/
//
//
//		ap_s();
//		// Copy ap,aw,ae,aw,an to device
//		// Copy ap to d_ap
//		HANDLE_ERROR(cudaMemcpy(d_ap, ap, img_size * sizeof(double), cudaMemcpyHostToDevice));
//		// ae,an,aw,as
//		HANDLE_ERROR(cudaMemcpy(d_ae, ae, img_size * sizeof(double), cudaMemcpyHostToDevice));
//		HANDLE_ERROR(cudaMemcpy(d_an, an, img_size * sizeof(double), cudaMemcpyHostToDevice));
//		HANDLE_ERROR(cudaMemcpy(d_aw, aw, img_size * sizeof(double), cudaMemcpyHostToDevice));
//		HANDLE_ERROR(cudaMemcpy(d_as, as, img_size * sizeof(double), cudaMemcpyHostToDevice));
//
//		/*End of Coefficient function*/
//
//		/*Begin of System Equation*/
//		//Copy from u to u0
//		memcpy(u0, u, sizeof(u));
//		// Reflection
//		reflexia(u);
//		// Copy u,u0 to d_u,d_u0
//		HANDLE_ERROR(cudaMemcpy(d_u, u, img_size * sizeof(double), cudaMemcpyHostToDevice));
//		HANDLE_ERROR(cudaMemcpy(d_u0, u0, img_size * sizeof(double), cudaMemcpyHostToDevice));
//		
//		/*Begin do while */
//		s = 0;
//		do
//		{
//			s = s + 1;
//			//Evaluate using the Gauss Seidel method
//			// gauss();
//			// Reflection
//			//reflexia(u);
//			// Copy the reflected u to d_u
//			// HANDLE_ERROR(cudaMemcpy(d_u, u, img_size * sizeof(double), cudaMemcpyHostToDevice));
//
//			gauss_seidel_kernel << <blocks, threads >> > (d_u0, d_u, d_ap, d_ae, d_an, d_aw, d_as);
//			// Use cudaDeviceSynchronize(); until process is done
//			cudaDeviceSynchronize();
//			//Copy back to Host - u for error calculation
//			HANDLE_ERROR(cudaMemcpy(u, d_u, img_size * sizeof(double), cudaMemcpyDeviceToHost));
//
//			// Evaluate error
//
//			// Reflection
//			//reflexia(u);
//
//			//Reset to Zero before next iteration
//			error_s = 0.0;
//
//			for (i = p; i < n1 + 1; i++)
//			{
//				for (j = p; j < n2 + 1; j++)
//				{
//					error_s += pow(ap[i][j] * u[i][j] - ae[i][j] * u[i][j + 1] - as[i][j] * u[i + 1][j] - an[i][j] * u[i - 1][j] - aw[i][j] * u[i][j - 1] - u0[i][j] * (h*h / tau), 2);
//				}
//			}
//			// Copy the reflected u to d_u
//			HANDLE_ERROR(cudaMemcpy(d_u, u, img_size * sizeof(double), cudaMemcpyHostToDevice));
//
//		} while ((error_s > tol) && (s < ni));
//		printf("The number of  system iterations is %d\n", s);
//		printf("error is %e\n", error_s);
//		
//		/* End of System Equation function*/
//		// Use cudaDeviceSynchronize(); until process is done
//		cudaDeviceSynchronize();
//		//Copy back to Host - u
//		HANDLE_ERROR(cudaMemcpy(u, d_u, img_size * sizeof(double), cudaMemcpyDeviceToHost));
//
//		// Reflection
//		reflexia(u);
//
//		// get stop time, and display the timing results
//		HANDLE_ERROR(cudaEventRecord(stop_gpu, 0));
//		HANDLE_ERROR(cudaEventSynchronize(stop_gpu));
//		float   elapsedTime;
//		HANDLE_ERROR(cudaEventElapsedTime(&elapsedTime, start_gpu, stop_gpu));
//		printf("Time to generate the %d-th step:  %3.1f ms\n", l, elapsedTime);
//
//		// Destroy time
//		HANDLE_ERROR(cudaEventDestroy(start_gpu));
//		HANDLE_ERROR(cudaEventDestroy(stop_gpu));
//
//
//		// Write the outputs
//		if ((l%iz) == 0)
//		{
//			strcpy(name, (*image).name);
//			sprintf(name_ending, "_%d_pm.pgm", l);
//			strcat(name, name_ending);
//			strcpy(file_path, "images/modified/pm/semi/");
//			write_new_image_data();
//		}
//
//	}
//
//	// AOD - function
//	HANDLE_ERROR(cudaMemcpy(d_v, v, img_size * sizeof(int), cudaMemcpyHostToDevice));
//
//	// Reset values back to 0
//	HANDLE_ERROR(cudaMemset(d_tmp, 0, 1 * sizeof(int)));
//
//	picaod_kernel << <blocks, threads >> > (d_v, img_size, d_tmp);
//	// Copy tmp from Device to Host
//	HANDLE_ERROR(cudaMemcpy(tmp, d_tmp, 1 * sizeof(int), cudaMemcpyDeviceToHost));
//
//	printf("AOD of the picture before the heat is: %lf \n", tmp[0] / ((double)(n1 + 1)*(n2 + 1)));
//
//
//	fclose(in_file);
//	// free more memory
//	free((void*)name);
//
//	/*gpu free memory*/
//	HANDLE_ERROR(cudaFree(d_u0));
//	HANDLE_ERROR(cudaFree(d_u));
//	HANDLE_ERROR(cudaFree(d_uq));
//	HANDLE_ERROR(cudaFree(d_ap));
//
//	HANDLE_ERROR(cudaFree(d_tmp));
//	HANDLE_ERROR(cudaFree(d_v));
//
//	return 0;
//
//}