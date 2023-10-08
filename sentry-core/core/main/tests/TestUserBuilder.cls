@Istest
public with sharing class TestUserBuilder {
  private User user;
  private Map<Schema.SObjectType, ObjectPermissions> objPerms = new Map<Schema.SObjectType, ObjectPermissions>();
  private List<FieldPermissions> fieldPerms = new List<FieldPermissions>();
  private List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();

  public enum OBJECT_PERM_TYPE {
    READ,
    CREATE //TODO, the rest
  }

  public TestUserBuilder() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
    Blob b = Crypto.GenerateAESKey(128);
    String h = EncodingUtil.ConvertTohex(b);
    String username = h + '@example.com';
    user = new User(
      Email = username,
      Username = username,
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      Alias = h.substring(0, 8),
      TimeZoneSidKey = 'America/New_York'
    );
  }

  // TODO ?
  //   public TestUserBuilder withPermissionSet(String permsetDevName){

  //   }

  public TestUserBuilder withObjectAccess(
    Schema.SObjectType sobjectType,
    OBJECT_PERM_TYPE permtype
  ) {
    if (!objPerms.containsKey(sobjectType)) {
      objPerms.put(
        sobjectType,
        new ObjectPermissions(SobjectType = sobjectType.getDescribe().getName())
      );
    }
    switch on permtype {
      when READ {
        objPerms.get(sobjectType).PermissionsRead = true;
      }
      when CREATE {
        objPerms.get(sobjectType).PermissionsCreate = true;
      }
    }

    return this;
  }

  public TestUserBuilder withFieldAccess(
    Schema.SObjectType sobjectType,
    Schema.SObjectField field,
    Boolean read,
    Boolean edit
  ) {
    fieldperms.add(
      new FieldPermissions(
        SobjectType = sobjectType.getDescribe().getName(),
        Field = sobjectType.getDescribe().getName() +
          '.' +
          field.getDescribe().getName(),
        PermissionsRead = read,
        PermissionsEdit = edit
      )
    );
    return this;
  }

  public User build() {
    insert user;
    // create permset for the objs and fields
    PermissionSet permSet = new PermissionSet(
      Name = 'CustomPermSet',
      Label = 'CustomPermSet'
    );
    insert permSet;

    for (ObjectPermissions objPerm : objPerms.values()) {
      objPerm.ParentId = permSet.Id;
    }
    insert objPerms.values();

    for (FieldPermissions fieldPerm : fieldPerms) {
      fieldPerm.ParentId = permSet.Id;
    }
    insert fieldPerms;

    psas.add(new PermissionSetAssignment(PermissionSetId = permSet.Id));

    for (PermissionSetAssignment psa : psas) {
      psa.AssigneeId = user.Id;
    }

    insert psas;

    return user;
  }
}
