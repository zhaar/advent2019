
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

int groupSize(int * input, int number) {
  int consecutives = 0;
  int isCounting = 0;
  for (int i = 0; i < 6; ++i) {
    if (isCounting && input[i] == number) {
      consecutives += 1;
    } else if (!isCounting && input[i] == number) {
      isCounting = 1;
      consecutives = 1;
    } else if (isCounting && input[i] != number) {
      isCounting = 0;
    } else { // not counting and not equal

    }
  }
  return consecutives < 2 ? 6 : consecutives;
}

int smallestGroupSize(int * input) {
  int small = 6;
  for (int i = 0; i <= 9; ++i) {
    if (groupSize(input, i) < small) {
      small = groupSize(input, i);
    }
  }
  return small;
}

int noLargetDoubleGroup(int * input) {

  return smallestGroupSize(input) == 2;
}

int satisfies(int input) {
  int digits[6];
  decompose(digits, input);
  if (alwaysIncreasing(digits) && hasDoubleAdjacent(digits) && noLargetDoubleGroup(digits)) {
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
  decompose(arr, 111145);
  int result = countPasswords(278384, 824795);
  printf("count %d", result);
}
