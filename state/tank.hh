#ifndef TANK_HPP
#define TANK_HPP

#include "states.hh"
#include <memory>
#include <string>
#include <utility>

class Tank {
 public:
  Tank(std::string id)
      : id_(std::move(id)),
        moveState_(std::make_unique<MoveState>(this)),
        attackState_(std::make_unique<AttackState>(this)),
        state_(moveState_.get()) {}

  void EnterTankMode() {
    state_ = moveState_.get();
    std::cout << "[Switch to tank mode]\n";
  }

  void EnterSiegeMode() {
    state_ = attackState_.get();
    std::cout << "[Switch to siege mode]\n";
  }

  void Attack() { state_->Attack(); }
  void Move(int x, int y) { state_->Move(x, y); }
  std::string Id() { return id_; }

 private:
  void SetState(State *p_siege_tank_mode) { state_ = p_siege_tank_mode; }

 
  std::string id_;
  std::unique_ptr<MoveState> moveState_;
  std::unique_ptr<AttackState> attackState_;
  State *state_;
};

#endif
