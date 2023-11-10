#include <iostream>

#include "iterator.hh"
#include "aggregator.hh"

int main() {
  Aggregator<int> aggr;
  aggr.PushBack(1);
  aggr.PushBack(2);
  aggr.PushBack(3);
  auto it = MyIterator<decltype(aggr)>(aggr);

  for (it.First(); !it.IsDone(); ++it) {
    std::cout << *it << '\n';
  }
  return 0;
}
