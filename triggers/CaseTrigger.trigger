trigger CaseTrigger on Case (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    new CaseTriggerHandler().run();
}