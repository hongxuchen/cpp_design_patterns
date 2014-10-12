#ifndef DATETIMEPRINTER_H
#define DATETIMEPRINTER_H

#include "timeprinter.hpp"
#include "dateprinter.hpp"

class DateTimePrinter {
 public:
  DateTimePrinter();
  void print();

 private:
  TimePrinter tp_;
  DatePrinter dp_;
};

#endif
