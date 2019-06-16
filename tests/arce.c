#include <stdio.h>

int add1(int a) { return a+1; }
typedef int (*fadd)(int v);
fadd fg = &add1;
fadd *pfg = &fg;
fadd *pfg2;
fadd fg3[4];
fadd* fg4[4];
void* pvoid0;
void* pvoid1[2];

int main(int argc, char **argv) {
  fadd f1 = &add1;
  int c= 10;
  int d = sizeof(fadd);
  int e = c + d;
  int result = (*f1)(e);
  //printf("result: %d\n", result);
  //printf("pfg:%x\n", (int)pfg);

  return 0;
}
