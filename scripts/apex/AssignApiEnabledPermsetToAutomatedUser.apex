String permissionSetName = 'Sentry_Automated_User_API_Access';
insert new PermissionSetAssignment(
  AssigneeId = [
    SELECT Id
    FROM User
    WHERE alias = 'autoproc'
  ]
  .Id,
  PermissionSetId = [
    SELECT id, Name, NamespacePrefix
    FROM PermissionSet
    WHERE name = :permissionSetName
  ]
  .Id
);
