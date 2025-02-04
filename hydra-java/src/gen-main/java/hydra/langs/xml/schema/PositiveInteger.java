package hydra.langs.xml.schema;

public class PositiveInteger {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/xml/schema.PositiveInteger");
  
  public final java.math.BigInteger value;
  
  public PositiveInteger (java.math.BigInteger value) {
    this.value = value;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof PositiveInteger)) {
      return false;
    }
    PositiveInteger o = (PositiveInteger) (other);
    return value.equals(o.value);
  }
  
  @Override
  public int hashCode() {
    return 2 * value.hashCode();
  }
}