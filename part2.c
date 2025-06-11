#include <stdbool.h>
#include<stdlib.h>

int pixel_buffer_start; // global variable
void draw_line(int x0, int y0, int x1, int y1, int colour);
void swap(int *a, int *b);
void clear_screen();
void plot_pixel(int x, int y, short int line_color);

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;
	
	int y = 0;
	bool up = true;
	while(1){ //endless loop
		//erase previous line by drawing a black line
		if(up){
			if(y == 0)
				draw_line(0, 1, 320, 1, 0);
			else
				draw_line(0, y - 1, 320, y - 1, 0);
		}else{
			if(y == 240)
				draw_line(0, 239, 320, 239, 0);
			else
				draw_line(0, y + 1, 320, y + 1, 0);
		}
		
		draw_line(0, y, 320, y, 0x07E0); // draw a green line
		
		//Write a 1 in buffer
		*pixel_ctrl_ptr = 1;
		
		//wait for buffer to sync by waiting for status to turn 0
		int status = *(pixel_ctrl_ptr + 3);
		while((status & 0x01) != 0){
			status = *(pixel_ctrl_ptr + 3);
		}
		
		//increment y
		if(y >= 240)
			up = false;
		else if(y <= 0)
			up = true;
		if(up)
			y++;
		else
			y--;
	}
}

// code not shown for clear_screen() and draw_line() subroutines
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

void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;

        one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);

        *one_pixel_address = line_color;
}

