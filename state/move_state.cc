#include "states.hh"
#include "tank.hh"

void MoveState::move(int x, int y) {
  std::cout << pTank->id() << " moves to (" << x << ", " << y << ")\n";
}

void MoveState::attack() { std::cout << pTank->id() << " attacks for 20\n"; }

MoveState::~MoveState() = default;
