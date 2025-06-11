int main(void)
{
 volatile int *LEDR_ptr = 0xFF200000;
 volatile int *KEYs = 0xff200050;
 *LEDR_ptr = 0;
 *(KEYs + 3) = 0xF;
 int edge_cap;
 while (1) { // infinite loop
  edge_cap = *(KEYs + 3);
	while(*KEYs)
		;
  if(edge_cap == 0b1){
	  *LEDR_ptr = 0b1111111111;
	  *(KEYs + 3) = 0b1;
  }if(edge_cap == 0b11){
	  *LEDR_ptr = 0b1111111111;
	  *(KEYs + 3) = 0b11;
  }if(edge_cap == 0b10){
	  *LEDR_ptr = 0;
	  *(KEYs + 3) = 0b10;
  }
 }
}