#include <stdlib.h>
#include <stdbool.h>
volatile int pixel_buffer_start; // global variable
short int Buffer1[240][512]; // 240 rows, 512 (320 + padding) columns
short int Buffer2[240][512];
int dx_box[8], dy_box[8], x_box[8], y_box[8];
int x_old[8], y_old[8];
volatile int * pixel_ctrl_ptr = (int *)0xFF203020;

void plot_pixel(int x, int y, short int line_color);
void wait_for_vsync();
void clear_screen();
void draw();
void draw_box(int x, int y, int colour);
void draw_line(int x0, int y0, int x1, int y1, int colour);
void swap(int *a, int *b);

int main(void)
{    // declare other variables(not shown)
    // initialize location and direction of rectangles(not shown)
	for(int i = 0; i < 8; i++){
		dx_box[i] = rand() % 2 * 2 - 1; //for random direction
		dy_box[i] = rand() % 2 * 2 - 1;
		x_box[i] = rand() % 318;
		y_box[i] = rand() % 238;
		x_old[i] = x_box[i];
		y_old[i] = y_box[i];
	}

    /* set front pixel buffer to Buffer 1 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer1; // first store the address in the  back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    /* set back pixel buffer to Buffer 2 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer2;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    while (1)
    {
        /* Erase any boxes and lines that were drawn in the last iteration */
        draw();

        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

// code for subroutines (not shown)

void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;
    one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);
    *one_pixel_address = line_color;
}

void wait_for_vsync()
{
	int status;
	*pixel_ctrl_ptr = 1; // start the synchronization process
	// - write 1 into front buffer address register
	status = *(pixel_ctrl_ptr + 3); // read the status register
	while ((status & 0x01) != 0) // polling loop waiting for S bit to go to 0
	{
		status = *(pixel_ctrl_ptr + 3);
	}
}

void clear_screen(){
	int y, x;
	for (x = 0; x < 320; x++)
		for (y = 0; y < 240; y++)
			plot_pixel(x, y, 0);
}

void draw(){
	
	for(int i = 0; i < 8; i++){
		//Erase old boxes and lines
		int j = (i + 1) % 8;
		int x0 = x_old[i];
		int y0 = y_old[i];
		int x1 = x_old[j];
		int y1 = y_old[j];
		int black = 0;
		draw_box(x0, y0, black);
		draw_line(x0, y0, x1, y1, black);
	}
	
	//Find new coordinates
	for(int i = 0; i < 8; i++){
		int new_x = x_box[i] + dx_box[i];
		int new_y = y_box[i] + dy_box[i];
		if(new_x == 1){
			new_x = 1;
			dx_box[i] = 1;
		}else if(new_x == 318){
			new_x = 318;
			dx_box[i] = -1;
		}
		if(new_y == 1){
			new_y = 1;
			dy_box[i] = 1;
		}else if(new_y == 238){
			new_y = 238;
			dy_box[i] = -1;
		}
		
		x_old[i] = x_box[i];
		y_old[i] = y_box[i];
		x_box[i] = new_x;
		y_box[i] = new_y;
	}
	
	for(int i = 0; i < 8; i++){
		//Draw new boxes and lines
		int j = (i + 1) % 8;
		int x0 = x_box[i];
		int y0 = y_box[i];
		int x1 = x_box[j];
		int y1 = y_box[j];
		int green = 0x07E0;
		int blue = 0x001F;
		draw_box(x0, y0, blue);
		draw_line(x0, y0, x1, y1, green);
	}
}

void draw_box(int x, int y, int colour){
	for(int i = -1; i < 2; i++){
		for(int j = -1; j < 2; j++){
			plot_pixel(x + i, y + j, colour);
		}
	}
}

void draw_line(int x0, int y0, int x1, int y1, int colour){
	bool is_steep = abs(y1 - y0) > abs(x1 - x0);
	if(is_steep){
		swap(&x0, &y0);
		swap(&x1, &y1);
	}
	if(x0 > x1){
		swap(&x0, &x1);
		swap(&y0, &y1);
	}
	
	int deltax = x1 - x0;
	int deltay = abs(y1 - y0);
	int error = -1*(deltax / 2);
	int y = y0;
	int y_step;
	if(y0 < y1)
		y_step = 1;
	else
		y_step = -1;
	
	for(int x = x0; x < x1; x++){
		if(is_steep)
			plot_pixel(y, x, colour);
		else
			plot_pixel(x, y, colour);
		error = error + deltay;
		if(error > 0){
			y = y + y_step;
			error = error - deltax;
		}
	}
}

void swap(int *a, int *b){
	int temp = *a;
	*a = *b;
	*b = temp;
}
