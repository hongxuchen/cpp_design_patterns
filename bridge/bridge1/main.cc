#include "abs_msg_sender.hh"
#include "bye_msg_impl.hh"
#include "char_msg_sender.hh"
#include "hello_msg_impl.hh"

int main() {
  CharMessageSender char_msg_sender;
  AbsMsgSender *sender = &char_msg_sender;

  auto hello = std::make_shared<HelloMessageImpl>();
  sender->SetMessage(hello);
  sender->SendMessage();

  auto bye = std::make_shared<ByeMessageImpl>();
  sender->SetMessage(bye);
  sender->SendMessage();

  return 0;
}
