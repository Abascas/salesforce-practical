trigger contact on Contact(before insert, before update, after insert) {
  if (Trigger.isInsert) {
    //if insert
    System.debug('contact trigger isinsert');
    for (Contact c : Trigger.new) {
      //for each contact being updated
      if (Trigger.isBefore) {
        c.Number_of_Houses__c = 1; //update the number of houses on the contact to '1'
      }
      if (Trigger.isAfter) {
        //originally when creating the new house object, it wasn't being related to the contact. I added "primaryHouse.Contact__c = c.Id;"
        System.debug('contact trigger isafter');
        //Originally if a contact was made without address information, the related house object would have 'null' in text added to its object,
        //I did a null check on the address fields to stop this
        String mailingAddress =
          (c.MailingStreet != null ? c.MailingStreet : '') +
          ' ' +
          (c.MailingState != null ? c.MailingState : '') +
          ' ' +
          (c.MailingPostalCode != null ? c.MailingPostalCode : '') +
          ' ' +
          (c.MailingCountry != null ? c.MailingCountry : ''); //build address string
        House__c primaryHouse = new House__c(); //create new house
        primaryHouse.Contact__c = c.Id; //set contact field to current contact
        primaryHouse.Primary__c = true; //set new house to primary
        primaryHouse.Address__c = mailingAddress; //set house address as contact address
        insert primaryHouse; //insert the house
      }
    }
  }

  if (Trigger.isUpdate) {
    //if update
    //Removed the if check between house.size and c.Number_of_Houses__c because it was redundant
    System.debug('contact trigger isupdate');
    for (Contact c : Trigger.new) {
      //for each contact being updated
      list<House__c> houses = new List<House__c>(
        [
          SELECT Id, Primary__c, Address__c
          FROM House__c
          WHERE Contact__c = :c.Id
        ]
      ); //get all houses related to the contact
      c.Number_of_Houses__c = houses.size(); //update the number of houses on the contact to the current number of houses
      String mailingAddress =
        c.MailingStreet +
        ' ' +
        c.MailingState +
        ' ' +
        c.MailingPostalCode +
        ' ' +
        c.MailingCountry; //build address string
      for (House__c h : houses) {
        //loop through the houses
        if (h.Primary__c == true) {
          //if the house is marked as primary
          if (h.Address__c != mailingAddress) {
            //if the address on the primary house is not the same as the address on the contact
            h.Address__c = mailingAddress; //update the primary house address with the new contact address
          }
        }
      }
    }
  }
}
