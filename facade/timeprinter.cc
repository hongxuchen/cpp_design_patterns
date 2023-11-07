#include "timeprinter.hh"

#include <cstdlib>
#include <ctime>
#include <iostream>

void TimePrinter::printTime() {
  time_t const now = time(nullptr);
  char date[128] = {
      0,
  };
  std::strftime(date, sizeof(date), "%H:%M:%S", localtime(&now));
  std::cout << "[TIME] " << date << '\n';
}
