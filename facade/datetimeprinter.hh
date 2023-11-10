#ifndef DATETIMEPRINTER_H
#define DATETIMEPRINTER_H

#include "timeprinter.hh"
#include "dateprinter.hh"

class DateTimePrinter {
 public:
  DateTimePrinter();
  static void Print();

 private:
  TimePrinter tp_;
  DatePrinter dp_;
};

#endif
