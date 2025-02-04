package hydra.langs.tinkerpop.propertyGraph;

/**
 * A key/value property
 */
public class Property<P> {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/tinkerpop/propertyGraph.Property");
  
  public final hydra.langs.tinkerpop.propertyGraph.PropertyKey key;
  
  public final P value;
  
  public Property (hydra.langs.tinkerpop.propertyGraph.PropertyKey key, P value) {
    this.key = key;
    this.value = value;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof Property)) {
      return false;
    }
    Property o = (Property) (other);
    return key.equals(o.key) && value.equals(o.value);
  }
  
  @Override
  public int hashCode() {
    return 2 * key.hashCode() + 3 * value.hashCode();
  }
  
  public Property withKey(hydra.langs.tinkerpop.propertyGraph.PropertyKey key) {
    return new Property(key, value);
  }
  
  public Property withValue(P value) {
    return new Property(key, value);
  }
}