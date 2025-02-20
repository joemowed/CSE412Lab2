///*
//* L2P3_C.c
//* Example relationship between C and Assembly
//* Created: 4:56:28 PM
//* Author: Joe Maloney / Eugene Rockey
//*/
////Compile and examine the .lss file beginning at <main>:,comment the lines the compiler left empty.
//signed char Global_A; //1-byte global symbol A
//signed char Global_B = 1;
//signed char Global_C = 2;
//int main(void)
//{
//Global_A = Global_C + Global_B;
//}
////Compile and examine the .lss file beginning at <main>:,comment the lines the compiler left empty.
//unsigned char Global_A;
//unsigned char Global_B = 1;
//unsigned char Global_C = 2;
//int main(void)
//{
//Global_A = Global_C + Global_B;
//}
//Compile and examine the .lss file beginning at <main>:,comment the lines the compiler left empty.
//signed int Global_A;
//signed int Global_B = 1;
//signed int Global_C = 2;
//signed int main(void)
//{
//Global_A = Global_C + Global_B;
//}
//Compile and examine the .lss file beginning at <main>:, comment the lines the compiler left empty.
unsigned int Global_A;
unsigned int Global_B = 1;
unsigned int Global_C = 2;

int main(void)
{
	Global_A = Global_C+Global_B;
}
//unsigned char Global_A;
//unsigned char Global_B = 1;
//unsigned char Global_C = 2;
//void main(void)
//{
//Global_A = (Global_C^2) - Global_B;
//}
