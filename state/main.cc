#include "tank.hh"

int main() {
  Tank tank("JUNGLE");
  tank.enterTankMode();
  tank.attack();
  tank.move(1, 1);

  tank.enterSiegeMode();
  tank.attack();
  tank.move(2, 2);

  tank.enterTankMode();
  tank.attack();
  tank.move(3, 3);

  return 0;
}
