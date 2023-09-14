public with sharing class SentryStacktraceDecorator {
  private SentryStacktraceDecorator() {
  }

  public static void decorate(List<SentryEvent> events) {
  }

  public static Set<String> getClassnames(List<SentryEvent> events) {
    Set<String> classnames = new Set<String>();

    for (SentryEvent event : events) {
    }

    return classnames;
  }

  public static List<ApexClass> getClasses(Set<String> classnames) {
    return new List<ApexClass>();
  }
}
