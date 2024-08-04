public abstract class SentrySyntheticException extends Exception {
    private string guid;

    public void setGuid(String value) {
      this.guid = value;
    }

    public String getGuid() {
      return this.guid;
    }
}