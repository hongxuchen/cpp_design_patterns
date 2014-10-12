class EventHandler {
 public:
  virtual ~EventHandler() {}
};
class MouseEventHandler : public EventHandler  // Note inheritance
                          {
 protected:
  ~MouseEventHandler() {}  // A protected virtual destructor.
 public:
  MouseEventHandler() {}  // Public Constructor.
};
int main(void) {
  /// MouseEventHandler m;
  EventHandler *e = new MouseEventHandler();  // Dynamic allocation is allowed
  delete e;  // Polymorphic delete. Does not leak memory.
}
