package hydra.langs.sql.ansi;

public class TimestampLiteral {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/sql/ansi.TimestampLiteral");
  
  public TimestampLiteral () {
  
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof TimestampLiteral)) {
      return false;
    }
    TimestampLiteral o = (TimestampLiteral) (other);
    return true;
  }
  
  @Override
  public int hashCode() {
    return 0;
  }
}