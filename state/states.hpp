#ifndef STATES_HPP
#define STATES_HPP

#include <iostream>

class State {
 public:
  virtual void move(int x, int y) = 0;
  virtual void attack() = 0;
};

class Tank;

class AttackState : public State {
 public:
  AttackState(Tank *pTank) : pTank(pTank) {}

  virtual void move(int x, int y) override;
  virtual void attack(void) override;

  virtual ~AttackState();

 private:
  Tank *pTank;
};

class MoveState : public State {
 public:
  MoveState(Tank *pTank) : pTank(pTank) {}

  virtual void move(int x, int y) override;
  virtual void attack(void) override;

  virtual ~MoveState();

 private:
  Tank *pTank;
};

#endif
