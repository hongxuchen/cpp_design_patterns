#include "timeprinter.hpp"
#include <iostream>
#include <ctime>
#include <stdlib.h>

void TimePrinter::printTime() {
  time_t now = time(nullptr);
  char date[128] = {
      0,
  };
  std::strftime(date, sizeof(date), "%H:%M:%S", localtime(&now));
  std::cout << "[TIME] " << date << '\n';
}
