#ifndef CONST_PASSWD_PROXY_H
#define CONST_PASSWD_PROXY_H

#include "passwd_proxy.hh"

class ConstPasswdProxy final : public PasswordProxy {
 public:
  bool Verify(std::string const& passwd) override;
};

#endif
