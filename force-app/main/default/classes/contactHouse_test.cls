@isTest
public without sharing class contactHouse_test {
  // Tests that when creating a new contact it creates a related house object with the address information, and updates the 'number of houses' field to 1
  @isTest
  static void contactInsert() {
    System.debug('test contactInsert');

    Contact c = new Contact(
      LastName = 'test',
      MailingStreet = '123 Street',
      MailingCity = 'City',
      MailingState = 'State',
      MailingPostalCode = 'ZIP',
      MailingCountry = 'Country'
    ); //new contact with address

    insert c; //insert contact

    list<House__c> houses = new List<House__c>(
      [
        SELECT Id, Contact__c, Primary__c, Address__c
        FROM House__c
        WHERE Contact__c = :c.Id
      ]
    ); //get all houses related to contact
    System.debug(houses);
    c = [
      SELECT
        id,
        Number_of_Houses__c,
        MailingStreet,
        MailingCity,
        MailingState,
        MailingPostalCode,
        MailingCountry
      FROM Contact
      WHERE Id = :c.id
      LIMIT 1
    ]; //get the contact we just inserted
    System.debug(c);

    System.assertEquals(1, houses.Size()); //check that there is 1 house related to the contact
    System.assertEquals(1, c.Number_of_Houses__c); //check that the contact shows that it has 1 house
  }
  // Tests that when a house is inserted its related contact accurately updated that there are multiple related houses.
  @isTest
  static void houseInsert() {
    System.debug('test houseInsert');

    Contact c = new Contact(
      LastName = 'test',
      MailingStreet = '123 Street',
      MailingCity = 'City',
      MailingState = 'State',
      MailingPostalCode = 'ZIP',
      MailingCountry = 'Country'
    ); //new contact with address
    insert c; //insert contact
    list<House__c> houses = new List<House__c>(
      [SELECT Id, Primary__c, Address__c FROM House__c WHERE Contact__c = :c.Id]
    ); //create list of houses
    House__c house2 = new House__c(Name = '2', Contact__c = c.Id); //new house

    insert house2; //insert our second house

    houses = new List<House__c>(
      [
        SELECT Id, Contact__c, Primary__c, Address__c
        FROM House__c
        WHERE Contact__c = :c.Id
      ]
    ); //refresh the list of houses
    System.debug(houses);
    c = [
      SELECT
        id,
        Number_of_Houses__c,
        MailingStreet,
        MailingCity,
        MailingState,
        MailingPostalCode,
        MailingCountry
      FROM Contact
      WHERE Id = :c.id
      LIMIT 1
    ]; //refresh the contact
    System.debug(c);

    System.assertEquals(2, houses.Size()); //check that there are 2 houses related to the contact
    System.assertEquals(2, c.Number_of_Houses__c); //check that the contact shows that it has 2 houses
  }
  // Tests that when houses are deleted, their related contact is updated to know how many related houses it now has.
  @isTest
  static void houseDelete() {
    System.debug('test houseDelete');

    Contact c = new Contact(
      LastName = 'test',
      MailingStreet = '123 Street',
      MailingCity = 'City',
      MailingState = 'State',
      MailingPostalCode = 'ZIP',
      MailingCountry = 'Country'
    ); //new contact with address
    insert c; //insert contact
    list<House__c> houses = new List<House__c>(
      [SELECT Id, Primary__c, Address__c FROM House__c WHERE Contact__c = :c.Id]
    ); //create list of houses

    delete houses; //delete all of the houses

    houses = new List<House__c>(
      [
        SELECT Id, Contact__c, Primary__c, Address__c
        FROM House__c
        WHERE Contact__c = :c.Id
      ]
    ); //refresh the list houses
    System.debug(houses);
    c = [
      SELECT
        id,
        Number_of_Houses__c,
        MailingStreet,
        MailingCity,
        MailingState,
        MailingPostalCode,
        MailingCountry
      FROM Contact
      WHERE Id = :c.id
      LIMIT 1
    ]; //refresh the contact
    System.debug(c);

    System.assertEquals(0, houses.Size()); //check that there are 0 houses related to the contact
    System.assertEquals(0, c.Number_of_Houses__c); //check that the contact shows that it has 0 houses

    //I added this section to also test that deleting multiple houses at once updates correctly

    House__c house1 = new House__c(Name = '1', Contact__c = c.Id); //new house created
    insert house1; //insert the additional house
    House__c house2 = new House__c(Name = '2', Contact__c = c.Id); //new house created
    insert house2; //insert the additional house
    houses = new List<House__c>(
      [
        SELECT Id, Contact__c, Primary__c, Address__c
        FROM House__c
        WHERE Contact__c = :c.Id
      ]
    ); //refresh house list to include the new houses

    delete houses; //delete all of the houses

    houses = new List<House__c>(
      [
        SELECT Id, Contact__c, Primary__c, Address__c
        FROM House__c
        WHERE Contact__c = :c.Id
      ]
    ); //refresh the list houses
    System.debug(houses);
    c = [
      SELECT
        id,
        Number_of_Houses__c,
        MailingStreet,
        MailingCity,
        MailingState,
        MailingPostalCode,
        MailingCountry
      FROM Contact
      WHERE Id = :c.id
      LIMIT 1
    ]; //refresh the contact
    System.debug(c);

    System.assertEquals(0, houses.Size()); //check that there are 0 houses related to the contact
    System.assertEquals(0, c.Number_of_Houses__c); //check that the contact shows that it has 0 houses
  }
}
