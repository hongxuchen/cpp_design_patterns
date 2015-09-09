#include "singleton.hh"

int main(void) {
  Single &single = Single::getInstance();
  single.dump();
  return 0;
}
