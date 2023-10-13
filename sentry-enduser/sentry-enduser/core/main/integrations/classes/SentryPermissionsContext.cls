public with sharing class SentryPermissionsContext extends SentryContext {
  public static final String TYPE = 'permissions';
  private User user;
  public SentryPermissionsContext(User user) {
    this.user = user;
    this.type = TYPE;
  }

  public override Map<String, Object> getData() {
    Map<String, object> data = new Map<String, object>{
      'Profile.Name' => user.Profile.Name,
      'UserRole.Name' => user.UserRole.Name,
      'UserType' => user.UserType
    };
    for (Integer i = 0; i < user.PermissionSetAssignments.size(); i++) {
      data.put(
        'PermissionSet' + i,
        user.PermissionSetAssignments.get(i).PermissionSet.NamespacePrefix +
          '_' +
          user.PermissionSetAssignments.get(i).PermissionSet.Name
      );
    }
    return data;
  }
}
