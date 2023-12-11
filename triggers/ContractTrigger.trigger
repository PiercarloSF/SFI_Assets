trigger ContractTrigger on Contract(before insert, before update, after update) {
  new ContractTriggerHandler().run();
}