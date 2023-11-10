#include "tank.hh"

int main() {
  Tank tank("JUNGLE");
  tank.EnterTankMode();
  tank.Attack();
  tank.Move(1, 1);

  tank.EnterSiegeMode();
  tank.Attack();
  tank.Move(2, 2);

  tank.EnterTankMode();
  tank.Attack();
  tank.Move(3, 3);

  return 0;
}
