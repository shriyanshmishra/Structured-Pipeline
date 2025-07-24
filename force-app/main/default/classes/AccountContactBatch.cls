public class AccountContactBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Sabhi Account ke saath unke Contacts la rahe hain
        return Database.getQueryLocator('SELECT Id, Name, (SELECT Id, LastName FROM Contacts) FROM Account');
    }

    public void execute(Database.BatchableContext bc, List<Account> accList) {
        List<Contact> storeContacts = new List<Contact>(); // extra contacts ko yahan store karenge
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contactsToInsert = new List<Contact>();
        List<Account> accountsToInsert = new List<Account>();

        // Pehle har Account ke contacts check karo
        for(Account acc : accList) {
            Integer contactCount = acc.Contacts != null ? acc.Contacts.size() : 0;

            // Agar contacts 2 se zyada hain
            if(contactCount > 2) {
                for(Integer i=2; i<contactCount; i++) {
                    Contact c = acc.Contacts[i];
                    c.AccountId = null; // Account se hata rahe hain
                    storeContacts.add(c);
                    contactsToUpdate.add(c);
                }
            }
        }

        // Ab har Account par kam contacts ko fill karo
        for(Account acc : accList) {
            Integer contactCount = acc.Contacts != null ? acc.Contacts.size() : 0;

            // Agar 2 contacts hain, kuch nahi karna
            if(contactCount == 2) {
                continue;
            }

            // Agar 1 contact hai
            if(contactCount == 1) {
                if(!storeContacts.isEmpty()) {
                    Contact c = storeContacts.remove(0);
                    c.AccountId = acc.Id;
                    contactsToUpdate.add(c);
                } else {
                    Contact newCont = new Contact();
                    newCont.LastName = 'CreatedByBatch';
                    newCont.AccountId = acc.Id;
                    contactsToInsert.add(newCont);
                }
            }

            // Agar 0 contact hai
            if(contactCount == 0) {
                Integer need = 2;
                for(Integer i=0; i<need; i++) {
                    if(!storeContacts.isEmpty()) {
                        Contact c = storeContacts.remove(0);
                        c.AccountId = acc.Id;
                        contactsToUpdate.add(c);
                    } else {
                        Contact newCont = new Contact();
                        newCont.LastName = 'CreatedByBatch';
                        newCont.AccountId = acc.Id;
                        contactsToInsert.add(newCont);
                    }
                }
            }
        }

        // Agar storeContacts mein abhi bhi contacts bache hain, toh naye Account banao
        while(!storeContacts.isEmpty()) {
            Account newAcc = new Account();
            newAcc.Name = 'CreatedByBatch';
            accountsToInsert.add(newAcc);

            // 2 contacts assign karne ki koshish karo
            for(Integer i=0; i<2; i++) {
                if(!storeContacts.isEmpty()) {
                    Contact c = storeContacts.remove(0);
                    // AccountId abhi assign nahi kar sakte, kyunki Account insert nahi hua
                    c.AccountId = null; // Baad mein set karenge
                    contactsToUpdate.add(c);
                } else {
                    break;
                }
            }
        }

        // Pehle naye Accounts insert karo (agar koi hain)
        if(!accountsToInsert.isEmpty()) {
            insert accountsToInsert;
            // Ab un Accounts par store wale contacts assign karo
            Integer idx = 0;
            for(Account a : accountsToInsert) {
                for(Integer i=0; i<2; i++) {
                    if(idx < contactsToUpdate.size()) {
                        Contact c = contactsToUpdate[idx];
                        c.AccountId = a.Id;
                        idx++;
                    }
                }
            }
        }

        // ===== REMOVE DUPLICATES FROM UPDATE AND INSERT LISTS =====
        // For update list
        Map<Id, Contact> uniqueUpdateMap = new Map<Id, Contact>();
        for(Contact c : contactsToUpdate) {
            if(c.Id != null) {
                uniqueUpdateMap.put(c.Id, c);
            }
        }
        List<Contact> uniqueContactsToUpdate = new List<Contact>();
        uniqueContactsToUpdate.addAll(uniqueUpdateMap.values());

        // For insert list (usually no duplicates, but just in case)
        Set<String> insertedContactKey = new Set<String>();
        List<Contact> uniqueContactsToInsert = new List<Contact>();
        for(Contact c : contactsToInsert) {
            String key = c.LastName + '-' + c.AccountId;
            if(!insertedContactKey.contains(key)) {
                uniqueContactsToInsert.add(c);
                insertedContactKey.add(key);
            }
        }

        // Update aur Insert DML
        if(!uniqueContactsToUpdate.isEmpty()) {
            update uniqueContactsToUpdate;
        }
        if(!uniqueContactsToInsert.isEmpty()) {
            insert uniqueContactsToInsert;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch Done');
    }
}