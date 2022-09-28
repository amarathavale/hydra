package hydra.ext.avro.schema;

public class Union {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/avro/schema.Union");
  
  public final java.util.List<hydra.ext.avro.schema.Schema> value;
  
  public Union (java.util.List<hydra.ext.avro.schema.Schema> value) {
    this.value = value;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof Union)) {
      return false;
    }
    Union o = (Union) (other);
    return value.equals(o.value);
  }
  
  @Override
  public int hashCode() {
    return 2 * value.hashCode();
  }
}