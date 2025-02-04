package hydra.langs.owl.syntax;

/**
 * See https://www.w3.org/TR/owl2-syntax/#Datatypes
 */
public abstract class Datatype {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/owl/syntax.Datatype");
  
  private Datatype () {
  
  }
  
  public abstract <R> R accept(Visitor<R> visitor) ;
  
  public interface Visitor<R> {
    R visit(XmlSchema instance) ;
    
    R visit(Other instance) ;
  }
  
  public interface PartialVisitor<R> extends Visitor<R> {
    default R otherwise(Datatype instance) {
      throw new IllegalStateException("Non-exhaustive patterns when matching: " + (instance));
    }
    
    default R visit(XmlSchema instance) {
      return otherwise((instance));
    }
    
    default R visit(Other instance) {
      return otherwise((instance));
    }
  }
  
  /**
   * Note: XML Schema datatypes are treated as a special case in this model (not in the OWL 2 specification itself) because they are particularly common
   */
  public static final class XmlSchema extends hydra.langs.owl.syntax.Datatype {
    /**
     * Note: XML Schema datatypes are treated as a special case in this model (not in the OWL 2 specification itself) because they are particularly common
     */
    public final hydra.langs.xml.schema.Datatype value;
    
    public XmlSchema (hydra.langs.xml.schema.Datatype value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof XmlSchema)) {
        return false;
      }
      XmlSchema o = (XmlSchema) (other);
      return value.equals(o.value);
    }
    
    @Override
    public int hashCode() {
      return 2 * value.hashCode();
    }
    
    @Override
    public <R> R accept(Visitor<R> visitor) {
      return visitor.visit(this);
    }
  }
  
  public static final class Other extends hydra.langs.owl.syntax.Datatype {
    public final hydra.langs.rdf.syntax.Iri value;
    
    public Other (hydra.langs.rdf.syntax.Iri value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Other)) {
        return false;
      }
      Other o = (Other) (other);
      return value.equals(o.value);
    }
    
    @Override
    public int hashCode() {
      return 2 * value.hashCode();
    }
    
    @Override
    public <R> R accept(Visitor<R> visitor) {
      return visitor.visit(this);
    }
  }
}