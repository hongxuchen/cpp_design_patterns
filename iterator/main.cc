#include <iostream>
#include <vector>

#include "iterator.hpp"
#include "aggregator.hpp"

int main() {
  Aggregator<int> aggr;
  aggr.push_back(1);
  aggr.push_back(2);
  aggr.push_back(3);
  auto it = MyIterator<decltype(aggr)>(aggr);

  for (it.first(); !it.isDone(); ++it) {
    std::cout << *it << '\n';
  }
  return 0;
}
