package hydra.ext.owl.syntax;

public class DataPropertyDomain {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/owl/syntax.DataPropertyDomain");
  
  public final java.util.List<hydra.ext.owl.syntax.Annotation> annotations;
  
  public final hydra.ext.owl.syntax.DataPropertyExpression property;
  
  public final hydra.ext.owl.syntax.ClassExpression domain;
  
  public DataPropertyDomain (java.util.List<hydra.ext.owl.syntax.Annotation> annotations, hydra.ext.owl.syntax.DataPropertyExpression property, hydra.ext.owl.syntax.ClassExpression domain) {
    this.annotations = annotations;
    this.property = property;
    this.domain = domain;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof DataPropertyDomain)) {
      return false;
    }
    DataPropertyDomain o = (DataPropertyDomain) (other);
    return annotations.equals(o.annotations) && property.equals(o.property) && domain.equals(o.domain);
  }
  
  @Override
  public int hashCode() {
    return 2 * annotations.hashCode() + 3 * property.hashCode() + 5 * domain.hashCode();
  }
  
  public DataPropertyDomain withAnnotations(java.util.List<hydra.ext.owl.syntax.Annotation> annotations) {
    return new DataPropertyDomain(annotations, property, domain);
  }
  
  public DataPropertyDomain withProperty(hydra.ext.owl.syntax.DataPropertyExpression property) {
    return new DataPropertyDomain(annotations, property, domain);
  }
  
  public DataPropertyDomain withDomain(hydra.ext.owl.syntax.ClassExpression domain) {
    return new DataPropertyDomain(annotations, property, domain);
  }
}