# Instructions/Environment Setup

1. fork this repo to your own private github repo and clone it to your local machine
2. install the salesforce SFDX CLI development tools (i recommend using VS Code because salesforce maintains the "Salesforce Extension Pack" which makes working with the SFDX tools a lot easier, but you are welcome to use a different IDE/terminal if you prefer)
3. create a scratch org and push the source from this project into it (you will need salesforce credentials for this, as you will need to set up a dev org to authenticate with)
4. complete the listed tasks in the scratch org
   - for code tasks, the salesforce "developer console", which is accessible from the gear icon menu in the top right of the screen, can be used as an IDE to edit code and also to run test classes and view debug logs. these tasks can also be done using the VS Code "salesforce extension pack", either way you should reach the same result, it's more a matter of preference. (I tend to switch back and forth depending on what I'm working on, no hard rules here, whatever makes the most sense.)
5. ensure your changes have been pulled back from the scratch org into your local environment
6. commit and push your updated project to the private repo you created and add my github user (matindow) as a collaborator so that I can review your work

- I anticipate this will take 2-4 hours to complete
- if you get stuck or have questions, reach out to me (Mat) directly

# Tasks

## Lead/Contact Formatting

1. capitalize first and last name: john doe => John Doe
   // I set this up with individual workflows for each field. Currently capitalizes the first letter and undercases all other letters of names when lead/contact objects are created/edited. Possible questions for desired output of compound/hyphenated names.
2. remove any unnecessary phone formatting: (123) 456-7890 => 1234567890
   // Also used workflows. Tried to use regex, but found you couldn't inside of the workflows. Ended up using a string of 'substitutes' to remove common phone number formating characters. Also thought about restricting their original entry with valifation rules if they had formatting.
3. create a task assigned to the record owner to investigate if a lead/contact record is missing state or country info
   //Used workflows, sends one joint alert if either field is blank. Could set it up to only send alert if other address information is present if useful based on expected use and order of getting information from customers. Only resends if the condition is changed (so if information gets deleted after the fact it will resend an alert, but if it’s blank it won’t continuously resend alerts each time something else is updated)

## Object Relationships

- we have a custom object for keeping track of how many houses a contact has

1.  add a new custom object to keep track of how many windows each house has
    - need fields to track window dimensions for width(in), height(in), and also calculated sqft
2.  we need a custom object to keep track of how many/what type of Indow inserts each window has
    - need picklist for standard/acoustic product type
    - also direct relationship to contact
      // I ran into a critical failure when first doing this. I reached out to Mat for help with this, and neither of us could solve it so I had to restart. I'm not certain of what caused it but I think I know what it was related to. When I originally made these objects, I named the insert object strangely, and so tried to change it after creating it's fields and relationships. It said I couldn't do that because it was already referenced as it was or something, and so I decided to just delete the object, but it wouldn't let me delete it. It still wouldn't let me delete it even after I deleted all fields and relationships to it. at some point some meta data outside of my control was created that I could neither interact with or delete, but also i could no longer pull the scratch back to my own machine because it tried to access this data.
3.  add these objects to the Indow app and make them visible on the related layouts
    //I had to change permisions on the original house object in order to see it and interact with it properly

## Reporting

1. What percentage of inserts sold overall are Acoustic type?
   - report showing all Indow inserts grouped by product type (standard/acoustic) with calculated product type percentage breakdown
2. Do our customers tend to have more Standard or Acoustic type inserts?
   - report showing all Indow inserts grouped by contact with calculated percentage breakdown of product type per contact
     //the automatically created report type "inserts with contacts" that I expected to work with this wasn't populating the records correctly when using fields from the contact object. I created a custom report type and it worked from there.
3. In which states are Acoustic inserts more popular than Standard inserts? - report showing all Indow inserts grouped by contact's State (US only) ordered by highest percentage of acoustic product type
   //The current version of the report builder doesn't allow you to sort by formula fields, so I was not able to order it by percentage of acoustic product type. In some states of using the classic builder I was able to view it sorted like that, but not save it for later viewing.
   note: when saving reports, salesforce defaults to the "Private Reports" folder, but the "sfdx force:source:pull" command will only capture your reports from the scratch org if they are placed in a public folder (eg "Public Reports"), so make sure to move them out of your private folder when trying to pull them back to save on your local machine.

