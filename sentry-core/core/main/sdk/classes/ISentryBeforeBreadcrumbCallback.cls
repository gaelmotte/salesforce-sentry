public interface ISentryBeforeBreadcrumbCallback {
  SentryBreadcrumb process(SentryBreadcrumb breadcrumb);
}
