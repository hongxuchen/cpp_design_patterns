#include "states.hh"
#include "tank.hh"
#include <iostream>

void MoveState::Move(int x, int y) {
  std::cout << pTank_->Id() << " moves to (" << x << ", " << y << ")\n";
}

void MoveState::Attack() { std::cout << pTank_->Id() << " attacks for 20\n"; }

MoveState::~MoveState() = default;
