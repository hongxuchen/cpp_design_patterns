#include "states.hh"
#include "tank.hh"
#include <iostream>

void AttackState::Move(int x, int y) {
  std::cout << pTank_->Id() << " can't move to (" << x << ", " << y << ")\n";
}

void AttackState::Attack() { std::cout << pTank_->Id() << " attacks for 40\n"; }

AttackState::~AttackState() = default;
