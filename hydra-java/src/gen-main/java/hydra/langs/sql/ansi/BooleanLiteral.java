package hydra.langs.sql.ansi;

public abstract class BooleanLiteral {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/sql/ansi.BooleanLiteral");
  
  private BooleanLiteral () {
  
  }
  
  public abstract <R> R accept(Visitor<R> visitor) ;
  
  public interface Visitor<R> {
    R visit(TRUE instance) ;
    
    R visit(FALSE instance) ;
    
    R visit(UNKNOWN instance) ;
  }
  
  public interface PartialVisitor<R> extends Visitor<R> {
    default R otherwise(BooleanLiteral instance) {
      throw new IllegalStateException("Non-exhaustive patterns when matching: " + (instance));
    }
    
    default R visit(TRUE instance) {
      return otherwise((instance));
    }
    
    default R visit(FALSE instance) {
      return otherwise((instance));
    }
    
    default R visit(UNKNOWN instance) {
      return otherwise((instance));
    }
  }
  
  public static final class TRUE extends hydra.langs.sql.ansi.BooleanLiteral {
    public TRUE () {
    
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof TRUE)) {
        return false;
      }
      TRUE o = (TRUE) (other);
      return true;
    }
    
    @Override
    public int hashCode() {
      return 0;
    }
    
    @Override
    public <R> R accept(Visitor<R> visitor) {
      return visitor.visit(this);
    }
  }
  
  public static final class FALSE extends hydra.langs.sql.ansi.BooleanLiteral {
    public FALSE () {
    
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof FALSE)) {
        return false;
      }
      FALSE o = (FALSE) (other);
      return true;
    }
    
    @Override
    public int hashCode() {
      return 0;
    }
    
    @Override
    public <R> R accept(Visitor<R> visitor) {
      return visitor.visit(this);
    }
  }
  
  public static final class UNKNOWN extends hydra.langs.sql.ansi.BooleanLiteral {
    public UNKNOWN () {
    
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof UNKNOWN)) {
        return false;
      }
      UNKNOWN o = (UNKNOWN) (other);
      return true;
    }
    
    @Override
    public int hashCode() {
      return 0;
    }
    
    @Override
    public <R> R accept(Visitor<R> visitor) {
      return visitor.visit(this);
    }
  }
}