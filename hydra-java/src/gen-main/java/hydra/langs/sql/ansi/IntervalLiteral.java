package hydra.langs.sql.ansi;

public class IntervalLiteral {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/sql/ansi.IntervalLiteral");
  
  public IntervalLiteral () {
  
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof IntervalLiteral)) {
      return false;
    }
    IntervalLiteral o = (IntervalLiteral) (other);
    return true;
  }
  
  @Override
  public int hashCode() {
    return 0;
  }
}