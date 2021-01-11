trigger house on House__c(after insert, after update, after delete) {
  if (Trigger.isinsert || Trigger.isupdate) {
    //originally "update c" was missing, so this wasn't triggering the contact update trigger
    System.debug('beginning of house trigger isinsert/isupdate');
    for (House__c h : Trigger.new) {
      // for each house being updated/inserted/deleted
      if (h.Contact__c != null) {
        // if the Contact relationship is not null
        Contact c = new Contact(Id = h.Contact__c); // create a new contact object to trigger
        update c; //update the related record
      }
    }
  }
  if (Trigger.isdelete) {
    //Had to seperate the delete trigger because delete can't use trigger.new
    System.debug('beginning of house trigger isdelete');
    for (House__c h : Trigger.old) {
      // for each house being updated/inserted/deleted
      if (h.Contact__c != null) {
        // if the Contact relationship is not null
        Contact c = new Contact(Id = h.Contact__c); //find associated contact object to trigger
        update c; //update the related record
      }
    }
  }
}