## Apex Triggers

### we have a contact trigger called "contact"

- when a contact is inserted, the trigger creates a corresponding new house object using the contact's address information
- whenever a contact is updated, the trigger checks to see if the address on the contact has changed. it looks at all of the houses related to the contact to find the primary house record, and updates the address on the house if it has changed on the contact
- whenever a contact is updated, the trigger counts the number of houses that are related to the contact, and stores that number in the "Number of Houses" field

### we also have a trigger on the House custom object called "house"

- whenever a house object is inserted or updated, it updates the related contact record (if there is one) in order to trigger the "Number of Houses" logic

### Errors

1. _EXCEPTION_THROWN [17]|System.AssertException: Assertion Failed: Expected: 1, Actual: 0_
   - the test method in contactHouse_test is failing on line 17, saying that there are no houses related to a contact after it is created. you can also see this by just creating a contact in salesforce. a house record is created, but it doesn't look like it is related to the contact. figure out why and correct the trigger so that the test passes.
     //when the saved contact was creating house object, it wasn't getting the contact id to give it a relationship. I added this to the creation of the house object so they now connect as expected.
2. _EXCEPTION_THROWN [30]|System.AssertException: Assertion Failed: Expected: 2, Actual: 1_
   - uncomment section 2 from the contactHouse_test class (lines 22 through 31)
   - the test is failing on line 31, saying that after a second house is inserted for a contact, the house trigger is not updating the related contact's "Number of Houses" field. figure out why and correct the house trigger so that the test passes.
     //the house trigger knew which contact to update, but it didn't actually have the command to update it. I added it
3. _EXCEPTION_THROWN [34]|System.DmlException: Delete failed. First exception on row 0 with id a003B000005AIkfQAG; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, house: execution of AfterDelete EXCEPTION_THROWN caused by: System.NullPointerException: Attempt to de-reference a null object_
   - uncomment section 3 from the contactHouse_test class (lines 34 through 42)
   - the test is failing on line 34, saying that there is a dml null pointer exception when trying to update the related contact when the house is deleted. figure out why and correct the house trigger so that the test passes.  
      //This was because the house delete trigger was trying to access "trigger.new", which didn't exist because it had just deleted it. I split the "isinsert" and "isdelete" functions and replaced with "trigger.old" for delete.

(commit and publish your project so far to your private repo to ensure we can later reference your solution up to this point, because we are now going to make additional changes to the test file.)

### Improvement

1. our three test sections in contactHouse_test are really testing three different things, and it would be nice to know if one of them was failing independently from the other two. restructure the test class to replace our single test method with three discrete test functions, one for each of the three sections: contactInsert(), houseInsert(), houseDelete()
   //Needed to make sure that all needed variables are created in each isolated test. Ran into some confusion because of the way that multiple tests are logged (seems they are ordered based on alphabetical name of the test function, not order written in the class or length of the test...which is odd)
2. find a few other ways to improve either our process, our logic, or our code
   //Originally if a contact was created with missing address information, the House object it created would populate with the text "null" in the fields. I did a null check to return blank instead. I thought about preventing it from making a house object if no address information was present, but decided not to because I wasn't sure on use case, and I expect that you want every contact to have a house object related to them even if it had no details in it.
   //I removed a redundant if check for the number of houses related to the contact.
   //I added another section to the deletehouse test trigger so that it first tests deleting a single house, and then checks if it can delete multiple houses at a time.

## Resources

- [Salesforce Trailblazer Community](https://trailblazers.salesforce.com)
- [Salesforce Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dev_guide.htm)
- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
  - note: there is a lot of documentation about 1st and 2nd generation "package management" within the SFDX docs, which we would likely make use of if we were planning to implement our work back into a live salesforce environment, but don't worry about any of that here, we don't need to create a package for this, the unpackaged project source files as they appear in the repo are fine.
