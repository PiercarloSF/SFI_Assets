trigger QuoteTrigger on Quote (before insert, before update, after insert, after update) {
  new QuoteTriggerHandler().run();
}