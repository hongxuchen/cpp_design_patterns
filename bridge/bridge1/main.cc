#include "char_msg_sender.hpp"
#include "hello_msg_impl.hpp"
#include "bye_msg_impl.hpp"

int main(void) {
  CharMessageSender charMsgSender;
  AbsMsgSender *sender = &charMsgSender;

  HelloMessageImpl hello;
  ByeMessageImpl bye;

  sender->setMessage(&hello);
  sender->sendMessage();
  sender->setMessage(&bye);
  sender->sendMessage();

  return 0;
}
