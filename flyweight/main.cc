#include <cassert>

#include "factory.hh"

int main() {
  FlyWeightFactory fw;
  fw.GetFlyWeight("Jackill")->Operate("1");
  fw.GetFlyWeight("Rukawa")->Operate("2");
  fw.GetFlyWeight("Jackill")->Operate("3");
  assert(fw.Size() == 2U);
}
