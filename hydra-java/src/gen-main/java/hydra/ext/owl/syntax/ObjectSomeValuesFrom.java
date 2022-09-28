package hydra.ext.owl.syntax;

public class ObjectSomeValuesFrom {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/owl/syntax.ObjectSomeValuesFrom");
  
  public final hydra.ext.owl.syntax.ObjectPropertyExpression property;
  
  public final hydra.ext.owl.syntax.ClassExpression class_;
  
  public ObjectSomeValuesFrom (hydra.ext.owl.syntax.ObjectPropertyExpression property, hydra.ext.owl.syntax.ClassExpression class_) {
    this.property = property;
    this.class_ = class_;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof ObjectSomeValuesFrom)) {
      return false;
    }
    ObjectSomeValuesFrom o = (ObjectSomeValuesFrom) (other);
    return property.equals(o.property) && class_.equals(o.class_);
  }
  
  @Override
  public int hashCode() {
    return 2 * property.hashCode() + 3 * class_.hashCode();
  }
  
  public ObjectSomeValuesFrom withProperty(hydra.ext.owl.syntax.ObjectPropertyExpression property) {
    return new ObjectSomeValuesFrom(property, class_);
  }
  
  public ObjectSomeValuesFrom withClass(hydra.ext.owl.syntax.ClassExpression class_) {
    return new ObjectSomeValuesFrom(property, class_);
  }
}