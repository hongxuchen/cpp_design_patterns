#include "states.hh"
#include "tank.hh"
#include <iostream>

void AttackState::move(int x, int y) {
  std::cout << pTank->id() << " can't move to (" << x << ", " << y << ")\n";
}

void AttackState::attack() { std::cout << pTank->id() << " attacks for 40\n"; }

AttackState::~AttackState() = default;
