#include "singleton.hh"

int main() {
  Single &single = Single::getInstance();
  single.dump();
  return 0;
}
