public class EmailQueueable implements Queueable {
  private List<Id> contactIds;

  public EmailQueueable(List<Id> contactIds) {
    this.contactIds = contactIds;
  }

  public void execute(QueueableContext ctx) {
    List<Contact> contacts = [
      SELECT Id, Email, FirstName
      FROM Contact
      WHERE Id IN :contactIds AND Email != NULL
    ];
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    for (Contact c : contacts) {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setToAddresses(new List<String>{ c.Email });
      mail.setSubject('Welcome, ' + c.FirstName);
      mail.setPlainTextBody('Thank you for registering.');
      emails.add(mail);
    }
    if (!emails.isEmpty()) {
      Messaging.sendEmail(emails);
    }
  }
}
