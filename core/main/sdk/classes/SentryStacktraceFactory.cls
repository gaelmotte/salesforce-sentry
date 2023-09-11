public class SentryStacktraceFactory {
  private SentryStacktraceFactory() {
  }

  private static final List<SentryExceptionMechanismFormatter> DEFAULT_FORMATTERS = new List<SentryExceptionMechanismFormatter>{
    new SentryExceptionMechanismFormatter(),
    new SentryDMLExceptionMechanismFormatter()
  };

  private static List<SentryExceptionMechanismFormatter> sortedFormatters;

  public static List<SentryValueClass> fromException(Exception ex) {
    List<SentryValueClass> values = new List<SentryValueClass>{ extract(ex) };
    Exception cause = ex.getCause();
    while (cause != null) {
      values.add(extract(cause));
      cause = cause.getCause();
    }
    return values;
  }
  private static SentryValueClass extract(Exception ex) {
    SentryValueClass valueClass = new SentryValueClass();

    valueClass.type = ex.getTypeName();
    valueClass.value = ex.getMessage();
    valueClass.mechanism = getFormatter(ex).getMechanism(ex);

    return valueClass;
  }

  private static SentryExceptionMechanismFormatter getFormatter(Exception ex) {
    if (sortedFormatters == null) {
      sortedFormatters = new List<SentryExceptionMechanismFormatter>{};
      sortedFormatters.addAll(DEFAULT_FORMATTERS);
      //TODO grab custom ones from config
      sortedFormatters.sort();
    }
    for (SentryExceptionMechanismFormatter formatter : sortedFormatters) {
      System.debug(
        'trying ' +
          formatter.getExceptionType() +
          ' and ' +
          TypeInspector.getType(ex)
      );
      if (
        formatter.getExceptionType().isAssignableFrom(TypeInspector.getType(ex))
      ) {
        return formatter;
      }
    }
    return null;
  }
}
