
#include <stdio.h>
void printArray(int * arr) {
  for (int i = 0; i < 6; i++)
    printf("%d", arr[i]);
}

void decompose(int * result, int input) {
  result[0] = input / 100000;
  int i1 = result[0] * 100000;
  result[1] = (input - i1) / 10000;
  int i2 = result[1] * 10000;
  result[2] = (input - i1 - i2) / 1000;
  int i3 = result[2] * 1000;
  result[3] = (input - i1 - i2 - i3) / 100;
  int i4 = result[3] * 100;
  result[4] = (input - i1 - i2 - i3 - i4)/ 10;
  int i5 = result[4] * 10;
  result[5] = (input - i1 - i2 - i3 - i4 - i5);

}

int alwaysIncreasing(int * input) {
  int last = input [0];
  for (int i = 1; i < 6; ++i) {
    if (last > input[i]) {
      //printf("last: %d", last);
      //printf("next: %d", input[i]);
      //printf("does not satisfy always increasing");
      return 0;
    }
    last = input[i];
  }
  return 1;
}

int hasDoubleAdjacent(int * input) {
  int last = input[0];
  for (int i = 1; i < 6; ++i) {
    if (last == input[i]) {
      return 1;
    }
    last = input[i];
  }
  //printf("does not satisfy double adjacent");
  return 0;
}

int satisfies(int input) {
  int digits[6];
  decompose(digits, input);
  if (alwaysIncreasing(digits) && hasDoubleAdjacent(digits)) {
    return 1;
  } else {
    //printArray(digits);
    //printf("does not satisfy");
    return 0;
  }
}

int countPasswords(int lower, int upper) {
  int count = 0;
  for (int i = lower; i <= upper; ++i) {
    if (satisfies(i)) {
      count += 1;
    }
  }
  return count;
}

int main() {

  int arr[6];
  decompose(arr, 278384);
  int result = countPasswords(278384, 824795);
  printf("count %d", result);
}
