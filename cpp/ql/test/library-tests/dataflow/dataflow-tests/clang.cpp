// semmle-extractor-options: --edg --clang

int source();
void sink(int); void sink(const int *); void sink(int **);

struct twoIntFields {
  int m1, m2;
  int getFirst() { return m1; }
};

void following_pointers(
    int sourceArray1[],
    int cleanArray1[],
    twoIntFields sourceStruct1,
    twoIntFields *sourceStruct1_ptr,
    int (*sourceFunctionPointer)())
{
  sink(sourceArray1); // flow

  sink(sourceArray1[0]); // no flow
  sink(*sourceArray1); // no flow
  sink(&sourceArray1); // flow (should probably be taint only)

  sink(sourceStruct1.m1); // no flow
  sink(sourceStruct1_ptr->m1); // no flow
  sink(sourceStruct1_ptr->getFirst()); // no flow

  sourceStruct1_ptr->m1 = source();
  sink(sourceStruct1_ptr->m1); // flow
  sink(sourceStruct1_ptr->getFirst()); // flow [NOT DETECTED with IR]
  sink(sourceStruct1_ptr->m2); // no flow
  sink(sourceStruct1.m1); // no flow

  twoIntFields s = { source(), source() };


  sink(s.m2); // flow

  twoIntFields sArray[1] = { { source(), source() } };
  // TODO: fix this like above
  sink(sArray[0].m2); // flow (AST dataflow misses this due to limitations of the analysis)

  twoIntFields sSwapped = { .m2 = source(), .m1 = 0 };

  sink(sSwapped.m2); // flow

  sink(sourceFunctionPointer()); // no flow

  int stackArray[2] = { source(), source() };
  stackArray[0] = source();
  sink(stackArray); // no flow
}

