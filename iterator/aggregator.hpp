#ifndef AGGREGATOR_HPP
#define AGGREGATOR_HPP

#include <vector>

template <typename Item>
class Aggregator {
 public:
  using value_type = Item;
  void push_back(Item const& item) { data.push_back(item); }
  Item& operator[](std::size_t index) { return data[index]; }
  std::size_t size() { return data.size(); }

 private:
  std::vector<value_type> data;
};

#endif
