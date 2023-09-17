public abstract class SentryContext {
  public String type { get; protected set; }

  public abstract ContextData getData();

  public interface ContextData {
  }
}
