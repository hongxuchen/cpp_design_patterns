/**
 *
 * @author Hongxu Chen <leftcopy.chx@gmail.com>
 * @brief usually used together with factory pattern
 *
 */

#include <cassert>
#include "factory.hh"

int main() {
  FlyWeightFactory fw;
  fw.getFlyWeight("Jackill")->operate("1");
  fw.getFlyWeight("Rukawa")->operate("2");
  fw.getFlyWeight("Jackill")->operate("3");
  assert(fw.size() == 2U);
}
