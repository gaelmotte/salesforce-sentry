public class TypeInspector {
  public class TypeInspectorException extends Exception {
  }

  private class Never {
  }

  static final Pattern TYPE_EXCEPTION_PATTERN = Pattern.compile(
    'Invalid conversion from runtime type (\\S*) to ' +
    TypeInspector.Never.class.getName()
  );

  public static System.Type getType(Object o) {
    String typeName;
    try {
      Never never = (Never) o; // will always throw
    } catch (System.TypeException e) {
      String message = e.getMessage();
      Matcher matcher = TYPE_EXCEPTION_PATTERN.matcher(message);
      if (!matcher.find()) {
        throw new TypeInspectorException(
          'Failed to identify typename from caught exception',
          e
        );
      }
      typeName = matcher.group(1);
    }

    return System.Type.forName(typeName);
  }
}
