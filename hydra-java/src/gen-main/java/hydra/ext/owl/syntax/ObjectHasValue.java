package hydra.ext.owl.syntax;

public class ObjectHasValue {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/owl/syntax.ObjectHasValue");
  
  public final hydra.ext.owl.syntax.ObjectPropertyExpression property;
  
  public final hydra.ext.owl.syntax.Individual individual;
  
  public ObjectHasValue (hydra.ext.owl.syntax.ObjectPropertyExpression property, hydra.ext.owl.syntax.Individual individual) {
    this.property = property;
    this.individual = individual;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof ObjectHasValue)) {
      return false;
    }
    ObjectHasValue o = (ObjectHasValue) (other);
    return property.equals(o.property) && individual.equals(o.individual);
  }
  
  @Override
  public int hashCode() {
    return 2 * property.hashCode() + 3 * individual.hashCode();
  }
  
  public ObjectHasValue withProperty(hydra.ext.owl.syntax.ObjectPropertyExpression property) {
    return new ObjectHasValue(property, individual);
  }
  
  public ObjectHasValue withIndividual(hydra.ext.owl.syntax.Individual individual) {
    return new ObjectHasValue(property, individual);
  }
}