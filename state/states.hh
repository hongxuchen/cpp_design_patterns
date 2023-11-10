#ifndef STATES_HPP
#define STATES_HPP

#include <iostream>

class State {
 public:
  virtual void Move(int x, int y) = 0;
  virtual void Attack() = 0;
};

class Tank;

class AttackState : public State {
 public:
  AttackState(Tank *p_tank) : pTank_(p_tank) {}

  void Move(int x, int y) override;
  void Attack() override;

  virtual ~AttackState();

 private:
  Tank *pTank_;
};

class MoveState : public State {
 public:
  MoveState(Tank *p_tank) : pTank_(p_tank) {}

  void Move(int x, int y) override;
  void Attack() override;

  virtual ~MoveState();

 private:
  Tank *pTank_;
};

#endif
