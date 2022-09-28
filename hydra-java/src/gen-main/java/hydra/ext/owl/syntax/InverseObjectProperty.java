package hydra.ext.owl.syntax;

public class InverseObjectProperty {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/owl/syntax.InverseObjectProperty");
  
  public final hydra.ext.owl.syntax.ObjectProperty value;
  
  public InverseObjectProperty (hydra.ext.owl.syntax.ObjectProperty value) {
    this.value = value;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof InverseObjectProperty)) {
      return false;
    }
    InverseObjectProperty o = (InverseObjectProperty) (other);
    return value.equals(o.value);
  }
  
  @Override
  public int hashCode() {
    return 2 * value.hashCode();
  }
}