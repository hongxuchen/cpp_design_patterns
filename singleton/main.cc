#include "singleton.hh"

int main() {
  Single &single = Single::GetInstance();
  single.Dump();
  return 0;
}
