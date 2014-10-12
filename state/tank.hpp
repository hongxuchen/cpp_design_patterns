#ifndef TANK_HPP
#define TANK_HPP

#include "states.hpp"
#include <memory>
#include <string>

class Tank {
 public:
  Tank(std::string const &id)
      : id_(id),
        moveState(std::make_unique<MoveState>(this)),
        attackState(std::make_unique<AttackState>(this)),
        state(moveState.get()) {}

  void enterTankMode() {
    state = moveState.get();
    std::cout << "[Switch to tank mode]\n";
  }

  void enterSiegeMode() {
    state = attackState.get();
    std::cout << "[Switch to siege mode]\n";
  }

  void attack() { state->attack(); }
  void move(int x, int y) { state->move(x, y); }
  std::string id() { return id_; }

 private:
  void setState(State *pSiegeTankMode) { state = pSiegeTankMode; }

 private:
  std::string id_;
  std::unique_ptr<MoveState> moveState;
  std::unique_ptr<AttackState> attackState;
  State *state;
};

#endif
