package hydra.ext.owl.syntax;

public class DataPropertyAssertion {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/owl/syntax.DataPropertyAssertion");
  
  public final java.util.List<hydra.ext.owl.syntax.Annotation> annotations;
  
  public final hydra.ext.owl.syntax.DataPropertyExpression property;
  
  public final hydra.ext.owl.syntax.Individual source;
  
  public final hydra.ext.owl.syntax.Individual target;
  
  public DataPropertyAssertion (java.util.List<hydra.ext.owl.syntax.Annotation> annotations, hydra.ext.owl.syntax.DataPropertyExpression property, hydra.ext.owl.syntax.Individual source, hydra.ext.owl.syntax.Individual target) {
    this.annotations = annotations;
    this.property = property;
    this.source = source;
    this.target = target;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof DataPropertyAssertion)) {
      return false;
    }
    DataPropertyAssertion o = (DataPropertyAssertion) (other);
    return annotations.equals(o.annotations) && property.equals(o.property) && source.equals(o.source) && target.equals(o.target);
  }
  
  @Override
  public int hashCode() {
    return 2 * annotations.hashCode() + 3 * property.hashCode() + 5 * source.hashCode() + 7 * target.hashCode();
  }
  
  public DataPropertyAssertion withAnnotations(java.util.List<hydra.ext.owl.syntax.Annotation> annotations) {
    return new DataPropertyAssertion(annotations, property, source, target);
  }
  
  public DataPropertyAssertion withProperty(hydra.ext.owl.syntax.DataPropertyExpression property) {
    return new DataPropertyAssertion(annotations, property, source, target);
  }
  
  public DataPropertyAssertion withSource(hydra.ext.owl.syntax.Individual source) {
    return new DataPropertyAssertion(annotations, property, source, target);
  }
  
  public DataPropertyAssertion withTarget(hydra.ext.owl.syntax.Individual target) {
    return new DataPropertyAssertion(annotations, property, source, target);
  }
}